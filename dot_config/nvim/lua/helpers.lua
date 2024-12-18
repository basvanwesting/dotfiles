local helpers = {}

function helpers.get_current_buffer_relative_dir()
  -- return vim.fn.fnamemodify(require('oil').get_current_dir() or vim.fn.expand '%:h', ':~:.')
  return vim.fn.expand '%:h', ':~:.'
end

return helpers
