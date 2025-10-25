local icons = {
  diagnostics = {
    Error = "",
    Warn  = "",
    Info  = "",
    Hint  = "",
  },
  dap = {
      Stopped = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint = { " ", "DapBreakpoint", "" },
      BreakpointCondition = { " ", "DapBreakpointCondition", "" },
      BreakpointRejected  = { " ", "DapBreakpointRejected", "" },
      LogPoint = { ".>", "DapLogPoint", "" },
  },
  git = {
    added    = "",
    modified = "",
    removed  = "",
  },
  kinds = {
    Class       = "",
    Function    = "󰊕",
    Variable    = "󰀫",
    Interface   = "",
    Module      = "",
    Snippet     = "󱄽",
    Text        = "",
    Property    = "",
  },
  misc = {
    dots = "󰇘",
  },
  ft = {
    lua   = "",
    python= "",
    cs    = "󰛬",
  },
}

return icons
