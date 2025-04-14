local helpers = {}

function helpers.get_current_buffer_relative_dir()
  -- return vim.fn.expand '%:h', ':~:.'
  return vim.fn.fnamemodify(require('oil').get_current_dir() or vim.fn.expand '%:h', ':~:.')
end

function helpers.close_other_buffers()
  local current_buf = vim.fn.bufnr '%'
  for bufnum = 1, vim.fn.bufnr '$' do
    if bufnum ~= current_buf and vim.fn.bufexists(bufnum) == 1 then
      local buftype = vim.fn.getbufvar(bufnum, '&buftype')
      if buftype ~= 'help' and buftype ~= 'quickfix' and buftype ~= 'acwrite' then
        vim.cmd('silent! bwipeout! ' .. bufnum)
      end
    end
  end
end

vim.api.nvim_create_user_command('CloseOthers', helpers.close_other_buffers, {})

return helpers
