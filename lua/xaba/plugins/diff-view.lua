return {
  {
    "sindrets/diffview.nvim",
    lazy = true,
    dependencies = "nvim-lua/plenary.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Open Diffview (Current Branch)" },
      { "<leader>gc", "<cmd>DiffviewClose<CR>", desc = "Close Diffview" },
      { "<leader>gf", "<cmd>DiffviewFocusFiles<CR>", desc = "Focus Files Panel" },
      { "<leader>gt", "<cmd>DiffviewToggleFiles<CR>", desc = "Toggle Files Panel" },
      { "<leader>gC", "<cmd>lua CompareCommits()<CR>", desc = "Compare Two Commits" },
      { "<leader>gB", "<cmd>lua CompareBranches()<CR>", desc = "Compare Current Branch with Another Branch" },
    },
    config = function()
      local actions = require("diffview.actions")
      local diffview = require("diffview")

      -- Custom function to compare two commits
      _G.CompareCommits = function()
        local commit1 = vim.fn.input("Enter first commit hash: ")
        local commit2 = vim.fn.input("Enter second commit hash: ")
        if commit1 ~= "" and commit2 ~= "" then
          vim.cmd("DiffviewOpen " .. commit1 .. " " .. commit2)
        else
          print("Commit hashes are required!")
        end
      end

      -- Custom function to compare current branch with another branch
      _G.CompareBranches = function()
        -- Get the current branch name
        local current_branch = vim.fn.system("git rev-parse --abbrev-ref HEAD"):gsub("\n", "")
        -- Prompt user for the other branch to compare with
        local other_branch = vim.fn.input("Enter branch name to compare with: ")

        if current_branch ~= "" and other_branch ~= "" then
          -- Open diff view comparing the current branch with the specified branch
          vim.cmd("DiffviewOpen " .. current_branch .. "..." .. other_branch)
        else
          print("Both branches are required!")
        end
      end

    end,
  },
}
