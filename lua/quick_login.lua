local debug = require "dbg_helper"
local redis = require "comm.redis"

ngx.log(ngx.INFO,"!!!!!!!!!!quick!!!!!!!!!!!!!!!!!!!!!",ok)
ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
local headers = ngx.req.get_headers()  
--debug.printArgs(headers)
ngx.log(ngx.INFO,"!!!!!!!!!cookies!!!!!!!!!!!!!!!!!",ngx.var.http_cookie)
_,_,acc,cookies=string.find (ngx.var.http_cookie,"name=%s*(.+),value=%s*(.+)")
ngx.log(ngx.INFO,"!!!!!!!!!cookies-name!!!!!!!!!!!!!!!!!",acc)
ngx.log(ngx.INFO,"!!!!!!!!!cookies-value!!!!!!!!!!!!!!!!!",cookies)

local redis_acc_key = string.format ("acc:%s",acc)
local redis_cookies_key = string.format("%s:cookies",redis_acc_key)

local red = redis:new() ;

--todo:更细致的检测
local ok,error = red:get(redis_cookies_key)
if ok == cookies then 
	ngx.say("result=QUICK_LOGIN_SUCESS")
else
	ngx.say("result=QUICK_LOGIN_FAILED")
end
