return {
  "ellisonleao/gruvbox.nvim",
  priority = 1000,
  config = function()
    vim.o.background = "dark"

    require("gruvbox").setup({
      contrast = "hard", -- "soft" | "medium" | "hard"
      transparent_mode = true,

      overrides = {

        -- SQL (treesitter + legacy)
        -- ["@keyword.sql"] = { fg = "#fb4934", bold = true },
        -- ["@type.sql"] = { fg = "#83a598" },
        -- ["@function.sql"] = { fg = "#8ec07c" },
        -- ["@string.sql"] = { fg = "#b8bb26" },
        -- ["@number.sql"] = { fg = "#fe8019" },
        --
        -- sqlKeyword = { fg = "#fb4934", bold = true },
        -- sqlType = { fg = "#83a598" },
        -- sqlFunction = { fg = "#8ec07c" },
        -- sqlString = { fg = "#b8bb26" },
        -- sqlNumber = { fg = "#fe8019" },
      },
    })

    vim.cmd("colorscheme gruvbox")
  end,
}
