-- Follow the Omarchy theme, live. theme.lua is a symlink to the active theme's
-- neovim.lua: a lazy spec with the colorscheme plugin (its colours as opts for
-- generated themes) plus a LazyVim entry that only names the colorscheme.
-- lazy watches imported spec files (this directory is imported, see
-- lazy-plugins.lua), so a theme switch fires LazyReload with the specs
-- re-parsed; the colorscheme plugin is then reloaded so its setup() runs with
-- the new colours.
--
-- Ported from omarchy-nvim 2026.9.21-5
-- (/usr/share/omarchy-nvim/config/lua/plugins/omarchy-theme-hotreload.lua).
-- Differences: the spec module name, the colorscheme is also applied here at
-- startup (LazyVim did that upstream), LazyVim itself is disabled rather than
-- installed, and no transparency file.

local Config = require 'lazy.core.config'
local Loader = require 'lazy.core.loader'

local function theme_spec()
  package.loaded['custom.omarchy.theme'] = nil
  local ok, spec = pcall(require, 'custom.omarchy.theme')
  return ok and spec or nil
end

-- The colorscheme plugin (as lazy names it) and the colorscheme, from the spec.
local function read_theme(spec)
  local plugin_name, colorscheme
  for _, entry in ipairs(spec) do
    if entry[1] == 'LazyVim/LazyVim' then
      colorscheme = entry.opts and entry.opts.colorscheme
    elseif entry[1] and not plugin_name then
      plugin_name = entry.name or entry[1]:match '[^/]+$'
    end
  end
  return plugin_name, colorscheme
end

local function finish(colorscheme)
  pcall(vim.cmd.colorscheme, colorscheme)
  vim.cmd.hi 'Comment gui=none'
end

local function apply_at_startup()
  local spec = theme_spec()
  local _, colorscheme = read_theme(spec or {})
  if not colorscheme then
    return
  end
  Loader.colorscheme(colorscheme)
  finish(colorscheme)
end

local function reload()
  local spec = theme_spec()
  local plugin_name, colorscheme = read_theme(spec or {})
  if not colorscheme then
    return
  end

  -- Clear all highlight groups before applying new theme
  vim.cmd 'highlight clear'
  if vim.fn.exists 'syntax_on' == 1 then
    vim.cmd 'syntax reset'
  end
  -- Reset background to default so colorscheme can set it properly (light themes will set to light)
  vim.o.background = 'dark'

  -- Unload theme plugin modules to force full reload
  local plugin = plugin_name and Config.plugins[plugin_name]
  if plugin then
    require('lazy.core.util').walkmods(plugin.dir .. '/lua', function(modname)
      package.loaded[modname] = nil
      package.preload[modname] = nil
    end)
  end

  -- Load the colorscheme plugin. If it's already loaded (old and new theme
  -- sharing the same plugin, e.g. generic themes on aether.nvim), lazy won't
  -- rerun setup() on a spec reload and keeps the old resolved opts in the
  -- plugin's property cache, so fully reload it to reapply setup() with the
  -- new theme's opts.
  if plugin and plugin._.loaded then
    Loader.reload(plugin)
  else
    Loader.colorscheme(colorscheme)
  end

  vim.defer_fn(function()
    finish(colorscheme)
    vim.cmd 'redraw!'
  end, 5)
end

return {
  -- Named by every theme spec; nothing here needs it.
  { 'LazyVim/LazyVim', enabled = false },
  {
    name = 'omarchy-theme',
    dir = vim.fn.stdpath 'config',
    lazy = false,
    priority = 1000,
    config = function()
      vim.api.nvim_create_autocmd('User', {
        pattern = 'LazyReload',
        callback = function()
          vim.schedule(reload)
        end,
      })
      apply_at_startup()
    end,
  },
}
