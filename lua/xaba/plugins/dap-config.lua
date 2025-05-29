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
            load_breakpoints_event = { "BufReadPost" },
        })

        -- Define DAP configurations for Java
        dap.configurations.java = {
            {
                type = "java",
                request = "launch",
                name = "Launch Java Program",
                mainClass = function()
                    return vim.fn.input("Main Class: ", vim.fn.expand("%:p"), "file")
                end,
                cwd = "${workspaceFolder}",
                stopAtEntry = true,
            },
        }

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

        local cached_project_root = nil

         -- Function to find the project directory with an entry point (Program.cs or Startup.cs)
        local function find_project_with_entry_point()
            if cached_project_root ~= nil then
                return cached_project_root
            end

            local cwd = vim.fn.getcwd()
            local sln_files = vim.fn.glob(cwd .. "/*.sln", false, true)

            if vim.tbl_isempty(sln_files) then
                vim.notify("No solution file found in the current directory", vim.log.levels.ERROR)
                return nil
            end

            local sln_path = sln_files[1]
            local sln_file = io.open(sln_path, "r")
            if not sln_file then
                vim.notify("Failed to open solution file", vim.log.levels.ERROR)
                return nil
            end

            local project_paths = {}

            for line in sln_file:lines() do
                local path = line:match('Project%([^%)]+%)%s*=%s*"[^"]+",%s*"([^"]+%.csproj)"')
                if path then
                    local fixed_path = path:gsub("\\", "/")
                    table.insert(project_paths, fixed_path)
                end
            end

            sln_file:close()


            for _, rel_path in ipairs(project_paths) do
                local abs_path = cwd .. "/" .. rel_path
                local project_dir = vim.fn.fnamemodify(abs_path, ":h")
                if vim.fn.filereadable(project_dir .. "/Program.cs") == 1 or vim.fn.filereadable(project_dir .. "/Startup.cs") == 1 then
                    cached_project_root = project_dir
                    return project_dir
                end
            end

            return nil
        end
        
        local function pick_profile()
            local project_dir = find_project_with_entry_point()
            if not project_dir then
                error("No project directory found for profile selection")
            end

            local launch_settings_path = project_dir .. "/Properties/launchSettings.json"
            local file = io.open(launch_settings_path, "r")
            if not file then
                error("Failed to open launchSettings.json")
            end

            local content = file:read("*a")
            file:close()

            content = content:gsub("^\239\187\191", "")  -- Remove UTF-8 BOM
            local decoded = vim.fn.json_decode(content)
            local profiles = decoded and decoded["profiles"]

            if not profiles then
                error("No profiles found in launchSettings.json", vim.log.levels.ERROR)
            end

            local profile_names = {}
            for name, _ in pairs(profiles) do
                table.insert(profile_names, name)
            end

            table.sort(profile_names)

            local co = coroutine.running()
            vim.ui.select(profile_names, {
                prompt = "Select Profile:",
            }, function(choice)
                coroutine.resume(co, choice)
            end)

            local selected_profile = coroutine.yield()
            if not selected_profile then
                return nil
            end

            return selected_profile
        end
        
        
        -- Function to read launchSettings.json and pick the selected profile
        local function read_launch_settings(profile)
            local project_dir = find_project_with_entry_point()
            if not project_dir then
                vim.notify("No project directory found for reading launch settings", vim.log.levels.ERROR)
                return nil
            end

            local launch_settings_path = project_dir .. "/Properties/launchSettings.json"
            local file = io.open(launch_settings_path, "r")
            if not file then
                vim.notify("Failed to open launchSettings.json", vim.log.levels.ERROR)
                return nil
            end

            local content = file:read("*a")
            file:close()

            content = content:gsub("^\239\187\191", "")  -- Remove UTF-8 BOM
            local launch_settings = vim.fn.json_decode(content)
            local profile_data = launch_settings["profiles"][profile]

            if not profile_data then
                vim.notify("Profile not found in launchSettings.json", vim.log.levels.WARN)
                return nil
            end

            return profile_data
        end

        local function find_dll_path()
            local project_dir = find_project_with_entry_point()
            if project_dir == nil then
                project_dir = vim.fn.getcwd()
            end

            local project_name = vim.fn.fnamemodify(project_dir, ":t")
            local debug_dirs = vim.fn.globpath(project_dir .. "/bin/Debug", "net*/", 0, 1)
            if vim.tbl_isempty(debug_dirs) then
                vim.notify("No Debug directories found")
                return nil
            end

            local dll_path = vim.fn.glob(debug_dirs[1] .. project_name .. ".dll")
            vim.notify("DLL Path: " .. dll_path)
            if dll_path == "" then
                error("No .dll file found in the Debug folder")
                return nil
            end
            
            return dll_path
        end

        local function find_env_variables()
            local profile = pick_profile()
            if not profile then
                error("No profile selected")
            end
            vim.notify("Selected Profile: " .. profile)

            local profile_data = read_launch_settings(profile)
            if not profile_data then
                return {}
            end
            
            local env_vars = profile_data["environmentVariables"] or {}
            env_vars["ASPNETCORE_ENVIRONMENT"] = env_vars["ASPNETCORE_ENVIRONMENT"] or "Development"
            env_vars["ASPNETCORE_URLS"] = profile_data["applicationUrl"]
            
            return env_vars
        end

        -- DAP Adapter for coreclr
        dap.adapters.coreclr = {
            type = "executable",
            command = vim.fn.stdpath("data") .. "/mason/packages/netcoredbg/netcoredbg/netcoredbg",
            args = { "--interpreter=vscode" },
        }
        
        -- DAP Configurations for .NET
        dap.configurations.cs = {
            {
                type = "coreclr",
                request = "launch",
                name = "Launch .NET",
                program = find_dll_path,
                env = find_env_variables,
                stopAtEntry = true,
            },
        }        

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
        vim.keymap.set("n", "<leader>b", function()
            require("persistent-breakpoints.api").toggle_breakpoint()
        end, { desc = "Toggle Breakpoint" })
        vim.keymap.set("n", "<leader>dc", dap.run_to_cursor, { desc = "Run to cursor" })
        vim.keymap.set("n", "<leader>dd", function()
            dap.terminate()
            dapui.close()
            dap.disconnect()
        end, { desc = "Close Debug Session" })

        vim.keymap.set("n", "<F1>", dap.continue, { desc = "Continue" })
        vim.keymap.set("n", "<F2>", dap.step_over, { desc = "Step over" })
        vim.keymap.set("n", "<F3>", dap.step_into, { desc = "Step into" })
        vim.keymap.set("n", "<F4>", dap.step_out, { desc = "Step out" })
        vim.keymap.set("n", "<F5>", dap.step_back, { desc = "Step back" })
        vim.keymap.set("n", "<F10>", dap.restart, { desc = "Restart" })

        vim.keymap.set("n", "<space>?", function()
            require("dapui").eval(nil, { enter = true })
        end)

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
