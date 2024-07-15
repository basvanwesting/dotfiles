return {
  {
    'tpope/vim-abolish',
    lazy = false,
    config = function()
      require('which-key').add {
        { 'cr', group = 'coercion' },
        { 'cr-', desc = 'Kebab Case (not reversible)' },
        { 'cr.', desc = 'Dot Case (not reversible)' },
        { 'cr<space>', desc = 'Space Case (not reversible)' },
        { 'crU', desc = 'Snake Upper Case' },
        { 'cr_', desc = 'Snake Case' },
        { 'crc', desc = 'Camel Case' },
        { 'crk', desc = 'Kebab Case' },
        { 'crm', desc = 'Mixed Case' },
        { 'crs', desc = 'Snake Case' },
        { 'crt', desc = 'Title Case (not reversible)' },
        { 'cru', desc = 'Snake Upper Case' },
      }
    end,
  },
}
