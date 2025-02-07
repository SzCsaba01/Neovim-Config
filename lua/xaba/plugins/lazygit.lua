return {
  "kdheepak/lazygit.nvim",
  lazygit = true,
  cmd = {
    "LazyGit",
    "LazyGitConfig",
    "LazyGitCurrentFile",
    "LazyGitFilter",
    "LazyGitFilterCurrentFile",
  },

  dependencies = {
    "nvim-lua/plenary.nvim",
  },

  keys = {
    { "<leader>lg", "<cmd>lua require('toggleterm.terminal').Terminal:new({cmd = 'lazygit', hidden = true, direction = 'float'}):toggle()<cr>", 
    desc = "Open LazyGit in floating terminal" },
  },
}
