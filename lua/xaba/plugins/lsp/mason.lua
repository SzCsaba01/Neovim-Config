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
      ensure_installed = {
        "omnisharp",
        "ts_ls",
        "html",
        "cssls",
        "lua_ls",
        -- "graphql",
        -- "emmet_ls",
        -- "pyright",
        "docker_compose_language_service",
        "dockerls",
        "jsonls",
        "eslint",
        "stylelint_lsp",
        -- "clangd",
        -- "jdtls",
        -- "gradle_ls",
      },
    })

    mason_dap.setup({
      ensure_installed = {
          "node-debug2-adapter", -- Node.js/JS Debugger
          --"netcoredbg",          -- .NET Debugger
          -- "java-debug-adapter",  -- Java Debugger
          -- "java-test",    -- Java Test Runner
      },
      automatic_installation 
  })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        -- "isort", -- python formatter
        -- "black", -- python formatter
        "eslint_d", -- eslint formatter
        -- "pylint", -- pylint formatter
        -- "taplo", -- toml formatter
        -- "ktlint", -- kotlin formatter
        -- "google-java-format", -- java formatter
        -- "beautysh", -- bash formatter
        "stylelint", -- stylelint formatter
      },
    })
  end,
}
