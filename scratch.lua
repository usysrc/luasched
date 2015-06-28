


seconds = 44100


measure = function(time)
	print("lag:", now() - time, now(), time)
	
	callback(time+seconds, measure, {time+seconds})
end

measure(now())





count = function(i)
	print("counting", i)
	callback(now()+seconds, count, {i+1})
end

count(1)

print("hello world")