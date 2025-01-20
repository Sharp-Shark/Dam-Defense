if SERVER or (CLIENT and not Game.IsMultiplayer) then return end

local oldHook = Hook
Hook = {}
local mt = {}
setmetatable(Hook, mt)
mt.__index = function(table, key)
	if key == "HookMethod" then
		return function() end
	end
	return oldHook[key]
end
	
--[[
Hook.Patch("Barotrauma.Camera", "set_MaxZoom", function(instance, ptable)
	if instance["maxZoom"] > 2.0 then
		instance["maxZoom"] = math.min(2.0, instance["maxZoom"])
	end
end, Hook.HookMethodType.After)

Hook.Patch("Barotrauma.Camera", "set_MinZoom", function(instance, ptable)
	if instance["minZoom"] > 2.0 then
		instance["minZoom"] = math.min(1.5, instance["minZoom"])
	end
end, Hook.HookMethodType.After)
--]]

Hook.Patch("Barotrauma.Lights.LightManager", "UpdateObstructVision", function()
	if Game.Client.MyClient.HasPermission(ClientPermissions.ConsoleCommands) then return end
	Game.LightManager.LosEnabled = true
end, Hook.HookMethodType.Before)

Hook.Patch("Barotrauma.Lights.LightManager", "RenderLightMap", function()
	if Game.Client.MyClient.HasPermission(ClientPermissions.ConsoleCommands) then return end
	Game.LightManager.LightingEnabled = true
end, Hook.HookMethodType.Before)