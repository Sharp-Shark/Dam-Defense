if CLIENT then return end

DD.lateJoinMessage = 'Respawning is currently disabled, however you and anyone who just joined will be spawned in as a laborer within {timer}.'

DD.lateJoinSpawn = function ()
	for client in Client.ClientList do
		if (not DD.isClientCharacterAlive(client)) and (not DD.lateJoinBlacklistSet[client.AccountId.StringRepresentation]) then
			local job = 'mechanic'
			local pos = DD.findRandomWaypointByJob(job).WorldPosition
			local character = DD.spawnHuman(client, job, pos)
			character.SetOriginalTeam(CharacterTeamType.Team1)
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
			spectatorSet[client.AccountId.StringRepresentation] = true
		end
	end
	
	local resetLateJoinTimer = true
	if not DD.allowRespawning then
		local lateJoinSet = DD.setSubtract(spectatorSet, DD.lateJoinBlacklistSet)
		
		if DD.tableSize(lateJoinSet) > 0 then
			if DD.lateJoinTimer <= 0 then
				DD.lateJoinSpawn()
			else
				resetLateJoinTimer = false
				if DD.lateJoinTimer == Game.ServerSettings.RespawnInterval then
					local message = 'Late-join spawn will occur within {timer}.'
					for client in Client.ClientList do
						if lateJoinSet[client.AccountId.StringRepresentation] then
							DD.messageClient(client, DD.stringReplace(DD.lateJoinMessage, {timer = DD.numberToTime(DD.lateJoinTimer)}), {preset = 'crit'})
						else
							DD.messageClient(client, DD.stringReplace(message, {timer = DD.numberToTime(DD.lateJoinTimer)}), {preset = 'info'})
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
	if (not DD.allowRespawning) and (not DD.lateJoinBlacklistSet[connectedClient.AccountId.StringRepresentation]) then
		DD.messageClient(connectedClient, DD.stringReplace(DD.lateJoinMessage, {timer = DD.numberToTime(DD.lateJoinTimer)}), {preset = 'crit'})
	end
end)