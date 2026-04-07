local function url_encode(str)
  if not str then
    return ""
  end
  str = tostring(str)
  str = str:gsub("([^%w%-._~])", function(c)
    return string.format("%%%02X", string.byte(c))
  end)
  return str
end

local user = "sa"
local pass = "#StrongPassword123"
local host = "localhost"
local port = "1433"
local default_db = "master"

local user_enc = url_encode(user)
local pass_enc = url_encode(pass)

-- SQL command to list all online databases
local master_conn = string.format(
  [[
sqlcmd -S %s,%s -U %s -P "%s" -d %s -h -1 -W -Q "SELECT name FROM sys.databases WHERE state_desc='ONLINE'" -C -N
]],
  host,
  port,
  user,
  pass,
  default_db
)

local dbs = {}
local handle = io.popen(master_conn)
if handle then
  for line in handle:lines() do
    line = line:gsub("^%s*(.-)%s*$", "%1") -- trim spaces
    if line ~= "" and not line:match("rows affected") and not line:match("Command%(s%) completed successfully") then
      local url =
        string.format("sqlserver://%s:%s@%s:%s/%s?trustServerCertificate=true", user_enc, pass_enc, host, port, line)
      dbs[line] = url
    end
  end
  handle:close()
end

vim.g.dbs = dbs
