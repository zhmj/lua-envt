package.path = package.path .. ';/eason/lua_test/?.lua;luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local cjson = require("cjson")
local cjson_map = cjson:new()
cjson_map.encode_sparse_array(true, 1, 1)

local time = require("time")
local mj = require("mj")

local redis_client = require("redis")

local redis_host = '127.0.0.1'
local redis_port = 6479

local redis = redis_client.connect(redis_host, redis_port)
redis:auth("mbyd007")

local response = redis:ping()
if not response then
	print("redis连接失败", response)
end

--筛选指定模式keys，不会阻塞
function scan_keys(start_id, params)
	local data = {}

	local params = params or {}

	local keys = redis:scan(start_id, params)
	local offset_id = tonumber(keys[1])
	local ks = keys[2]
	for i = 1, #ks do
		local k = ks[i]
		data[k] = true
		--print(offset_id, #ks, k)
	end

	if offset_id == 0 then
		return keys_table, data
	else
		local kt, d = scan_keys(offset_id, params)
		for k, v in pairs(d) do
			if not data[k] then
				data[k] = true
			end
		end
	end

	local keys_table = {}
	for k, v in pairs(data) do
		table.insert(keys_table, k)
	end

	return keys_table, data
end

--筛选指定模式keys，数据量大时会阻塞
function get_keys(pattern)
	local keys = redis:keys(pattern)

	return keys
end

local params = {}
params.match = "word_infos:*"
params.count = 1000
local keys_table = scan_keys(0, params)
--mj.show_table(keys_table)

local g_keys = get_keys(params.match)
--mj.show_table(g_keys)

print(#keys_table, #g_keys)


function sscan_keys(key, start_id, params)
	local data = {}

	local params = params or {}

	local keys = redis:sscan(key, start_id, params)
	local offset_id = tonumber(keys[1])
	local ks = keys[2]
	for i = 1, #ks do
		local k = ks[i]
		data[k] = true
		--print(offset_id, #ks, k)
	end

	if offset_id == 0 then
		if start_id == 0 then
			return ks, data
		else
			return keys_table, data
		end
	else
		local kt, d = sscan_keys(key, offset_id, params)
		for k, v in pairs(d) do
			if not data[k] then
				data[k] = true
			end
		end
	end

	local keys_table = {}
	for k, v in pairs(data) do
		table.insert(keys_table, k)
	end

	return keys_table, data
end
local sparams = {}
--sparams.match = "*"
sparams.count = 1000

--local ids_key = "sex1"
local ids_key = "words_list"
local ids_table = sscan_keys(ids_key, 0, sparams)

local ids = redis:smembers(ids_key)
print(#ids_table, #ids)
