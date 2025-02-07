return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lint = require("lint")
  
      local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
  
      lint.linters_by_ft = {
        javascript = { "eslint_d", "eslint" },
        typescript = { "eslint_d", "eslint" },
        javascriptreact = { "eslint_d", "eslint" },
        typescriptreact = { "eslint_d", "eslint" },
        svelte = { "eslint_d", "eslint" },
        python = { "pylint" },
        angular = { "eslint_d", "eslint" },
        css = { "stylelint" },
        scss = { "stylelint" },
        less = { "stylelint" },
      }
  
      -- Function to check if the project has an ESLint config file
      local function has_eslint_config()
        local filepath = vim.fn.findfile(".eslintrc.json", vim.fn.expand("%:p:h") .. ";")
        if filepath == "" then
          filepath = vim.fn.findfile(".eslintrc.js", vim.fn.expand("%:p:h") .. ";")
        end
        if filepath == "" then
          filepath = vim.fn.findfile(".eslintrc.yaml", vim.fn.expand("%:p:h") .. ";")
        end
        if filepath == "" then
          filepath = vim.fn.findfile(".eslint.json", vim.fn.expand("%:p:h") .. ";")
        end
        if filepath == "" then
          filepath = vim.fn.findfile("eslint.config.js", vim.fn.expand("%:p:h") .. ";")
        end
        return filepath ~= ""
      end
  
      -- Set up the callback for linting, only run eslint_d if config exists
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
        group = lint_augroup,
        callback = function()
          -- Only run linting if an ESLint config file is found
          if has_eslint_config() then
            lint.try_lint()
          end
        end,
      })
  
      vim.diagnostic.config({
        virtual_text = true,  -- Enable virtual text
        signs = true,         -- Show signs (e.g., error/warning indicators)
        underline = true,     -- Underline errors/warnings
        update_in_insert = true,  -- Update diagnostics in insert mode
      })
    end,
  }
  