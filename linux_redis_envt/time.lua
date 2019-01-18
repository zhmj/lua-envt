--lua5.1
--module("time", package.seeall)

--lua5.3
local modname = ...
local M = {}
_G[modname] = M

package.loaded[modname] = M  --return modname的功能
setmetatable(M,{__index=_G})
_ENV[modname] = M --以前版本setfenv(1,M)

local month_days = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31}

--秒数转字符串
function date(time, short)

	return short and os.date("%Y-%m-%d", time) or os.date("%Y-%m-%d %H:%M:%S", time)
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

	local st = os.time{year = year, month = month, day = day, hour = hour, min = min, sec = sec}

	return st
end

--返回当天的0点秒数
function begin(time)

	local target_tab = os.date("*t", time)
	target_tab.hour = 0
	target_tab.min = 0
	target_tab.sec = 0
	return os.time(target_tab)
end

--返回今天的0点秒数
function today()

	return begin(os.time())
end

--返回count周前的周wday
function week_before(time, wday, count, inc)

	local time_tab = os.date("*t",time)
	local time_wday = time_tab.wday
	time_wday = time_wday == 1 and 7 or time_wday - 1

	count = (wday < time_wday or (wday == time_wday and inc))  and count - 1 or count

	local diff = (wday - time_wday) - count * 7
	return time + diff * 86400
end

--返回count周后的周wday
function week_after(time, wday, count, inc)

	local time_tab = os.date("*t",time)
	local time_wday = time_tab.wday
	time_wday = time_wday == 1 and 7 or time_wday - 1

	count = (wday < time_wday or (wday == time_wday and not inc)) and count or count - 1

	local diff = (wday - time_wday) + count * 7
	return time + diff * 86400
end

--返回今天的0点字符串
function today_string()

	return date(begin(os.time()))
end

--比较两个秒数是否属于同一天
function is_same_day(time1, time2)
	
	local t1 = os.date("*t", time1)
	local t2 = os.date("*t", time2)

	return t1.day == t2.day and t1.month == t2.month and t1.year == t2.year
end

--比较两个时间字符串是否属于同一天
function is_same_day_string(date1, date2)

	local d1 = string.sub(date1, 1, 10)
	local d2 = string.sub(date2, 1, 10)

	return d1 == d2
end

--闰年
function is_leap_year(year)

	return (year % 4 == 0 and year % 100 ~= 0) or year % 400 == 0
end

--月份天数
function get_month_day(year, month)

	return (month ~= 2 or not is_leap_year(year)) and month_days[month] or month_days[month] + 1
end

--增加天数
function add_days(time, days)

	return time + days * 86400
end

--增加小时
function add_hours(time, hours)

	return time + hour * 3600
end

--增加分钟
function add_minutes(time, mins)

	return time + mins * 60
end

--增加秒数
function add_seconds(time, secs)

	return time + secs
end
