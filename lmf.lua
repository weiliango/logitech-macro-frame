----------------------------------------------------------------------------------------------------
--                                        Ã¤Â½Â¿Ã§â€Â¨Ã¨â‚¬â€¦Ã©â€¦ÂÃ§Â½Â®Ã¨Â®Â¾Ã§Â½Â®                                           --
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
--                    Please click [Ã¢Ëœâ€¦ Star] to support my project, thank you.                    --
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
	monitor = {}, -- Ã§â€ºâ€˜Ã¥ÂÂ¬Ã¥â„¢Â¨Ã¥Ë†â€”Ã¨Â¡Â¨
	_timers = {}, -- Ã¥Â®Å¡Ã¦â€”Â¶Ã¥â„¢Â¨Ã¥â€¡Â½Ã¦â€¢Â°Ã¥Ë†â€”Ã¨Â¡Â¨
	_for_protect_time = 20000, -- lmf.for Ã¦â€“Â¹Ã¦Â³â€¢Ã§Å¡â€žÃ¥Â¾ÂªÃ§Å½Â¯Ã¤Â¿ÂÃ¦Å Â¤Ã¯Â¼Å’Ã¨Â¶â€¦Ã¨Â¿â€¡Ã¦Â­Â¤Ã¦Â¯Â«Ã§Â§â€™Ã¦â€¢Â°Ã¦â€”Â¶Ã©â€”Â´Ã¥Â°â€ Ã¥Â¼ÂºÃ¥Ë†Â¶Ã§Â»â€œÃ¦ÂÅ¸Ã¥Â¾ÂªÃ§Å½Â¯Ã¯Â¼Å’Ã©ËœÂ²Ã¦Â­Â¢Ã¦Â­Â»Ã¥Â¾ÂªÃ§Å½Â¯Ã¥ÂÂ¡Ã¦Â­Â»Ã£â‚¬â€š
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

-- Ã©â€¡ÂÃ¥â€˜Â½Ã¥ÂÂ APIÃ¯Â¼Å’Ã¦â€¢Â´Ã¥ÂË†Ã¤Â¸ÂªÃ¥Ë†Â« API Ã¥Å Å¸Ã¨Æ’Â½
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

-- Ã©â€¡ÂÃ¥â€˜Â½Ã¥ÂÂ OnEvent Ã§Å¡â€ž event Ã¥Ââ€šÃ¦â€¢Â°
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

-- Ã§â€ºâ€˜Ã¥ÂÂ¬Ã¥Å Â¨Ã¤Â½Å“
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

-- Ã¥Ââ€“Ã¦Â¶Ë†Ã§â€ºâ€˜Ã¥ÂÂ¬
function lmf.off (n)
	lmf.monitor[n.event][n.id] = false
end

-- Ã¨Â§Â¦Ã¥Ââ€˜Ã§â€ºâ€˜Ã¥ÂÂ¬Ã¤Âºâ€¹Ã¤Â»Â¶
function lmf.emit (k, d)
	if lmf.monitor[k] and #lmf.monitor[k] then
		table.forEach(lmf.monitor[k], function (n, i)
			if n then n(d) end
		end)
	end
end

-- lmf Ã¦ÂÂÃ¤Â¾â€ºÃ§Å¡â€ž loop Ã¥Â¾ÂªÃ§Å½Â¯Ã¦â€“Â¹Ã¦Â³â€¢
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
	* Ã¦â€°â€œÃ¥ÂÂ° table
	* @param  {any} val     Ã¤Â¼ Ã¥â€¦Â¥Ã¥â‚¬Â¼
	* @return {str}         Ã¦ Â¼Ã¥Â¼ÂÃ¥Å’â€“Ã¥ÂÅ½Ã§Å¡â€žÃ¦â€“â€¡Ã¦Å“Â¬
]]
function table.print (val)

	local function loop (val, keyType, _indent)
		_indent = _indent or 1
		keyType = keyType or "string"
		local res = ""
		local indentStr = "     " -- Ã§Â¼Â©Ã¨Â¿â€ºÃ§Â©ÂºÃ¦ Â¼
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
			val = string.gsub(val, "\a", "\\a") -- Ã¥â€œÂÃ©â€œÆ’(BEL)
			val = string.gsub(val, "\b", "\\b") -- Ã©â‚¬â‚¬Ã¦ Â¼(BS),Ã¥Â°â€ Ã¥Â½â€œÃ¥â€°ÂÃ¤Â½ÂÃ§Â½Â®Ã§Â§Â»Ã¥Ë†Â°Ã¥â€°ÂÃ¤Â¸â‚¬Ã¥Ë†â€”
			val = string.gsub(val, "\f", "\\f") -- Ã¦ÂÂ¢Ã©Â¡Âµ(FF),Ã¥Â°â€ Ã¥Â½â€œÃ¥â€°ÂÃ¤Â½ÂÃ§Â½Â®Ã§Â§Â»Ã¥Ë†Â°Ã¤Â¸â€¹Ã©Â¡ÂµÃ¥Â¼â‚¬Ã¥Â¤Â´
			val = string.gsub(val, "\n", "\\n") -- Ã¦ÂÂ¢Ã¨Â¡Å’(LF),Ã¥Â°â€ Ã¥Â½â€œÃ¥â€°ÂÃ¤Â½ÂÃ§Â½Â®Ã§Â§Â»Ã¥Ë†Â°Ã¤Â¸â€¹Ã¤Â¸â‚¬Ã¨Â¡Å’Ã¥Â¼â‚¬Ã¥Â¤Â´
			val = string.gsub(val, "\r", "\\r") -- Ã¥â€ºÅ¾Ã¨Â½Â¦(CR),Ã¥Â°â€ Ã¥Â½â€œÃ¥â€°ÂÃ¤Â½ÂÃ§Â½Â®Ã§Â§Â»Ã¥Ë†Â°Ã¦Å“Â¬Ã¨Â¡Å’Ã¥Â¼â‚¬Ã¥Â¤Â´
			val = string.gsub(val, "\t", "\\t") -- Ã¦Â°Â´Ã¥Â¹Â³Ã¦Å’â€¡Ã¦ â€¡(HT),(Ã¨Â°Æ’Ã§â€Â¨Ã¤Â¸â€¹Ã¤Â¸â‚¬Ã¤Â¸ÂªTABÃ¤Â½ÂÃ§Â½Â®)
			val = string.gsub(val, "\v", "\\v") -- Ã¥Å¾â€šÃ§â€ºÂ´Ã¦Å’â€¡Ã¦ â€¡(VT)
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
		event = ename, -- Ã¨Â§Â¦Ã¥Ââ€˜Ã§Å¡â€žÃ¤Âºâ€¹Ã¤Â»Â¶
		g = arg, -- Ã¨Â§Â¦Ã¥Ââ€˜Ã¤Âºâ€¹Ã¤Â»Â¶Ã§Å¡â€ž G Ã©â€Â®Ã¯Â¼Å’Ã¥Å’â€¦Ã¦â€¹Â¬Ã©Â¼ Ã¦ â€¡Ã£â‚¬ÂÃ©â€Â®Ã§â€ºËœÃ£â‚¬ÂÃ¨â‚¬Â³Ã¦Å“ÂºÃ§Â­â€°
		family = family ~= "" and family or "other", -- Ã¨Â§Â¦Ã¥Ââ€˜Ã¤Âºâ€¹Ã¤Â»Â¶Ã§Å¡â€žÃ¨Â®Â¾Ã¥Â¤â€¡ (Ã©Â¼ Ã¦ â€¡Ã¦Ë†â€“Ã¥â€¦Â¶Ã¤Â»â€“)
		pressed = {}, -- Ã¥â€œÂªÃ¤Âºâ€º G Ã©â€Â®Ã¦ËœÂ¯Ã¦Å’â€°Ã¤Â½ÂÃ§Å¡â€žÃ§Å Â¶Ã¦â‚¬Â (Ã¤Â»â€¦Ã¦â€Â¯Ã¦Å’ÂÃ¥Ë†Â¤Ã¦â€“Â­ g1Ã£â‚¬Âg2Ã£â‚¬Âg3Ã£â‚¬Âg4Ã£â‚¬Âg5 Ã¤Âºâ€Ã¤Â¸ÂªÃ©Â¼ Ã¦ â€¡ G Ã©â€Â®)
		modifier = {}, -- Ã¥â€œÂªÃ¤Âºâ€ºÃ¤Â¿Â®Ã©Â¥Â°Ã©â€Â®Ã¦ËœÂ¯Ã¦Å’â€°Ã¤Â½ÂÃ§Å¡â€žÃ§Å Â¶Ã¦â‚¬Â (laltÃ£â‚¬ÂlctrlÃ£â‚¬ÂlshiftÃ£â‚¬ÂraltÃ£â‚¬ÂrctrlÃ£â‚¬Ârshift)
		capslock = isLock("capslock"), -- Ã¥Â¤Â§Ã¥â€ â„¢Ã©â€ÂÃ¥Â®Å¡Ã©â€Â®Ã¦ËœÂ¯Ã¥ÂÂ¦Ã¥Â¼â‚¬Ã¥ÂÂ¯
		numlock = isLock("numlock"), -- Ã¥Â°ÂÃ©â€Â®Ã§â€ºËœÃ©â€ÂÃ¥Â®Å¡Ã¦ËœÂ¯Ã¥ÂÂ¦Ã¥Â¼â‚¬Ã¥ÂÂ¯
		scrolllock = isLock("scrolllock"), -- Ã¦Â»Å¡Ã¥Å Â¨Ã©â€ÂÃ¥Â®Å¡Ã¦ËœÂ¯Ã¥ÂÂ¦Ã¥Â¼â‚¬Ã¥ÂÂ¯
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
--                                     Ã¤Â»Å½Ã¨Â¿â„¢Ã©â€¡Å’Ã¥Â¼â‚¬Ã¥Â§â€¹Ã¥â€ â„¢Ã¤Â½ Ã§Å¡â€žÃ¤Â»Â£Ã§ Â                                         --
--                                Start writing your code here.                                   --
--                                                                                                --
--||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||--

EnablePrimaryMouseButtonEvents(true)
-- Execute when the script is loaded

local sleepTime = 10
local iteration = 1200
lmf._for_protect_time = 60 * 60 * 24 * 1000 -- 24 hours

function injectLarvae()
	keyDown(0x1d) -- control Ã¨Â¿â€ºÃ¨Â¡Å’Ã§Â¼â€“Ã©ËœÅ¸
	sleep(sleepTime)
	keyDown(0x0c) -- -
	sleep(sleepTime)
	keyUp(0x0c)
	sleep(sleepTime)
	keyUp(0x1d) -- Ã§Â¼â€“Ã©ËœÅ¸Ã§Â»â€œÃ¦ÂÅ¸
	--Ã¤Â¿ÂÃ¥Â­ËœÃ¨Â§â€ Ã¨Â§â€™
	keyDown(0x2a) -- shift Ã¨Â¿â€ºÃ¨Â¡Å’Ã§Â¼â€“Ã¥Â±Â
	sleep(sleepTime)
	keyDown(0x1c) -- Enter
	sleep(sleepTime)
	keyUp(0x1c)
	sleep(sleepTime)
	keyUp(0x2a) -- Ã§Â¼â€“Ã¥Â±ÂÃ§Â»â€œÃ¦ÂÅ¸
	--corner caseÃ¯Â¼Å¡Ã¦Â²Â¡Ã¦Å“â€°Ã©â‚¬â€°Ã¤Â¸Â­Ã¤Â»Â»Ã¤Â½â€¢Ã¥Ââ€¢Ã¤Â½ÂÃ¯Â¼Å’Ã¦Â¯â€Ã¥Â¦â€šÃ¥Å“Â¨Ã§Å“â€¹Ã©Â£Å½Ã¦â„¢Â¯Ã¯Â¼Å’Ã¨Â¿â„¢Ã§Â§ÂÃ¦Æ’â€¦Ã¥â€ ÂµÃ¤Â¸â€¹
	--Ã§Â¼â€“Ã©ËœÅ¸Ã¥Å“Â¨Ã§Â§Â»Ã¥Å Â¨
	--Ã¦â€°â‚¬Ã¤Â»Â¥Ã¥Âºâ€Ã¨Â¯Â¥Ã¥â€¦Ë†Ã¦ÂÂ¢Ã¥Â¤ÂÃ¨Â§â€ Ã¨Â§â€™Ã¯Â¼Å’Ã§â€žÂ¶Ã¥ÂÅ½Ã¥â€ ÂÃ¥ÂÅ’Ã¥â€¡Â»Ã§Â¼â€“Ã©ËœÅ¸Ã¯Â¼Å’Ã¥Â¦â€šÃ¦Å¾Å“Ã¦Â²Â¡Ã¦Å“â€°Ã§Â¼â€“Ã©ËœÅ¸Ã§Å¡â€žÃ¥Å’â€“Ã¥â€ºÅ¾Ã¥â€ºÅ¾Ã¥Ë†Â°Ã¥Å½Å¸Ã¤Â½Â
	--Ã§Â¼â€“Ã©ËœÅ¸Ã§Â§Â»Ã¥Å Â¨Ã¤Âºâ€ Ã¤Â¹Å¸Ã¨Æ’Â½Ã¦ÂÂ¢Ã¥Â¤ÂÃ¦Å“â‚¬Ã¥ÂÅ½Ã§Å¡â€žÃ¤Â½ÂÃ§Â½Â®

	--	--Ã¦Â¯ÂÃ¦Â¬Â¡Ã¦â€°Â§Ã¨Â¡Å’Ã§Å¡â€žÃ¦â€”Â¶Ã¥â‚¬â„¢Ã¥Âºâ€Ã¨Â¯Â¥Ã¦Â¸â€¦Ã§Â©ÂºÃ¥Â¥Â³Ã§Å½â€¹Ã§Â¼â€“Ã©ËœÅ¸Ã¯Â¼Å’Ã¥â€º Ã¤Â¸ÂºÃ¤Â¹â€¹Ã¥â€°ÂÃ¥ÂÂ¯Ã¨Æ’Â½Ã¤Â¼Å¡Ã©â‚¬â€°Ã¤Â¸Â­Ã¥â€ Å“Ã¦Â°â€˜Ã¥â€™Å’Ã¨â„¢Â«Ã¥ÂÂµ
	--		sleep(sleepTime)
	--		keyDown(0x34) -- .
	--		sleep(sleepTime)
	--		keyDown(0x1d) -- control Ã¨Â¿â€ºÃ¨Â¡Å’Ã§Â¼â€“Ã©ËœÅ¸
	--		sleep(sleepTime)
	--		keyDown(0x0b) -- 0
	--		sleep(sleepTime)
	--		keyUp(0x0b)
	--		sleep(sleepTime)
	--		keyUp(0x1d) -- Ã§Â¼â€“Ã©ËœÅ¸Ã§Â»â€œÃ¦ÂÅ¸
	--	--Ã¨Â¿ËœÃ¥Â¾â€”Ã¦Â¸â€¦Ã§Â©ÂºÃ¥Å¸ÂºÃ¥Å“Â°Ã§Â¼â€“Ã©ËœÅ¸Ã¯Â¼Å’Ã¤Â¹Å¸Ã¥Â®Â¹Ã¦Ëœâ€œÃ¥â€¡ÂºÃ©â€”Â®Ã©Â¢Ëœ
	--		sleep(sleepTime)
	--		keyDown(0x1c) -- Enter
	--		sleep(sleepTime)
	--		keyDown(0x1d) -- control Ã¨Â¿â€ºÃ¨Â¡Å’Ã§Â¼â€“Ã©ËœÅ¸
	--		sleep(sleepTime)
	--		keyDown(0x0b) --
	--		sleep(sleepTime)
	--		keyUp(0x0b)
	--		sleep(sleepTime)
	--		keyUp(0x1d) -- Ã§Â¼â€“Ã©ËœÅ¸Ã§Â»â€œÃ¦ÂÅ¸

	local j = 4;
	if IsKeyLockOn("scrolllock") then
		j = 4
	else
		j = 8
	end

	SetMouseDPITable({0, 800}, 1)
	for i = 0, j do
		keyTap(0x1e) -- a Ã¥Ë†â€¡Ã¥Â±Â
		sleep(sleepTime)
		--			keyTap(0x34) -- .
		--			sleep(50)
		--Ã¦Â¡â€ Ã©â‚¬â€°
		moveToThis (30200, 38000)
		sleep(sleepTime)
		mouseDown(1)
		sleep(sleepTime)
		moveToThis (35294, 20534)
		sleep(sleepTime)
		mouseUp(1)
		--Ã¦Â¡â€ Ã©â‚¬â€°Ã§Â»â€œÃ¦ÂÅ¸,Ã¥Â¦â€šÃ¦Å¾Å“Ã¦Â²Â¡Ã¦Å“â€°Ã¥Â¥Â³Ã§Å½â€¹Ã¯Â¼Å’Ã¤Â¼Å¡Ã©â‚¬â€°Ã¤Â¸Â­Ã¥Å¸ÂºÃ¥Å“Â°Ã¦Å“Â¬Ã¨ÂºÂ«
		--			sleep(sleepTime)
		--			moveToThis (29500, 55000) --Ã©â‚¬â€°Ã¤Â¸Â­Ã©ËœÅ¸Ã¤Â¼ÂÃ¤Â¸Â­Ã§Â¬Â¬Ã¤Â¸â‚¬Ã¤Â¸ÂªÃ¥Ââ€¢Ã¤Â½Â
		--			sleep(sleepTime)
		--			mouseTap(1)
		--			sleep(sleepTime)
		--			keyDown(0x1d) -- control Ã¨Â¿â€ºÃ¨Â¡Å’Ã§Â¼â€“Ã©ËœÅ¸
		--			sleep(sleepTime)
		--			keyDown(0x34) -- .
		--			sleep(sleepTime)
		--			keyUp(0x34)
		--			sleep(sleepTime)
		--			keyUp(0x1d) -- Ã§Â¼â€“Ã©ËœÅ¸Ã§Â»â€œÃ¦ÂÅ¸
		sleep(sleepTime)
		moveToThis (32767, 32767) --Ã©Â¼ Ã¦ â€¡Ã§Â§Â»Ã¥Å Â¨Ã¥Ë†Â°Ã¥Â±ÂÃ¥Â¹â€¢Ã¤Â¸Â­Ã¥Â¤Â®
		sleep(sleepTime)
		keyTap(0x25) -- K Ã¦Â³Â¨Ã¥ÂÂµ
		sleep(sleepTime)
		mouseTap(1)
		-- Ã¤Â»Â¥Ã¤Â¸Å Ã¦ÂµÂÃ§Â¨â€¹Ã¥Â¦â€šÃ¦Å¾Å“Ã§Â¢Â°Ã¥Ë†Â°Ã¦Â²Â¡Ã¦Å“â€°Ã¥Â¥Â³Ã§Å½â€¹Ã§Å¡â€žÃ¥Å¸ÂºÃ¥Å“Â°Ã¤Â¼Å¡Ã§â€Å¸Ã¤ÂºÂ§Ã¥Â¥Â³Ã§Å½â€¹Ã¥Â¹Â¶Ã¤Â¸â€Ã¥Â°â€ Ã¤Â¼Å¡Ã©â€â„¢Ã¨Â¯Â¯Ã§Å¡â€žÃ¦Å Å Ã¥Å¸ÂºÃ¥Å“Â°Ã§Â¼â€“Ã¥â€¦Â¥Ã©ËœÅ¸Ã¤Â¼Â
		-- Ã¤Â¸ÂºÃ¤Âºâ€ Ã¨Â§Â£Ã¥â€ Â³Ã¤Â»Â¥Ã¤Â¸Å Ã©â€”Â®Ã©Â¢Ëœ 1Ã£â‚¬â€šÃ§â€Å¸Ã¤ÂºÂ§Ã¥Â¥Â³Ã§Å½â€¹Ã©Å“â‚¬Ã¨Â¦ÂÃ¤Â¸â‚¬Ã¤Â¸ÂªÃ¤Â¸ÂÃ¤Â¸â‚¬Ã¦ Â·Ã§Å¡â€žÃ¦â€” Ã¦â€¢Ë†Ã¥Â¿Â«Ã¦ÂÂ·Ã©â€Â® 2Ã£â‚¬â€šÃ§Â¼â€“Ã©ËœÅ¸Ã¥Â¥Â³Ã§Å½â€¹Ã§Å¡â€žÃ¥ÂÅ’Ã¦â€”Â¶Ã¯Â¼Å’Ã¥Âºâ€Ã¨Â¯Â¥Ã¦Å Å Ã¥Å¸ÂºÃ¥Å“Â°Ã¤Â¹Å¸Ã§Â¼â€“Ã©ËœÅ¸
		-- Ã¦Â³Â¨Ã¥ÂÂµÃ¦â€Â¹Ã¤Â¸ÂºÃ¤Âºâ€ KÃ©â€Â®
		sleep(sleepTime)
		--			mouseTap(1) -- Ã©â‚¬â€°Ã§Â§ÂÃ¥Å¸ÂºÃ¥Å“Â°
		--			sleep(sleepTime)
		--			keyDown(0x1d) -- control Ã¨Â¿â€ºÃ¨Â¡Å’Ã§Â¼â€“Ã©ËœÅ¸
		--			sleep(sleepTime)
		--			keyDown(0x1c) -- Enter
		--			sleep(sleepTime)
		--			keyUp(0x1c)
		--			sleep(sleepTime)
		--			keyUp(0x1d) -- Ã§Â¼â€“Ã©ËœÅ¸Ã§Â»â€œÃ¦ÂÅ¸

	end
	SetMouseDPITable({0, 800}, 2)
	--Ã¦ÂÂ¢Ã¥Â¤ÂÃ¨Â§â€ Ã¨Â§â€™
	keyDown(0x38) -- alt
	sleep(sleepTime)
	keyDown(0x1c) -- Enter
	sleep(sleepTime)
	keyUp(0x1c)
	sleep(sleepTime)
	keyUp(0x38) -- Ã§Â¼â€“Ã¥Â±Â
	--Ã¦ÂÂ¢Ã¥Â¤ÂÃ§Â¼â€“Ã©ËœÅ¸
	sleep(sleepTime)
	keyTap(0x0c) -- -
	sleep(sleepTime)
	keyTap(0x0c) -- -
end

-- local G1 = false
--
-- lmf.on("mousedown", function (e)
-- 	-- console.log(e)
-- 	if e.g == 7 and e.capslock then
-- 		G1 = true
-- 		setM(1)
-- 	end
-- end)
--
-- lmf.on("mkeydown", function (e)
-- 	if G1 and e.capslock then
-- 		setM(1)
-- 		mouseTap(1)
-- 	end
-- end)
--
--

local a = 0

lmf.loop(function ()
	if IsKeyLockOn("capslock") then
		injectLarvae()
	else
		console.log("capslock disabled, going to ignore")
	end
	a = a + 1
	return a < iteration
end, 30000)




---------------------------------------------- Code End --------------------------------------------
----------------------------------------------------------------------------------------------------
