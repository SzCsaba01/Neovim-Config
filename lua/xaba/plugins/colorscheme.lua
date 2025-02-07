return {
  "folke/tokyonight.nvim",
  priority = 1000,
  config = function()
    require("tokyonight").setup({
      style = "night",         
      transparent = true,      
      styles = {
        sidebars = "dark",     
        floats = "dark",       
      },
      hide_inactive_statusline = true, 

      on_colors = function(colors)
       
        colors.bg = "#13151a"       
        colors.fg = "#a1a1a1"       
        colors.comment = "#5f5f5f"  
        colors.border = "#2d2f36"   
        colors.gutter_fg = "#22262f" 
        
        colors.statusline_bg = "#22272e"  
        colors.tabline_bg = "#1f2328"     
      end,

      on_highlights = function(hl, colors)
        
        hl.Normal = { bg = "none", fg = colors.fg }  
        hl.Comment = { fg = colors.comment, italic = true }  
        hl.CursorLine = { bg = "#1e2228" }  
        hl.LineNr = { fg = colors.gutter_fg }  
        hl.StatusLine = { bg = colors.statusline_bg, fg = colors.fg }
        hl.TabLine = { bg = colors.tabline_bg, fg = colors.fg }
        hl.TabLineSel = { bg = colors.bg, fg = colors.fg, bold = true }  
        hl.FloatBorder = { fg = colors.border }  
      end,
    })

    vim.cmd("colorscheme tokyonight")
  end,
}
