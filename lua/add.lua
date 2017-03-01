local args = ngx.req.get_uri_args()
ngx.log(ngx.ERR, "!!!!!!!!!!!!!!!args:!!!!!!!!!!!!!!!!!!", args.a, args.b)
ngx.log(ngx.INFO, "#####################args:#################", args.a, args.b)
ngx.say(args.a+args.b)
