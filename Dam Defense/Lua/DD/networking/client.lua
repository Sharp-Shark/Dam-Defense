if SERVER or Game.IsSingleplayer then return end

DD.receivedJobBans = false

Networking.Receive("updateJobBans", function (message, client)
	DD.jobBans = json.parse(message.ReadString())
	DD.receivedJobBans = true
end)

Networking.Receive("syncEntityRotation", function (message, client)
	local id = message.ReadUInt16()
	local rotation = message.ReadSingle()
	local entity = Entity.FindEntityByID(id)
	if entity == nil then return end
	entity.Rotation = rotation
end)

Networking.Receive("updateGUICharacterRole", function (message, client)
	DD.gui.characterRole = json.parse(message.ReadString())
end)