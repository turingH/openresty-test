local api = {}
local bit = require("bit")
 
--- 使用密钥对字符串进行加密(解密)
----
---- @param string str 原始字符串(加密后的密文)
---- @param string key 密钥
---- @return string 加密后的密文(原始字符串)
function api.encrypt(str, mykey)
	local strBytes = { str:byte(1, #str) }
	local n, keyLen = 1, #mykey

	for i = 2, #strBytes do
		strBytes[i] = bit.bxor(strBytes[i], mykey[n])

		n = n + 1

		if n > keyLen then
			n = n - keyLen
		end
	end

	return string.char(unpack(strBytes))
end

return api
