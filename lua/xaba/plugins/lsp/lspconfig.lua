return {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
        "hrsh7th/cmp-nvim-lsp",
        "williamboman/mason-lspconfig.nvim",
        { "antosha417/nvim-lsp-file-operations", config = true },
        { "folke/neodev.nvim", opts = {} },
        { "b0o/schemastore.nvim", event = "BufReadPre" },
    },
    config = function()
        local lspconfig = require("lspconfig")
        local util = require("lspconfig.util")
        local cmp_nvim_lsp = require("cmp_nvim_lsp")
        local omnisharp_path = vim.fn.stdpath("data") .. "/mason/bin/omnisharp"

        local capabilities = cmp_nvim_lsp.default_capabilities()

        local keymap = vim.keymap 

        vim.api.nvim_create_autocmd("LspAttach", {
            group = vim.api.nvim_create_augroup("UserLspConfig", {}),
            callback = function(ev)
                -- Retrieve the client object based on the current buffer
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                if not client then
                    return
                end

                -- Buffer local mappings
                local opts = { buffer = ev.buf, silent = true }

                opts.desc = "Show LSP references"
                vim.keymap.set("n", "gR", "<cmd>Telescope lsp_references<CR>", opts) -- show references

                opts.desc = "Go to declaration"
                vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts) -- go to declaration

                opts.desc = "Show LSP definitions"
                vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts) -- show definitions

                opts.desc = "Show LSP implementations"
                vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts) -- show implementations

                opts.desc = "Show LSP type definitions"
                vim.keymap.set("n", "gt", "<cmd>Telescope lsp_type_definitions<CR>", opts)

                opts.desc = "See available code actions"
                vim.keymap.set({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, opts) -- show code actions

                opts.desc = "Smart rename"
                vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)

                opts.desc = "Show buffer diagnostics"
                vim.keymap.set("n", "<leader>D", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

                opts.desc = "Show documentation for what is under cursor"
                vim.keymap.set("n", "K", vim.lsp.buf.hover, opts) -- show documentation for what is under cursor

                opts.desc = "Restart LSP"
                vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts) -- mapping to restart lsp if necessary
            end,
        })

        lspconfig.omnisharp.setup({
            cmd = { omnisharp_path, "--languageserver", "--hostPID", tostring(vim.fn.getpid()) },

            root_dir = function(fname)
                local root = util.search_ancestors(fname, function(dir)
                    if vim.fn.globpath(dir, "*.sln") ~= "" then
                        return dir
                    end
                    if vim.fn.globpath(dir, "*.csproj") ~= "" then
                        return dir
                    end
                    return nil
                end)
                return root or util.find_git_ancestor(fname) or vim.loop.cwd()
            end,

            capabilities = capabilities,
        })

        local signs = {
            Error = "",
            Warn = "",
            Info = "",
            Hint = "󰠠",
        }

        for type, icon in pairs(signs) do
            local hl = "DiagnosticSign" .. type
            vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
        end

        vim.diagnostic.config({
            virtual_text = true,
            signs = true,     
            underline = true,
            update_in_insert = false,
            severity_sort = true,
            float = { border = "rounded" },
            linehl = false,    
        })
    end,
}
