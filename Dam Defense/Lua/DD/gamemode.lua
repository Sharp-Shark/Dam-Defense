if CLIENT then return end

-- Base gamemode class all gamemode inherit from
require 'DD/gamemodes/base'
-- Load the files with the gamemodes
require 'DD/gamemodes/dampwood'

-- All gamemodes
DD.gamemodePool = {
	DD.gamemodeBase,
	DD.gamemodeDampwood,
}

-- Active gamemode
DD.gamemodeClass = DD.gamemodeBase

-- Allows starting a vote to change gamemode
DD.gamemodeAllowPoll = true

DD.roundStartFunctions.gamemode = function ()
	if not Game.RoundStarted then return end
	DD.gamemode = DD.gamemodeClass.new()
	DD.gamemode.onRoundStart()
	
	DD.gamemodeAllowPoll = true
end

DD.thinkFunctions.gamemode = function ()
	if (not Game.RoundStarted) or (DD.roundData.roundEnding) then return end
	
	DD.gamemode.onThink()
end

DD.roundEndFunctions.gamemode = function ()
	DD.gamemode.onRoundEnd()
	DD.gamemode.dispose()
end

local callback = function (winner, optionVoteCount)
	DD.gamemodeAllowPoll = false
	
	for gamemodeClass in DD.gamemodePool do
		if gamemodeClass.tbl.votable and (gamemodeClass.tbl.displayName == winner) then
			DD.gamemodeClass = gamemodeClass
		end
	end
	
	DD.democracy.announceResult(winner, optionVoteCount)
end
DD.chatMessageFunctions.pollGamemode = function (message, sender)
	if message ~= '/gamemode' then return end
	
	if not DD.gamemodeAllowPoll then
		DD.messageClient(sender, DD.stringLocalize('commandStartVoteErrorGamemode'), {preset = 'commandError'})
		return true
	end
	
	local options = {}
	for gamemodeClass in DD.gamemodePool do
		if gamemodeClass.tbl.votable then
			table.insert(options, gamemodeClass.tbl.displayName)
		end
	end
	
	local result = DD.democracy.start(options, callback)
	
	if not result then
		DD.messageClient(sender, DD.stringLocalize('commandStartVoteError'), {preset = 'commandError'})
		return true
	end
	
	DD.messageAllClients(DD.stringLocalize('commandStartVote') .. '\n' .. DD.stringLocalize('commandVoteList', {list = DD.democracy.optionListText}), {preset = 'command'})
	
	return true
end