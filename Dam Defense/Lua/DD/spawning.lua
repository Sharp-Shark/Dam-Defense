-- Give talents
Hook.Add("character.giveJobItems", "DD.onGiveJobItems", function (character)
	-- Message
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		DD.messageClient(client, JobPrefab.Get(character.JobIdentifier).Description, {preset = 'info'})
	end
	-- Items to be locked (to be made non interactable)
	local lockedJobItems = {
		captain = {
			[DD.invSlots.innerclothes] = {captainsuniform1 = true, captainsuniform3 = true}
		},
		diver = {
			[DD.invSlots.innerclothes] = {securityuniform2 = true}
		},
		securityofficer = {
			[DD.invSlots.innerclothes] = {securityuniform1 = true}
		},
		foreman = {
			[DD.invSlots.innerclothes] = {orangejumpsuit2 = true}
		},
		-- event jobs
		jet = {
			[DD.invSlots.outerclothes] = {suicidevest = true},
		},
		wizard = {
			[DD.invSlots.head] = {merasmushat = true},
		},
		gangster = {
			[DD.invSlots.head] = {bosshat = true},
			[DD.invSlots.innerclothes] = {bossclothes = true},
		},
	}
	local lockedItems = lockedJobItems[tostring(character.JobIdentifier)]
	if lockedItems ~= nil then
		for slot, itemSet in pairs(lockedItems) do
			local item = character.Inventory.GetItemAt(slot)
			if itemSet[tostring(item.Prefab.Identifier)] then
				item.NonInteractable = true
				if SERVER then
					local nonInteractable = item.SerializableProperties[Identifier("NonInteractable")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(nonInteractable, item))
				end
			end
		end
	end
	-- Special code for certain jobs
	if character.JobIdentifier == 'wizard' then
		DD.giveAfflictionCharacter(character, 'wizard', 1)
	elseif character.JobIdentifier == 'assistant' then
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('handcuffs'), character.Inventory, nil, nil, function (spawnedItem)
			spawnedItem.Condition = spawnedItem.Condition / 10
			Timer.NextFrame(function ()
				character.Inventory.TryPutItem(spawnedItem, DD.invSlots.righthand, true, true, character, true, true)
			end)
		end)
	end
	-- Give Talents
	local jobTalents = {
		captain = {'drunkensailor'},
		diver = {'daringdolphin', 'ballastdenizen'},
		securityofficer = {'physicalconditioning'},
		foreman = {'daringdolphin', 'ballastdenizen', 'unstoppablecuriosity', 'engineeringknowledge'},
		engineer = {'daringdolphin', 'ballastdenizen', 'unstoppablecuriosity', 'engineeringknowledge'},
		researcher = {'dontdieonme', 'firemanscarry'},
		medicaldoctor = {'dontdieonme', 'firemanscarry'},
		janitor = {'janitorialknowledge', 'greenthumb', 'firemanscarry'},
		mechanic = {'unlockallrecipes', 'miner'},
		clown = {'unlockallrecipes', 'skedaddle'},
		assistant = {'unlockallrecipes', 'skedaddle'},
		-- event jobs
		gangster = {'drunkensailor', 'gangknowledge'},
		jet = {'daringdolphin', 'ballastdenizen', 'rebelknowledge'},
		mercs = {'daringdolphin', 'ballastdenizen'},
		mercsevil = {'daringdolphin', 'ballastdenizen'},
	}
	if (character.SpeciesName == 'human') and (jobTalents[tostring(character.JobIdentifier)] ~= nil) then
		Timer.Wait(function ()
			for talent in jobTalents[tostring(character.JobIdentifier)] do
				character.GiveTalent(talent, true)
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

if CLIENT then return end

DD.lateJoinBlacklistSet = {}
DD.autoJobExecutionCount = 0
DD.clientJob = {}

DD.roundEndFunctions.spawning = function ()
	DD.lateJoinBlacklistSet = {}
	
	DD.autoJobExecutionCount = 0
	DD.clientJob = {}
end

DD.autoJob = function ()
	if #Client.ClientList == 0 then return {} end

	local antagSafeCap = math.ceil(#Client.ClientList * 2 / 5)

	local jobSet = {}
	for jobPrefab in JobPrefab.Prefabs do
		if (jobPrefab.MaxNumber > 0) and (not jobPrefab.HiddenJob) then
			jobSet[tostring(jobPrefab.Identifier)] = true
		end
	end
	
	local clientPreferredJobsSet = {}
	for client in Client.ClientList do
		clientPreferredJobsSet[client] = {}
		for index, jobVariant in pairs(client.JobPreferences) do
			local job = tostring(jobVariant.Prefab.Identifier)
			if job ~= 'mechanic' then
				clientPreferredJobsSet[client][job] = true
			end
		end
	end
	
	local jobsLeft = {}
	local sorted = {}
	for jobPrefab in JobPrefab.Prefabs do
		if (jobPrefab.MaxNumber > 0) and (not jobPrefab.HiddenJob) then
			jobsLeft[tostring(jobPrefab.Identifier)] = jobPrefab.MaxNumber
			sorted[tostring(jobPrefab.Identifier)] = {{}, {}, {}, {}}
			for client in DD.arrShuffle(Client.ClientList) do
				if DD.isClientRespawnable(client) then
					local found = false
					local count = 1
					for jobVariant in client.JobPreferences do
						if jobVariant.Prefab.Identifier == jobPrefab.Identifier then
							found = true
							break
						end
						count = count + 1
					end
					if not found then count = 4 end
					if DD.isClientBannedFromJob(client, job) then count = 4 end
					table.insert(sorted[tostring(jobPrefab.Identifier)][count], client)
				end
			end
		end
	end
	
	local assignClientJob = function (client, job, ignore)
		if DD.antagSafeJobs[job] and (antagSafeCap <= 0) and (not ignore) then return end
		DD.clientJob[client] = job
		if jobsLeft[job] ~= nil then
			jobsLeft[job] = jobsLeft[job] - 1
		end
		if DD.antagSafeJobs[job] then
			antagSafeCap = antagSafeCap - 1
		end
	end
	
	local oldClientJob = DD.clientJob
	DD.clientJob = {}
	-- assign living player jobs
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) and jobSet[tostring(client.Character.JobIdentifier)] then
			assignClientJob(client, tostring(client.Character.JobIdentifier), true)
		end
	end
	-- assign captain
	if #Client.ClientList > 1 then
		for n = 1, 4 do
			if not (jobsLeft['captain'] > 0) then break end
			for client in sorted['captain'][n] do
				if not (jobsLeft['captain'] > 0) then break end
				if (DD.clientJob[client] == nil) and (not DD.isClientBannedFromJob(client, 'captain')) then
					assignClientJob(client, 'captain', true)
				end
			end
		end
	end
	-- try to give players the job they had before they died
	for client, job in pairs(oldClientJob) do
		if DD.isClientRespawnable(client) then
			local clientFound = false
			for otherClient in Client.ClientList do
				if client == otherClient then clientFound = true end
			end
			if (DD.clientJob[client] == nil) and clientFound and (jobsLeft[job] > 0) and jobSet[job] and clientPreferredJobsSet[client][job] and (not DD.isClientBannedFromJob(client, job)) then
				assignClientJob(client, job)
			end
		end
	end
	-- try to assign player's their desired job
	for n = 1, 3 do
		for job, tbl in pairs(sorted) do
			for client in tbl[n] do
				if not (jobsLeft[job] > 0) then break end
				if (DD.clientJob[client] == nil) and (not DD.isClientBannedFromJob(client, job))  then
					assignClientJob(client, job)
				end
			end
		end
	end
	-- worst case scenario
	for client in Client.ClientList do
		if DD.clientJob[client] == nil then
			if not DD.isClientBannedFromJob(client, 'mechanic') then
				assignClientJob(client, 'mechanic', true)
			else
				assignClientJob(client, 'assistant', true)
			end
		end
	end
	
	return DD.clientJob
end

-- Overrides the jobs the players chose, assuming auto jobs is activated
Hook.Add("jobsAssigned", "DD.autoJob", function ()
	DD.autoJob()
	DD.autoJobExecutionCount = DD.autoJobExecutionCount + 1
	
	for client, job in pairs(DD.clientJob) do
		local variant
		for jobVariant in client.JobPreferences do
			if tostring(jobVariant.Prefab.Identifier) == job then
				variant = jobVariant.Variant
			end
		end
		if variant == nil then variant = math.random(JobPrefab.Get(job).Variants) - 1 end
		client.AssignedJob = JobVariant(JobPrefab.Get(job), variant)
	end
end)

-- think function
DD.thinkFunctions.spawning = function ()
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	
	local spectatorSet = {}
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) then
			DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation] = true
		else
			spectatorSet[client.AccountId.StringRepresentation] = DD.isClientRespawnable(client)
		end
	end
end

-- replace vanilla respawn
Hook.Patch("Barotrauma.Networking.RespawnManager", "RespawnCharacters", {"Barotrauma.Networking.RespawnManager+TeamSpecificState"}, function(instance, ptable)
	if DD.respawningState == 'default' then
		DD.autoJob()
		DD.autoJobExecutionCount = DD.autoJobExecutionCount + 1
		
		for client in Client.ClientList do
			if DD.isClientRespawnable(client) and client.InGame then
				-- reset talents (and more) before respawn
				local info = CharacterInfo('human', client.Name)
				if client.CharacterInfo ~= nil then
					info.RecreateHead(client.CharacterInfo.Head)
				end
				client.CharacterInfo = info
				
				-- get job and job variant
				local job = DD.clientJob[client]
				local variant
				for jobVariant in client.JobPreferences do
					if tostring(jobVariant.Prefab.Identifier) == job then
						variant = jobVariant.Variant
					end
				end
				if variant == nil then variant = math.random(JobPrefab.Get(job).Variants) - 1 end
				
				-- spawn character
				local pos = DD.findRandomWaypointByJob(job).WorldPosition
				local character = DD.spawnHuman(client, job, pos, nil, variant, nil)
				character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
				character.UpdateTeam()
			end
		end
	elseif DD.respawningState == 'latejoin' then
		for client in DD.arrShuffle(Client.ClientList) do
			if DD.isClientRespawnable(client) then
				if (DD.eventDirector.mainEvent ~= nil) and (DD.eventDirector.mainEvent.lateJoinSpawn ~= nil) then
					-- if statement condition function does something and returns true if it succeeds (function has side-effects and is not pure)
					if not DD.eventDirector.mainEvent.lateJoinSpawn(client) then
						DD.messageClient(client, DD.stringLocalize('latejoinMessageNoRespawnCustom'), {preset = 'crit'})
					end
				elseif not DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation] then
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
				else
					DD.messageClient(client, DD.stringLocalize('latejoinMessageNoRespawn'), {preset = 'crit'})
				end
			end
		end
	end
	
	ptable.PreventExecution = true
end, Hook.HookMethodType.Before)