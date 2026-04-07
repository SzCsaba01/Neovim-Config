return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    -- FORCE dark mode
    vim.o.background = "dark"

    require("gruvbox").setup({
      contrast = "hard",
      transparent_mode = true,

      italic = {
        comments = true,
      },

      overrides = {
        -- Core
        Normal = { bg = "none" },
        NormalFloat = { bg = "none" },
        CursorLine = { bg = "#1d2021" },
        LineNr = { fg = "#665c54" },
        Comment = { fg = "#928374", italic = true },

        -- Floating UI
        FloatBorder = { fg = "#504945" },

        -- SQL
        ["@keyword.sql"] = { fg = "#fb4934", bold = true },
        ["@type.sql"] = { fg = "#83a598" },
        ["@function.sql"] = { fg = "#8ec07c" },
        ["@string.sql"] = { fg = "#b8bb26" },
        ["@number.sql"] = { fg = "#fe8019" },

        sqlKeyword = { fg = "#fb4934", bold = true },
        sqlType = { fg = "#83a598" },
        sqlFunction = { fg = "#8ec07c" },
        sqlString = { fg = "#b8bb26" },
        sqlNumber = { fg = "#fe8019" },
      },
    })

    vim.cmd("colorscheme gruvbox")
  end,
}
