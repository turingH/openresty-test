local debug = require "dbg_helper"
local redis = require "comm.redis"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}


ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body

local data = ngx.req.get_body_data()
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",data)
data = encrypt.encrypt(data,mykey)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",data)
local arg = json.decode(data);
debug.printArgs(arg)


local redis_acc_key = string.format("acc:%s",arg.Account) 
local redis_passwd_key = string.format("%s:strPassWord",redis_acc_key);
local redis_type_key = string.format("%s:strType",redis_acc_key);

local red = redis:new() ;

--检查账号是否存在
local ok,error = red:get(redis_acc_key)
if tonumber(ok) ~= 1 then 
	return ngx.say("LOGIN_FAILED_ACCOUNT_ERROR");
end
if error then 
	return ngx.say("LOGIN_FAILED_UNKNOWERROR1")
end

--检测密码是否正确
local ok,error = red:get(redis_passwd_key)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",ok)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",arg.Password)
if tostring(ok) ~= tostring(arg.Password) then 
	return ngx.say("LOGIN_FAILED_PASSWD_ERROR");
end
if error then 
	return ngx.say("LOGIN_FAILED_UNKNOWERROR2")
end

--检测账号类型是否正确
local ok,error = red:get(redis_type_key)
if tostring(ok) ~= tostring(arg.Type) then 
	return ngx.say("LOGIN_FAILED_TYPE_ERROR");
end
if error then 
	return ngx.say("LOGIN_FAILED_UNKNOWERROR3")
end

local resty_md5 = require "resty.md5"
local md5 = resty_md5:new()
if not md5 then
	ngx.say("FAILED_TO_CREATE_MD5_OBJECT")
	return
end

local ok = md5:update(redis_acc_key)
if not ok then
	ngx.say("FAILED_TO_ADD_DATA")
	return
end

ok = md5:update(tostring(os.time()))
if not ok then
	ngx.say("FAILED_TO_ADD_DATA")
	return
end

ok = md5:update("huangxudong")
if not ok then
	ngx.say("FAILED_TO_ADD_DATA")
	return
end

local digest = md5:final()

local str = require "resty.string"
local md_digest = str.to_hex(digest)



local cookie_value = ngx.var.cookie_Foo
ngx.header['Set-Cookie'] = string.format("name=%s,value=%s",arg.Account,md_digest)

ngx.say("LOGIN_SUCESS")


--todo:出错处理,这里默认成功
local redis_cookies_key = string.format("%s:cookies",redis_acc_key)
local ok,err = red:set(redis_cookies_key,md_digest)
ngx.log(ngx.INFO,"set cookies result",ok)
ngx.log(ngx.INFO,"set cookies result",err)














