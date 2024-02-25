-- Crafting materials conveniently airdropped at the radio tower above the factory
DD.eventBlackout = DD.class(DD.eventBase, nil, {
	name = 'blackout',
	isMainEvent = false,
	cooldown = 60 * 2,
	weight = 0.5,
	goodness = -0.5,
	
	onStart = function (self)
		self.doors = {}
		self.lights = {}
		for item in Item.ItemList do
			local component
			component = item.GetComponentString('Door')
			if (math.random() > 0.0) and (component ~= nil) and (not item.NonInteractable) and (component.HasIntegratedButtons) and (not component.IsJammed) and (not component.IsStuck) then
				self.doors[item] = component.isOpen
				DD.setDoorState(item, not component.isOpen)
				component.IsJammed = true
			end
			component = item.GetComponentString('LightComponent')
			if (math.random() > 0.0) and (component ~= nil) and (component.PowerConsumption > 0) and (component.isOn) then
				self.lights[item] = component.isOn
				DD.setLightState(item, false)
			end
		end
		
		-- Timer until event ends
		self.timer = 60 * 2
		
		-- Warn players about event
		local message = 'Unusual magnetic interference is causing issues with eletrical systems. It is expected to go away on its own in {timer}.'
		DD.messageAllClients(DD.stringReplace(message, {timer = DD.numberToTime(self.timer)}), {preset = 'badinfo'})
	end,
	
	onThink = function (self)
		if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
		
		if self.timer <= 0 then
			self.finish()
		else
			self.timer = self.timer - 0.5
		end
	end,
	
	onFinishAlways = function (self)
		for item, state in pairs(self.doors) do
			DD.setDoorState(item, state)
			item.GetComponentString('Door').IsJammed = false
		end
		for item, state in pairs(self.lights) do
			DD.setLightState(item, state)
		end
	end
})