if CLIENT then return end

DD.getCustomLateJoinSpawn = function ()
	if DD.eventDirector.mainEvent == nil then return nil end
	return DD.eventDirector.mainEvent.lateJoinSpawn
end

DD.getCustomLateJoinBlacklistSet = function ()
	if DD.eventDirector.mainEvent == nil then return {} end
	return DD.eventDirector.mainEvent.lateJoinBlacklistSet or {}
end

DD.lateJoinSpawn = function ()
	for client in Client.ClientList do
		if DD.isClientRespawnable(client) then
			if DD.getCustomLateJoinSpawn() ~= nil then
				DD.getCustomLateJoinSpawn()(client)
			elseif not DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation] then
				local job = 'mechanic'
				local pos = DD.findRandomWaypointByJob(job).WorldPosition
				local character = DD.spawnHuman(client, job, pos)
				character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
				character.UpdateTeam()
			end
		end
	end
end

DD.thinkFunctions.lateJoin = function ()
	if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	
	local spectatorSet = {}
	for client in Client.ClientList do
		if DD.isClientCharacterAlive(client) then
			DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation] = true
		else
			spectatorSet[client.AccountId.StringRepresentation] = DD.isClientRespawnable(client)
		end
	end
	
	local resetLateJoinTimer = true
	if not DD.allowRespawning then
		local lateJoinSet = DD.setSubtract(spectatorSet, DD.lateJoinBlacklistSet)
		
		local localizeKey = 'lateJoinMessage'
		if DD.getCustomLateJoinSpawn() ~= nil then
			lateJoinSet = DD.setSubtract(spectatorSet, DD.getCustomLateJoinBlacklistSet())
			useCustomLateJoinRespawn = 'lateJoinMessageCustom'
		end
		
		if DD.tableSize(lateJoinSet) > 0 then
			if DD.lateJoinTimer <= 0 then
				DD.lateJoinSpawn()
			else
				resetLateJoinTimer = false
				if DD.lateJoinTimer == Game.ServerSettings.RespawnInterval then
					for client in Client.ClientList do
						if lateJoinSet[client.AccountId.StringRepresentation] then
							DD.messageClient(client, DD.stringLocalize(localizeKey, {timer = DD.numberToTime(DD.lateJoinTimer)}), {preset = 'crit'})
						else
							DD.messageClient(client, DD.stringLocalize('lateJoinAnnounceTimer', {timer = DD.numberToTime(DD.lateJoinTimer)}), {preset = 'info'})
						end
					end
				end
				DD.lateJoinTimer = DD.lateJoinTimer - 0.5
			end
		end
	end
	if resetLateJoinTimer then
		DD.lateJoinTimer = Game.ServerSettings.RespawnInterval
	end
end

DD.roundStartFunctions.lateJoin = function ()
	DD.lateJoinTimer = Game.ServerSettings.RespawnInterval
	DD.lateJoinBlacklistSet = {} -- like a blacklist, but it's a set
end

Hook.Add("client.connected", "DD.lateJoinClientConnect", function (connectedClient)
	if DD.allowRespawning then return end
	
	local localizeKey = 'lateJoinMessage'
	if DD.getCustomLateJoinSpawn() ~= nil then
		localizeKey = 'lateJoinMessageCustom'
		if DD.getCustomLateJoinBlacklistSet()[connectedClient.AccountId.StringRepresentation] then return end
	else
		if DD.lateJoinBlacklistSet[connectedClient.AccountId.StringRepresentation] then return end
	end
	DD.messageClient(connectedClient, DD.stringLocalize(localizeKey, {timer = DD.numberToTime(DD.lateJoinTimer)}), {preset = 'crit'})
end)