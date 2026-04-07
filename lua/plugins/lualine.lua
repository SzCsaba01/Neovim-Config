return {
  -- lualine status line
  {
    "nvim-lualine/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      local lualine = require("lualine")

      lualine.setup({
        options = {
          theme = "gruvbox",
        },
        sections = {
          lualine_x = {
            {
              function()
                if vim.bo.filetype ~= "sql" then
                  return ""
                end
                local bdb = vim.b.db
                for name, url in pairs(vim.g.dbs or {}) do
                  if url == bdb then
                    return " " .. name
                  end
                end
                return " (no db)"
              end,
              color = { fg = "#ff9e64", gui = "bold" },
              padding = { left = 1, right = 1 },
            },
            "encoding",
            "fileformat",
            "filetype",
          },
        },
      })
    end,
  },
}
