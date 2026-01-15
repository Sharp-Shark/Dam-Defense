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
	entity.GetComponentString('Holdable').AttachToWall()
end)

Networking.Receive("syncEntityAttached", function (message, client)
	local id = message.ReadUInt16()
	local entity = Entity.FindEntityByID(id)
	if entity == nil then return end
	entity.GetComponentString('Holdable').AttachToWall()
end)

Networking.Receive("updateGUICharacterRole", function (message, client)
	DD.gui.characterRole = json.parse(message.ReadString())
end)

local pingCooldown = 60
local pingDone = false
DD.thinkFunctions.ping = function ()
	if pingDone then return end
	if pingCooldown > 0 then
		pingCooldown = pingCooldown - 1
		return
	end
	pingCooldown = 60
	
	local message = Networking.Start("pingServer")
	Networking.Send(message)
end
Networking.Receive("pingReset", function (message, client)
	pingDone = false
end)
Networking.Receive("pingClient", function (message, client)
	pingDone = true
end)