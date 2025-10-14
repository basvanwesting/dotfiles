return {
  {
    'nvim-neotest/neotest',
    -- status = { virtual_text = true },
    -- output = { open_on_run = true },
    keys = {
      {
        '<leader>tt',
        function()
          require('neotest').run.run(vim.fn.expand '%')
        end,
        desc = 'Run File',
      },
      {
        '<leader>tw',
        function()
          require('neotest').watch.toggle(vim.fn.expand '%')
        end,
        desc = 'Watch File',
      },
      {
        '<leader>tT',
        function()
          require('neotest').run.run(vim.uv.cwd())
        end,
        desc = 'Run All Test Files',
      },
      {
        '<leader>tr',
        function()
          require('neotest').run.run()
        end,
        desc = 'Run Nearest',
      },
      {
        '<leader>tl',
        function()
          require('neotest').run.run_last()
        end,
        desc = 'Run Last',
      },
      {
        '<leader>ts',
        function()
          require('neotest').summary.toggle()
        end,
        desc = 'Toggle Summary',
      },
      {
        '<leader>to',
        function()
          require('neotest').output.open { enter = true, auto_close = true }
        end,
        desc = 'Show Output',
      },
      {
        '<leader>tO',
        function()
          require('neotest').output_panel.toggle()
        end,
        desc = 'Toggle Output Panel',
      },
      {
        '<leader>tS',
        function()
          require('neotest').run.stop()
        end,
        desc = 'Stop',
      },
    },
    dependencies = {
      'nvim-neotest/nvim-nio',
      'nvim-lua/plenary.nvim',
      'antoinemadec/FixCursorHold.nvim',
      'nvim-treesitter/nvim-treesitter',
      'olimorris/neotest-rspec',
    },
    config = function()
      ---@diagnostic disable-next-line: missing-fields
      require('neotest').setup {
        -- See all config options with :h neotest.Config
        -- discovery = {
        --   -- Drastically improve performance in ginormous projects by
        --   -- only AST-parsing the currently opened buffer.
        --   enabled = true,
        --   -- Number of workers to parse files concurrently.
        --   -- A value of 0 automatically assigns number based on CPU.
        --   -- Set to 1 if experiencing lag.
        --   concurrent = 1,
        -- },
        -- running = {
        --   -- Run tests concurrently when an adapter provides multiple commands to run.
        --   concurrent = true,
        -- },
        -- summary = {
        --   -- Enable/disable animation of icons.
        --   animated = false,
        -- },
        adapters = {
          require 'neotest-rspec' {
            rspec_cmd = function()
              -- test for local bin/spring as spring is shimmed globally
              if vim.fn.executable 'bin/spring' == 1 then
                return { vim.fs.normalize '~/.asdf/shims/bundle', 'exec', 'spring', 'rspec' }
              else
                return { vim.fs.normalize '~/.asdf/shims/bundle', 'exec', 'rspec' }
              end
            end,
          },
          require 'rustaceanvim.neotest',
        },
      }
    end,
  },
}
