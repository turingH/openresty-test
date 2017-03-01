local debug = require "dbg_helper"
local redis = require "comm.redis"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
local data = ngx.req.get_body_data()
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",data)
local data = encrypt.encrypt(data,mykey)
local request_info = json.decode(data);
debug.printArgs(request_info)


local result = {}
result.ret = "GET_USER_DATA_SUCESS"

local red = redis:new()

result.requests,_ = red:smembers (string.format("acc:%s:requests",request_info.account))

local ok,err = red:smembers ("all:doctor:acc")

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

result.doctors = dl



ngx.say(json.encode(result))
