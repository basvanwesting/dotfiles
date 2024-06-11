return {
  {
    'zbirenbaum/copilot.lua',
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
}
-- vim: ts=2 sts=2 sw=2 et
