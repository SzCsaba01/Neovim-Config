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
        local dotnet = require("easy-dotnet")

        dapui.setup()

        -- Define DAP configurations for Java
        -- dap.configurations.java = {
        --     {
        --         type = "java",
        --         request = "launch",
        --         name = "Launch Java Program",
        --         mainClass = function()
        --             return vim.fn.input("Main Cla fss: ", vim.fn.expand("%:p"), "file")
        --         end,
        --         cwd = "${workspaceFolder}",
        --         stopAtEntry = true,
        --     },
        -- }

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
                            filter = ".*%.ts|.*%.js", -- Filter for both JavaScript and TypeScript files
                            executables = false, -- Disable executable search
                            path = vim.fn.getcwd(),
                        })
                    end,
                    skipFiles = { "${workspaceFolder}/node_modules/**/*.js" },
                },
            }
        end

        -- C#, .NET debugging 

        -- easy-dotnet helper to rebuild project async
        local function rebuild_project(co, path)
            local spinner = require("easy-dotnet.ui-modules.spinner").new()
            spinner:start_spinner("Building")
            vim.fn.jobstart(string.format("dotnet build %s", path), {
                on_exit = function(_, return_code)
                if return_code == 0 then
                    spinner:stop_spinner("Built successfully")
                else
                    spinner:stop_spinner("Build failed with exit code " .. return_code, vim.log.levels.ERROR)
                    error("Build failed")
                end
                coroutine.resume(co)
                end,
            })
            coroutine.yield()
        end

        local debug_dll = nil

        local function ensure_dll()
            if debug_dll ~= nil then
                return debug_dll
            end
            local dll = dotnet.get_debug_dll(true)
            debug_dll = dll
            return dll
        end

        -- DAP Adapter for coreclr
        dap.adapters.coreclr = {
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg",
            args = { "--interpreter=vscode" },
        }
        
        for _, lang in ipairs { "cs", "fsharp" } do
            dap.configurations[lang] = {
                {
                    type = "coreclr",
                    name = "Program",
                    request = "launch",
                    env = function()
                        local dll = ensure_dll()
                        local vars = dotnet.get_environment_variables(dll.project_name, dll.relative_project_path, false)
                        return vars or nil
                    end,
                    program = function()
                        local dll = ensure_dll()
                        local co = coroutine.running()
                        rebuild_project(co, dll.project_path)
                        return dll.relative_dll_path
                    end,
                    cwd = function()
                        local dll = ensure_dll()
                        return dll.relative_project_path
                    end,
                },
            }
        end

        -- --Clear debug_dll on termination
        dap.listeners.before["event_terminated"]["easy-dotnet"] = function()
            debug_dll = nil
        end

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
        vim.keymap.set("n", "<F1>", dap.continue, {})
        vim.keymap.set("n", "<F2>", dap.step_over, {})
        vim.keymap.set("n", "<F3>", dap.step_into, {})
        vim.keymap.set("n", "<F5>", dap.run_to_cursor, {})
        vim.keymap.set("n", "<F4>", dap.step_out, {})
        vim.keymap.set("n", "<leader>b", dap.toggle_breakpoint, {})
        vim.keymap.set("n", "<leader>dr", dap.repl.toggle, {})
        vim.keymap.set("n", "<leader>dd", function()
            dap.close()
            dapui.close()
        end, {})

        vim.keymap.set("n", "<space>?", function()
            dapui.eval(nil, { enter = true })
        end)

        -- dapui listeners
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
    end,
}
