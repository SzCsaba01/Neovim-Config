-- File: ~/.config/nvim/lua/plugins.lua or similar

return {
    -- Lualine status line
    {
        "nvim-lualine/lualine.nvim",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            local lualine = require("lualine")
            local lazy_status = require("lazy.status") -- For lazy.nvim updates count

            -- Configure lualine with default or basic theme
            lualine.setup({
                options = {
                    theme = "tokyonight", -- Use the Tokyonight theme for lualine
                },
                sections = {
                    lualine_x = {
                        {
                            lazy_status.updates,
                            cond = lazy_status.has_updates,
                            color = { fg = "#ff9e64" }, -- Optional color for updates indicator
                        },
                        { "encoding" },
                        { "fileformat" },
                        { "filetype" },
                    },
                },
            })
        end,
    },
}
