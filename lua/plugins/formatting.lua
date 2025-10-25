return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters_by_ft = {
                lua = { "stylua" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                json = { "prettier" },
                -- graphql = { "prettier" },
                -- kotlin = { "ktlint" },
                markdown = { "prettier" },
                -- erb = { "prettier" },
                html = { "prettier" },
                -- bash = { "beautysh" },
                -- proto = { "buf" },
                yaml = { "prettier" },
                toml = { "taplo" },
                css = { "prettier" },
                scss = { "prettier" },
                -- liquid = { "prettier" },
                -- python = { "isort", "black" },
                -- angular = {  "prettier" },
            },
            format_on_save = {
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
                stop_after_first = true,
            },
        })

        vim.keymap.set({ "n", "v" }, "<leader>mp", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
                stop_after_first = true,
            })
        end, { desc = "Format file or range (in visual mode)" })
    end,
}
