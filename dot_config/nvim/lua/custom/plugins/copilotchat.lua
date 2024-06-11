return {
  {
    'CopilotC-Nvim/CopilotChat.nvim',
    branch = 'canary',
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
-- vim: ts=2 sts=2 sw=2 et
