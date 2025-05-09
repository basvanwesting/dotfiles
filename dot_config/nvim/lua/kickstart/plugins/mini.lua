return {
  { -- Collection of various small independent plugins/modules
    'echasnovski/mini.nvim',
    config = function()
      -- Better Around/Inside textobjects
      --
      -- Examples:
      --  - va)  - [V]isually select [A]round [)]paren
      --  - yinq - [Y]ank [I]nside [N]ext [']quote
      --  - ci'  - [C]hange [I]nside [']quote
      require('mini.ai').setup { n_lines = 500 }

      -- Add/delete/replace surroundings (brackets, quotes, etc.)
      --
      -- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
      -- - sd'   - [S]urround [D]elete [']quotes
      -- - sr)'  - [S]urround [R]eplace [)] [']
      require('mini.surround').setup()

      -- - ga - start interactive
      -- - gA - start interactive (preview)
      require('mini.align').setup()

      -- - ii - object_scope
      -- - ai - object_scope_with_border
      -- - [i - goto_top
      -- - ]i - goto_bottom
      require('mini.indentscope').setup { draw = {} }
      vim.g.miniindentscope_disable = true

      -- require('mini.pairs').setup()

      require('mini.bracketed').setup()

      local jump2d = require 'mini.jump2d'
      local jump_line_start = jump2d.builtin_opts.word_start
      jump2d.setup {
        spotter = jump_line_start.spotter,

        -- Options for visual effects
        view = {
          -- Whether to dim lines with at least one jump spot
          dim = false,

          -- How many steps ahead to show. Set to big number to show all steps.
          n_steps_ahead = 1,
        },

        -- Which lines are used for computing spots
        allowed_lines = {
          blank = false, -- Blank line (not sent to spotter even if `true`)
          cursor_before = true, -- Lines before cursor line
          cursor_at = true, -- Cursor line
          cursor_after = true, -- Lines after cursor line
          fold = true, -- Start of fold (not sent to spotter even if `true`)
        },

        -- Which windows from current tabpage are used for visible lines
        allowed_windows = {
          current = true,
          not_current = false,
        },
      }

      -- Simple and easy statusline.
      --  You could remove this setup call if you don't like it,
      --  and try some other statusline plugin
      local statusline = require 'mini.statusline'
      -- set use_icons to true if you have a Nerd Font
      statusline.setup { use_icons = vim.g.have_nerd_font }

      -- You can configure sections in the statusline by overriding their
      -- default behavior. For example, here we set the section for
      -- cursor location to LINE:COLUMN
      ---@diagnostic disable-next-line: duplicate-set-field
      statusline.section_location = function()
        return '%2l:%-2v'
      end

      -- ... and there is more!
      --  Check out: https://github.com/echasnovski/mini.nvim
    end,
  },
}
