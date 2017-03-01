local api = {}

local redis = require "comm.redis"

function api.check_cookies (cookies)
	_,_,acc,cookies=string.find (ngx.var.http_cookie,"name=%s*(.+),value=%s*(.+)")
	ngx.log(ngx.INFO,"!!!!!!!!!cookies-name!!!!!!!!!!!!!!!!!",acc)
	ngx.log(ngx.INFO,"!!!!!!!!!cookies-value!!!!!!!!!!!!!!!!!",cookies)

	local redis_acc_key = string.format ("acc:%s",acc)
	local redis_cookies_key = string.format("%s:cookies",redis_acc_key)

	local red = redis:new() ;
	--todo:更细致的检测
	local ok,error = red:get(redis_cookies_key)
	if ok == cookies then 
		return true
	else
		return false
	end
end

return api
