return {
  "ahmedkhalf/project.nvim",
  dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
  config = function()
    -- import project.nvim
    local project = require("project_nvim")

    -- Configure project.nvim
    project.setup({
      detection_methods = { "pattern", "lsp", "manual" },
      patterns = {
        "package.json", -- Node.js and React projects
        "angular.json", -- Angular projects
        "tsconfig.json", -- TypeScript config (for Angular, React, Node.js)
        "webpack.config.js", -- React/Node.js projects with Webpack
        ".git", -- Git repository root
        "*.sln", -- .NET solution files
      },
      manual_mode = true,
    })

    -- Load Telescope's project.nvim extension
    require("telescope").load_extension("projects")

    -- Keymap for opening the project picker with Telescope
    vim.api.nvim_set_keymap("n", "<leader>pp", "<cmd>Telescope projects<CR>", { noremap = true, silent = true })
    vim.api.nvim_set_keymap(
      "n",
      "<leader>pa",
      ":ProjectRootAdd<CR>",
      { noremap = true, silent = true, desc = "Add current folder as project" }
    )
  end,
}
