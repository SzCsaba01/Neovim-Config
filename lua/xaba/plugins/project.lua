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
            ".git",              -- For Git-based projects (e.g., Angular, React, Node.js, .NET, Java)
            "package.json",      -- Node.js and React projects
            "angular.json",      -- Angular projects
            "tsconfig.json",     -- TypeScript config (for Angular, React, Node.js)
            "webpack.config.js", -- React/Node.js projects with Webpack
            "Cargo.toml",        -- Rust projects (optional)
            "App_Start",         -- .NET projects (older ASP.NET)
            "web.config",        -- .NET projects (ASP.NET and WebForms)
            "project.json",      -- Older .NET Core projects (pre .csproj format)
            "*.sln",             -- .NET solution files
            "pom.xml",           -- Maven for Java projects
            "build.gradle",      -- Gradle for Java projects
            "settings.gradle",   -- Gradle settings for Java projects
        },
        scope_chdir = 'global',  -- Automatically change the working directory to project root
      })
  
      -- Load Telescope's project.nvim extension
      require('telescope').load_extension('projects')
      
      -- Keymap for opening the project picker with Telescope
      vim.api.nvim_set_keymap('n', '<leader>pp', '<cmd>Telescope projects<CR>', { noremap = true, silent = true })
    end,
  }
  