return {
  "jiaoshijie/undotree",
  event = "VeryLazy",
  dependencies = { "nvim-lua/plenary.nvim" },

  keys = {
    { "<leader>u", function() require("undotree").toggle() end, desc = "Toggle UndoTree" },
  },

  config = function()
    local ok, undotree = pcall(require, "undotree")
    if not ok then
      vim.notify("Failed to load undotree", vim.log.levels.ERROR)
      return
    end

    undotree.setup({
      float_diff = true,            -- show diff in floating window
      layout = "left_bottom",       -- layout of the tree window
      position = "left",            -- where to open (left/right/bottom)
      ignore_filetype = {
        "undotree", "undotreeDiff", "qf",
        "TelescopePrompt", "help", "spectre_panel",
        "tsplayground", "neo-tree", "dap-repl"
      },
      window = {
        winblend = 15,              -- transparency
        border = "rounded",         -- nice rounded borders
      },
      keymaps = {
        j = "move_next",            -- move to next node
        k = "move_prev",            -- move to previous node
        gj = "move2parent",         -- move to parent node
        J = "move_change_next",     -- move to next change
        K = "move_change_prev",     -- move to previous change
        ["<CR>"] = "action_enter",  -- checkout state
        p = "enter_diffbuf",        -- open diff buffer
        q = "quit",                 -- quit panel
      },
    })

    vim.api.nvim_create_autocmd("BufDelete", {
      callback = function()
        if vim.bo.filetype == "undotree" then
          undotree.close()
        end
      end,
    })
  end,
}
