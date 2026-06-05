return {
  "mfussenegger/nvim-dap",
  lazy = true,
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
  },
  config = function()
    local dap = require("dap")
    local dapui = require("dapui")
    local icons = require("config.icons")

    dapui.setup()

    -- signs
    for name, icon in pairs(icons.dap) do
      vim.fn.sign_define("Dap" .. name, {
        text = icon[1],
        texthl = icon[2],
        linehl = icon[3] or "",
        numhl = icon[4] or "",
      })
    end

    ----------------------------------------------------------------------
    -- UI auto open/close
    ----------------------------------------------------------------------
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end

    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end

    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end

    ----------------------------------------------------------------------
    -- Keymaps
    ----------------------------------------------------------------------
    vim.keymap.set("n", "<F1>", dap.continue)
    vim.keymap.set("n", "<F2>", dap.step_over)
    vim.keymap.set("n", "<F3>", dap.step_into)
    vim.keymap.set("n", "<F4>", dap.step_out)
    vim.keymap.set("n", "<F5>", dap.run_to_cursor)

    vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint)

    vim.keymap.set("n", "<leader>dd", function()
      dap.terminate()
      dapui.close()
    end)

    vim.keymap.set("n", "<space>?", function()
      dapui.eval(nil, { enter = true })
    end)
  end,
}
