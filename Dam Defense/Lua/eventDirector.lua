-- Base event class all events inherit from
require 'events/base'
-- Ghost role event
require 'events/ghostRole'
-- Load the files with the events
require 'events/airdrop'
require 'events/fish'
require 'events/affliction'
require 'events/arrest'
require 'events/murder'
require 'events/revolution'
require 'events/nukies'
require 'events/serialKiller'

-- Event director table
DD.eventDirector = {}
DD.eventDirector.enabled = true
DD.eventDirector.eventPool = {
	-- Main events
	DD.eventNukies,
	DD.eventRevolution,
	DD.eventSerialKiller,
	-- Side events
	DD.eventFish,
	DD.eventAirdrop,
	DD.eventAirdropMedical,
	DD.eventAirdropSecurity,
	DD.eventAirdropSeparatist,
	DD.eventMurder,
	DD.eventArrest1984,
	DD.eventAfflictionFlu,
	DD.eventAfflictionHusk
}
DD.eventDirector.goodness = 0
DD.eventDirector.events = {}
DD.eventDirector.cooldown = nil
DD.eventDirector.mainEvent = nil
DD.eventDirector.mainEventCooldown = nil
DD.eventDirector.eventsPerClientCap = 2 -- how many events a single client can be a participant of

-- Debug function
DD.eventDirector.debug = function (list)
	local list = list
	if type(list) ~= 'table' then
		list = DD.setSubtract(DD.toSet(DD.tableKeys(DD.eventDirector)), DD.toSet({'eventPool', 'mainEvent', 'events'}))
	else
		list = DD.toSet(list)
	end
	
	for key, _ in pairs(list) do
		local value = DD.eventDirector[key]
		if type(value) == 'table' then
			print('"' .. key .. '" = ' .. DD.tablePrint(value, true, 1))
		else
			print('"' .. key .. '" = ' .. tostring(value))
		end
	end
end

-- List all ongoing events
DD.eventDirector.listEvents = function ()
	for key, value in pairs(DD.eventDirector.events) do
		print(value.name)
	end
	if DD.tableSize(DD.eventDirector.events) <= 0 then print('No events!') end
end

-- Get a list of the events a client is a participant of
DD.eventDirector.getClientEvents = function (client)
	local events = {}
	local clientIsInEvent = false
	for event in DD.eventDirector.events do
		clientIsInEvent = false
		for eventClientKey in event.clientKeys do
			if type(event[eventClientKey]) == 'table' then
				for other in event[eventClientKey] do
					if other == client then clientIsInEvent = true break end
				end
				if clientIsInEvent then break end
			else
				if event[eventClientKey] == client then clientIsInEvent = true break end
			end
		end
		if clientIsInEvent then
			table.insert(events, event)
		end
	end
	
	return events
end
DD.eventDirector.isClientBelowEventCap = function (client)
	if DD.eventDirector.eventsPerClientCap <= 0 then return true end
	
	if #DD.eventDirector.getClientEvents(client) < DD.eventDirector.eventsPerClientCap then
		return true
	else
		return false
	end
end

-- Returns a set of the people that would be considered as enemies to the client
DD.eventDirector.getClientRelations = function (client)
	local targets = {} -- people client should kill (and thusly may be killed by)
	
	local clients = DD.toSet(Client.ClientList)
	
	local others = DD.setSubtract(clients, {[client] = true})
	
	local security = {}
	for client in Client.ClientList do
		if (client.Character ~= nil) and DD.isCharacterSecurity(client.Character) then
			security[client] = true
		end
	end
	
	local clowns = {}
	for client in Client.ClientList do
		if (client.Character ~= nil) and (client.Character.JobIdentifier == 'clown') then
			clowns[client] = true
		end
	end
	
	if DD.isClientCharacterAlive(client) then
		if client.Character.SpeciesName == 'human' then
			if DD.isCharacterProletariat(client.Character) then
				targets = DD.setUnion(targets, security)
			end
			if client.Character.JobIdentifier == 'clown' then
				local nonclowns = DD.setSubtract(clients, clowns)
				targets = DD.setUnion(targets, nonclowns)
			else
				targets = DD.setUnion(targets, clowns)
			end
		else
			targets = DD.setUnion(targets, clients)
		end
	end
	
	for	event in DD.eventDirector.events do
		if event.name == 'nukie' then
			local nukies = DD.toSet(event.nukies)
			local nonnukies = DD.setSubtract(clients, nukies)
			if nukies[client] then
				targets = DD.setUnion(targets, nonnukies)
			else
				targets = DD.setUnion(targets, nukies)
			end
		elseif event.name == 'murder' then
			if event.murderer == client then
				targets = DD.setUnion(targets, {[event.victim] = true})
			else
				targets = DD.setUnion(targets, {[event.murderer] = true})
			end
		elseif event.name == 'revolution' then
			local rebels = DD.toSet(event.rebels)
			local nonrebels = DD.setSubtract(clients, rebels)
			if rebels[client] then
				targets = DD.setUnion(targets, security)
			elseif security[client] then
				targets = DD.setUnion(targets, rebels)
			end
		elseif (event.name == 'arrest') and (event.charge == 'manslaughter') then
			if event.target == client then
				targets = DD.setUnion(targets, security)
			else
				targets = DD.setUnion(targets, {[event.target] = true})
			end
		elseif event.name == 'serialKiller' then
			if event.killer == client then
				targets = DD.setUnion(targets, others)
			else
				targets = DD.setUnion(targets, {[event.killer] = true})
			end
		end
	end
	
	return targets
end

-- Death
DD.eventDirector.unfairKillCounter = {}
Hook.Add("character.death", "DD.friendlyFireDetector", function(character)
	if CLIENT and Game.IsMultiplayer then return end
	local killed = DD.findClientByCharacter(character)
	if killed == nil then return end
	if character.LastAttacker == nil then return end
	local killer = DD.findClientByCharacter(character.LastAttacker)
	if killer == nil then return end
	if (character.SpeciesName ~= 'human') or (character.LastAttacker.SpeciesName ~= 'human') then return end
	
	if not DD.eventDirector.getClientRelations(killer)[killed] then
		if DD.eventDirector.unfairKillCounter[killer] == nil then
			DD.eventDirector.unfairKillCounter[killer] = 1
		else
			DD.eventDirector.unfairKillCounter[killer] = DD.eventDirector.unfairKillCounter[killer] + 1
		end
		print('[!] ' .. killed.Name .. ' was possibly killed unfairly by: ' .. killer.Name .. '! This is their ' .. DD.eventDirector.unfairKillCounter[killer] .. ' unfair kill.')
	end
	
	return true
end)

-- Start a new event
DD.eventDirector.startNewEvent = function (isMainEvent)
	local isMainEvent = isMainEvent
	if isMainEvent == nil then isMainEvent = false end

	-- Get weights
	local weights = {}
	for key, value in pairs(DD.eventDirector.eventPool) do
		if value.tbl.isMainEvent == isMainEvent then
			weights[key] = math.max(0, value.tbl.weight - value.tbl.weight * value.tbl.goodness * DD.eventDirector.goodness)
		end
	end
	-- Start event
	local event = DD.weightedRandom(DD.eventDirector.eventPool, weights).new()
	event.start(event)
	
	if not event.failed then
		DD.eventDirector.goodness = DD.eventDirector.goodness + event.goodness / 2
		DD.eventDirector.cooldown = event.cooldown
		if isMainEvent then
			DD.eventDirector.mainEventCooldown = event.cooldown
			DD.eventDirector.mainEvent = event
		end
		return event
	else
		return
	end
end

-- Called every 1/2 a second
DD.thinkFunctions.eventDirector = function ()
	if DD.tableSize(DD.eventDirector.events) > 0 then
		for key, event in pairs(DD.eventDirector.events) do
			if event.finished then
				table.remove(DD.eventDirector.events, key)
			end
		end
	end
	if (DD.eventDirector.mainEvent ~= nil) and DD.eventDirector.mainEvent.finished then
		DD.eventDirector.cooldown = DD.eventDirector.mainEvent.cooldown / 2
		DD.eventDirector.mainEventCooldown = DD.eventDirector.mainEvent.cooldown
		DD.eventDirector.mainEvent = nil
	end
	
	if not DD.eventDirector.enabled then return end
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	
	if (DD.eventDirector.mainEvent == nil) and (DD.eventDirector.mainEventCooldown <= 0) then
		DD.eventDirector.startNewEvent(true)
		DD.eventDirector.mainEventCooldown = math.max(5, DD.eventDirector.mainEventCooldown)
	else
		DD.eventDirector.mainEventCooldown = DD.eventDirector.mainEventCooldown - 0.5
	end
	
	if DD.eventDirector.cooldown <= 0 then
		DD.eventDirector.startNewEvent()
	else
		DD.eventDirector.cooldown = DD.eventDirector.cooldown - 0.5
	end
end

-- Called at round start
DD.roundStartFunctions.eventDirector = function ()
	DD.eventDirector.goodness = 0
	DD.eventDirector.mainEvent = nil
	DD.eventDirector.events = {}
	DD.eventDirector.mainEventCooldown = 30
	DD.eventDirector.cooldown = DD.eventDirector.mainEventCooldown
end

-- Lists to the message sender the events they're a participant of
DD.chatMessageFunctions.myEvents = function (message, sender)
	if message ~= '/myevents' then return end
	
	local list = ''
	for event in DD.eventDirector.getClientEvents(sender) do
		list = list .. event.name .. ', '
	end
	list = string.sub(list, 1, #list - 2)
	
	if list == '' then
		list = 'none (you are in no events)'
	end
	
	DD.messageClient(sender, DD.stringReplace('The events you are currently in are: {list}.', {list = list}), {preset = 'command'})
	
	return true
end

-- If it's a client then do run the event director
if CLIENT then
	DD.thinkFunctions.eventDirector = nil
	DD.roundStartFunctions.eventDirector = nil
end

-- Short for DD.eventDirector for live inputting lua commands in debug menu
if ed == nil then
	ed = DD.eventDirector
else
	DD.ed = DD.eventDirector
end