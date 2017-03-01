--todo:注册失败删除所有的相关的已经写入的key
local debug = require "dbg_helper"
local redis = require "comm.redis"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
local data = ngx.req.get_body_data()
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",data)
local data = encrypt.encrypt(data,mykey)
local register_data = json.decode(data);

--debug.printArgs(register_data)

local redis_acc_key = string.format("acc:%s",register_data.strAccount)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!redis-key!!!!!!!!!!!!!!!!:",redis_acc_key)


local t = {"strMedNumber","strType","strConfirmPassword","strEMail","strFirstName","strGender","strPassWord","strHospital","strLastName"}
local redis_keys = {}
for _,v in pairs (t) do
	local key = string.format("%s:%s",redis_acc_key,v)
	assert (not redis_keys[key])
	redis_keys[key] = register_data[v] ;
end

local red = redis:new() ;
local ok,error = red:get(redis_acc_key)

if not ok and not error then 
	red:set(redis_acc_key,1)
	for k,v in pairs (redis_keys) do 
		local ok,error = red:get(k)
		if error then 
			return ngx.say(encrypt.encrypt("REG_UNKNOW_ERROR2",mykey))
		end

		if ok then 
			return ngx.say(encrypt.encrypt("REG_UNKNOW_ERROR3",mykey))
		end
		--ngx.log(ngx.INFO, "@@@@@@@@@@@@@@@@redis-key!!!!!!!!!!!!!!!!",k)
		--ngx.log(ngx.INFO, "$$$$$$$$$$$$$$$$redis-key!!!!!!!!!!!!!!!!",v)
		red:set(k,v)
	end
	--add doctor information to redis set
	if register_data.strType == "Doctor" then
		local ok,error = red:sadd ("all:doctor:acc",register_data.strAccount)
		--ngx.log(ngx.INFO, "##################################set result",ok,error)
		if not ok or err then
			return ngx.say(encrypt.encrypt("REG_UNKNOW_ERROR3",mykey))
		end
	end
	return ngx.say(encrypt.encrypt("REG_SUCESS",mykey))
elseif tonumber(ok) == 1 and not error then
	return ngx.say(encrypt.encrypt("REG_FAILED_ALREADY_REGISTED",mykey))
else
	return ngx.say(encrypt.encrypt("REG_UNKNOW_ERROR",mykey))
end

