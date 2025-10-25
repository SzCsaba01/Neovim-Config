return {
  "rcarriga/nvim-notify",
  priority = 1000,
  config = function()
    vim.notify = require("notify")

    require("notify").setup({
      timeout = 3000,
    })

    vim.keymap.set("n", "<leader>no", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "Open Notification History" })
  end,
}
