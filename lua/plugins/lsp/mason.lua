return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    "jay-babu/mason-nvim-dap.nvim",
  },
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")
    local mason_dap = require("mason-nvim-dap")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      automatic_enable = {
        exclude = {
          "jdtls",
        },
      },
      automatic_installation = true,
      ensure_installed = {
        "angularls",
        "omnisharp",
        "ts_ls",
        "html",
        "cssls",
        "lua_ls",
        "docker_compose_language_service",
        "dockerls",
        "jsonls",
        "yamlls",
      },
    })

    mason_dap.setup({
      automatic_installation = true,
      ensure_installed = {
        "netcoredbg", -- .NET Debugger
      },
    })

    mason_tool_installer.setup({
      automatic_installation = true,
      ensure_installed = {
        "prettier", -- prettier formatter
        "prettierd", -- prettier formatter
        "stylua", -- lua formatter
        "eslint_d", -- eslint formatter
        "stylelint", -- stylelint formatter
      },
    })
  end,
}
