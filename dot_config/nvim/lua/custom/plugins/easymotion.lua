return {
  {
    'easymotion/vim-easymotion',
    lazy = false,
    config = function()
      -- Open parent directory in floating window
      -- vim.keymap.set('n', '<leader>F', require 'vim-easymotion', { desc = 'Open parent directory (float)' })
      -- " <Leader>f{char} to move to {char}
      -- map  <Leader>f <Plug>(easymotion-bd-f)
      -- nmap <Leader>f <Plug>(easymotion-overwin-f)
      --
      -- " s{char}{char} to move to {char}{char}
      -- nmap s <Plug>(easymotion-overwin-f2)
    end,
  },
}
