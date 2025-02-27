local is_windows = system.IsWindows()
local is_linux = system.IsLinux()
local arch = jit.arch

module_filename = "gmsv_chttp_" .. ((is_windows and (arch == "x64" and "win64" or "win32")) or (is_linux and (arch == "x64" and "linux64" or "linux"))) .. ".dll"

require("reqwest")
require("chttp")


--[[
if CHTTP == nil then
	CHTTP = HTTP
else
	CHTTP = require("chttp")
end]]