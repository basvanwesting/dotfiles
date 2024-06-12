return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
    cond = vim.g.personal,
    -- cmd = 'CopilotChat',
    dependencies = {
      { 'zbirenbaum/copilot.lua' },
      { 'nvim-lua/plenary.nvim' },
    },
    keys = {
      {
        '<leader>aa',
        function()
          return require('CopilotChat').toggle()
        end,
        desc = 'Toggle (CopilotChat)',
      },
      {
        '<leader>ax',
        function()
          return require('CopilotChat').clear()
        end,
        desc = 'Clear (CopilotChat)',
      },
      {
        '<leader>aq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').line })
          end
        end,
        desc = 'Quick Chat on line (CopilotChat)',
        mode = { 'n' },
      },
      {
        '<leader>aq',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').visual })
          end
        end,
        desc = 'Quick Chat on visual (CopilotChat)',
        mode = { 'v' },
      },
      {
        '<leader>ab',
        function()
          local input = vim.fn.input 'Quick Chat: '
          if input ~= '' then
            require('CopilotChat').ask(input, { selection = require('CopilotChat.select').buffer })
          end
        end,
        desc = 'Quick Chat on buffer (CopilotChat)',
      },
      {
        -- Show help actions with telescope
        '<leader>ad',
        function()
          local actions = require 'CopilotChat.actions'
          local help = actions.help_actions()
          if not help then
            vim.print 'No diagnostics found on the current line'
            return
          end
          require('CopilotChat.integrations.telescope').pick(help)
        end,
        desc = 'Diagnostic Help (CopilotChat)',
        mode = { 'n', 'v' },
      },
      {
        -- Show prompts actions with telescope
        '<leader>ap',
        function()
          local actions = require 'CopilotChat.actions'
          require('CopilotChat.integrations.telescope').pick(actions.prompt_actions())
        end,
        desc = 'Prompt Actions (CopilotChat)',
        mode = { 'n', 'v' },
      },
    },
    config = function(_, opts)
      vim.api.nvim_create_autocmd('BufEnter', {
        pattern = 'copilot-chat',
        callback = function()
          vim.opt_local.relativenumber = false
          vim.opt_local.number = false
        end,
      })
      require('CopilotChat').setup(opts)
    end,
  },
}
