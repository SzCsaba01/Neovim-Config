return {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
        "Weissle/persistent-breakpoints.nvim",
    },
    config = function()
        local dap = require("dap")
        local dapui = require("dapui")
        local persistent_breakpoints = require("persistent-breakpoints")

        dapui.setup()

        persistent_breakpoints.setup({
            save_dir = vim.fn.stdpath("data") .. "/nvim_checkpoints/",
            load_breakpoints_on_start = true,
            save_breakpoints_on_exit = true,
            load_breakpoints_event = { "BufReadPost" }
        })

        -- JavaScript and TypeScript Adapter using node-debug2-adapter from Mason
        dap.adapters.node2 = {
            type = "executable",
            command = "node",
            args = { vim.fn.stdpath("data") .. "/mason/packages/node-debug2-adapter/out/src/nodeDebug" },
        }

        -- JavaScript and TypeScript Debugging Configurations
        for _, language in ipairs({ "typescript", "javascript" }) do
            dap.configurations[language] = {
                {
                    type = "node2",
                    request = "launch",
                    name = "Launch file in new node process",
                    program = function()
                        return require("dap.utils").pick_file({
                            filter = ".*%.js",  -- Filter for JavaScript files
                            executables = false,  -- Disable executable search
                            path = vim.fn.getcwd(),
                        })
                    end,
                    skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
                }
            }
        end

        -- .NET Core (C#) Adapter using netcoredbg from Mason
        -- dap.adapters.coreclr = {
        --     type = "executable",
        --     command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg",
        --     args = { "--interpreter=vscode" },
        -- }
        -- dap.configurations.cs = {
        --     {
        --         type = "coreclr",
        --         request = "launch",
        --         name = "Launch .NET",
        --         program = function()
        --             -- Use pick_file to allow dynamic picking of a DLL file
        --             return require("dap.utils").pick_file({
        --                 filter = ".*%.dll",  -- Only show .dll files
        --                 executables = false,  -- Disable executable search (we only want DLLs)
        --                 path = vim.fn.getcwd() 
        --             })
        --         end,
        --         skipFiles = {
        --             "${workspaceFolder}/**/bin/**",  -- Skip compiled binaries
        --             "${workspaceFolder}/**/obj/**",  -- Skip obj directories
        --         },
        --     },
        -- }

        -- C/C++ Adapter using cpptools from Mason
        -- require("dap").adapters.codelldb = {
        --     type = "server",
        --     port = "${port}",
        --     executable = {
        --         command = vim.fn.stdpath("data") .. "/mason/packages/codelldb/extension/adapter/codelldb",
        --         args = { "--port", "${port}" },
        --     },
        -- }

        -- dap.configurations.cpp = {
        --     {
        --         type = "codelldb",
        --         name = "Launch",
        --         request = "launch",
        --         program = function()
        --             return require("dap.utils").pick_file({
        --                 executables = false
        --             })
        --         end,
        --         cwd = "${workspaceFolder}",
        --         stopAtEntry = false,
        --     },
        -- }
        -- dap.configurations.c = dap.configurations.cpp

        -- Keybindings
        vim.keymap.set("n", "<leader>b", function() require('persistent-breakpoints.api').toggle_breakpoint() end, { desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })
        vim.keymap.set("n", "<leader>dd", function() dap.terminate(); dapui.close(); dap.disconnect() end, { desc = "Close Debug Session" })

        vim.keymap.set("n", "<F1>", dap.continue, { desc = "Continue" })
        vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Step over" })
        vim.keymap.set("n", "<F3>", dap.step_into, { desc = "Step into" })
        vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Step out" })
        vim.keymap.set("n", "<F5>", dap.step_back, { desc = "Step back" })
        vim.keymap.set("n", "<F10>", dap.restart, { desc = "Restart" })

        vim.keymap.set("n", "<space>?", function() require("dapui").eval(nil, { enter = true}) end)

        dap.listeners.after.launch.dapui_config = function()
            dapui.open()
        end
        dap.listeners.after.event_terminated.dapui_config = function()
            dapui.close()
        end
        dap.listeners.after.event_exited.dapui_config = function()
            dapui.close()
        end
    end,
}
