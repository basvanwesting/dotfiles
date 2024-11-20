local helpers = {}

function helpers.get_current_buffer_absolute_dir()
  return require('oil').get_current_dir() or vim.fn.expand '%:p'
end

function helpers.get_current_buffer_relative_dir()
  return vim.fn.fnamemodify(helpers.get_current_buffer_absolute_dir())
end

return helpers
