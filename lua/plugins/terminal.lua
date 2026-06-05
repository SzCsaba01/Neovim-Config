return {
  {
    "akinsho/toggleterm.nvim",
    version = "*",
    config = function()
      require("toggleterm").setup({
        size = 20,
        open_mapping = [[<C-t>]],
        hide_numbers = true,
        direction = "float",
        float_opts = {
          border = "curved",
        },

        auto_scroll = true,
      })
    end,
  },
}
