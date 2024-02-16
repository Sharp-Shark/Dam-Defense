-- Dam Defense table
DD = {}

-- Set up the mod's path
DD.path = table.pack(...)[1]

-- Debug mode
DD.debugMode = false

-- Warnings to be printed once mod finishes loading
DD.warnings = {}

-- Json
json = dofile(DD.path .. "/Lua/json.lua")
json.serialize = json.encode
json.parse = json.decode

-- Husk Control cuz WHY NOT?!
Game.EnableControlHusk(true)

-- Functions executed at round start
DD.roundStartFunctions = {}
local doRoundStartFunctions = function ()
	for name, func in pairs(DD.roundStartFunctions) do
		func()
	end
end
DD.roundStartFunctions.main = function ()
	DD.roundData = {}
	DD.roundEnding = false
	DD.roundTimer = 0
end

-- Functions executed at round end
DD.roundEndFunctions = {}
local doRoundEndFunctions = function ()
	for name, func in pairs(DD.roundEndFunctions) do
		func()
	end
end
DD.roundEndFunctions.main = function ()
	DD.roundEnding = true
end

-- Functions executed 60 times a second
--[[
newThinkFunctions is a queue of functions to be added to thinkFunctions
The functions on the queue are all added to thinkFunctions right before the functions in thinkFunctions are executed
It was added to solve a bug where creating a new event inside another event's onFinish() caused an error in doThinkFunctions()
--]]
DD.thinkFunctions = {}
DD.newThinkFunctions = {}
local doThinkFunctions = function ()
	for name, func in pairs(DD.newThinkFunctions) do
		DD.thinkFunctions[name] = func
		DD.newThinkFunctions[name] = nil
	end
	for name, func in pairs(DD.thinkFunctions) do
		func()
	end
end
DD.thinkFunctions.main = function ()
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) or CLIENT then return end
	
	DD.roundTimer = DD.roundTimer + 0.5
	
	if DD.roundTimer < 10 then return end
	
	local anyHumanAlive = false
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and client.Character.SpeciesName == 'human' then
			anyHumanAlive = true
			break
		end
	end
	
	if not anyHumanAlive then
		DD.messageAllClients('All of the crew is dead! Round ending in 10 seconds.', {preset = 'crit'})
		DD.roundData.roundEnding = true
		Timer.Wait(function ()
			Game.EndGame()
		end, 10 * 1000)
	end
end

-- Functions executed whenever a character dies
DD.characterDeathFunctions = {}
local doCharacterDeathFunctions = function (character)
	for name, func in pairs(DD.characterDeathFunctions) do
		func(character)
	end
end
DD.characterDeathFunctions.corpseCleanUp = function (character)
	DD.roundData.creatureGrowthTimer[character] = nil
	DD.roundData.creatureBreedTimer[character] = nil

	if (character.SpeciesName ~= 'human') and (character.SpeciesName ~= 'humanhusk') then
		Timer.Wait(function ()
			Entity.Spawner.AddEntityToRemoveQueue(character)
		end, 60*1000)
	end

	return true
end

-- Functions executed whenever a chat message is sent
DD.chatMessageFunctions = {}
local doChatMessageFunctions = function (message, sender)
	local returnValue
	for name, func in pairs(DD.chatMessageFunctions) do
		if returnValue == nil then returnValue = func(message, sender) end
	end
	return returnValue
end
DD.chatMessageFunctions.help = function (message, sender)
	if message ~= '/help' then return end
	
	commands = {'help', 'myevents', 'credits', 'withdraw'}
	
	local list = ''
	for command in commands do
		list = list .. ' - /' .. command .. '\n'
	end
	list = string.sub(list, 1, #list - 1)
	
	DD.messageClient(sender, DD.stringReplace('List of chat commands:\n{list}.', {list = list}), {preset = 'command'})
	
	return true
end

-- Load dependencies
require 'utilities'
require 'class'
require 'nature'
require 'afflictions'
require 'eventDirector'
require 'money'
require 'saving'
require 'commands'

-- Execute at round start
Hook.Add("roundStart", "DD.prepareRound", function ()

	doRoundStartFunctions()
	
	return true
end)

-- Execute at round end
Hook.Add("roundEnd", "DD.finishRound", function ()

	doRoundEndFunctions()
	
	return
end)

-- Executes constantly
DD.thinkCounter = 0
Hook.Add("think", "DD.think", function ()
	DD.thinkCounter = DD.thinkCounter + 1
	
	doThinkFunctions()
	
	return true
end)

-- Executes whenever someone dies
Hook.Add("character.death", "DD.characterDeath", function (character)
	
	doCharacterDeathFunctions(character)
	
	return true
end)

-- Executes cwhenever a chat message is sent
Hook.Add("chatMessage", "DD.chatMessage", function (message, sender)
	return doChatMessageFunctions(message, sender)
end)

-- Make the following properties of items changeable (this is important for DD.onGiveJobItems)
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Item"], "set_InventoryIconColor")
-- Give talents
Hook.Add("character.giveJobItems", "DD.onGiveJobItems", function (character)
	-- Give Talents
	if character.SpeciesName == 'human' then
		Timer.Wait(function ()
			if (character.JobIdentifier == 'mechanic') or (character.JobIdentifier == 'laborer') or (character.JobIdentifier == 'clown') then
				character.GiveTalent('unlockallrecipes', true)
			end
			if (character.JobIdentifier == 'captain') then
				character.GiveTalent('drunkensailor', true)
			end
			if (character.JobIdentifier == 'medicaldoctor') or (character.JobIdentifier == 'researcher') then
				character.GiveTalent('firemanscarry', true)
			end
			if (character.JobIdentifier == 'diver') or (character.JobIdentifier == 'engineer') or (character.JobIdentifier == 'jet') then
				character.GiveTalent('daringdolphin', true)
				character.GiveTalent('ballastdenizen', true)
			end
		end, 1000)
	end
	
	-- Mess with their idcard
	local idcard = character.Inventory.GetItemAt(DD.invSlots.idcard)
	if idcard ~= nil then
		local jobPrefab = JobPrefab.Get(character.JobIdentifier)
		
		-- Give idcard any tags that it should have
		local waypoint = DD.findRandomWaypointByJob(character.JobIdentifier)
		if waypoint ~= nil then
			local tags = ''
			for tag in waypoint.IdCardTags do
				if not idcard.HasTag(tag) then tags = tags .. ',' .. tag end
			end
			idcard.Tags = idcard.Tags .. tags
		end
		
		-- Set the idcard's color to be the job's UIColor
		local color = jobPrefab.UIColor
		color = Color.Lerp(color, Color.White, 0.25)
		idcard.SpriteColor = color
		idcard['set_InventoryIconColor'](color)
		
		-- Sync changes for clients
		if SERVER then
			local item = idcard
			local tags = item.SerializableProperties[Identifier("Tags")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
			local sprcolor = item.SerializableProperties[Identifier("SpriteColor")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(sprcolor, item))
			local invColor = item.SerializableProperties[Identifier("InventoryIconColor")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(invColor, item))
		end
	end
end)

-- Sends a message to husks telling them about their objective
Hook.Add("husk.clientControl", "DD.huskMessage", function (client, husk)
	print('test')
	
	DD.messageClient(client, 'You have become a husk! Try and spread the infection to other players, thusly turning everyone into a husk.', {preset = 'crit'})

	return true
end)

-- Round start functions called at lua script execution just incase reloadlua is called mid-round
doRoundStartFunctions()

-- Debug mode warning
if DD.debugMode then
	DD.warn('Dam Defense is running in debug mode! Autosaving is disabled.')
end

-- Print warnings
Timer.Wait(function ()
	if DD.tableSize(DD.warnings) > 0 then
		print(' ')
		print('[!] Warnings from Dam Defense')
		for warning in DD.warnings do
			print(' - ' .. warning)
		end
	end
end, 0)