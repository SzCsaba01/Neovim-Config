return {
    "nvim-tree/nvim-tree.lua",
    dependencies = "nvim-tree/nvim-web-devicons",
    config = function()
        local nvimtree = require("nvim-tree")
        -- recommended settings from nvim-tree documentation
        vim.g.loaded_netrw = 1
        vim.g.loaded_netrwPlugin = 1

        nvimtree.setup({
            view = {
                width = 35,
                relativenumber = true,
            },
            -- change folder arrow icons
            renderer = {
                indent_markers = {
                    enable = true,
                },
                icons = {
                    glyphs = {
                        folder = {
                            arrow_closed = "",
                            arrow_open = "",
                        },
                    },
                },
            },

            actions = {
                open_file = {
                    window_picker = {
                        enable = false,
                    },
                },
            },
            filters = {
                custom = { ".DS_Store" },
            },
            git = {
                ignore = false,
            },
        })

        local keymap = vim.keymap

        keymap.set("n", "<leader>ee", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" }) -- toggle file explorer
        keymap.set(
            "n",
            "<leader>ef",
            "<cmd>NvimTreeFindFileToggle<CR>",
            { desc = "Toggle file explorer on current file" }
        ) -- toggle file explorer on current file
        keymap.set("n", "<leader>ec", "<cmd>NvimTreeCollapse<CR>", { desc = "Collapse file explorer" }) -- collapse file explorer
        keymap.set("n", "<leader>er", "<cmd>NvimTreeRefresh<CR>", { desc = "Refresh file explorer" }) -- refresh file explorer

        vim.cmd([[
      " Background and foreground for NvimTree window (make background transparent)
      hi NvimTreeNormal guibg=NONE guifg=#a1a1a1
      hi NvimTreeNormalNC guibg=NONE guifg=#a1a1a1  " This ensures transparency when NvimTree is not focused
      " Folder names in NvimTree
      hi NvimTreeFolderName guifg=#a1a1a1
      " Opened folder names
      hi NvimTreeOpenedFolderName guifg=#a1a1a1
      " Root folder name
      hi NvimTreeRootFolderName guifg=#a1a1a1
      " Empty folder name in dark gray
      hi NvimTreeEmptyFolderName guifg=#5f5f5f
      " Git dirty (unstaged) files, yellow
      hi NvimTreeGitDirty guifg=#ffaf00
      " Git staged files, green
      hi NvimTreeGitStaged guifg=#00ff00
      " Git merge conflict, red
      hi NvimTreeGitMerge guifg=#ff0000
      " Renamed files, light blue
      hi NvimTreeGitRenamed guifg=#00bfff
      " Untracked files, magenta
      hi NvimTreeGitUntracked guifg=#ff00ff
      " Deleted files, orange
      hi NvimTreeGitDeleted guifg=#ff4500
    ]])
    end,
}
