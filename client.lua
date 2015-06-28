local host, port = "localhost", 7098
local socket = require("socket")

local filename = arg[1]

local f = assert(io.open(filename, "r"))
local t = f:read("*all")
f:close()

local io = t

--note the newline below
-- while true do
	local tcp = assert(socket.tcp())
	tcp:connect(host, port)
	tcp:send(io.."\n")
	tcp:send("stop\n")
	tcp:close()
-- end/