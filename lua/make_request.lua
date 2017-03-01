local debug = require "dbg_helper"
local redis = require "comm.redis"
local check = require "access_check"
local encrypt = require "comm.encrypt"
local json = require("cjson")
local mykey = {1,9,8,9,1,0,2,6}

ngx.req.read_body() -- 解析 body 参数之前一定要先读取 body

local data = ngx.req.get_body_data()
local data = encrypt.encrypt(data,mykey)

ngx.log(ngx.INFO, "\n--------------[json]: read data from http request------------------\n",data)

local request_info = json.decode(data);
-- init picture history table
request_info.history_left = {}
table.insert (request_info.history_left,{uid = request_info.uidl,timetag = os.time()})
request_info.history_right = {}
table.insert (request_info.history_right,{uid = request_info.uidr,timetag =os.time()})

request_info.is_solved = false 
request_info.request_timetag = os.time();


-- save request info
local red = redis:new() 
local uid = red:incr ("request:uid")
local request_key = "request:"..tostring(uid)

local doctor_acc = request_info.doctor
local _,_,patient_acc,_ =  string.find (ngx.var.http_cookie,"name=%s*(.+),value=%s*(.+)")
request_info.patient = patient_acc
data = json.encode(request_info)

ngx.log(ngx.INFO, "\n------------[json]: save data to redis------------------\n",data)
local ok,err = red:set (request_key,data)


-- save data to doctor and patient
ngx.log(ngx.INFO,"\n------------[string]: doctor acc in the request ------------------\n",doctor_acc)
ngx.log(ngx.INFO,"\n------------[string]: patient acc in the request ------------------\n",patient_acc)
local doctor_request_key = string.format ("acc:%s:requests",doctor_acc);
local patient_request_key = string.format ("acc:%s:requests",patient_acc);
local ok,error = red:sadd (doctor_request_key,request_key);
local ok,error = red:sadd (patient_request_key,request_key);

ngx.say("MAKE_REQUEST_SUCESS")
