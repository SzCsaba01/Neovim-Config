return {
  "windwp/nvim-autopairs",
  event = { "InsertEnter" }, 
  dependencies = {
    { "hrsh7th/nvim-cmp", opts = true }, 
  },
  config = function()
    local autopairs = require("nvim-autopairs")

    local function is_large_file(bufnr)
      local max_filesize = 200 * 1024 
      local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
      return ok and stats and stats.size > max_filesize
    end

    autopairs.setup({
      check_ts = function(bufnr)
        return not is_large_file(bufnr) 
      end,
      ts_config = {
        lua = { "string" },
        javascript = { "template_string" },
        java = false,
      },
    })

    local cmp_autopairs = require("nvim-autopairs.completion.cmp")
    local cmp = require("cmp")

    cmp.event:on("confirm_done", function(...)
      cmp_autopairs.on_confirm_done(...) 
    end)
  end,
}
