-- Dam Defense table
DD = {}

-- Set up the mod's path
DD.path = table.pack(...)[1]

-- Debug mode
DD.debugMode = false

-- Warnings to be printed once mod finishes loading
DD.warnings = {}

-- Allow respawing
DD.allowRespawning = true
DD.disableRespawningAfter = 60 * 45

-- Json
json = dofile(DD.path .. "/Lua/json.lua")
json.serialize = json.encode
json.parse = json.decode

-- Load utilities/dependencies
require 'DD/class'
require 'DD/utilities'
require 'DD/saving'
require 'DD/updater'

-- Load localizations
DD.localizations = {}
DD.localizations.english = dofile(DD.path .. '/Localizations/english.lua')

-- Mod workshop ID
local getSteamWorkshopId = function ()
	local text = File.Read(DD.path .. '/' .. 'filelist.xml')
	local substr = 'steamworkshopid="'
	local pos = DD.stringFind(text, substr)[1]
	return string.sub(text, pos + #substr, pos + #substr + 9) -- the "+ 9" is because steam workshop ids are exactly 9 characters long
end
DD.steamWorkshopId = getSteamWorkshopId()

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
	DD.setAllowRespawning(true)
	if Game.RoundStarted then
		Submarine.MainSub.LockX = true
		Submarine.MainSub.LockY = true
	end

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
	
	if #Client.ClientList == 1 then return end
	
	-- After 30 minutes disable respawing
	if DD.allowRespawning and (DD.roundTimer > DD.disableRespawningAfter) then
		DD.messageAllClients(DD.stringLocalize('matchHasGoneOnForTooLong'), {preset = 'crit'})
		DD.setAllowRespawning(false)
	end
	
	-- End round if everyone is dead
	local anyHumanAlive = false
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and client.Character.SpeciesName == 'human' then
			anyHumanAlive = true
			break
		end
	end
	if not anyHumanAlive then
		DD.messageAllClients(DD.stringLocalize('allTheCrewIsDead'), {preset = 'crit'})
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
	
	commands = {'help', 'events', 'myevents', 'credits', 'withdraw', 'possess', 'freecam'}
	
	local specialCommands = {rebels = false, cultists = false, whisper = false}
	for event in DD.eventDirector.getEventInstances('revolution') do
		specialCommands['rebels'] = true
	end
	for event in DD.eventDirector.getEventInstances('bloodCult') do
		if event.cultistsSet[sender] then
			specialCommands['cultists'] = true
			specialCommands['whisper'] = true
		end
	end
	
	for specialCommand, value in pairs(specialCommands) do
		if value then
			table.insert(commands, specialCommand)
		end
	end
	
	local list = ''
	for command in commands do
		list = list .. ' - /' .. command .. '\n'
	end
	list = string.sub(list, 1, #list - 1)
	
	DD.messageClient(sender, DD.stringLocalize('commandHelp', {list = list}), {preset = 'command'})
	
	return true
end
DD.chatMessageFunctions.ghostRole = function (message, sender)
	if message ~= '/possess' then return end
	if DD.isClientCharacterAlive(sender) then
		local message = DD.stringLocalize('commandPossessErrorDead')
		DD.messageClient(sender, message, {preset = 'command'})
		return true
	end
	
	local winner = nil
	local winnerDistance = 750
	for character in Character.CharacterList do
		if (DD.findClientByCharacter(character) == nil) and (not character.IsDead) and (character.SpeciesName ~= 'human') and
		(Vector2.Distance(sender.SpectatePos, character.WorldPosition) < winnerDistance) then
			winner = character
			winnerDistance = Vector2.Distance(sender.SpectatePos, character.WorldPosition)
		end
	end
	
	if winner ~= nil then
		local message = DD.stringLocalize('commandPossess')
		DD.messageClient(sender, message, {preset = 'command'})
		sender.SetClientCharacter(winner)
	else
		local message = DD.stringLocalize('commandPossessErrorNothingNearby')
		DD.messageClient(sender, message, {preset = 'command'})
	end
	
	return true
end
DD.chatMessageFunctions.freecam = function (message, sender)
	if message ~= '/freecam' then return end
	if sender.Character == nil then
		local message = DD.stringLocalize('commandFreecamErrorDead')
		DD.messageClient(sender, message, {preset = 'command'})
		return true
	end
	if sender.Character.SpeciesName == 'human' then
		local message = DD.stringLocalize('commandFreecamErrorHuman')
		DD.messageClient(sender, message, {preset = 'command'})
		return true
	end
	
	sender.SetClientCharacter(nil)
	
	return true
end

-- Load other files
require 'DD/nature'
require 'DD/afflictions'
require 'DD/eventDirector'
require 'DD/latejoin'
require 'DD/money'
require 'DD/luahooks'
require 'DD/commands'
require 'DD/discord'

-- Save file
DD.saving.boot()

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
	-- Message
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		DD.messageClient(client, JobPrefab.Get(character.JobIdentifier).Description, {preset = 'info'})
	end
	-- Give Talents
	if character.SpeciesName == 'human' then
		Timer.Wait(function ()
			if (character.JobIdentifier == 'mechanic') or (character.JobIdentifier == 'clown') then
				character.GiveTalent('unlockallrecipes', true)
			end
			if (character.JobIdentifier == 'janitor') then
				character.GiveTalent('janitorialknowledge', true)
			end
			if (character.JobIdentifier == 'engineer') then
				character.GiveTalent('unstoppablecuriosity', true)
			end
			if (character.JobIdentifier == 'captain') then
				character.GiveTalent('drunkensailor', true)
			end
			if (character.JobIdentifier == 'medicaldoctor') or (character.JobIdentifier == 'researcher') or (character.JobIdentifier == 'securityofficer') or (character.JobIdentifier == 'janitor') then
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