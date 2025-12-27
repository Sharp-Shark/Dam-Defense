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
			-- find reactors
			DD.reactors = {}
			for item in Submarine.MainSub.GetItems(false) do
				if item.HasTag('reactor') then
					table.insert(DD.reactors, item)
				end
			end
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
			local identifierResetSet = {
				-- pipe gun
				pipegun = true,
				-- handcannons
				antiquerevolver = true,
				handcannonround = true,
				handcannonround = true,
				-- revolver
				revolver = true,
				revolverround = true,
				-- shotgun
				shotgun = true,
				shotgununique = true,
				foldableshotgun = true,
				shotgunshell = true,
				shotgunslugbreaching = true,
				-- smg
				smg = true,
				smgmagazine = true,
				smground = true,
				-- pistol
				tommygun = true,
				tommygundrum = true,
				uzi = true,
				pistol = true,
				pistolmagazine = true,
				pistolround = true,
				-- separatist rifle
				separatistrifle = true,
				marksmanrifle = true,
				['762magazine'] = true,
				['762round'] = true,
				-- rifle
				rifle = true,
				riflebullet = true,
				-- flare gun
				flaregun = true,
				flaregunround = true,
				-- harpoon gun
				whalinggun = true,
				whalingspear = true,
				harpooncoilrifle = true,
				harpoongun = true,
				explosivespear = true,
				-- grenade launcher
				grenadelauncher = true,
				['40mmgrenade'] = true,
				['40mmrubberround'] = true,
				['40mmjumpergrenade'] = true,
				-- barricade
				barricade = true,
				barricadestatic = true,
			}
			for item in Item.ItemList do
				-- reset item
				if identifierResetSet[tostring(item.Prefab.Identifier)] and (not item.HasTag('dd_noreset')) then
					item.Reset()
				end
				-- do not lock some wires
				local component = item.GetComponentString('Wire')
				if component ~= nil then
					if (#component.connections == 2) and (isValidConnection(component.connections[1]) or isValidConnection(component.connections[2])) then
						component.NoAutoLock = true
					end
				end
				-- disable autofill
				local component = item.GetComponentString('ItemContainer')
				if component ~= nil then
					component.AutoFill = false
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
			researcher = 'id_researcher,id_medic',
			medicaldoctor = 'id_medic',
			foreman = 'id_engineer,id_janitor',
			engineer = 'id_engineer',
			shopkeeper = 'id_shop',
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
	
	-- Skip round end checks if certain events are happening
	local set = {
		[DD.eventNukies.tbl.name] = true,
		[DD.eventDeathSquad.tbl.name] = true,
	}
	for event in DD.eventDirector.events do
		if set[event.name] and event.started and not event.finished then return end
	end
	
	-- End round if everyone is dead
	local anyHumanAlive = false
	for client in Client.ClientList do
		if not DD.isClientAntagNonTarget(client) then
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
		return
	end
	-- End round if all reactors are broken
	local anyReactorIsUnbroken = false
	for reactor in DD.reactors do
		if reactor.Condition > 0 then
			anyReactorIsUnbroken = true
			break
		end
	end
	if not anyReactorIsUnbroken then
		DD.messageAllClients(DD.stringLocalize('allReactorsAreBroken'), {preset = 'crit'})
		DD.roundData.roundEnding = true
		Timer.Wait(function ()
			Game.EndGame()
		end, 10 * 1000)
		return
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
	
	local isAntag = character.CharacterHealth.GetAfflictionStrengthByIdentifier('antag', true) > 0
	
	-- Do death message to deceased
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		Timer.Wait(function ()
			if (client ~= nil) and not DD.isClientCharacterAlive(client) then
				local key = 'deathMessage'
				if isAntag then key = 'deathAntagMessage' end
				DD.messageClient(client, DD.stringLocalize(key), {preset = 'crit'})
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

-- Functions executed whenever a client respawns
DD.respawnFunctions = {}
DD.doRespawnFunctions = function (client) -- is global so it can be called in spawning.lua
	local returnValue
	for name, func in pairs(DD.respawnFunctions) do
		if returnValue == nil then returnValue = func(client) end
		func(client)
	end
	return returnValue
end

-- Load other files
require 'DD/chatCommands'
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
require 'DD/gui/wiki'

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
    ShowEnemyHealthBars = 2, -- Hide all
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
--NetConfig.MaxEventPacketsPerUpdate = 8
--NetConfig.RoundStartSyncDuration = 60
--NetConfig.EventRemovalTime = 30
--NetConfig.OldReceivedEventKickTime = 30
--NetConfig.OldEventKickTime = 60

LuaUserData.MakePropertyAccessible(Descriptors["Barotrauma.Networking.ServerSettings"], "MinimumMidRoundSyncTimeout")

if Game.ServerSettings and Game.ServerSettings.MinimumMidRoundSyncTimeout == 10 then
    Game.ServerSettings.MinimumMidRoundSyncTimeout = 100
end