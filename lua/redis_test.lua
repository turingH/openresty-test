local redis = require "comm.redis"
local red = redis:new()

local ok, err = red:set("dog", "an animal")
if not ok then
	ngx.say("failed to set dog: ", err)
	return
end

ngx.say("set result: ", ok)
