rnd = function()
	return math.random()*2-1
end

play = function(t)
	local sinc = 200*t*2*math.pi/44100
	if math.sin(sinc) < math.sin((sinc)/(99)) then
		out(0.2)
	else
		out(-0.2)
	end
	-- callback(now(), function() play(t+1) end)
end

-- liftup

synth = function(f, t)
	local sinc = f*t*2*math.pi/44100
	if math.sin(sinc) < math.sin((sinc)/(94)) then
		out(0.2)
	else
		out(-0.2)
	end
end

for_do = function(func, t)
	func(now())
	if  t > 0 then
		callback(now(), function() for_do(func, t-1) end)
	end
end

second = 44100

synthie = function(f, t)
	for_do(function(t) synth(f, t) end, t* second)
end

play = function(t)
	synthie(200+(t%10)*9, 0.05)
	callback(now()+second*0.1, function() play(t+1) end)
end

play(1)

print("hello world")

second = 44100

local sound = function()
	ping()
end

metro(0.2*second, sound)