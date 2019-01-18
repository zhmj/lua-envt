--lua5.1
module(..., package.seeall)

--lua5.3
--local modname = ...
--local M = {}
--_G[modname] = M
--
--package.loaded[modname] = M  --return modname的功能
--setmetatable(M,{__index=_G})
--_ENV[modname] = M --以前版本setfenv(1,M)

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

--[
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

	print(year, month, day, hour, min, sec)
	print(year .. '年' .. month .. '月' .. day .. '日' .. hour .. '时' .. min .. '分' .. sec .. '秒')

	local st = os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}

	return st
end


--秒数转字符串
function date(time)

	return os.date("%Y-%m-%d %H:%M:%S", time)
end


function serialize(t)

	local mark = {}
	local assign = {}

	local function ser_table(tbl, parent)
		mark[tbl] = parent
		local tmp = {}
		for k,v in pairs(tbl) do
			local key = type(k) == "number" and "["..k.."]" or "[\""..k.."\"]"
			local vtype = type(v)
			if vtype == "table" then
				local dotkey= parent .. (type(k) == "number" and key or "." .. key)
				if mark[v] then
					table.insert(assign, dotkey .. "=" .. mark[v])
				else
					table.insert(tmp, key .. "=" .. ser_table(v, dotkey))
				end
				else
				local tv = v
				if vtype == "string" then
					local s = string.gsub(tv, "\\", "\\\\")
					s = string.gsub(s, "\r", "\\r")
					s = string.gsub(s, "\n", "\\n")
					s = string.gsub(s, "\t", "\\t")
					s = string.gsub(s, "\"", "\\\"")
					tv = string.format("\"%s\"", s)
				end

				table.insert(tmp, key .. "=" .. tv)
			end
		end
		return "{" .. table.concat(tmp, ",") .. "}"
	end

	return "local ret=" .. ser_table(t," ret") .. table.concat(assign," ") .. " return ret"
end

function deserialize(str)
	return loadstring(str)()
end


function reg_encode(str)
	if not str then
		return
	end

	local s = string.gsub(str, "\\", "\\\\")
	s = string.gsub(s, "\r", "\\r")
	s = string.gsub(s, "\n", "\\n")
	s = string.gsub(s, "\t", "\\t")
	s = string.gsub(s, "\"", "\\\"")
	return s
end

function reg_decode(str)
	if not str then
		return
	end
	str = string.gsub(str, "\\\\", "\\")
	str = string.gsub(str, "\\r", "\r")
	str = string.gsub(str, "\\n", "\n")
	str = string.gsub(str, "\\t", "\t")
	str = string.gsub(str, "\\\"", "\"")
	return str
end


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

function check_chinese(str)
	local chinese = ""

	for c in string.gmatch(str, "[\\0-\127\194-\244][\128-\191]*") do
		if #c ~= 1 then
			--print('===', c)
			chinese = chinese .. c
		end
	end

	return chinese
end

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

--show_table(split('135,999,888,777', ','))
--]]

