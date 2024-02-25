local function escapeQuotes (str)
    return str:gsub("\"", "\\\"")
end

local function discordChatMessage (message, hook)
	local discordWebHook = "https://discord.com/api/webhooks/1128508877458133113/PLmw236dj136aewlPnAEupWJbCxXb3gYCOAfZfC1kWQj9WhhPkN4tx-daucar-99lPQI"
	if hook ~= nil then
		discordWebHook = hook
	end
    local escapedName = escapeQuotes(Game.ServerSettings.ServerName)
    local escapedMessage = escapeQuotes(message)

    Networking.RequestPostHTTP(discordWebHook, function(result) end, '{\"content\": \"'..escapedMessage..'\", \"username\": \"'..escapedName..'\"}')
end

Hook.Add("client.connected", "DD.discordClientConnect", function (connectedClient)
	if SERVER and Game.ServerSettings.IsPublic then
		local name = connectedClient.Name
		
		if DD.stringHas(name, 'http://') or DD.stringHas(name, 'https://') then
			name = '**[CENSORED]**'
		end
	
		if #Client.ClientList > 1 then
			discordChatMessage('01| ' .. name .. ' has joined! There are ' .. #Client.ClientList .. ' clients.')
		elseif #Client.ClientList > 0 then
			discordChatMessage('02| ' .. name .. ' has joined! There is ' .. #Client.ClientList .. ' client.')
		else
			discordChatMessage('03| ' .. name .. ' has joined! There are no clients.')
		end
	end
end)

Hook.Add("client.disconnected", "DD.discordClientDisconnect", function (disconnectedClient)
	if SERVER and Game.ServerSettings.IsPublic then
		local name = disconnectedClient.Name
		
		if DD.stringHas(name, 'http://') or DD.stringHas(name, 'https://') then
			name = '**[CENSORED]**'
		end
		
		if (#Client.ClientList - 1) > 1 then
			discordChatMessage('04| ' .. name .. ' has left. There are ' .. (#Client.ClientList - 1) .. ' clients.')
		elseif (#Client.ClientList - 1) > 0 then
			discordChatMessage('05| ' .. name .. ' has left. There is ' .. (#Client.ClientList - 1) .. ' client.')
		else
			discordChatMessage('06| ' .. name .. ' has left. There are no clients.')
		end
	end
end)

if SERVER and Game.ServerSettings.IsPublic then
	discordChatMessage('00| Server is up and running!')
end