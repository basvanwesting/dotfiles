return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    main = 'nvim-treesitter.configs', -- Sets main module to use for opts
    init = function()
      -- Compat shim: nvim-treesitter `master` (frozen) registers predicates/directives with
      -- `{ all = false }`, expecting `match[id]` to be a single TSNode. Neovim 0.12 removed that
      -- option and always passes a list of nodes, which breaks e.g. markdown code-fence injections
      -- ("attempt to call method 'range' (a nil value)"). Wrap the registration so those handlers
      -- get the legacy single-node shape (last node per capture, as 0.10/0.11 did).
      if vim.fn.has 'nvim-0.12' == 1 then
        local query = vim.treesitter.query
        local function legacy(handler)
          return function(match, ...)
            local single = {}
            for id, nodes in pairs(match) do
              single[id] = type(nodes) == 'table' and nodes[#nodes] or nodes
            end
            return handler(single, ...)
          end
        end
        for _, fname in ipairs { 'add_predicate', 'add_directive' } do
          local orig = query[fname]
          query[fname] = function(name, handler, opts)
            if type(opts) == 'table' and opts.all == false then
              return orig(name, legacy(handler), { force = opts.force })
            end
            return orig(name, handler, opts)
          end
        end
      end
    end,
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    opts = {
      -- ensure_installed = { 'bash', 'c', 'diff', 'html', 'lua', 'luadoc', 'markdown', 'vim', 'vimdoc' },
      ensure_installed = {
        'bash',
        'c',
        'csv',
        'diff',
        'dockerfile',
        'html',
        'json',
        'kdl',
        'lua',
        'luadoc',
        'markdown',
        'sql',
        'toml',
        'vim',
        'vimdoc',
        'yaml',
      },
      -- Autoinstall languages that are not installed
      auto_install = not vim.g.offline,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        -- additional_vim_regex_highlighting = { 'ruby' },
        additional_vim_regex_highlighting = false,

        disable = function(_lang, buf)
          local max_filesize = 50 * 1024 -- 50 KB
          local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
        end,
      },
      -- indent = { enable = true, disable = { 'ruby' } },
    },
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
}
