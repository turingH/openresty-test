local debug = require "dbg_helper"
local redis = require "comm.redis"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
local data = ngx.req.get_body_data()
local data = encrypt.encrypt(data,mykey)

ngx.log(ngx.INFO, "\n-----------update picture--------\n:",data)
local request_info = json.decode(data);
