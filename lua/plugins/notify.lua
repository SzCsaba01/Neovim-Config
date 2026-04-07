return {
  "rcarriga/nvim-notify",
  priority = 1000,
  config = function()
    vim.notify = require("notify")

    require("notify").setup({
      background_colour = "#1d2021", -- REQUIRED when bg = none
      fps = 60,
      render = "minimal",
      stages = "fade",
      timeout = 3000,
    })

    vim.keymap.set("n", "<leader>no", function()
      require("telescope").extensions.notify.notify()
    end, { desc = "Open Notification History" })
  end,
}
