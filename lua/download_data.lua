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
local request_info = json.decode(data);

debug.printArgs(request_info)

local red = redis:new()
local download_data = red:get(request_info.key)
ngx.say(download_data)

