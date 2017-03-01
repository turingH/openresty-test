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
local request_info = json.decode(data);
debug.printArgs(request_info)

local red = redis:new()
local request_info_json = red:get(request_info.request)
ngx.log(ngx.INFO, "!!!!!!!!!!!!!!request_info_json!!!!!!!!!!!!!!!!:",request_info_json)
local request_info_table = json.decode(request_info_json)
--debug.printArgs(request_info_table)
request_info_table.result="REQUEST_INFO_SUCESS"
ngx.say(json.encode(request_info_table))
