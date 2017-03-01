local debug = require "dbg_helper"
local redis = require "comm.redis"
local check = require "access_check"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body

local data = ngx.req.get_body_data()

local _,_,acc,_ =  string.find (ngx.var.http_cookie,"name=%s*(.+),value=%s*(.+)")
debug.printArgs(request_info)

local key = string.format("acc:%s:requests",acc)
local red = redis:new()
local data = red:smembers(key)
ngx.say(json.encode(data))

