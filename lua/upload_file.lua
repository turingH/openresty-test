local debug = require "dbg_helper"
local json = require "cjson"
local redis = require "comm.redis"
local red = redis:new() ;
ngx.log(ngx.INFO, "Enter upload_file")


local function getFile(file_name)
	local f = assert(io.open(file_name, 'r'))
	local string = f:read("*all")
	f:close()
	return string
end

--for k,v in pairs(arg) do
--	ngx.say("[GET ] key:", k, " v:", v)
--end
local arg = ngx.req.get_uri_args()
debug.printArgs(arg)
local headers = ngx.req.get_headers()  
--debug.printArgs(headers)


ngx.log(ngx.INFO, "start ReadBody")
ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
ngx.log(ngx.INFO, "finish ReadBody")

local data = ngx.req.get_body_data()
if nil == data then
	local file_name = ngx.req.get_body_file()
	ngx.log(ngx.INFO,">> temp file: ", file_name)
	if file_name then
		data = getFile(file_name)
	end
end

local data_index,err = red:incr("upload:data:uid")
local ok,err = red:set ("upload:data:"..tostring(data_index),data)
local result = {}
result.result="UPLOAD_SUCESS"
result.uid = tostring(data_index) 

ngx.say(json.encode(result))

