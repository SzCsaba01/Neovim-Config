return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "hrsh7th/cmp-nvim-lsp",
    "williamboman/mason-lspconfig.nvim",
    { "antosha417/nvim-lsp-file-operations", config = true },
    { "b0o/schemastore.nvim", event = "BufReadPre" },
  },
  config = function()
    local icons = require("config.icons")
    local cmp_nvim_lsp = require("cmp_nvim_lsp")
    local lspconfig_util = require("lspconfig.util")

    -- LSP attach keymaps
    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("UserLspConfig", {}),
      callback = function(ev)
        local client = vim.lsp.get_client_by_id(ev.data.client_id)
        if not client then
          return
        end

        local opts = { buffer = ev.buf, silent = true }

        vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts)
        vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
        vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)
        vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)
        vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)
        vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
        vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)
        vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
        vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
      end,
    })

    local omnisharp_cmd = {
      vim.fn.stdpath("data") .. "/mason/bin/OmniSharp",
      "--languageserver",
      "--hostPID",
      tostring(vim.fn.getpid()),
    }

    vim.api.nvim_create_autocmd("FileType", {
      pattern = "cs",
      callback = function(args)
        local bufnr = args.buf
        for _, client in pairs(vim.lsp.get_clients({ bufnr = bufnr })) do
          if client.name == "omnisharp" then
            return
          end
        end

        local root_dir = lspconfig_util.root_pattern("*.sln", "*.csproj")(vim.api.nvim_buf_get_name(bufnr))
          or vim.fn.getcwd()

        vim.lsp.start({
          name = "omnisharp",
          cmd = omnisharp_cmd,
          root_dir = root_dir,
          capabilities = cmp_nvim_lsp.default_capabilities(),
        })
      end,
    })

    -- Diagnostics configuration
    local severity = vim.diagnostic.severity
    vim.diagnostic.config({
      signs = {
        active = true,
        text = {
          [severity.ERROR] = icons.diagnostics.Error,
          [severity.WARN] = icons.diagnostics.Warn,
          [severity.INFO] = icons.diagnostics.Info,
          [severity.HINT] = icons.diagnostics.Hint,
        },
      },
      virtual_text = { prefix = "●" },
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded" },
    })
  end,
}
