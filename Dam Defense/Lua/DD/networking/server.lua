if CLIENT then return end

local function escapeQuotes (str)
    return str:gsub("\"", "\\\"")
end

local function discordChatMessage (message, hook)
	if CLIENT or (not Game.ServerSettings.IsPublic) then return end

	local discordWebHook = DD.discordWebHook
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

Networking.Receive("requestUpdateJobBans", function (message, client)
	if client.HasPermission(ClientPermissions.ConsoleCommands) then
		local message = Networking.Start("updateJobBans")
		message.WriteString(json.serialize(DD.jobBans))
		Networking.Send(message, client.Connection)
	end
end)

Networking.Receive("requestUpdateGUICharacterRole", function (message, client)
	local characterRole = {}
	local assignClientRole = function (client, role)
		if not DD.isClientCharacterAlive(client) then return end
		if characterRole[tostring(client.Character.ID)] == nil then characterRole[tostring(client.Character.ID)] = {} end
		characterRole[tostring(client.Character.ID)][role] = true
	end
	for event in DD.eventDirector.events do
		if (event.name == 'revolution') and (event.rebelsSet[client] or event.rebelsDoxHappened or not DD.isClientCharacterAlive(client)) then
			for client in event.rebels do
				assignClientRole(client, 'rebel')
			end
		elseif (event.name == 'murder') and (event.murderer == client) then
			assignClientRole(event.victim, 'victim')
		elseif (event.name == 'vip') and ((event.vip == client) or (event.guard == client)) then
			assignClientRole(event.vip, 'vip')
			assignClientRole(event.guard, 'guard')
		elseif ((event.name == 'arrest') or (event.name == 'arrest1984')) and event.isTargetKnown then
			assignClientRole(event.target, 'arresttarget')
		end
	end

	local message = Networking.Start("updateGUICharacterRole")
	message.WriteString(json.serialize(characterRole))
	Networking.Send(message, client.Connection)
end)