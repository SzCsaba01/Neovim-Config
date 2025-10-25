return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons", "folke/todo-comments.nvim" },
  opts = {
    focus = true,
  },
  cmd = "Trouble",
  keys = {
    { "<leader>xw", "<cmd>Trouble diagnostics toggle<CR>", desc = "Open trouble workspace diagnostics" },
    {
      "<leader>xd",
      "<cmd>Trouble diagnostics toggle filter.buf=0<CR>",
      desc = "Open trouble document diagnostics",
    },
    { "<leader>xt", "<cmd>Trouble todo toggle<CR>", desc = "Open todos in trouble" },
    {
      "<leader>xx",
      function()
        vim.diagnostic.open_float()
      end,
      desc = "Show diagnostic message in float",
      noremap = true,
      silent = true,
      mode = "n",
    },
  },
}
