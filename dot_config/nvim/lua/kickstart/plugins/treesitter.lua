return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    branch = 'main', -- `master` is frozen and does not support Neovim 0.12+
    lazy = false,
    build = ':TSUpdate',
    -- [[ Configure Treesitter ]] See `:help nvim-treesitter`
    config = function()
      local ts = require 'nvim-treesitter'

      -- Parsers to always have installed (no-op when already present).
      -- Others are auto-installed on first use of the filetype, unless offline.
      ts.install {
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
        'markdown_inline',
        'query',
        'sql',
        'toml',
        'vim',
        'vimdoc',
        'yaml',
      }

      local max_filesize = 50 * 1024 -- 50 KB
      local function too_large(buf)
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        return ok and stats and stats.size > max_filesize
      end

      ---@param buf integer
      ---@param lang string
      local function attach(buf, lang)
        if not vim.api.nvim_buf_is_valid(buf) or too_large(buf) then
          return
        end
        if not vim.treesitter.language.add(lang) then
          return
        end
        vim.treesitter.start(buf, lang)
        -- Indentation and folds intentionally left on Vim's built-ins.
      end

      local available = ts.get_available()
      vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('kickstart-treesitter', { clear = true }),
        callback = function(args)
          local buf, filetype = args.buf, args.match
          local lang = vim.treesitter.language.get_lang(filetype)
          if not lang then
            return
          end
          if vim.tbl_contains(ts.get_installed 'parsers', lang) then
            attach(buf, lang)
          elseif not vim.g.offline and vim.tbl_contains(available, lang) then
            ts.install(lang):await(function()
              attach(buf, lang)
            end)
          else
            attach(buf, lang) -- parser may exist outside nvim-treesitter (e.g. bundled with Neovim)
          end
        end,
      })
    end,
    -- There are additional nvim-treesitter modules that you can use to interact
    -- with nvim-treesitter. You should go explore a few and see what interests you:
    --
    --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
    --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
    --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
  },
}
