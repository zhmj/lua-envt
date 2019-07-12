--lua5.1
--module(..., package.seeall)

--lua5.3
local modname = ...
local M = {}
_G[modname] = M

package.loaded[modname] = M  --return modname的功能
setmetatable(M,{__index=_G})
_ENV[modname] = M --以前版本setfenv(1,M)

local print = print
local type = type
local tostring = tostring
local pairs = pairs
local ipairs = ipairs
local math = math
local table = table
local string = string

--打印表的内容
function dump_obj(obj, key, sp, lv, st)
    sp = sp or ' '
 
    if type(obj) ~= 'table' then
        return sp ..  (key or '') .. ' = ' .. tostring(obj) .. '\n'
    end
 
    local ks, vs, s = { mxl = 0 }, {}
    lv, st = lv or 1, st or {}
 
    st[obj] = key or '.'
    key = key or ''
    for k, v in pairs(obj) do
        if type(v) == 'table' then
            if st[v] then
                table.insert(vs,'[' .. st[v] .. ']')
                s = sp:rep(lv) .. tostring(k)
                table.insert(ks, s)
                ks.mxl = math.max(#s, ks.mxl)
            else
                st[v] = key .. '.' .. k
                table.insert(vs, dump_obj(v, st[v], sp, lv + 1, st))

                --mj
				if type(k) == 'number' then
					k = '[' .. tostring(k) .. ']'
				end

                s = sp:rep(lv) .. tostring(k)
                table.insert(ks, s)
                ks.mxl = math.max(#s, ks.mxl)
            end
        else
            if type(v) == 'string' then
                table.insert(vs, (('%q'):format(v):gsub('\\\10','\\n'):gsub('\\r\\n', '\\n')))
            else
                table.insert(vs, tostring(v))
            end
		
			--mj
			if type(k) == 'number' then
				k = '[' .. k .. ']'
			end

            s = sp:rep(lv) .. tostring(k)
            table.insert(ks, s)
            ks.mxl = math.max(#s, ks.mxl);
        end
    end
 
    s = ks.mxl
    for i, v in ipairs(ks) do
		--mj
        vs[i] = v .. (' '):rep(s - #v) .. ' = ' .. vs[i] .. ',' .. '\n'

        --vs[i] = v .. (' '):rep(s - #v) .. ' = ' .. vs[i] .. '\n'
    end
 
    return '{\n' .. table.concat(vs) .. sp:rep(lv - 1) .. '}'
end

function show_table(t)
    if type(t) ~= "table" then
        return error("object is not a table, the type is " .. type(t) .. " value is " .. tostring(t))
    else
        return print("----------table content----------\n" .. dump_obj(t, "base") .. "\n")
    end 
end

--把数字一定间隔以逗号隔开
function join_delimiter(number, interval, delimiter)
	local val, str = interval, tostring(number)
	local len = string.len(str)

	if val == 0 then
		return str .. delimiter
	elseif val == len then
		return delimiter .. str
	elseif val > len then
		return '间隔数不能大于数字总长度'
	elseif val < 0 then
		return '间隔数不能小于零'
	end

	if len % val ~= 0 then
		n = math.floor(len / val) + 1
	else
		n = len / val
	end

	local src = {}
	for i = 1, len, val do
		local s1 = -i
		local s2 = -(i + val - 1)
		local s3 = string.sub(str, s2, s1)
		table.insert(src, s3)
	end

	local dest = {}
	for i = -n, 0 do
		table.insert(dest, src[-i])
	end

	return table.concat(dest, delimiter)
end

--秒数转换成几天几时几分几秒
function d_h_m_s(time)
	local days = math.floor(time / 86400)
	local d = time % 86400

	local hours = math.floor(d / 3600)
	local h = d % 3600

	local minutes = math.floor(h / 60)
	local m = h % 60
	
	local s = m % 60
	local seconds = math.floor(s)
	
	--local days = math.floor(time / 86400)
	--local hours = math.floor((time % 86400) / 3600)
	--local minutes = math.floor(((time % 86400) % 3600) / 60)
	--local seconds = math.floor((((time % 86400) % 3600) % 60))

	return days .. '天, ' .. hours .. '时, ' .. minutes .. '分, ' .. seconds .. '秒'
end

--字符串转秒数
function time(date)
	local len = #date

	local year = string.sub(date, 1, 4)
	local month = string.sub(date, 6, 7)
	local day = string.sub(date, 9, 10)

	local hour = len == 10 and 0 or string.sub(date, 12, 13)
	local min = len == 10 and 0 or string.sub(date, 15, 16)
	local sec = len == 10 and 0 or string.sub(date, 18, 19)
	--print(year, month, day, hour, min, sec)
	--print(year .. '年' .. month .. '月' .. day .. '日' .. hour .. '时' .. min .. '分' .. sec .. '秒')

	local st = os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}

	return st
end

--秒数转字符串
function date(time)
	return os.date("%Y-%m-%d %H:%M:%S", time)
end

--获取字符串长度
function utfstrlen(str)
	local len = #str
	local left = len
	local count = 0
	local arr = {0,0xc0,0xe0,0xf0,0xf8,0xfc}

	while left ~= 0 do
		local tmp = string.byte(str, -left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		count = count + 1
	end
	return count
end

--查找中文字符
function check_chinese(str)
	local chinese = ""

	for c in string.gmatch(str, "[\\0-\127\194-\244][\128-\191]*") do
		if #c ~= 1 then
			chinese = chinese .. c
		end
	end

	return chinese
end

--以指定字符分割字符串
function split(str, delimiter)
	if str == nil or str == '' or delimiter == nil then
		return nil
	end

	local result = {}
	for match in (str..delimiter):gmatch("(.-)"..delimiter) do
		table.insert(result, match)
	end

	return result
end

--lang:语言
--num:被格式化数字
--precision:精度，保留小数点后precision位
function get_number_expr(lang, num, precision)
    if precision < 0 then
        return num
    end

    if num < 1000 then
        return num
    end

	local n = 1000
	local unit = "K"

	if lang == "hi" then
		--1L表示10万，1Cr表示1千万
		if num >= 10000000 then
			n = 10000000
			unit = "Cr"
		elseif num >= 100000 then
			n = 100000
			unit = "L"
		end

	elseif lang == "zh" then
		if num >= 100000000 then
			n = 100000000
			unit = "亿"
		elseif num >= 10000 then
			n = 10000
			unit = "万"
		else
			return num
		end

	elseif lang == "zh_hk" then
		if num >= 100000000 then
			n = 100000000
			unit = "億"
		elseif num >= 10000 then
			n = 10000
			unit = "萬"
		else
			return num
		end

	else
		--k=10的3次方 千
		--m=10的6次方 百万
		--b=10的9次方 十亿
		--t=10的12次方 万亿
		if num >= 1000000000 then
			n = 1000000000
			unit = "B"
		elseif num >= 1000000 then
			n = 1000000
			unit = "M"
		end
	end

    local main = math.floor(num / n)
    if precision == 0 or main * n == num then
        return main .. unit
    end

    local mod = math.floor((num - main * n) / (n * math.pow(0.1, precision)))
    return main .. "." .. mod .. unit
end

--当前时间超过ts_day号则返回当月一号之后的时间
--当前时间未超过ts_day号则返回上个月一号之后的时间
function get_ts_time(ts_day, s_t, e_t)
    local now = os.time()
    local t = os.date("*t", now)

    local month_number = tonumber(os.date("%m", now))
    local day_number = tonumber(os.date("%d", now))
    local hour_number = tonumber(os.date("%H", now))
    print("day_number", ts_day, date(s_t), date(e_t), month_number, day_number, hour_number)

    if day_number > ts_day or (day_number == ts_day and hour_number >= 12) then
        t.day = 1
        t.hour = 12
        t.min = 0
        t.sec = 0
        local check_start_time = os.time(t)
        if s_t < check_start_time then
            s_t = check_start_time
        end

    else
        local prev_month = month_number - 1
        if prev_month == 0 then
            local year_number = tonumber(os.date("%Y", now))
            local prev_year = year_number - 1
            t.year = prev_year
            prev_month = 12
        end

        t.month = prev_month
        t.day = 1
        t.hour = 12
        t.min = 0
        t.sec = 0

        local check_start_time = os.time(t)
        if s_t < check_start_time then
            s_t = check_start_time
        end
    end

    print("最终时间", date(s_t), date(e_t))

    return s_t, e_t
end

--随机包含大写字母及数字的字符串
function random_string_number1(len)
    local temp = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local max_len = string.len(temp)

    local str = {}
    for i = 1, len do
        local index = math.random(1, max_len)
        str[i] = string.sub(temp, index, index)
    end

    return table.concat(str, "")
end

function random_string_number2(n_len, s_len)
    local temp_num = "0123456789"
    local temp_str = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    local max_n_len = string.len(temp_num)
    local max_s_len = string.len(temp_str)

    local str = {}
    for i = 1, n_len do
        local index = math.random(1, max_n_len)
        str[i] = string.sub(temp_num, index, index)
        --print(i, str[i])
    end

    for i = n_len + 1, n_len + s_len do
        local index = math.random(1, max_s_len)
        str[i] = string.sub(temp_str, index, index)
        --print(i, str[i])
    end

    local res = {}
    local str_size = #str
    for i = 1, str_size do
        local s = table.remove(str, math.random(1, str_size))
        str_size = str_size - 1
        --print("s:", s)
        table.insert(res, s)
    end

    return table.concat(res, "")
end

function random_string_number3()
    local str = ""
    for i = 1, 4 do
        local temp_str = string.char(math.random(65, 90))
        str = str .. temp_str
    end

    local temp_num = math.random(100, 999)

    str = str .. temp_num

    return str
end

--从table中随机取出n个元素
function random_table(t, num)
    for i, v in pairs(t) do
        local r = math.random(#t)
        local temp = t[i]
        t[i] = t[r]
        t[r] = temp
    end

    num = num or #t

    for i = #t, num + 1, -1 do
        t[i] = nil
    end

    return t
end

--从map中随机取出n个元素
function random_map(map, num)
    local t = {}
    for k, v in pairs(map) do
        table.insert(t, k)
    end

    local list = {}
    local t_size = #t
    local num = t_size > num and num or t_size
    for i = 1, num do
        local a = table.remove(t, math.random(1, t_size))
        t_size = t_size - 1
        table.insert(list, a)
    end

    return list
end

--分批取出大表中的元素
function batches_table(data, count)
    local list = {}

    if #data > count then
        local temp = {}
        for i = 1, count do
            local aa = table.remove(data, i)
            table.insert(temp, aa)
        end
        table.insert(list, temp)

        local l = batches_table(data, count)
        table.insert(l, temp)
        return l

    else
        table.insert(list, data)
        return list
    end

    return list
end

