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


local red = redis:new()
local request_info_json = red:get(request_info.requestID)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!request_info_json!!!!!!!!!!!!!!!!:",request_info_json)

local request_info_table = json.decode(request_info_json)
request_info_table.comment = request_info_table.comment .. request_info.addComment .. "\n"
request_info_json = json.encode(request_info_table)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!request_info_json_2!!!!!!!!!!!!!!!!:",request_info_json)
red:set (request_info.requestID,request_info_json)
ngx.say("UPDATE_SUCESS")
