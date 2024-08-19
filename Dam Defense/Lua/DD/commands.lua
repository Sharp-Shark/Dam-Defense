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
	DD.saving.autoSave({'eventDirector.enabled'})
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

-- Debug console dd_jobBan
local func = function (args)
	if CLIENT then print('Server-side only!') return end
	
	if args[1] == nil then
		DD.tablePrint(DD.jobBans, nil, 1)
		return
	end
	
	local targetName = args[1]
	local job = args[2]
	local reason = args[3]
	if reason == nil then reason = '' end
	
	local target
	for client in Client.ClientList do
		if client.Name == targetName then
			target = client
			break
		end
		if client.SessionId == targetName then
			target = client
			break
		end
	end
	
	-- target oopsie
	if target == nil then
		print('Could not find specified client.')
		return
	end
	
	-- info
	if args[2] == nil then
		DD.tablePrint(DD.jobBans[target.AccountId.StringRepresentation], nil, 1)
		return
	end
	
	local jobSet = {}
	for jobPrefab in JobPrefab.Prefabs do
		if (jobPrefab.MaxNumber > 0) and (not jobPrefab.HiddenJob) then
			jobSet[tostring(jobPrefab.Identifier)] = true
		end
	end
	jobSet['all'] = true
	-- job oopsie
	if not jobSet[job] then
		print(job .. ' is not a valid job.')
		return
	end
	
	-- actually applies the job ban
	if DD.jobBans[target.AccountId.StringRepresentation] == nil then
		DD.jobBans[target.AccountId.StringRepresentation] = {names = {}, reasons = {}}
	end
	if not DD.tableHas(DD.jobBans[target.AccountId.StringRepresentation].names, target.Name) then
		table.insert(DD.jobBans[target.AccountId.StringRepresentation].names, target.Name)
	end
	if job == 'all' then
		local jobSet = {}
		for jobPrefab in JobPrefab.Prefabs do
			if (jobPrefab.MaxNumber > 0) and (not jobPrefab.HiddenJob) then
				DD.jobBans[target.AccountId.StringRepresentation][tostring(jobPrefab.Identifier)] = true
				DD.jobBans[target.AccountId.StringRepresentation].reasons[tostring(jobPrefab.Identifier)] = reason
			end
		end
	else
		DD.jobBans[target.AccountId.StringRepresentation][job] = true
		DD.jobBans[target.AccountId.StringRepresentation].reasons[job] = reason
	end
	
	-- give message
	if reason ~= '' then
		DD.messageClient(target, DD.stringReplace('You have been banned from the {jobName} job because: {reason}.', {jobName = job, reason = reason}), {preset = 'crit'})
	end
	
	-- debug
	local text = 'Banned ' .. DD.clientLogName(target) .. ' from the ' .. job .. ' job because: ' .. reason .. '.'
	print(text)
	Game.Log(text, 10)
	DD.tablePrint(DD.jobBans[target.AccountId.StringRepresentation], nil, 1)
	
	-- network
	local message = Networking.Start("updateJobBans")
	message.WriteString(json.serialize(DD.jobBans))
	for client in Client.ClientList do
		if client.HasPermission(ClientPermissions.ConsoleCommands) then
			Networking.Send(message, client.Connection)
		end
	end
	
	-- saving
	DD.saving.autoSave({'jobBans'})
end
local validArgs = function (...)
	local tbl = {{}, {}, {'', 'no reason specified', 'you were being an idiot', 'an admin felt like it'}}
	
	if CLIENT and Game.IsMultiplayer and (not DD.receivedCaptainWhitelist) then
		local message = Networking.Start("requestUpdateJobBans")
		Networking.Send(message)
	end
	
	for client in Client.ClientList do
		table.insert(tbl[1], client.Name)
	end
	
	for jobPrefab in JobPrefab.Prefabs do
		if (jobPrefab.MaxNumber > 0) and (not jobPrefab.HiddenJob) then
			table.insert(tbl[2], tostring(jobPrefab.Identifier))
		end
	end
	table.insert(tbl[2], 'all')
	
	return tbl
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_jobBan', 'dd_jobBan [name/number] [job] [reason]: job bans a client. Specify no arguments to get the full list of job bans.', func, validArgs, false)

-- Debug console dd_jobUnban
local func = function (args)
	if CLIENT then print('Server-side only!') return end
	
	if args[1] == nil then
		DD.tablePrint(DD.jobBans, nil, 1)
		return
	end
	
	local accountId = args[1]
	local job = args[2]
	
	-- accountId oopsie
	local foundAccountId = false
	for otherAccountId, value in pairs(DD.jobBans) do
		if accountId == otherAccountId then
			 foundAccountId = true
		end
	end
	if not foundAccountId then
		print('Could not find specified client.')
		DD.tablePrint(DD.jobBans, nil, 1)
		return
	end
	
	local jobSet = {}
	for key, value in pairs(DD.jobBans[accountId]) do
		if type(value) == 'boolean' then
			jobSet[key] = true
		end
	end
	jobSet['all'] = true
	-- job oopsie
	if not jobSet[job] then
		if job ~= nil then
			print('Client is not banned from ' .. job .. ' job')
		end
		DD.tablePrint(DD.jobBans[accountId], nil, 1)
		return
	end
	
	local name = DD.jobBans[accountId].names[1]
	if args[2] == 'all' then
		DD.jobBans[accountId] = nil
	else
		DD.jobBans[accountId][job] = nil
		DD.jobBans[accountId].reasons[job] = nil
	end
	
	-- debug
	if args[2] == 'all' then
		local text = 'Revoked all job bans and job ban data from ' .. name .. '.'
		print(text)
		Game.Log(text, 10)
	else
		local text = 'Revoked ' .. args[2] ..' job ban from ' .. name .. '.'
		print(text)
		Game.Log(text, 10)
		DD.tablePrint(DD.jobBans[accountId], nil, 1)
	end
	
	-- network
	local message = Networking.Start("updateJobBans")
	message.WriteString(json.serialize(DD.jobBans))
	for client in Client.ClientList do
		if client.HasPermission(ClientPermissions.ConsoleCommands) then
			Networking.Send(message, client.Connection)
		end
	end
	
	-- saving
	DD.saving.autoSave({'jobBans'})
end
local validArgs = function (...)
	local tbl = {{}, {}}
	
	if CLIENT and Game.IsMultiplayer and (not DD.receivedCaptainWhitelist) then
		local message = Networking.Start("requestUpdateJobBans")
		Networking.Send(message)
	end
	
	for accountId, value in pairs(DD.jobBans) do
		table.insert(tbl[1], accountId)
	end
	
	for jobPrefab in JobPrefab.Prefabs do
		if (jobPrefab.MaxNumber > 0) and (not jobPrefab.HiddenJob) then
			table.insert(tbl[2], tostring(jobPrefab.Identifier))
		end
	end
	table.insert(tbl[2], 'all')
	
	return tbl
end
if CLIENT and Game.IsMultiplayer then
	func = function () return end
end
Game.AddCommand('dd_jobUnban', 'dd_jobUnban [accountId] [job]: unbans a client of a job. Do not specify a job to clear all the job ban data of a client. Specify no arguments to get the full list of job bans.', func, validArgs, false)