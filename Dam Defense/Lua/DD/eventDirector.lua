-- Base event class all events inherit from
require 'DD/events/base'
-- Ghost role event
require 'DD/events/ghostRole'
-- Load the files with the events
require 'DD/events/airdrop'
require 'DD/events/fish'
require 'DD/events/affliction'
require 'DD/events/blackout'
require 'DD/events/arrest'
require 'DD/events/murder'
require 'DD/events/revolution'
require 'DD/events/nukies'
require 'DD/events/serialKiller'
require 'DD/events/bloodCult'
require 'DD/events/greenskins'
require 'DD/events/vip'
require 'DD/events/gang'
require 'DD/events/mercs'
require 'DD/events/deathSquad'
require 'DD/events/election'
require 'DD/events/wizard'
require 'DD/events/chimera'
require 'DD/events/attackbot'
require 'DD/events/terrorist'

-- Event director table
DD.eventDirector = {}
DD.eventDirector.enabled = true
DD.eventDirector.eventPool = {
	-- Main events
	DD.eventNukies,
	DD.eventRevolution,
	DD.eventSerialKiller,
	DD.eventBloodCult,
	DD.eventGreenskins,
	DD.eventDeathSquad,
	-- Side events
	DD.eventFish,
	DD.eventAirdrop,
	DD.eventAirdropMedical,
	DD.eventAirdropSecurity,
	DD.eventAirdropArtifact,
	DD.eventMurder,
	DD.eventArrest1984,
	DD.eventAfflictionFlu,
	DD.eventAfflictionTB,
	DD.eventBlackout,
	DD.eventVIP,
	DD.eventMERCS,
	DD.eventElection,
	DD.eventWizard,
	DD.eventGang,
	DD.eventChimera,
	DD.eventAttackbot,
	DD.eventTerrorist,
}
DD.eventDirector.goodness = 0
DD.eventDirector.events = {}
DD.eventDirector.cooldown = nil
DD.eventDirector.mainEvent = nil
DD.eventDirector.mainEventCooldown = nil
DD.eventDirector.eventsPerClientCap = 2 -- how many events a single client can be a participant of
DD.eventDirector.mainEventCap = 1 -- how many main events can be active at the same time (negative values means it is uncapped)
DD.eventDirector.canMainEventBeRegularEvent = false -- can a main event be called when a regular event is to be started
DD.eventDirector.mainEventsDisableRespawning = true -- if there is any active main event then respawning will be disabled
DD.eventDirector.goodnessBiasInitial = -3 -- offsets goodness
DD.eventDirector.goodnessBiasGrowth = 1 / 60 / 5  -- per second
DD.eventDirector.cooldownDecrementInitial = 1 -- per second
DD.eventDirector.cooldownDecrementGrowth = 1 / 60 / 30 -- per second

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
	for key, event in pairs(DD.eventDirector.events) do
		local text = ''
		for eventClientKey in event.clientKeys do
			text = text .. eventClientKey .. ' = '
			if type(event[eventClientKey]) == 'table' then
				text = text .. '{ '
				local bool = true
				for other in event[eventClientKey] do
					text = text .. '"' .. other.Name .. '", '
					bool = false
				end
				if bool then
					text = text .. '}'
				else
					text = string.sub(text, 1, #text - #', ') .. ' }'
				end
			elseif event[eventClientKey] ~= nil then
				text = text .. '"' .. event[eventClientKey].Name .. '"'
			end
			text = text .. ', '
		end
		if text ~= '' then text = '{ ' .. string.sub(text, 1, #text - #', ') .. ' }' end
		text = '[' .. key ..  '] ' .. event.name .. event.seed .. ' ' .. text
		print(text)
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

-- Sees if client is below configured event cap
DD.eventDirector.isClientBelowEventCap = function (client)
	if DD.eventDirector.eventsPerClientCap <= 0 then return true end
	
	if #DD.eventDirector.getClientEvents(client) < DD.eventDirector.eventsPerClientCap then
		return true
	else
		return false
	end
end

-- Find the amount of instaces of an event
DD.eventDirector.getEventInstances = function (eventName)
	local tbl = {}
	
	for event in DD.eventDirector.events do
		if event.name == eventName then
			table.insert(tbl, event)
		end
	end
	
	return tbl
end

-- Get the list of main events
DD.eventDirector.getMainEvents = function ()
	local tbl = {}
	
	for event in DD.eventDirector.events do
		if event.isMainEvent then
			table.insert(tbl, event)
		end
	end
	
	return tbl
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
	
	local antagSafe = {}
	for client in Client.ClientList do
		if (client.Character ~= nil) and DD.antagSafeJobs[tostring(client.Character.JobIdentifier)] then
			antagSafe[client] = true
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
		if event.name == 'nukies' then
			local nukies = DD.toSet(event.nukies)
			local nonnukies = DD.setSubtract(clients, nukies)
			if nukies[client] then
				targets = DD.setUnion(targets, nonnukies)
			else
				targets = DD.setUnion(targets, nukies)
			end
		elseif event.name == 'deathSquad' then
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
		elseif event.name == 'vip' then
			if (event.vip ~= client) and (event.guard ~= client) and (not antagSafe[client]) then
				local tbl = {}
				if event.vip ~= nil then tbl[event.vip] = true end
				if event.guard ~= nil then tbl[event.guard] = true end
				targets = DD.setUnion(targets, tbl)
			end
		elseif event.name == 'revolution' then
			local rebels = DD.toSet(event.rebels)
			local nonrebels = DD.setSubtract(clients, rebels)
			if rebels[client] then
				targets = DD.setUnion(targets, security)
			elseif security[client] then
				targets = DD.setUnion(targets, rebels)
			end
		elseif event.name == 'bloodCult' then
			local cultists = DD.toSet(event.cultists)
			local noncultists = DD.setSubtract(clients, cultists)
			if cultists[client] then
				targets = DD.setUnion(targets, noncultists)
			else
				targets = DD.setUnion(targets, cultists)
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
		local text = '{killedName} was possibly killed unfairly by {killerName}! This is their {count} possibly unfair kill.'
		Game.Log(DD.stringReplace(text, {killedName = DD.clientLogName(killed), killerName = DD.clientLogName(killer), count = DD.eventDirector.unfairKillCounter[killer]}), 10)
	end
	
	return true
end)

-- Start a new event
DD.eventDirector.startNewEvent = function (isMainEvent)
	local isMainEvent = isMainEvent
	if isMainEvent == nil then isMainEvent = false end

	-- Count players
	local players = 0
	local alive = 0
	for client in Client.ClientList do
		if client.InGame and (DD.isClientCharacterAlive(client) or DD.isClientRespawnable(client)) then
			players = players + 1
			if DD.isClientCharacterAlive(client) then
				alive = alive + 1
			end
		end
	end
	local alivePercentage = alive / players
	local deadPercentage = 1 - alivePercentage
	
	-- calculates the weight of an event
	local calculateEventWeight = function (eventClass)
		if ((eventClass.tbl.isMainEvent ~= isMainEvent) and not (eventClass.tbl.isMainEvent and DD.eventDirector.canMainEventBeRegularEvent)) or
		(eventClass.tbl.minimunAlivePercentage > alivePercentage) or (eventClass.tbl.minimunDeadPercentage > deadPercentage) or (DD.roundTimer < eventClass.tbl.minimunTimeElapsed) then
			return 0
		end
		local directorGoodness = DD.eventDirector.goodness + DD.eventDirector.goodnessBiasInitial + DD.eventDirector.goodnessBiasGrowth * DD.roundTimer
		local weight = eventClass.tbl.weight / math.max(0.5, math.abs(eventClass.tbl.goodness + directorGoodness))
		return math.max(0, weight)
	end

	-- Get weights
	local weights = {}
	for key, eventClass in pairs(DD.eventDirector.eventPool) do
		local weight = calculateEventWeight(eventClass)
		if weight > 0 then
			weights[key] = weight
		end
	end
	-- Start event
	local eventClass = DD.weightedRandom(DD.eventDirector.eventPool, weights)
	if eventClass == nil then return end
	local event = eventClass.new()
	event.start(event)
	
	if not event.failed then
		DD.eventDirector.goodness = DD.eventDirector.goodness + event.goodness
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
	-- Respawning is disabled if there are ongoing main events
	if ((#DD.eventDirector.getMainEvents() > 0) and DD.eventDirector.mainEventsDisableRespawning) then
		local canAnyoneRespawn = false
		for client in Client.ClientList do
			if DD.isClientRespawnable(client) then
				if (DD.eventDirector.mainEvent ~= nil) and (DD.eventDirector.mainEvent.lateJoinSpawn ~= nil) then
					if (DD.eventDirector.mainEvent.lateJoinBlacklistSet == nil) or not DD.eventDirector.mainEvent.lateJoinBlacklistSet[client.AccountId.StringRepresentation] then
						canAnyoneRespawn = true
					end
				elseif not DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation] then
					canAnyoneRespawn = true
				end
			end
		end
		if canAnyoneRespawn then
			DD.setRespawning('latejoin')
		else
			DD.setRespawning('latejoin-disabled')
		end
	else
		DD.setRespawning('default')
	end
	
	if (DD.eventDirector.mainEvent ~= nil) and DD.eventDirector.mainEvent.finished then
		DD.eventDirector.cooldown = 60 * 2
		DD.eventDirector.mainEventCooldown = DD.eventDirector.mainEvent.cooldown
		DD.eventDirector.mainEvent = nil
	end
	
	if not DD.eventDirector.enabled then return end
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	local timesPerSecond = 2
	
	-- get current cooldown value decrement amount
	local cooldownDecrement = math.round(DD.eventDirector.cooldownDecrementInitial + DD.roundTimer * DD.eventDirector.cooldownDecrementGrowth, 1)
	
	-- main event
	if (DD.eventDirector.mainEvent == nil) and (DD.eventDirector.mainEventCooldown <= 0) then
		DD.eventDirector.startNewEvent(true)
		DD.eventDirector.mainEventCooldown = 1 -- I don't know if this line is needed, but I rather play it safe
	else
		DD.eventDirector.mainEventCooldown = DD.eventDirector.mainEventCooldown - cooldownDecrement / timesPerSecond
	end
	
	-- side/minor events
	if DD.eventDirector.cooldown <= 0 then
		DD.eventDirector.startNewEvent()
	else
		DD.eventDirector.cooldown = DD.eventDirector.cooldown - cooldownDecrement / timesPerSecond
	end
end

-- Called at round start
DD.roundStartFunctions.eventDirector = function ()
	DD.eventDirector.goodness = 0
	DD.eventDirector.mainEvent = nil
	DD.eventDirector.events = {}
	DD.eventDirector.cooldown = 60 * 2
	DD.eventDirector.mainEventCooldown = 60 * 8
end

-- Lists to the message sender all of the publicly known events
DD.chatMessageFunctions.events = function (message, sender)
	if message ~= '/events' then return end
	
	local clientEventsSet = DD.toSet(DD.eventDirector.getClientEvents(sender))
	
	local list = ''
	for event in DD.eventDirector.events do
		if event.public then
			if ((event.name == 'arrest') or (event.name == 'arrest1984')) and (event.isTargetKnown or (event.target == sender)) then
				list = list .. ' - ' .. event.name .. DD.stringReplace(' ({target} is {targetName})', {target = DD.stringLocalize('target'), targetName = DD.clientLogName(event.target)}) .. '\n'
			else
				list = list .. ' - ' ..  event.name .. '\n'
			end
		elseif clientEventsSet[event] then
			if (event.name == 'murder') and (event.murderer == sender) then
				list = list .. ' - ' .. event.name .. DD.stringReplace(' ({secret}) ({target} is {victimName})', {secret = DD.stringLocalize('secret'), target = DD.stringLocalize('target'), victimName = DD.clientLogName(event.victim)}) .. '\n'
			else
				list = list .. ' - ' .. event.name .. ' (' .. DD.stringLocalize('secret') .. ')' .. '\n'
			end
		end
	end
	list = string.sub(list, 1, #list - 1)
	
	if list == '' then
		list = DD.stringLocalize('commandEventsNone')
	end
	
	DD.messageClient(sender, DD.stringLocalize('commandEvents', {list = list}), {preset = 'command'})
	
	return true
end

-- If it's a client then do NOT run the event director
if CLIENT then
	DD.eventDirector.enabled = false
	DD.thinkFunctions.eventDirector = nil
	DD.roundStartFunctions.eventDirector = nil
end

-- Short for DD.eventDirector for live inputting lua commands in debug menu
if ed == nil then
	ed = DD.eventDirector
end
DD.ed = DD.eventDirector