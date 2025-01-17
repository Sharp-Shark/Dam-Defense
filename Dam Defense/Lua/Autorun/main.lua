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
	if SERVER then
		Game.ServerSettings['AllowFriendlyFire'] = true
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
	if CLIENT or (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	
	DD.roundTimer = DD.roundTimer + 0.5
	
	if DD.roundTimer < 10 then return end
	
	if #Client.ClientList == 1 then return end
	
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
-- lists commands
DD.chatMessageFunctions.help = function (message, sender)
	if string.sub(message, 1, 1) ~= '/' then return end
	
	commands = {'help', 'jobinfo', 'events', 'myevents', 'credits', 'withdraw', 'possess', 'freecam', 'election'}
	
	local specialCommands = {rebels = false, cultists = false, whisper = false, gang = false, fire = false}
	for event in DD.eventDirector.getEventInstances('revolution') do
		specialCommands['rebels'] = true
	end
	for event in DD.eventDirector.getEventInstances('bloodCult') do
		if event.cultistsSet[sender] then
			specialCommands['cultists'] = true
			specialCommands['whisper'] = true
		end
	end
	for event in DD.eventDirector.getEventInstances('gangWar') do
		specialCommands['gang'] = true
	end
	if (DD.isClientCharacterAlive(sender) and (sender.Character.JobIdentifier == 'captain')) or sender.HasPermission(ClientPermissions.ConsoleCommands) then
		specialCommands['fire'] = true
	end
	for specialCommand, value in pairs(specialCommands) do
		if value then
			table.insert(commands, specialCommand)
		end
	end
	
	local isMisspell = true
	for command in commands do
		if string.sub(message, 1, #command + 1) == '/' .. command then
			isMisspell = false
		end
	end
	if (not isMisspell) and (message ~= '/help') then
		return
	end
	if isMisspell then
		DD.messageClient(sender, DD.stringLocalize('commandHelpMisspell', {command = message}), {preset = 'commandError'})
		return true
	end
	
	local list = ''
	for command in commands do
		list = list .. ' - /' .. command .. '\n'
	end
	list = string.sub(list, 1, #list - 1)
	
	DD.messageClient(sender, DD.stringLocalize('commandHelp', {list = list}), {preset = 'command'})
	
	return true
end
DD.chatMessageFunctions.jobinfo = function (message, sender)
	if message ~= '/jobinfo' then return end
	if not DD.isClientCharacterAlive(sender) then return end
	
	if sender.Character.SpeciesName == 'human' then
		DD.messageClient(sender, JobPrefab.Get(sender.Character.JobIdentifier).Description, {preset = 'command'})
	else
		DD.messageClient(sender, DD.stringLocalize('commandInfoMonster'), {preset = 'command'})
	end
	
	return true
end
DD.chatMessageFunctions.possess = function (message, sender)
	if message ~= '/possess' then return end
	if DD.isClientCharacterAlive(sender) then
		local message = DD.stringLocalize('commandPossessErrorDead')
		DD.messageClient(sender, message, {preset = 'command'})
		return true
	end
	
	local winner = nil
	local winnerDistance = nil
	for character in Character.CharacterList do
		if (DD.findClientByCharacter(character) == nil) and (not character.IsDead) and (character.SpeciesName ~= 'human') and
		((winner == nil) or (Vector2.Distance(sender.SpectatePos, character.WorldPosition) < winnerDistance)) then
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
DD.chatMessageFunctions.fire = function (message, sender)
	if string.sub(message, 1, 5) ~= '/fire' then return end
	if not DD.isClientCharacterAlive(sender) and not sender.HasPermission(ClientPermissions.ConsoleCommands) then return end
	if DD.isClientCharacterAlive(sender) and (sender.Character.JobIdentifier ~= 'captain') and not sender.HasPermission(ClientPermissions.ConsoleCommands) then return end
	
	local count = 1
	local numberMap = {}
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) then
			numberMap[tostring(count)] = client
			count = count + 1
		end
	end
	
	local client
	local foundTarget = false
	local targetName = string.sub(message, 7)
	if numberMap[targetName] then
		client = numberMap[targetName]
		DD.giveAfflictionCharacter(client.Character, 'beepingbomb', 5)
		foundTarget = true
		targetName = client.Name
	end
	if foundTarget == false then
		for client in Client.ClientList do
			if DD.isClientCharacterAlive(client) then
				local character = client.Character
				if (character.SpeciesName == 'human') and DD.isCharacterSecurity(character) and (client.Name == targetName) then
					client = DD.findClientByCharacter(character)
					DD.giveAfflictionCharacter(character, 'beepingbomb', 5)
					foundTarget = true
					break
				end
			end
		end
	end
	if foundTarget == false then
		for character in Character.CharacterList do
			if (not character.IsDead) and (character.SpeciesName == 'human') and DD.isCharacterSecurity(character) and (character.Name == targetName) then
				client = DD.findClientByCharacter(character)
				DD.giveAfflictionCharacter(character, 'beepingbomb', 5)
				foundTarget = true
				break
			end
		end
	end
	
	if not foundTarget then
		local text = ''
		for key, client in pairs(numberMap) do
			text = text .. DD.stringReplace(' {number}: "{name}".', {number = key, name = DD.clientLogName(client)})
		end
		if targetName == '' then
			DD.messageClient(sender, DD.stringReplace('You can fire someone using their security ID number.' .. text, {name = targetName}), {preset = 'command'})
		else
			DD.messageClient(sender, DD.stringReplace('No member of security named {name} was found. You can fire someone using their security ID number.' .. text, {name = targetName}), {preset = 'command'})
		end
		return true
	end
	
	if (sender.Character == nil) or (sender.Character.JobIdentifier ~= 'captain') then
		DD.messageAllClients(DD.stringLocalize('commandFireAdmin', {name = targetName}), {preset = 'badinfo'})
	else
		DD.messageAllClients(DD.stringLocalize('commandFire', {name = targetName}), {preset = 'badinfo'})
	end
	
	if client == nil then return true end
	
	DD.clientJob[client] = 'mechanic'
	
	client.AssignedJob = JobVariant(JobPrefab.Get('mechanic'), math.random(JobPrefab.Get('mechanic').Variants) - 1)
	local seed = tostring(math.floor(math.random() * 10^8))
	DD.characterDeathFunctions['respawnAsLaborer' .. seed] = function (character)
		local client = client
		Timer.Wait(function ()
			if client ~= DD.findClientByCharacter(character) then return end
			local seed = seed
			local job = 'mechanic'
			local pos = DD.findRandomWaypointByJob(job).WorldPosition
			local character = DD.spawnHuman(client, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
		
			DD.characterDeathFunctions['respawnAsLaborer' .. seed] = nil
		end, 100)
	end
	
	return true
end
DD.chatMessageFunctions.election = function (message, sender)
	if message ~= '/election' then return end
	if #DD.eventDirector.getEventInstances('election') > 0 then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorAlreadyOngoing'), {preset = 'command'})
		return true
	end
	if #DD.eventDirector.getMainEvents() > 0 then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorMainEvent'), {preset = 'command'})
		return true
	end
	if DD.roundData.electionBlacklistSet == nil then
		DD.roundData.electionBlacklistSet = {}
	end
	if DD.roundData.electionBlacklistSet[sender.AccountId.StringRepresentation] then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorLimitReached'), {preset = 'command'})
		return true
	end
	
	local captainIsAlive = false
	local anySecurityIsAlive = false
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and DD.isCharacterSecurity(client.Character) and (client.Character.SpeciesName == 'human') then
			if client.Character.JobIdentifier == 'captain' then
				captainIsAlive = true
			else
				anySecurityIsAlive = true
			end
		end
	end
	
	if not captainIsAlive then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorNoCaptain'), {preset = 'command'})
		return true
	end
	if not anySecurityIsAlive then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorNoSecurity'), {preset = 'command'})
		return true
	end
	
	DD.roundData.electionBlacklistSet[sender.AccountId.StringRepresentation] = true
	
	local event = DD.eventElection.new()
	event.start()
	
	return true
end

-- Load other files
require 'DD/nature'
require 'DD/procGen'
require 'DD/afflictions'
require 'DD/eventDirector'
require 'DD/latejoin'
require 'DD/autoJob'
require 'DD/money'
require 'DD/luahooks'
require 'DD/commands'
require 'DD/networking/client'
require 'DD/networking/server'
require 'DD/gui'

-- Save file
DD.saving.boot()

-- Execute when lua stops
Hook.Add("stop", "DD.stop", function ()

	for event in DD.eventDirector.events do
		if DD.debugMode then print('fail: ' .. event.name .. event.seed) end
		event.failed = true
		event.onFinishAlways()
	end
	
	return true
end)

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

-- Executes whenever a chat message is sent
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
			if (character.JobIdentifier == 'mechanic') or (character.JobIdentifier == 'clown') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('unlockallrecipes', true)
			end
			if (character.JobIdentifier == 'janitor') then
				character.GiveTalent('janitorialknowledge', true)
				character.GiveTalent('greenthumb', true)
			end
			if (character.JobIdentifier == 'engineer') or (character.JobIdentifier == 'foreman') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('unstoppablecuriosity', true)
			end
			if (character.JobIdentifier == 'captain') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('drunkensailor', true)
			end
			if (character.JobIdentifier == 'medicaldoctor') or (character.JobIdentifier == 'researcher') or (character.JobIdentifier == 'securityofficer') or (character.JobIdentifier == 'janitor') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('firemanscarry', true)
			end
			if (character.JobIdentifier == 'diver') or (character.JobIdentifier == 'engineer') or (character.JobIdentifier == 'foreman') or (character.JobIdentifier == 'jet') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('daringdolphin', true)
				character.GiveTalent('ballastdenizen', true)
			end
		end, 1000)
	end
	
	-- Mess with their idcard
	Timer.Wait(function ()
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
	end, 100)
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

-- Evil NetConfig (TM)
NetConfig.MaxHealthUpdateInterval = 0
NetConfig.LowPrioCharacterPositionUpdateInterval = 0
NetConfig.MaxEventPacketsPerUpdate = 8