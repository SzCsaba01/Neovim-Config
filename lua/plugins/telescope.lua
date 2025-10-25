return {
  "nvim-telescope/telescope.nvim",
  branch = "0.1.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
    "nvim-tree/nvim-web-devicons",
    "folke/todo-comments.nvim",
    "rcarriga/nvim-notify",
  },
  config = function()
    local telescope = require("telescope")
    local actions = require("telescope.actions")
    local transform_mod = require("telescope.actions.mt").transform_mod
    local trouble = require("trouble")
    local trouble_telescope = require("trouble.sources.telescope")
    local icons = require("config.icons")
    telescope.load_extension("notify")

    local custom_actions = transform_mod({
      open_trouble_qflist = function(prompt_bufnr)
        trouble.toggle("quickfix")
      end,
    })

    telescope.setup({
      defaults = {
        prompt_prefix = icons.misc.dots .. " ",
        selection_caret = " ",
        path_display = { "truncate" },
        file_ignore_patterns = {
          "node_modules",
          "/.class",
          "/.gradle",
          "/.settings",
          "object",
          ".git",
          "package%-lock%.json",
          "dist",
          "bin",
          "build",
          "target",
        },
        hidden = false,
        winblend = 10,
        preview = { treesitter = false },
        dynamic_preview_title = true,
        mappings = {
          i = {
            ["<C-k>"] = actions.move_selection_previous,
            ["<C-j>"] = actions.move_selection_next,
            ["<C-q>"] = actions.send_selected_to_qflist + custom_actions.open_trouble_qflist,
            ["<C-t>"] = trouble_telescope.open,
          },
        },
      },
    })

    telescope.load_extension("fzf")

    local keymap = vim.keymap
    local builtin = require("telescope.builtin")

    keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find files (git-aware)" })
    keymap.set("n", "<leader>fr", builtin.oldfiles, { desc = "Recent files" })
    keymap.set("n", "<leader>fs", builtin.live_grep, { desc = "Live grep" })
    keymap.set("n", "<leader>fc", builtin.grep_string, { desc = "Grep word under cursor" })
  end,
}
