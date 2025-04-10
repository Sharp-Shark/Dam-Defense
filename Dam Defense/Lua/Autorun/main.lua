-- Dam Defense table
if DD == nil then DD = {} end

-- Set up the mod's path
DD.path = table.pack(...)[1]

-- Debug mode
DD.debugMode = false

-- Warnings to be printed once mod finishes loading
DD.warnings = {}

-- Allow respawing
DD.respawningState = 'default'

-- Json
json = dofile(DD.path .. "/Lua/json.lua")
json.serialize = json.encode
json.parse = json.decode

-- Load utilities/dependencies
require 'DD/secret'
require 'DD/class'
require 'DD/utilities'
require 'DD/saving'

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

-- CSharp
if pcall(function ()
	DamDefenseClass = LuaUserData.RegisterType('DamDefense.DamDefenseClass')
	DD.fullPath = DamDefenseClass.Type.Path
	DD.openHTML = DamDefenseClass.Type.OpenHTML
end) then
	DD.isCSharpLoaded = true
else
	DD.isCSharpLoaded = false
end

-- Necessary for other bits of the code to work
RelationType = LuaUserData.CreateEnumTable('Barotrauma.RelatedItem+RelationType')
LuaUserData.RegisterType('System.Collections.Generic.Dictionary`2[[Barotrauma.RelatedItem+RelationType],[System.Collections.Generic.List`1[[Barotrauma.RelatedItem]]]]')
RelatedItem = LuaUserData.CreateStatic('Barotrauma.RelatedItem', true)
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.WayPoint"], "set_IdCardTags")
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.Item"], "set_InventoryIconColor")
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.DamageModifier"], "set_DamageMultiplier")

-- Functions executed at round start
DD.roundStartFunctions = {}
local doRoundStartFunctions = function ()
	for name, func in pairs(DD.roundStartFunctions) do
		func()
	end
end
DD.roundStartFunctions.main = function ()
	DD.setRespawning('default')
	
	if Submarine.MainSub ~= nil then
		if Game.RoundStarted then
			-- lock sub
			Submarine.MainSub.LockX = true
			Submarine.MainSub.LockY = true
		end
		
		-- automations for sub editor
		if CLIENT and Game.IsSingleplayer and Game.IsSubEditor then
			local isValidConnection = function (connection)
				if (connection.Name ~= 'power') and (connection.Name ~= 'power_in') then return false end
			
				local item = connection.Item
				if item.HasTag('junctionbox') then return false end
				
				local tags = {
					'oxygengenerator',
					'medicalfabricator',
					'deconstructor',
					'fabricator',
				}
				for tag in tags do
					if item.HasTag(tag) then
						return true
					end
				end
				
				local attribute = item.Prefab.ConfigElement.GetAttribute('nameidentifier')
				if (attribute ~= nil) and (attribute.Value == 'lamp') then return true end
				if item.Prefab.Identifier == 'lamp' then return true end
				
				return false
			end
			for item in Item.ItemList do
				-- do not lock some wires
				local component = item.GetComponentString('Wire')
				if component ~= nil then
					if (#component.connections == 2) and (isValidConnection(component.connections[1]) or isValidConnection(component.connections[2])) then
						component.NoAutoLock = true
					end
				end
				-- improves performance for maps with lots of ores or plants
				if (item.HasTag('ore') or item.HasTag('plant')) and (item.GetComponentString('LightComponent') ~= nil) then
					item.GetComponentString('LightComponent').Range = 65
					item.GetComponentString('LightComponent').CastShadows = false
					item.GetComponentString('LightComponent').DrawBehindSubs = false
				end
				-- color location markers (dd_location)
				if item.Prefab.Identifier == 'dd_location' then
					if #item.linkedTo > 0 then
						if item.linkedTo[1].HasTag('dd_plantspawn') then
							item.SpriteColor = Color(155, 255, 155)
							item.Scale = 0.5
						end
					end
					if item.HasTag('dd_plantspawn') then
						item.SpriteColor = Color(155, 255, 55)
						item.Scale = 0.5
					end
					if item.HasTag('dd_airdrop') then
						item.SpriteColor = Color(89,191,63)
						item.Scale = 1.0
					end
					if item.HasTag('dd_airdropmedical') then
						item.SpriteColor = JobPrefab.Get('medicaldoctor').UIColor
						item.Scale = 1.0
					end
					if item.HasTag('dd_airdropsecurity') then
						item.SpriteColor = JobPrefab.Get('securityofficer').UIColor
						item.Scale = 1.0
					end
					if item.HasTag('dd_airdropseparatist') then
						item.SpriteColor = Color(255,155,55)
						item.Scale = 1.0
					end
					if item.HasTag('dd_airdropartifact') then
						item.SpriteColor = Color(155,55,255)
						item.Scale = 1.0
					end
					if item.HasTag('dd_dambasin') then
						item.SpriteColor = Color(55,100,255)
						item.Scale = 1.0
					end
					if item.HasTag('dd_wetsewer') then
						item.SpriteColor = Color(55,255,200)
						item.Scale = 1.0
					end
				end
			end
		end
	
		-- automatically put idcard tags in spawnpoints for standartization
		local jobTags = {
			captain = 'id_captain,id_security,id_medic,id_engineer,id_janitor',
			diver = 'id_security,id_engineer,id_janitor',
			securityofficer = 'id_security,id_engineer,id_janitor',
			foreman = 'id_security,id_engineer,id_janitor',
			researcher = 'id_researcher,id_medic',
			medicaldoctor = 'id_medic',
			engineer = 'id_engineer',
			janitor = 'id_janitor',
			bodyguard = 'id_laborer',
			mechanic = 'id_laborer',
			clown = 'id_clown,id_laborer',
			assistant = 'id_assistant',
			-- other jobs
			mercs = 'id_captain,id_security,id_medic,id_engineer,id_janitor',
			mercsevil = 'id_jet',
			jet = 'id_jet'
		}
		for waypoint in  Submarine.MainSub.GetWaypoints(false) do
			if (waypoint.AssignedJob ~= nil) and (jobTags[tostring(waypoint.AssignedJob.Identifier)] ~= nil) then
				waypoint['set_IdCardTags'](DD.stringSplit(jobTags[tostring(waypoint.AssignedJob.Identifier)], ','))
			end
		end
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
DD.characterDeathFunctions.main = function (character)
	if CLIENT then return end
	
	-- Do death message to deceased
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		Timer.Wait(function ()
			if (client ~= nil) and not DD.isClientCharacterAlive(client) then
				DD.messageClient(client, DD.stringLocalize('deathMessage'), {preset = 'crit'})
			end
		end, 1000)
	end
	
	-- remove grow/breed timers of dead creature
	DD.roundData.creatureGrowthTimer[character] = nil
	DD.roundData.creatureBreedTimer[character] = nil

	return true
end

-- Functions executed whenever a chat message is sent
DD.chatMessageFunctions = {}
local doChatMessageFunctions = function (message, sender)
	if CLIENT then return end

	local returnValue
	for name, func in pairs(DD.chatMessageFunctions) do
		if returnValue == nil then returnValue = func(message, sender) end
	end
	return returnValue
end
-- lists commands
DD.chatMessageFunctions.help = function (message, sender)
	if (string.sub(message, 1, 1) ~= '/') and (string.sub(message, 1, 1) ~= '!') then return end
	
	local specialCommands = {'help', 'info', 'neverantag', 'events', 'credits', 'withdraw', 'possess', 'freecam', 'election', 'rebels', 'cultists', 'whisper', 'gang', 'fire'}
	local commandText = {
		help = 'Gives a list of commands. List of commands given will only include commands relevant for the current context.',
		info = 'Gives relevant job and role information.',
		neverantag = 'Toggles between being antag exempt and being antag eligible. Being dead or having an antag safe job may make you exempt/eligible despite of whatever you set this to.',
		events = 'Gives a list of public and personal events. Some events are secret and will not be listed here.',
		credits = 'Informs the amount of credits currently in the bank account. Do /withdraw to withdraw credits. There is no /deposit command, so withdrawing cannot be undone.',
		withdraw = 'Withdraws an amount of credits from the bank account. If no amount of credits is specified, all the credits will be withdrawn. Credits cannot be deposited.',
		possess = 'Possess the nearest creature that is not already being controlled by a player. Do /freecam to go into spectating. Will not respawn whilst controlling a creature.',
		freecam = 'Goes into spectating. Can be used whilst controlling a creature. If you turn into a husk, you can use this stop being the husk and become eligible to respawning.',
		election = 'Starts an election event to replace the current mayor/captain. Insert your money into a ballot box and either choose YES to remove the captain or NO to keep him.',
		rebels = 'Lists rebel leaders if you are a rebel leader or if enough time has elapsed. This command also informs how much more time needs to elapse.',
		cultists = 'Lists fellow blood cultists. List will not include undead zombies, but undead zombies are allied to cultists and can also use this command.',
		whisper = 'Globally and secretly send a text message to all blood cultists and undead zombies. Command can be used by both cultists and zombies.',
		gang = 'Lists fellow gang members and the name of your boss. Be cautious with enemy gangs.',
		fire = 'Usable by the mayor to lethally fire members of security or to kill himself. Type /fire without arguments to see what number relates to each guard. Numbers can be used in place of names.',
	}
	
	local tbl = {}
	for command in specialCommands do
		tbl[command] = false
	end
	specialCommands = tbl
	
	specialCommands['help'] = true
	if Game.RoundStarted then
		specialCommands['events'] = true
		if DD.isClientCharacterAlive(sender) then
			specialCommands['info'] = true
			if sender.Character.SpeciesName == 'human' then
				specialCommands['credits'] = true
				specialCommands['withdraw'] = true
				if (DD.roundData.electionBlacklistSet == nil) or (not DD.roundData.electionBlacklistSet[sender.AccountId.StringRepresentation]) then
					specialCommands['election'] = true
				end
			else
				specialCommands['freecam'] = true
			end
		else
			specialCommands['possess'] = true
		end
		if (DD.isClientCharacterAlive(sender) and (sender.Character.JobIdentifier == 'captain')) or sender.HasPermission(ClientPermissions.ConsoleCommands) then
			specialCommands['fire'] = true
		end
		-- event related commands
		if #DD.eventDirector.getEventInstances('revolution') > 0 then
			specialCommands['rebels'] = true
		end
		for event in DD.eventDirector.getEventInstances('bloodCult') do
			if event.cultistsSet[sender] or (DD.isClientCharacterAlive(sender) and (sender.Character.SpeciesName == 'Humanundead')) then
				specialCommands['cultists'] = true
				specialCommands['whisper'] = true
			end
		end
		for event in DD.eventDirector.getEventInstances('gang') do
			if event.gangstersSet[sender] then
				specialCommands['gang'] = true
			end
		end
	end
	
	local commands = {}
	for command, value in pairs(specialCommands) do
		if value then
			table.insert(commands, command)
		end
	end
	
	local isValid = true
	local isMisspell = true
	for command, value in pairs(specialCommands) do
		if string.sub(message, 1, #command + 1) == '/' .. command then
			isMisspell = false
			isValid = value
		end
	end
	if (not isMisspell) and (string.sub(message, 1, 5) ~= '/help') then
		if not isValid then
			DD.messageClient(sender, DD.stringLocalize('commandHelpInvalid', {command = message}), {preset = 'commandError'})
			return true
		end
		return
	end
	if isMisspell then
		DD.messageClient(sender, DD.stringLocalize('commandHelpMisspell', {command = message}), {preset = 'commandError'})
		return true
	end
	
	if specialCommands[string.sub(message, 7, #message)] then
		DD.messageClient(sender, '/' .. string.sub(message, 7, #message) .. ' - ' .. commandText[string.sub(message, 7, #message)], {preset = 'command'})
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
DD.chatMessageFunctions.jobinfo = function (message, sender, special)
	if (message ~= '/info') and (not special) then return end
	if not DD.isClientCharacterAlive(sender) then return end
	
	local preset = special and 'crit' or 'command'
	
	if sender.Character.SpeciesName == 'human' then
		DD.messageClient(sender, JobPrefab.Get(sender.Character.JobIdentifier).Description, {preset = preset})
	else
		if DD.isCharacterHusk(sender.Character) then
			DD.messageClient(sender, DD.stringLocalize('huskInfo'), {preset = preset})
		elseif sender.Character.SpeciesName == 'humanUndead' then
			local undeadInfo = DD.stringLocalize('undeadInfo')
			if #DD.eventDirector.getEventInstances('bloodCult') >= 1 then
				undeadInfo = undeadInfo .. ' ' .. DD.stringLocalize('undeadInfoBloodCult')
			end
			DD.messageClient(sender, undeadInfo, {preset = preset})
		elseif (sender.Character.SpeciesName == 'humanGoblin') or (sender.Character.SpeciesName == 'humanTroll') then
			DD.messageClient(sender, DD.stringLocalize('greenskinInfo'), {preset = preset})
		else
			DD.messageClient(sender, DD.stringLocalize('commandInfoMonster'), {preset = preset})
		end
	end
	
	return true
end
DD.antagExemptClients = {}
DD.chatMessageFunctions.neverantag = function (message, sender)
	if message ~= '/neverantag' then return end
	
	if DD.antagExemptClients[sender.AccountId.StringRepresentation] then
		DD.messageClient(sender, DD.stringLocalize('commandNeverantagExempt'), {preset = 'command'})
		DD.antagExemptClients[sender.AccountId.StringRepresentation] = nil
	else
		DD.messageClient(sender, DD.stringLocalize('commandNeverantagEligible'), {preset = 'command'})
		DD.antagExemptClients[sender.AccountId.StringRepresentation] = true
	end
	DD.saving.autoSave({'antagExemptClients'})
	
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
		
		DD.chatMessageFunctions.jobinfo('', sender, true)
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
			DD.messageClient(sender, DD.stringLocalize('commandFireError', {name = targetName}) .. text, {preset = 'command'})
		else
			DD.messageClient(sender, DD.stringLocalize('commandFireErrorClientNotFound', {name = targetName}) .. text, {preset = 'command'})
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
			
			-- get job and job variant
			local job = 'mechanic'
			local variant
			for jobVariant in client.JobPreferences do
				if tostring(jobVariant.Prefab.Identifier) == job then
					variant = jobVariant.Variant
				end
			end
			if variant == nil then variant = math.random(JobPrefab.Get(job).Variants) - 1 end
						
			local pos = DD.findRandomWaypointByJob(job).WorldPosition
			local character = DD.spawnHuman(client, job, pos)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
		
			DD.characterDeathFunctions['respawnAsLaborer' .. seed] = nil
		end, 100)
	end
	
	return true
end
DD.electionCommandUsableAfter = 0
DD.chatMessageFunctions.election = function (message, sender)
	if message ~= '/election' then return end
	if (not DD.isClientCharacterAlive(sender)) or (sender.Character.SpeciesName ~= 'human') then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorDead'), {preset = 'command'})
		return true
	end
	if #DD.eventDirector.getEventInstances('election') > 0 then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorAlreadyOngoing'), {preset = 'command'})
		return true
	end
	if DD.thinkCounter <= DD.electionCommandUsableAfter then
		DD.messageClient(sender, DD.stringLocalize('commandElectionErrorCooldown', {timer = DD.numberToTime(math.ceil((DD.electionCommandUsableAfter - DD.thinkCounter) / 60))}), {preset = 'command'})
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
require 'DD/spawning'
require 'DD/money'
require 'DD/luahooks'
require 'DD/commands'
require 'DD/networking/client'
require 'DD/networking/server'
require 'DD/gui/gui'

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

-- Give talents
Hook.Add("character.giveJobItems", "DD.onGiveJobItems", function (character)
	-- Message
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		DD.messageClient(client, JobPrefab.Get(character.JobIdentifier).Description, {preset = 'info'})
	end
	-- Event related jobs
	if character.JobIdentifier == 'wizard' then
		DD.giveAfflictionCharacter(character, 'wizard', 1)
		local item = character.Inventory.GetItemAt(DD.invSlots.head)
		item.NonInteractable = true
		if SERVER then
			local nonInteractable = item.SerializableProperties[Identifier("NonInteractable")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(nonInteractable, item))
		end
	elseif character.JobIdentifier == 'gangster' then
		local item = character.Inventory.GetItemAt(DD.invSlots.head)
		item.NonInteractable = true
		if SERVER then
			local nonInteractable = item.SerializableProperties[Identifier("NonInteractable")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(nonInteractable, item))
		end
		local item = character.Inventory.GetItemAt(DD.invSlots.innerclothes)
		item.NonInteractable = true
		if SERVER then
			local nonInteractable = item.SerializableProperties[Identifier("NonInteractable")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(nonInteractable, item))
		end
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
			if (character.JobIdentifier == 'engineer') or (character.JobIdentifier == 'foreman') or (character.JobIdentifier == 'jet') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('unstoppablecuriosity', true)
			end
			if (character.JobIdentifier == 'captain') or (character.JobIdentifier == 'gangster') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('drunkensailor', true)
			end
			if DD.isCharacterMedical(character) or (character.JobIdentifier == 'janitor') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('firemanscarry', true)
			end
			if (character.JobIdentifier == 'diver') or (character.JobIdentifier == 'engineer') or (character.JobIdentifier == 'foreman') or (character.JobIdentifier == 'jet') or (character.JobIdentifier == 'assistant') then
				character.GiveTalent('daringdolphin', true)
				character.GiveTalent('ballastdenizen', true)
			end
			if character.JobIdentifier == 'gangster' then
				character.GiveTalent('gangknowledge', true)
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
end, 1)

-- Server only
if CLIENT then return end

-- Server settings to be applied
DD.serverSettings = {
    AllowDisguises = true,
    AllowFileTransfers = true,
    AllowFriendlyFire = true,
    AllowLinkingWifiToChat = false,
    AllowModDownloads = true,
    AllowModeVoting = false,
	RespawnMode = 1,
    AllowRewiring = true,
    AllowSpectating = true,
    AllowSubVoting = true,
    BotCount = 0,
    DisableBotConversations = true,
    ExtraCargo = {},
    GameModeIdentifier = 'sandbox',
    KarmaEnabled = false,
    KillableNPCs = true,
    LockAllDefaultWires = true,
	TraitorProbability = 0,
    LosMode = 2, --Opaque    
    MinRespawnRatio = 0, --Minimun players to respawn
    ModeSelectionMode = 0, --Manual
    MonsterEnabled = {},
    PlayStyle = 2, --Roleplay
    RespawnInterval = 1.5 * 60,
    ShowEnemyHealthBars = 0,
    UseRespawnShuttle = false,
    SelectedSubmarine = 'DD Olde Towne',
    ServerDetailsChanged = true,
}

-- Applies settings to server
if SERVER then
	for setting, value in pairs(DD.serverSettings) do
		if not pcall(function ()
			Game.ServerSettings[setting] = value
		end) then
			LuaUserData.MakeMethodAccessible(Descriptors['Barotrauma.Networking.ServerSettings'], 'set_' .. setting)
			Game.ServerSettings['set_' .. setting](value)
		end
	end
	-- Actually applies the settings
	Game.ServerSettings.ForcePropertyUpdate()
	-- Set difficulty to 0%
	Game.NetLobbyScreen.SetLevelDifficulty(0)
end

-- Evil NetConfig (TM)
NetConfig.MaxHealthUpdateInterval = 0
NetConfig.LowPrioCharacterPositionUpdateInterval = 0
NetConfig.MaxEventPacketsPerUpdate = 8
NetConfig.RoundStartSyncDuration = 60
NetConfig.EventRemovalTime = 30
NetConfig.OldReceivedEventKickTime = 30
NetConfig.OldEventKickTime = 60

LuaUserData.MakePropertyAccessible(Descriptors["Barotrauma.Networking.ServerSettings"], "MinimumMidRoundSyncTimeout")

if Game.ServerSettings and Game.ServerSettings.MinimumMidRoundSyncTimeout == 10 then
    Game.ServerSettings.MinimumMidRoundSyncTimeout = 100
end