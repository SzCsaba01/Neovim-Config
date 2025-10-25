return {
  "stevearc/dressing.nvim",
  event = "VeryLazy",
  config = function()
    require("dressing").setup({
      select = {
        backend = { "telescope", "builtin" },
        telescope = {},
      },
    })
  end,
}
