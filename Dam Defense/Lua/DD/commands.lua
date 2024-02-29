-- Debug console dd_test
local func = function (args)
	DD.tablePrint(args, nil, 1)
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
local validArgs = function ()
	local tbl = {}
	local alphabet = DD.stringSplit('ABCDEFGHIJKLMNOPQRSTUVWXYZ', '')
	alphabet[27] = nil
	for n = 0, 9 do
		table.insert(tbl, {})
		for m = 0, #alphabet - 1 do
			table.insert(tbl[n+1], n .. alphabet[m + 1])
		end
	end
	return tbl
end
Game.AddCommand('dd_test', 'dd_test: test.', func, validArgs, false)

-- Debug console dd_save
local func = function (args)
	print(DD.saving.save(args))
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
local validArgs = function ()
	local tbl = {}
	for n = 1, #DD.saving.keys do
		table.insert(tbl, {})
		for key in DD.saving.keys do
			table.insert(tbl[n], key)
		end
	end
	return tbl
end
Game.AddCommand('dd_save', 'dd_save: manually trigger saving of certain key-values. Useful if autosaving is disabled.', func, validArgs, false)

-- Debug console dd_showsave
local func = function (args)
	DD.saving.debug()
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_showsave', 'dd_dd_showsave: prints out the value of keys that are saved. Useful for debugging.', func, nil, false)

-- Debug console dd_saveall
local func = function (args)
	print(DD.saving.save())
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_saveall', 'dd_saveall: manually trigger saving of all key-values. Useful if autosaving is disabled.', func, nil, false)

-- Debug console dd_toggledebugmode
local func = function (args)
	DD.debugMode = not DD.debugMode
	if DD.debugMode then
		print('Debug mode enabled.')
	else
		print('Debug mode disabled.')
	end
	if DD.saving.autoSave then DD.saving.save({'debugMode'}) end
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_toggledebugmode', 'dd_toggledebugmode: Toggles debug mode. Debug mode should only be used for debugging.', func, nil, false)

-- Debug console dd_toggleeventdirector
local func = function (args)
	if CLIENT then print('Server-side only!') return end
	
	DD.eventDirector.enabled = not DD.eventDirector.enabled
	if DD.eventDirector.enabled then
		print('Event director enabled.')
	else
		print('Event director disabled.')
	end
	if DD.saving.autoSave and not DD.debugMode then DD.saving.save({'eventDirector.enabled'}) end
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_toggleeventdirector', 'dd_toggleeventdirector: Toggles the event director. The event director is a system which automatically starts events.', func, nil, false)

-- Debug console dd_startevent
local func = function (args)
	if CLIENT then print('Server-side only!') return end
	
	local eventName = table.remove(args, 1)
	local eventClass = DD[eventName]
	
	local convertFunctions = {}
	convertFunctions.string = function (str)
		return str
	end
	convertFunctions.stringList = function (str)
		return DD.stringSplit(str, ',')
	end
	convertFunctions.number = function (str)
		return tonumber(str)
	end
	convertFunctions.boolean = function (str)
		if str == 'true' then
			return true
		elseif str == 'false' then
			return false
		end
		return
	end
	convertFunctions.event = function (str)
		return DD[str]
	end
	convertFunctions.client = function (str)
		return DD.findClient('Name', str)
	end
	convertFunctions.clientList = function (str)
		local split = DD.stringSplit(str, ',')
		local list = {}
		for value in split do table.insert(list, convertFunctions.client(value)) end
		return list
	end
	
	local eventArgs = {}
	for n = 1, #args do
		local convertFunction = convertFunctions[eventClass.tbl.paramType[n]]
		convertFunction = convertFunction or convertFunctions.string
		table.insert(eventArgs, convertFunction(args[n]))
	end
	
	local event = eventClass.new(unpack(eventArgs))
	event.start()
	if event.failed then print('Event failed. This usually happens because the conditions necessary for it to occur were not met.') end
end
local validArgs = function (...)
	local eventNames = {}
	for event in DD.eventDirector.eventPool do
		for key, value in pairs(DD) do
			if value == event then
				table.insert(eventNames, key)
			end
		end
	end

	-- 1st argument will be an eventName
	local tbl = {eventNames}
	-- other arguments will be valid arguments to events
	local validEventArgs = {}
	table.insert(validEventArgs, 'true')
	table.insert(validEventArgs, 'false')
	for client in Client.ClientList do table.insert(validEventArgs, client.Name) end
	for eventName in eventNames do table.insert(validEventArgs, eventName) end
	for n = 1, 8 do
		table.insert(tbl, validEventArgs)
	end
	
	return tbl
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_startEvent', 'dd_startEvent [eventidentifier]: manually creates and starts an event with the provided identifier.', func, validArgs, false)