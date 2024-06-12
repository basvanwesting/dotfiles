return {
  {
    'zbirenbaum/copilot.lua',
    cond = vim.g.personal,
    cmd = 'Copilot',
    build = ':Copilot auth',
    event = 'InsertEnter',
    config = function()
      require('copilot').setup {
        -- for copilot_cmp
        suggestion = { enabled = false },
        panel = { enabled = false },
        -- general
        filetypes = {
          markdown = true,
          help = true,
        },
      }
    end,
  },
  {
    'zbirenbaum/copilot-cmp',
    cond = vim.g.personal,
    dependencies = 'copilot.lua',
    config = function()
      require('copilot_cmp').setup()
    end,
  },
}
