return {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = "nvim-lua/plenary.nvim", 
    config = function()
        local harpoon = require("harpoon")
        local conf = require("telescope.config").values

        local function toggle_telescope(harpoon_files)
            local file_paths = {}
            for _, item in ipairs(harpoon_files.items) do
                table.insert(file_paths, item.value)
            end
        
            require("telescope.pickers").new({}, {
                prompt_title = "Harpoon",
                finder = require("telescope.finders").new_table({
                    results = file_paths,
                }),
                previewer = conf.file_previewer({}),
                sorter = conf.generic_sorter({}),
            }):find()
        end

        vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end, { desc = "Add file to harpoon" })
        vim.keymap.set("n", "<C-e>", function() toggle_telescope(harpoon:list()) end, { desc = "Open harpoon window" })

        vim.keymap.set("n", "<leader>1", function() harpoon:list():select(1) end, { desc = "Select file 1 from harpoon" })
        vim.keymap.set("n", "<leader>2", function() harpoon:list():select(2) end, { desc = "Select file 2 from harpoon" })
        vim.keymap.set("n", "<leader>3", function() harpoon:list():select(3) end, { desc = "Select file 3 from harpoon" })
        vim.keymap.set("n", "<leader>4", function() harpoon:list():select(4) end, { desc = "Select file 4 from harpoon" })

        -- Toggle previous & next buffers stored within Harpoon list
        vim.keymap.set("n", "<C-z>", function() harpoon:list():prev() end, { desc = "Select previous file from harpoon" })
        vim.keymap.set("n", "<C-x>", function() harpoon:list():next() end, { desc = "Select next file from harpoon" })
        
    end
}