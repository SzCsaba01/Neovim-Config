return {
  "kristijanhusak/vim-dadbod-ui",
  dependencies = {
    "tpope/vim-dadbod",
    "tpope/vim-dotenv",
    { "kristijanhusak/vim-dadbod-completion", ft = { "sql", "mysql", "plsql" } },
  },

  cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },

  keys = {
    { "<leader>db", "<cmd>tab DBUI<CR>", desc = "Open DBUI in tab" },
  },

  init = function()
    local dbt = require("config.db-telescope")

    -- ===== DBUI config =====
    vim.g.db_ui_use_nerd_fonts = true
    vim.g.db_ui_show_database_icon = true
    vim.g.db_ui_auto_execute_table_helpers = true
    vim.g.db_ui_use_nvim_notify = true
    vim.g.db_ui_execute_on_save = false
    vim.g.db_ui_win_position = "left"

    vim.g.db_ui_table_helpers = {
      sqlserver = {
        -- List table rows
        List = "SELECT TOP 100 * FROM {optional_schema}{table};",

        -- List Tables
        Tables = "SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE='BASE TABLE';",

        -- Search tables by name
        SearchTable = [[
          SELECT TABLE_NAME
          FROM INFORMATION_SCHEMA.TABLES
          WHERE LOWER(TABLE_NAME) LIKE LOWER('%{table}%');
        ]],

        -- List columns for a table
        ColumnInfo = [[
          SELECT COLUMN_NAME,
                 DATA_TYPE +
                 CASE WHEN CHARACTER_MAXIMUM_LENGTH IS NOT NULL
                   THEN ' (' + CAST(CHARACTER_MAXIMUM_LENGTH AS VARCHAR(20)) + ')'
                   ELSE '' END AS DATA_TYPE
          FROM INFORMATION_SCHEMA.COLUMNS
          WHERE TABLE_NAME='{table_name}';
        ]],

        -- Search columns
        SearchColumn = [[
          SELECT COLUMN_NAME AS 'ColumnName', TABLE_NAME AS 'TableName'
          FROM INFORMATION_SCHEMA.COLUMNS
          WHERE LOWER(COLUMN_NAME) LIKE LOWER('%column_name%')
          ORDER BY TableName, ColumnName;
        ]],

        -- Views
        Views = [[
          SELECT TABLE_SCHEMA + '.' + TABLE_NAME
          FROM INFORMATION_SCHEMA.VIEWS;
        ]],
        SearchView = [[
          SELECT TABLE_SCHEMA + '.' + TABLE_NAME
          FROM INFORMATION_SCHEMA.VIEWS
          WHERE LOWER(TABLE_NAME) LIKE LOWER('%{table}%');
        ]],
        ViewDefinition = [[
          SELECT OBJECT_DEFINITION(OBJECT_ID('{view_name}'));
        ]],

        -- Procedures
        Procedures = [[
          SELECT ROUTINE_SCHEMA + '.' + ROUTINE_NAME
          FROM INFORMATION_SCHEMA.ROUTINES
          WHERE ROUTINE_TYPE='PROCEDURE';
        ]],
        SearchProcedure = [[
          SELECT ROUTINE_SCHEMA + '.' + ROUTINE_NAME
          FROM INFORMATION_SCHEMA.ROUTINES
          WHERE ROUTINE_TYPE='PROCEDURE'
            AND LOWER(ROUTINE_NAME) LIKE LOWER('%{routine}%');
        ]],
        ProcedureDefinition = [[
          SELECT OBJECT_DEFINITION(OBJECT_ID('{procedure_name}'));
        ]],

        -- Functions
        Functions = [[
          SELECT ROUTINE_SCHEMA + '.' + ROUTINE_NAME
          FROM INFORMATION_SCHEMA.ROUTINES
          WHERE ROUTINE_TYPE='FUNCTION';
        ]],
        SearchFunction = [[
          SELECT ROUTINE_SCHEMA + '.' + ROUTINE_NAME
          FROM INFORMATION_SCHEMA.ROUTINES
          WHERE ROUTINE_TYPE='FUNCTION'
            AND LOWER(ROUTINE_NAME) LIKE LOWER('%{routine}%');
        ]],
        FunctionDefinition = [[
          SELECT OBJECT_DEFINITION(OBJECT_ID('{function_name}'));
        ]],
      },
    }

    -- Auto resize DBUI window
    vim.api.nvim_create_autocmd({ "WinEnter", "BufWinEnter" }, {
      callback = function()
        if vim.bo.filetype == "dbui" then
          vim.cmd("vertical resize 40")
        end
      end,
    })

    ---------------------------------------------------------------------------
    -- BUFFER-LOCAL DB COMMAND
    ---------------------------------------------------------------------------
    vim.api.nvim_create_user_command("DBChange", function(opts)
      local dbname = opts.args
      if dbname == "" then
        vim.notify("Usage: :DBChange <database_name>", vim.log.levels.WARN)
        return
      end

      local conn = vim.g.dbs[dbname]
      if not conn then
        vim.notify("Unknown database: " .. dbname, vim.log.levels.ERROR)
        return
      end

      vim.b.db = conn
      vim.notify("Buffer DB set to: " .. dbname, vim.log.levels.INFO)
    end, {
      nargs = 1,
      complete = function()
        return vim.tbl_keys(vim.g.dbs or {})
      end,
    })

    vim.keymap.set("v", "<leader>E", ":'<,'>DB<CR>", {
      desc = "Execute selected SQL",
      silent = true,
    })

    vim.keymap.set("n", "<leader>A", ":%DB<CR>", {
      desc = "Execute the whole file",
      silent = true,
    })

    vim.keymap.set("n", "<leader>ds", dbt.change_db, { desc = "Pick DB for buffer" })

    vim.keymap.set("n", "<leader>dt", dbt.tables, { desc = "Pick table and show definition" })
    vim.keymap.set("n", "<leader>dv", dbt.views, { desc = "Pick view and show definition" })
    vim.keymap.set("n", "<leader>dp", dbt.procedures, { desc = "Pick procedure and show definition" })
    vim.keymap.set("n", "<leader>df", dbt.functions, { desc = "Pick function and show definition" })
  end,
}
