-- Highlight todo, notes, etc in comments
return {
  {
    'folke/todo-comments.nvim',
    event = 'VimEnter',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('todo-comments').setup {
        signs = false,
      }

      -- vim.keymap.set('n', ']t', function()
      --   require('todo-comments').jump_next()
      -- end, { desc = 'Next todo comment' })
      --
      -- vim.keymap.set('n', '[t', function()
      --   require('todo-comments').jump_prev()
      -- end, { desc = 'Previous todo comment' })
    end,
  },
}
