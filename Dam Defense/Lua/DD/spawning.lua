DD.jobBans = {}

if CLIENT then return end

DD.lateJoinBlacklistSet = {}
DD.autoJobExecutionCount = 0
DD.clientJob = {}

DD.roundEndFunctions.spawning = function ()
	DD.lateJoinBlacklistSet = {}
	
	DD.autoJobExecutionCount = 0
	DD.clientJob = {}
end

DD.isClientBannedFromJob = function (client, job)
	if DD.jobBans[client.AccountId.StringRepresentation] == nil then return false end
	return DD.jobBans[client.AccountId.StringRepresentation][job]
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
	
	local jobsLeft = {}
	jobsLeft['assistant'] = 100
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
		jobsLeft[job] = jobsLeft[job] - 1
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
				if (DD.clientJob[client] == nil) and (not DD.isClientBannedFromJob(client, job)) then
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
			if clientFound and (jobsLeft[job] > 0) and jobSet[job] and (job ~= 'mechanic') and (not DD.isClientBannedFromJob(client, job)) then
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
				info.RecreateHead(client.CharacterInfo.Head)
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
		for client in Client.ClientList do
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