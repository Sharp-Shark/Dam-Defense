if CLIENT then return end

-- cooldown for election command
DD.electionCommandUsableAfter = 0

-- load credits (thanks)
local creditsPath = DD.path .. '/credits.txt'
local creditsText = 'Credits file was not found.'
if File.Exists(creditsPath) then
	creditsText = File.Read(creditsPath)
	print(creditsText)
end

-- lists commands
DD.chatMessageFunctions.help = function (message, sender)
	if (string.sub(message, 1, 1) ~= '/') and (string.sub(message, 1, 1) ~= '!') then return end
	
	local specialCommands = {'help', 'thanks', 'info', 'neverantag', 'events', 'credits', 'withdraw', 'possess', 'freecam', 'election', 'rebels', 'cultists', 'whisper', 'w', 'gang', 'announce', 'fire'}
	local commandText = {
		help = 'Gives a list of commands. List of commands given will only include commands relevant for the current context.',
		thanks = 'Credit where it is due. Without the work these people did, Dam Defense would not be where it stands.',
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
		w = 'Equivalent to /whisper command. Shorter for convenience.',
		gang = 'Lists fellow gang members and the name of your boss. Be cautious with enemy gangs.',
		announce = 'Usable by the mayor to make global announcements that even people without headsets will hear. Speak up and everyone shall hear you.',
		fire = 'Usable by the mayor to lethally fire members of security or to kill himself. Type /fire without arguments to see what number relates to each guard. Numbers can be used in place of names.',
	}
	
	local tbl = {}
	for command in specialCommands do
		tbl[command] = false
	end
	specialCommands = tbl
	
	specialCommands['help'] = true
	specialCommands['thanks'] = true
	specialCommands['neverantag'] = true
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
		if DD.isClientCharacterAlive(sender) and (sender.Character.JobIdentifier == 'captain') then
			specialCommands['announce'] = true
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
				specialCommands['w'] = true
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
	
	local isValid = false
	local isMisspell = true
	for command, value in pairs(specialCommands) do
		if string.sub(message, 1, #command + 1) == '/' .. command then
			isMisspell = false
			if value == true then isValid = true end
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

DD.chatMessageFunctions.thanks = function (message, sender, special)
	if (message ~= '/thanks') and (not special) then return end
	
	DD.messageClient(sender, creditsText, {preset = 'command'})
	
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
			if sender.Character.SpeciesName == 'Husk_prowler' then
				DD.messageClient(sender, DD.stringLocalize('huskProwlerInfo'), {preset = preset})
			elseif sender.Character.SpeciesName == 'Husk_chimera' then
				DD.messageClient(sender, DD.stringLocalize('huskChimeraInfo'), {preset = preset})
			else
				DD.messageClient(sender, DD.stringLocalize('huskInfo'), {preset = preset})
			end
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
		DD.messageClient(sender, DD.stringLocalize('commandNeverantagEligible'), {preset = 'command'})
		DD.antagExemptClients[sender.AccountId.StringRepresentation] = nil
	else
		DD.messageClient(sender, DD.stringLocalize('commandNeverantagExempt'), {preset = 'command'})
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
		if (DD.findClientByCharacter(character) == nil) and (not character.IsDead) and (character.SpeciesName ~= 'human') and (character.SpeciesName ~= 'Attackbot') and
		((winner == nil) or (Vector2.Distance(sender.SpectatePos, character.WorldPosition) < winnerDistance)) then
			winner = character
			winnerDistance = Vector2.Distance(sender.SpectatePos, character.WorldPosition)
		end
	end
	
	if winner ~= nil then
		local message = DD.stringLocalize('commandPossess')
		DD.messageClient(sender, message, {preset = 'command'})
		sender.SetClientCharacter(winner)
		sender.SpectateOnly = false
		
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

local announceCooldown = 0
DD.chatMessageFunctions.announce = function (message, sender)
	if string.sub(message, 1, 9) ~= '/announce' then return end
	if (not DD.isClientCharacterAlive(sender)) or (sender.Character.JobIdentifier ~= 'captain') then return end
	if DD.thinkCounter <= announceCooldown then
		DD.messageClient(sender, DD.stringLocalize('commandAnnounceErrorCooldown', {timer = DD.numberToTime(math.ceil((announceCooldown - DD.thinkCounter) / 60))}), {preset = 'command'})
		return true
	end
	announceCooldown = DD.thinkCounter + 60 * 10
	
	DD.messageAllClients(string.sub(message, 11, #message), {sender = 'Mayor Announcement', type='Server', color = JobPrefab.Get('captain').UIColor, sendMain = false, sendAnother = true})
	for character in Character.CharacterList do
		DD.giveAfflictionCharacter(character, 'announcementfx', 999)
	end
	
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