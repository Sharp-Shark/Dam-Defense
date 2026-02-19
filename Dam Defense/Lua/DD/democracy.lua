if CLIENT then return end

DD.democracy = {
	active = false,
	
	options = {},
	optionVoteCount = {},
	clientOption = {},
	
	optionListText = '',
	
	callback = function () return end,
	
	announceResult = function (winner, optionVoteCount)
		if winner == nil then
			winner = DD.stringLocalize('none')
		else
			winner = '"' .. winner .. '"'
		end
		
		local list = ''
		for option, voteCount in pairs(optionVoteCount) do
			list = list .. '\n' .. option .. ': ' .. tostring(voteCount) .. '.'
		end
		
		DD.messageAllClients(DD.stringLocalize('commandVoteResult', {winner = winner, list = list}), {preset = 'command'})
	end,
	
	uncastVote = function (client)
		if not DD.democracy.active then return false end
		local option = DD.democracy.clientOption[client]
		if option == nil then return false end
		
		DD.democracy.optionVoteCount[option] = DD.democracy.optionVoteCount[option] - 1
		DD.democracy.clientOption[client] = nil
		
		return true
	end,
	
	castVote = function (client, option)
		if not DD.democracy.active then return false end
		if DD.democracy.optionVoteCount[option] == nil then return false end
		
		DD.democracy.uncastVote(client)
		
		DD.democracy.optionVoteCount[option] = DD.democracy.optionVoteCount[option] + 1
		DD.democracy.clientOption[client] = option
		
		return true
	end,
	
	buildOptionList = function ()
	end,
	
	start = function (options, callback)
		if DD.democracy.active then return false end
		DD.democracy.active = true
		
		DD.democracy.options = options or {}
		DD.democracy.optionVoteCount = {}
		DD.democracy.clientOption = {}
		for option in DD.democracy.options do
			DD.democracy.optionVoteCount[option] = 0
		end
		
		DD.democracy.callback = callback or DD.democracy.announceResult
		
		local build = ''
		for option in DD.democracy.options do
			build = build .. option .. ', '
		end
		build = string.sub(build, 1, #build - 2)
		if #build == 0 then
			build = DD.stringLocalize('empty')
		end
		DD.democracy.optionListText = build
		
		return true
	end,
	
	finish = function ()
		if not DD.democracy.active then return end
		DD.democracy.active = false
		
		local winner = nil
		local winnerVoteCount = 0
		for option, voteCount in pairs(DD.democracy.optionVoteCount) do
			if voteCount > winnerVoteCount then
				winner = option
				winnerVoteCount = voteCount
			end
		end
		
		DD.democracy.callback(winner, DD.democracy.optionVoteCount)
	end,
}

DD.chatMessageFunctions.vote = function (message, sender)
	if string.sub(message, 1, 5) ~= '/vote' then return end
	
	if not DD.democracy.active then
		DD.messageClient(sender, DD.stringLocalize('commandVoteError'), {preset = 'command'})
		return true
	end
	
	local option = string.sub(message, 7, #message)
	local result = DD.democracy.castVote(sender, option)
	
	if not result then
		DD.messageClient(sender, DD.stringLocalize('commandVoteList', {list = DD.democracy.optionListText}), {preset = 'command'})
		return true
	end
	
	DD.messageClient(sender, DD.stringLocalize('commandVote', {option = option}), {preset = 'command'})
	
	return true
end

Hook.Patch("Barotrauma.Networking.GameServer", "InitiateStartGame", function (instance, ptable)
	DD.democracy.finish()
end)