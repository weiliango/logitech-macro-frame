----------------------------------------------------------------------------------------------------
--                                        使用者配置设置                                           --
--                                    User config settings                                        --
----------------------------------------------------------------------------------------------------

userConfig = {

}

























--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--                                                                                                --
--                                   >> Logitech Macro Frame <<                                   --
--                                                                                                --
--               Welcome to this script. If you have any questions, please visit:                 --
--                        https://github.com/kiccer/logitech-macro-frame                          --
--                    Please click [★ Star] to support my project, thank you.                    --
--                                                                                                --
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

----------------------------------------------------------------------------------------------------
--                                     Framework built-in code                                    --
----------------------------------------------------------------------------------------------------

-- console
console = {
	clear = ClearLog
}

function console.log (...)
	local arr = {...}
	for i = 1, #arr do logMsg(table.print(arr[i]) .. "\n") end
end

lmf = {
	debug = true,
	monitor = {}, -- 监听器列表
	_timers = {}, -- 定时器函数列表
	_for_protect_time = 20000, -- lmf.for 方法的循环保护，超过此毫秒数时间将强制结束循环，防止死循环卡死。
}

function lmf.isPressed (n)
	if type(n) == "number" then
		return IsMouseButtonPressed(n)
	elseif type(n) == "string" then
		return IsModifierPressed(n)
	else
		if lmf.debug then error("[lmf.isPressed] Wrong parameter data type: " .. tostring(n) .. " is not a \"number\" or \"string\".") end
	end
end

function lmf.setDpi (n, i)
	if type(n) == "table" then
		SetMouseDPITable(n, i)
	elseif type(n) == "number" then
		SetMouseDPITableIndex(n)
	else
		if lmf.debug then error("[lmf.setDpi] Wrong parameter data type: " .. tostring(n) .. " is not a \"table\" or \"number\".") end
	end
end

function lmf.addSpeed (n)
	if type(n) ~= "number" then
		if lmf.debug then error("[lmf.addSpeed] Wrong parameter data type: " .. tostring(n) .. " is not a \"number\".") end
	elseif n > 0 then
		IncrementMouseSpeed(n)
	elseif n < 0 then
		DecrementMouseSpeed(-n)
	end
end

-- 重命名 API，整合个别 API 功能
getM = GetMKeyState
setM = SetMKeyState
sleep = Sleep
logMsg = OutputLogMessage
lcdMsg = OutputLCDMessage
debugMsg = OutputDebugMessage
getTime = GetRunningTime
getDate = GetDate
keyDown = PressKey
keyUp = ReleaseKey
keyTap = PressAndReleaseKey
mouseDown = PressMouseButton
mouseUp = ReleaseMouseButton
mouseTap = PressAndReleaseMouseButton
move = MoveMouseRelative
moveTo = MoveMouseTo
moveToThis = MoveMouseToVirtual
wheel = MoveMouseWheel
getMouse = GetMousePosition
playMacro = PlayMacro
abortMacro = AbortMacro
setColor = SetBacklightColor
setSpeed = SetMouseSpeed
getSpeed = GetMouseSpeed
addSpeed = lmf.addSpeed
isLock = IsKeyLockOn
isPressed = lmf.isPressed
setDpi = lmf.setDpi

-- 重命名 OnEvent 的 event 参数
lmf.events = {
	-- load event
	{ "PROFILE_ACTIVATED", "load" },
	{ "PROFILE_DEACTIVATED", "unload" },
	-- mouse event
	{ "MOUSE_BUTTON_PRESSED", "mousedown" },
	{ "MOUSE_BUTTON_RELEASED", "mouseup" },
	-- G key event
	{ "G_PRESSED", "gkeydown" },
	{ "G_RELEASED", "gkeyup" },
	-- M key event
	{ "M_PRESSED", "mkeydown" },
	{ "M_RELEASED", "mkeyup" },
}

-- 监听动作
function lmf.on (k, f)
	local index = nil
	local list = table.map(lmf.events, function (n, i)
		return n[2]
	end)

	if table.some(list, function (n, i)
		return n == k
	end) then
		if lmf.monitor[k] and #lmf.monitor[k] > 0 then
			index = #lmf.monitor[k] + 1
			lmf.monitor[k][index] = f
		else
			index = 1
			lmf.monitor[k] = { f }
		end
	end

	return index and {
		event = k,
		id = index
	} or nil
end

-- 取消监听
function lmf.off (n)
	lmf.monitor[n.event][n.id] = false
end

-- 触发监听事件
function lmf.emit (k, d)
	if lmf.monitor[k] and #lmf.monitor[k] then
		table.forEach(lmf.monitor[k], function (n, i)
			if n then n(d) end
		end)
	end
end

-- lmf 提供的 loop 循环方法
function lmf.loop (func, timestamp)
	local startTime = getTime()
	local lastTime = getTime()

	repeat
		if getTime() - lastTime >= timestamp then
			lastTime = lastTime + timestamp
			if not func() then break end
		end
		sleep(1)
	until getTime() - startTime >= lmf._for_protect_time
end

--[[ tools ]]

-- split function
function string.split (str, s)
	if string.find(str, s) == nil then return { str } end

	local res = {}
	local reg = "(.-)" .. s .. "()"
	local index = 0
	local last_i

	for n, i in string.gfind(str, reg) do
		index = index + 1
		res[index] = n
		last_i = i
	end

	res[index + 1] = string.sub(str, last_i)

	return res
end

-- table find
function table.find (t, f)
	local res = nil
	for i = 1, #t do
		local n = t[i]
		if f(n, i) then
			res = n
			break
		end
	end
	return res
end

-- table filter
function table.filter (t, f)
	local res = {}
	table.forEach(t, function (n, i)
		if f(n, i) then table.push(res, n) end
	end)
	return res
end

-- join function
function string.join (t, s)
	return table.reduce(t, function(n, m)
		return n .. s .. m
	end)
end

-- table push
function table.push (t, v)
	t[#t + 1] = v
end

-- table indexOf
function table.indexOf (t, v)
	local res = -1
	for i = 1, #t do
		if t[i] == v then
			res = i
			break
		end
	end
	return res
end

-- table merge
function table.merge (...)
	local res = {}
	local tabs = {...}

	for i = 1, #tabs do
		local n = tabs[i]
		assert(type(n) == "table", "[table.merge] Wrong parameter data type: " .. tostring(n) .. " is not a \"table\".")
		for k, v in pairs(n) do
			table._merge(res, k, v)
		end
	end

	return res
end

function table._merge (tab, key, val)
	if type(val) == "table" then
		tab[key] = tab[key] ~= nil and tab[key] or {}
		for k, v in pairs(val) do
			table._merge(tab[key], k, v)
		end
	else
		tab[key] = val
	end
end

-- table cloneDeep
function table.cloneDeep (t)
	return type(t) == "table" and table.merge(t) or t
end

-- Javascript Array.prototype.some
function table.some (t, c)
	local res = false
	for i = 1, #t do
		if c(t[i], i) then
			res = true
			break
		end
	end
	return res
end

-- Javascript Array.prototype.every
function table.every (t, c)
	local res = true
	for i = 1, #t do
		if not c(t[i], i) then
			res = false
			break
		end
	end
	return res
end

-- Javascript Array.prototype.reduce
function table.reduce (t, c)
	local res = c(t[1], t[2])
	for i = 3, #t do res = c(res, t[i]) end
	return res
end

-- Javascript Array.prototype.map
function table.map (t, c)
	local res = {}
	for i = 1, #t do res[i] = c(t[i], i) end
	return res
end

-- Javascript Array.prototype.forEach
function table.forEach (t, c)
	for i = 1, #t do c(t[i], i) end
end

function table.createFill (n, v)
	local res = {}
	for i = 1, n do res[i] = v end
	return res
end

--[[
	* 打印 table
	* @param  {any} val     传入值
	* @return {str}         格式化后的文本
]]
function table.print (val)

	local function loop (val, keyType, _indent)
		_indent = _indent or 1
		keyType = keyType or "string"
		local res = ""
		local indentStr = "     " -- 缩进空格
		local indent = string.rep(indentStr, _indent)
		local end_indent = string.rep(indentStr, _indent - 1)
		local putline = function (...)
			local arr = { res, ... }
			for i = 1, #arr do
				if type(arr[i]) ~= "string" then arr[i] = tostring(arr[i]) end
			end
			res = table.concat(arr)
		end

		if type(val) == "table" then
			putline("{ ")

			if #val > 0 then
				local index = 0
				local block = false

				for i = 1, #val do
					local n = val[i]
					if type(n) == "table" or type(n) == "function" then
						block = true
						break
					end
				end

				if block then
					for i = 1, #val do
						local n = val[i]
						index = index + 1
						if index == 1 then putline("\n") end
						putline(indent, loop(n, type(i), _indent + 1), "\n")
						if index == #val then putline(end_indent) end
					end
				else
					for i = 1, #val do
						local n = val[i]
						index = index + 1
						putline(loop(n, type(i), _indent + 1))
					end
				end

			else
				putline("\n")
				for k, v in pairs(val) do
					putline(indent, k, " = ", loop(v, type(k), _indent + 1), "\n")
				end
				putline(end_indent)
			end

			putline("}, ")
		elseif type(val) == "string" then
			val = string.gsub(val, "\a", "\\a") -- 响铃(BEL)
			val = string.gsub(val, "\b", "\\b") -- 退格(BS),将当前位置移到前一列
			val = string.gsub(val, "\f", "\\f") -- 换页(FF),将当前位置移到下页开头
			val = string.gsub(val, "\n", "\\n") -- 换行(LF),将当前位置移到下一行开头
			val = string.gsub(val, "\r", "\\r") -- 回车(CR),将当前位置移到本行开头
			val = string.gsub(val, "\t", "\\t") -- 水平指标(HT),(调用下一个TAB位置)
			val = string.gsub(val, "\v", "\\v") -- 垂直指标(VT)
			putline("\"", val, "\", ")
		elseif type(val) == "boolean" then
			putline(val and "true, " or "false, ")
		elseif type(val) == "function" then
			putline(tostring(val), ", ")
		elseif type(val) == "nil" then
			putline("nil, ")
		else
			putline(val, ", ")
		end

		return res
	end

	local res = loop(val)
	res = string.gsub(res, ",(%s*})", "%1")
	res = string.gsub(res, ",(%s*)$", "%1")
	res = string.gsub(res, "{%s+}", "{}")

	return res
end

----------------------------------------------------------------------------------------------------
--                                         Default event                                          --
----------------------------------------------------------------------------------------------------

lmf.on('unload', function ()
	EnablePrimaryMouseButtonEvents(false)
end)

----------------------------------------------------------------------------------------------------
--                                         Entry function                                         --
----------------------------------------------------------------------------------------------------

function OnEvent (event, arg, family)
	-- console.log("event = " .. event .. ", arg = " .. arg .. ", family = " .. family)

	table.forEach(lmf.events, function (n, i)
		if event == n[1] then
			lmf._emit(n[2], arg, family)
		end
	end)

end

function lmf._emit (ename, arg, family)
	if arg == 2 then arg = 3 elseif arg == 3 then arg = 2 end
	local list = { "lalt", "lctrl", "lshift", "ralt", "rctrl", "rshift" }
	local res = {
		event = ename, -- 触发的事件
		g = arg, -- 触发事件的 G 键，包括鼠标、键盘、耳机等
		family = family ~= "" and family or "other", -- 触发事件的设备 (鼠标或其他)
		pressed = {}, -- 哪些 G 键是按住的状态 (仅支持判断 g1、g2、g3、g4、g5 五个鼠标 G 键)
		modifier = {}, -- 哪些修饰键是按住的状态 (lalt、lctrl、lshift、ralt、rctrl、rshift)
		capslock = isLock("capslock"), -- 大写锁定键是否开启
		numlock = isLock("numlock"), -- 小键盘锁定是否开启
		scrolllock = isLock("scrolllock"), -- 滚动锁定是否开启
	}

	for i = 1, 5 do
		if isPressed(i) then
			res.pressed[#res.pressed + 1] = "g" .. i
		end
	end

	for i = 1, #list do
		if isPressed(list[i]) then
			res.modifier[#res.modifier + 1] = list[i]
		end
	end

	lmf.emit(ename, res)
end

--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--
--                                                                                                --
--                                     从这里开始写你的代码                                         --
--                                Start writing your code here.                                   --
--                                                                                                --
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

EnablePrimaryMouseButtonEvents(true)
-- Execute when the script is loaded
lmf.on("load", function ()
	console.log("let's rocking!")
--	lmf.loop(function ()
--		sleep(30000)
--		keyTap(0x34) -- .
--		for i = 0, 10 do
--			keyTap(0x1e) -- a
--			moveToThis (32767, 32767)
--			keyTap(0x18) -- o
--			keyTap(0x16) -- u
--		end
--		keyTap(0x1a) -- [
--		keyTap(0x1a) -- [
--		a = a + 1
--		return a < 5
--	end, 10000)
end)

lmf.on('unload', function ()
	console.clear()
end)

-- 按住左键连点效果实现范例 (开启大写生效)
 local G1 = false

 lmf.on("mousedown", function (e)
 	-- console.log(e)
 	if e.g == 7 and e.capslock then
 		G1 = true
 		setM(1)
 	end
 end)
--
 lmf.on("mkeydown", function (e)
 	if G1 and e.capslock then
 		setM(1)
 		mouseTap(1)
 	end
 end)
--

 local sleepTime = 10
 lmf.on("mouseup", function (e)
 	if e.g == 7 then
--		moveToThis (29500, 55000) -- point of first unit
-- 		moveToThis (30200, 38000) -- point of left bottom corner of base
-- 		moveToThis (35294, 20534) -- point of left bottom corner of base

	--保存编队
		keyDown(0x1d) -- control 进行编队
		sleep(sleepTime)
		keyDown(0x0c) -- -
		sleep(sleepTime)
		keyUp(0x0c)
		sleep(sleepTime)
		keyUp(0x1d) -- 编队结束
	--保存视角
		keyDown(0x2a) -- shift 进行编屏
		sleep(sleepTime)
		keyDown(0x1c) -- Enter
		sleep(sleepTime)
		keyUp(0x1c)
		sleep(sleepTime)
		keyUp(0x2a) -- 编屏结束
	--corner case：没有选中任何单位，比如在看风景，这种情况下
	--编队在移动
	--所以应该先恢复视角，然后再双击编队，如果没有编队的化回回到原位
	--编队移动了也能恢复最后的位置

	--每次执行的时候应该清空女王编队，因为之前可能会选中农民和虫卵
		sleep(sleepTime)
		keyDown(0x34) -- .
		sleep(sleepTime)
		keyDown(0x1d) -- control 进行编队
		sleep(sleepTime)
		keyDown(0x0b) -- 0
		sleep(sleepTime)
		keyUp(0x0b)
		sleep(sleepTime)
		keyUp(0x1d) -- 编队结束
	--还得清空基地编队，也容易出问题
		sleep(sleepTime)
		keyDown(0x1c) -- Enter
		sleep(sleepTime)
		keyDown(0x1d) -- control 进行编队
		sleep(sleepTime)
		keyDown(0x0b) --
		sleep(sleepTime)
		keyUp(0x0b)
		sleep(sleepTime)
		keyUp(0x1d) -- 编队结束


		for i = 0, 10 do
			keyTap(0x1e) -- a 切屏
		    sleep(sleepTime)
--			keyTap(0x34) -- .
--			sleep(50)
		    --框选
			moveToThis (30200, 38000)
			sleep(sleepTime)
			mouseDown(1)
			sleep(sleepTime)
			moveToThis (35294, 20534)
			sleep(sleepTime)
		    mouseUp(1)
			--框选结束,如果没有女王，会选中基地本身
			sleep(sleepTime)
			moveToThis (29500, 55000) --选中队伍中第一个单位
			sleep(sleepTime)
			mouseTap(1)
			sleep(sleepTime)
			keyDown(0x1d) -- control 进行编队
			sleep(sleepTime)
			keyDown(0x34) -- .
			sleep(sleepTime)
			keyUp(0x34)
			sleep(sleepTime)
			keyUp(0x1d) -- 编队结束
			sleep(sleepTime)
			moveToThis (32767, 32767) --鼠标移动到屏幕中央
			sleep(sleepTime)
			keyTap(0x25) -- K 注卵
			sleep(sleepTime)
			mouseTap(1)
			-- 以上流程如果碰到没有女王的基地会生产女王并且将会错误的把基地编入队伍
			-- 为了解决以上问题 1。生产女王需要一个不一样的无效快捷键 2。编队女王的同时，应该把基地也编队
			-- 注卵改为了K键
			sleep(sleepTime)
			mouseTap(1) -- 选种基地
			sleep(sleepTime)
			keyDown(0x1d) -- control 进行编队
			sleep(sleepTime)
			keyDown(0x1c) -- Enter
			sleep(sleepTime)
			keyUp(0x1c)
			sleep(sleepTime)
			keyUp(0x1d) -- 编队结束

		end
		--恢复视角
		keyDown(0x38) -- alt
		sleep(sleepTime)
		keyDown(0x1c) -- Enter
		sleep(sleepTime)
		keyUp(0x1c)
		sleep(sleepTime)
		keyUp(0x38) -- 编屏
		--恢复编队
		sleep(sleepTime)
		keyTap(0x0c) -- -
		sleep(sleepTime)
		keyTap(0x0c) -- -

	end
 end)

-- console.log(lmf)













---------------------------------------------- Code End --------------------------------------------
----------------------------------------------------------------------------------------------------
