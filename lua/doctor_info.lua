local debug = require "dbg_helper"
local redis = require "comm.redis"
local check = require "access_check"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body

local data = ngx.req.get_body_data()
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!data!!!!!!!!!!!!!!!!:",data)
local data = encrypt.encrypt(data,mykey)
local doctor_info = json.decode(data);

--debug.printArgs(doctor_info)

local acc = doctor_info.account

local keys = {"strType","strGender","strEmail","strLastName","strHospital","strFirstName","strLastName"}
local red = redis:new() 
local result = {}

result.strAccount = acc;

for _,_key in pairs (keys) do
	local key = string.format ("acc:%s:%s",acc,_key)
	local value,err = red:get (key)
	result[_key]=value
end

ngx.say (json.encode(result))
