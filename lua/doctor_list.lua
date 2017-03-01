local debug = require "dbg_helper"
local redis = require "comm.redis"
local check = require "access_check"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body

local red = redis:new() 
local ret_check_cookies = check.check_cookies(ngx.var.http_cookie)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!check_cookies!!!!!!!!!!!!!!!!:",ret_check_cookies)
local ok,err = red:smembers ("all:doctor:acc")

if type(ok) ~= "table" then 
	return ngx.say("DOCTOR_LIST_EMPTY")
end

if err then 
	return ngx.say("DOCTOR_LIST_ERROR")
end

debug.printArgs(ok)

local dl = {}
for _,acc in pairs (ok) do
	local d = {}
	d.account = acc
	local redis_acc_key = string.format("acc:%s",acc)
	ok,err = red:get (string.format("%s:strGender",redis_acc_key))
	assert (ok)
	assert (not err)
	d.gender = ok

	ngx.log(ngx.INFO, "!!!!!!!!!!!!!!d!!!!!!!!!!!!!!!!:",d.account)
	ngx.log(ngx.INFO, "!!!!!!!!!!!!!!d!!!!!!!!!!!!!!!!:",d.gender)
	table.insert (dl,d)
end

ngx.say (json.encode(dl))
