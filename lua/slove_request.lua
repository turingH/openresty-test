local debug = require "dbg_helper"
local redis = require "comm.redis"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.log(ngx.INFO, "\n------------------------slove request start--------------------\n")

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body
local data = ngx.req.get_body_data()
local data = encrypt.encrypt(data,mykey)
ngx.log(ngx.INFO, "\n------------------------[slove_request]--------------------\n",data)
local request_info = json.decode(data);

local red = redis:new() 

local doctor_acc = request_info.doctor
local patient_acc = request_info.patient
local request_key = request_info.requestID

local doctor_sloved_request_key = string.format ("acc:%s:sloved_requests",doctor_acc);
local patient_sloved_request_key = string.format ("acc:%s:sloved_requests",patient_acc);

local doctor_request_key = string.format ("acc:%s:requests",doctor_acc);
local patient_request_key = string.format ("acc:%s:requests",patient_acc);

ngx.log(ngx.INFO, "\n------------------------[slove_request]:keys--------------------\n",doctor_sloved_request_key)
ngx.log(ngx.INFO, "\n------------------------[slove_request]:keys--------------------\n",patient_sloved_request_key)
ngx.log(ngx.INFO, "\n------------------------[slove_request]:keys--------------------\n",doctor_request_key)
ngx.log(ngx.INFO, "\n------------------------[slove_request]:keys--------------------\n",patient_request_key)

--remove from acc:*:requests
ngx.log(ngx.INFO, "\n------------------------[slove_request]:result--------------------\n"..doctor_request_key.."\n"..request_key)
local ok,error = red:srem (doctor_request_key,request_key)
ngx.log(ngx.INFO, "\n------------------------[slove_request]:result--------------------\n",ok,error)
local ok,error = red:srem (patient_request_key,request_key)
ngx.log(ngx.INFO, "\n------------------------[slove_request]:result--------------------\n",ok,error)

--add to acc:*:sloved_requests
local ok,error = red:sadd (doctor_sloved_request_key,request_key);
ngx.log(ngx.INFO, "\n------------------------[slove_request]:result--------------------\n",ok,error)
local ok,error = red:sadd (patient_sloved_request_key,request_key); 
ngx.log(ngx.INFO, "\n------------------------[slove_request]:result--------------------\n",ok,error)

ngx.say("SLOVE_REQUEST_SUCESS")
