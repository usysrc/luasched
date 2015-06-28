--------------------------------------------------------------------------------
-- Server
--
-- 2015 Headchant, Tilmann Hars <headchant@headchant.com>
--
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- imports
--------------------------------------------------------------------------------
local PriorityQueue = require "PriorityQueue"
local socket   		= require("socket")
local copas    		= require("copas")
local server   		= assert(socket.bind("*", 7099))
local ip, port 		= server:getsockname()
local portaudio 	= require "portaudio"
portaudio.init()

local env = {
	print = print,
	require = require
}


local queue = {}

local function connection(skt)
	skt = copas.wrap(skt)
	skt:send(">>> ")
	local data = ""
	while true do
		local dat = skt:receive()
		if dat == "stop" then
			local d, e = load(data, nil, 't', env)
			if e then print(e) end
			queue[#queue+1] = function() return pcall(d) end
			data = ""
		elseif dat then
			data = data .. dat.."\n"
		end
	end
	
end

copas.addserver(server, connection)

--------------------------------------------------------------------------------
-- server loop
--------------------------------------------------------------------------------

local functions = {}
local t = 0
local now = function() return t + 1 end
local sample = 0

function out(s)
	sample = sample + s
end

env.out = out
env.math = math
env.queue = PriorityQueue()

env.callback = function(t, f, arguments)
	env.queue:put(t, function() f(unpack(arguments or {})) end)
end

env.now = now

local lib = require "lib"
setfenv(lib, env)
lib()


function run()
	t = t + 1
	while true do
		local time, task = env.queue:pop()
		if task then
			if time <= t then
				task()
			else
				env.queue:put(time, task)
				break
			end
		else
			break
		end
	end
end

while true do
	sample = 0
	copas.step(1/(44100*10))
	run()
	if #queue > 0 then
		for i,v in ipairs(queue) do
			local err = v()
			if err then print(err) end
		end
		queue = {}
	end
	portaudio.put_sample(sample)
end