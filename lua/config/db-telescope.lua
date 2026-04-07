local M = {}

local ok, _ = pcall(require, "telescope")
if not ok then
  return M
end

local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local conf = require("telescope.config").values
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

-- ---------------------------------------------------------------------
-- Helper: check buffer-local db
-- ---------------------------------------------------------------------
local function require_buffer_db()
  if not vim.b.db then
    vim.notify("b:db is not set for this buffer", vim.log.levels.ERROR)
    return nil
  end
  return vim.b.db
end

-- ---------------------------------------------------------------------
-- Helper: open results in a new tab buffer with unique timestamped name
-- ---------------------------------------------------------------------
local function open_buffer(lines, ft)
  local db = vim.b.db

  local ts = os.date("%Y%m%d_%H%M%S")
  local buf_name = "SQLQuery_" .. ts .. ".sql"

  vim.cmd("tabnew")
  local buf = vim.api.nvim_get_current_buf()

  vim.api.nvim_buf_set_name(buf, buf_name)
  vim.bo[buf].buftype = ""
  vim.bo[buf].bufhidden = "hide"
  vim.bo[buf].swapfile = true
  vim.bo[buf].filetype = ft or "sql"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].modifiable = true

  if db then
    vim.b.db = db
  end
end

-- ---------------------------------------------------------------------
-- Queries to list objects
-- ---------------------------------------------------------------------
local LIST_QUERIES = {
  tables = [[
    SELECT s.name + '.' + t.name AS name
    FROM sys.tables t
    JOIN sys.schemas s ON t.schema_id = s.schema_id
    ORDER BY t.name;
  ]],
  views = [[
    SELECT s.name + '.' + v.name AS name
    FROM sys.views v
    JOIN sys.schemas s ON v.schema_id = s.schema_id
    ORDER BY v.name;
  ]],
  procedures = [[
    SELECT s.name + '.' + p.name AS name
    FROM sys.procedures p
    JOIN sys.schemas s ON p.schema_id = s.schema_id
    ORDER BY p.name;
  ]],
  functions = [[
    SELECT s.name + '.' + f.name AS name
    FROM sys.objects f
    JOIN sys.schemas s ON f.schema_id = s.schema_id
    WHERE f.type IN ('FN','IF','TF')
    ORDER BY f.name;
  ]],
}

-- ---------------------------------------------------------------------
-- Fetch object info
-- ---------------------------------------------------------------------
local function get_object_info(kind, fullname)
  local sql
  local lines = {}

  if kind == "tables" then
    -- Full table info including columns, constraints, and indexes
    local schema, table_name = fullname:match("([^.]+)%.(.+)")
    if not schema or not table_name then
      vim.notify("Invalid table name: " .. fullname, vim.log.levels.ERROR)
      return nil
    end

    -- Columns
    sql = string.format(
      [[
        SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH, COLUMN_DEFAULT
        FROM INFORMATION_SCHEMA.COLUMNS
        WHERE TABLE_SCHEMA = '%s' AND TABLE_NAME = '%s'
        ORDER BY ORDINAL_POSITION;
      ]],
      schema,
      table_name
    )
    local col_rows = vim.fn["db_ui#query"](sql)
    if col_rows and #col_rows > 0 then
      table.insert(lines, "-- Columns for " .. fullname)
      table.insert(lines, "COLUMN | TYPE | NULLABLE | MAX_LENGTH | DEFAULT")
      table.insert(lines, string.rep("-", 60))
      for _, row in ipairs(col_rows) do
        table.insert(lines, table.concat(row, " | "))
      end
    end

    -- Constraints (Primary Key, Foreign Keys)
    sql = string.format(
      [[
        SELECT kc.CONSTRAINT_NAME, kc.CONSTRAINT_TYPE, ccu.COLUMN_NAME, ccu.TABLE_NAME AS ReferencedTable, ccu.COLUMN_NAME AS ReferencedColumn
        FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS kc
        LEFT JOIN INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE ccu
          ON kc.CONSTRAINT_NAME = ccu.CONSTRAINT_NAME
        WHERE kc.TABLE_SCHEMA = '%s' AND kc.TABLE_NAME = '%s'
        ORDER BY kc.CONSTRAINT_TYPE, kc.CONSTRAINT_NAME;
      ]],
      schema,
      table_name
    )
    local constr_rows = vim.fn["db_ui#query"](sql)
    if constr_rows and #constr_rows > 0 then
      table.insert(lines, "")
      table.insert(lines, "-- Constraints")
      table.insert(lines, "CONSTRAINT_NAME | TYPE | COLUMN | REFERENCED_TABLE | REFERENCED_COLUMN")
      table.insert(lines, string.rep("-", 60))
      for _, row in ipairs(constr_rows) do
        table.insert(lines, table.concat(row, " | "))
      end
    end

    -- Indexes
    sql = string.format(
      [[
        SELECT i.name AS IndexName,
               i.type_desc AS IndexType,
               i.is_unique AS IsUnique,
               STRING_AGG(c.name, ', ') AS Columns
        FROM sys.indexes i
        JOIN sys.index_columns ic ON i.object_id = ic.object_id AND i.index_id = ic.index_id
        JOIN sys.columns c ON ic.object_id = c.object_id AND ic.column_id = c.column_id
        JOIN sys.tables t ON i.object_id = t.object_id
        JOIN sys.schemas s ON t.schema_id = s.schema_id
        WHERE s.name = '%s' AND t.name = '%s' AND i.is_primary_key = 0 -- exclude PKs (already in constraints)
        GROUP BY i.name, i.type_desc, i.is_unique
        ORDER BY i.name;
      ]],
      schema,
      table_name
    )
    local idx_rows = vim.fn["db_ui#query"](sql)
    if idx_rows and #idx_rows > 0 then
      table.insert(lines, "")
      table.insert(lines, "-- Indexes")
      table.insert(lines, "INDEX_NAME | TYPE | UNIQUE | COLUMNS")
      table.insert(lines, string.rep("-", 60))
      for _, row in ipairs(idx_rows) do
        table.insert(lines, table.concat(row, " | "))
      end
    end

    return lines, "sql"
  elseif kind == "views" then
    -- Full view definition
    sql = string.format([[SELECT OBJECT_DEFINITION(OBJECT_ID(N'%s')) AS Definition;]], fullname)
    local rows = vim.fn["db_ui#query"](sql)
    if not rows or #rows == 0 then
      vim.notify("Cannot fetch definition for view " .. fullname, vim.log.levels.WARN)
      return nil
    end
    for _, row in ipairs(rows) do
      for _, col in ipairs(row) do
        table.insert(lines, tostring(col or ""))
      end
    end
    return lines, "sql"
  else
    -- procedures/functions
    sql = string.format("EXEC sp_helptext '%s';", fullname)
    local rows = vim.fn["db_ui#query"](sql)
    if not rows or #rows == 0 then
      vim.notify("Cannot fetch definition for " .. fullname, vim.log.levels.WARN)
      return nil
    end
    for _, row in ipairs(rows) do
      table.insert(lines, tostring(row[1] or "")) -- preserve empty lines
    end
    return lines, "sql"
  end
end

-- ---------------------------------------------------------------------
-- Telescope picker for SQL objects
-- ---------------------------------------------------------------------
local function pick_object(kind)
  local conn = require_buffer_db()
  if not conn then
    return
  end

  local list_sql = LIST_QUERIES[kind]
  if not list_sql then
    return
  end

  local rows = vim.fn["db_ui#query"](list_sql)
  if not rows or #rows == 0 then
    vim.notify("No objects found for " .. kind, vim.log.levels.WARN)
    return
  end

  local results = {}
  for _, row in ipairs(rows) do
    table.insert(results, row[1])
  end

  pickers
    .new({}, {
      prompt_title = "SQL " .. kind,
      finder = finders.new_table(results),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end
          local object_name = selection[1]

          local lines, ft = get_object_info(kind, object_name)
          if lines then
            open_buffer(lines, ft)
          end
        end)
        return true
      end,
    })
    :find()
end

-- ---------------------------------------------------------------------
-- Telescope picker to change current buffer's b:db
-- ---------------------------------------------------------------------
function M.change_db()
  local dbs = vim.g.dbs or {}
  local names = vim.tbl_keys(dbs)
  if #names == 0 then
    vim.notify("No databases found in vim.g.dbs", vim.log.levels.WARN)
    return
  end

  pickers
    .new({}, {
      prompt_title = "Select Database for this buffer",
      finder = finders.new_table(names),
      sorter = conf.generic_sorter({}),
      attach_mappings = function(prompt_bufnr)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
          local selection = action_state.get_selected_entry()
          if not selection then
            return
          end

          local dbname = selection[1]
          local conn = vim.g.dbs[dbname]
          if not conn then
            vim.notify("Unknown database: " .. dbname, vim.log.levels.ERROR)
            return
          end

          vim.b.db = conn
          vim.notify("Database for current buffer set to: " .. dbname, vim.log.levels.INFO)
        end)
        return true
      end,
    })
    :find()
end

-- ---------------------------------------------------------------------
-- Public API
-- ---------------------------------------------------------------------
function M.tables()
  pick_object("tables")
end
function M.views()
  pick_object("views")
end
function M.procedures()
  pick_object("procedures")
end
function M.functions()
  pick_object("functions")
end

return M
