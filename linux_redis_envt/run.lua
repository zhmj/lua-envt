package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local cjson = require("cjson")
local time = require('time')
local mj = require('mj')

local luasql = require("luasql.mysql")
local redis = require("redis")

--redis
local redis_host = "127.0.0.1"
local redis_port = 6379
local redis_pwd = "mbyd007"

local redis = Redis.connect(redis_host, redis_port)
if redis_pwd and redis_pwd ~= '' then
    redis:auth(redis_pwd)
end

local response = redis:ping()
print("response", response)

local r = redis:keys("*")
mj.show_table(r)


redis:quit()


--mysql
local host = "127.0.0.1"
local port = 3306
local dbname = "mj"
local user = "root"
local pwd = "root"

local env = luasql.mysql()
local conn = env:connect(dbname, user, pwd, host, port)
conn:execute("set names utf8mb4")

local sql = "select * from user"
local cur = conn:execute(sql)

local data = {}
local row = cur:fetch({}, "a")
while row do
	data[row.id] = row
	row = cur:fetch({}, "a")
end
mj.show_table(data)

conn:close()
env:close()


--json
function read_json_file(filename)
	local file = io.open(filename, "r")
	local data = file:read("*a")
	local json = cjson.decode(data)
	file:close()

	return json
end

function write_json_file(data, filename)
	local json = cjson.encode(data)
	local file = io.open(filename, "w")
	file:write(json)
	file:flush()
	file:close()
end

local data = read_json_file("data.json")
mj.show_table(data)

local t_time = time.time("2019-01-12 00:00:00")
local t_date = time.date(1547222400)
print("time", t_time, t_date)

