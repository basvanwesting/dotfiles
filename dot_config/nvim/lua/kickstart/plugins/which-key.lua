-- NOTE: Plugins can also be configured to run Lua code when they are loaded.
--
-- This is often very useful to both group configuration, as well as handle
-- lazy loading plugins that don't need to be loaded immediately at startup.
--
-- For example, in the following configuration, we use:
--  event = 'VimEnter'
--
-- which loads which-key before all the UI elements are loaded. Events can be
-- normal autocommands events (`:help autocmd-events`).
--
-- Then, because we use the `config` key, the configuration only runs
-- after the plugin has been loaded:
--  config = function() ... end

return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VeryLazy',
    opts = {
      spec = {
        { '<leader>T', group = '[T]oggle' },
        { '<leader>T_', hidden = true },
        { '<leader>l', group = '[l]SP' },
        { '<leader>l_', hidden = true },
        { '<leader>s', group = '[s]earch' },
        { '<leader>s_', hidden = true },
        { '<leader>t', group = '[t]est' },
        { '<leader>t_', hidden = true },
        {
          mode = { 'n', 'v' },
          { '<leader>a', group = '[a]I CopilotChat' },
          { '<leader>a_', hidden = true },
          { '<leader>h', group = 'Git [h]unk' },
          { '<leader>h_', hidden = true },
        },
      },
    },
    keys = {
      {
        '<leader>?',
        function()
          require('which-key').show { global = false }
        end,
        desc = 'Buffer Local Keymaps (which-key)',
      },
    },
  },
}
