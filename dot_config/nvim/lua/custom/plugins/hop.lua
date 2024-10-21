return {
  {
    'smoka7/hop.nvim',
    version = '*',
    lazy = false,
    config = function()
      local hop = require 'hop'
      hop.setup {
        multi_windows = true,
      }
      vim.keymap.set('', '<leader>f', function()
        hop.hint_char2()
      end, { desc = 'Hop [f]ind characters' })

      -- local directions = require('hop.hint').HintDirection
      -- vim.keymap.set('', '<leader>F', function()
      --   hop.hint_char1 { direction = directions.BEFORE_CURSOR }
      -- end, {})
    end,
  },
}
