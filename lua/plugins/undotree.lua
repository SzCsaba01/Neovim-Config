return {
  "mbbill/undotree",
  cmd = "UndotreeToggle",
  keys = {
    { "<leader>u", "<cmd>UndotreeToggle<CR>", desc = "Toggle UndoTree" },
  },
  config = function()
    vim.api.nvim_create_autocmd("BufReadPost", {
      callback = function()
        if vim.fn.exists("t:undotree") == 0 then
          vim.cmd("UndotreeLoad")
        end
      end,
    })

    vim.g.undotree_WindowLayout = 2       
    vim.g.undotree_ShortIndicators = 1    
    vim.g.undotree_SetFocusWhenToggle = 1 
  end,
}
