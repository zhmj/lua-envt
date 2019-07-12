package.path = package.path .. ';luasocket/?.lua'
package.cpath = package.cpath .. ';luasocket/?.so'

local cjson = require("cjson")
local time = require('time')
local mj = require('mj')


print("\n====================================================================")
--把数字一定间隔以逗号隔开
local num = 123456789
local str = mj.join_delimiter(num, 3, ",")
print(num, str)


print("\n====================================================================")
--查找中文字符
local check_str = "123 了速度快九分8989裤零点数据 jjjjlskjflskdj"
local chinese = mj.check_chinese(check_str)
print(chinese)


print("\n====================================================================")
--以指定字符分割字符串
local s = "123 456 789 算了 jjkj"
local s_t = mj.split(s, " ")
mj.show_table(s_t)


print("\n====================================================================")
--local list = {8000000, 32000000, 1000000, 160000000, 6000000, 400000000, 18000000, 800000000, 40000000}
local list = {92000, 920000, 2760000, 9500000, 49000000, 100000000}
for i = 1, #list do
	local l = list[i]
	local n = get_number_expr("hi", l, 1)
	--local n = get_number_expr("zh", l, 1)
	print(l, n)
end


print("\n====================================================================")
local start_time = time.time("2018-06-09 12:00:00")
local end_time = time.time("2018-08-10 12:00:00")
mj.get_ts_time(10, start_time, end_time)


print("\n====================================================================")
--math.randomseed(os.time())
math.randomseed( tonumber(tostring(os.time()):reverse():sub(1,6)) )

local code1 = mj.random_string_number1(7)
print("code1: ", code1)

local code2 = mj.random_string_number2(3, 4)
print("code2: ", code2)

local code3 = mj.random_string_number3()
print("code3: ", code3)


print("\n====================================================================")
local t = {100001, 100002, 100003, 10004, 100005, 100006, 100007}
local tt = mj.random_table(t, 5)
print(table.concat(tt, ","))

local map = {
 [100221] = 1,
 [100222] = 1,
 [100223] = 1,
 [100224] = 1,
 [100225] = 1,
 [100226] = 1,
 [100227] = 1,
 [100228] = 1
}
local mm = mj.random_map(map, 3)
print(table.concat(mm, ","))


print("\n====================================================================")
local data = {}
for i = 1, 1000 do
	local acc = 100000 + i
	table.insert(data, acc)
end
print(#data)

local count = 0
local list = mj.batches_table(data, 100)
print(#list)
for i = 1, #list do
	local l = list[i]
	count = count + #l
	--print(i, #l, count, table.concat(l, ","))
	print(i, #l, count)
end 
print(count)


