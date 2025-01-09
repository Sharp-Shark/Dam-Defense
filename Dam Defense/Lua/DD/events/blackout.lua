-- Crafting materials conveniently airdropped at the radio tower above the factory
DD.eventBlackout = DD.class(DD.eventWithStartBase, nil, {
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
				DD.setDoorState(item, false)
				component.IsJammed = true
			end
			component = item.GetComponentString('LightComponent')
			if (math.random() > 0.0) and (component ~= nil) and (component.PowerConsumption > 0) and (component.isOn) then
				self.lights[item] = {isOn = component.isOn, flicker = component.flicker, flickerSpeed = component.flickerSpeed}
				item.GetComponentString('LightComponent').flicker = 1.0
				item.GetComponentString('LightComponent').flickerSpeed = 0.1
				if SERVER then
					local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("Flicker")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
				end
				if SERVER then
					local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("FlickerSpeed")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
				end
			end
		end
	end,
	
	stateStartInitialTimer = 10, -- in seconds
	
	stateMain = {
		onChange = function (self, state)
			for item in Item.ItemList do
				local component
				component = item.GetComponentString('Door')
				if (math.random() > 0.0) and (component ~= nil) and (not item.NonInteractable) and (component.HasIntegratedButtons) and ((not component.IsJammed) or (self.parent.doors[item] ~= nil)) and (not component.IsStuck) then
					if self.parent.doors[item] == nil then
						self.parent.doors[item] = component.isOpen
					end
					DD.setDoorState(item, true)
					component.IsJammed = true
				end
				component = item.GetComponentString('LightComponent')
				if (math.random() > 0.0) and (component ~= nil) and (component.PowerConsumption > 0) and (component.isOn) then
					if self.parent.lights[item] == nil then
						self.parent.lights[item] = {}
						self.parent.lights[item].isOn = component.isOn
					end
					DD.setLightState(item, false)
				end
			end
		
			-- Timer until event ends
			self.timer = 60 * 2
		
			-- Warn players about event
			local message = 'Unusual magnetic interference is causing issues with eletrical systems. It is expected to go away on its own in {timer}.'
			DD.messageAllClients(DD.stringReplace(message, {timer = DD.numberToTime(self.timer)}), {preset = 'badinfo'})
			for client in Client.ClientList do
				if client.Character ~= nil then DD.giveAfflictionCharacter(client.Character, 'notificationfx', 999) end
			end
			-- Make event public
			self.parent.public = true
		end,
		onThink = function (self)
			if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
			local timesPerSecond = 2
		
			if self.timer > 0 then
				self.timer = self.timer - 1 / timesPerSecond
			else
				self.parent.finish()
				return
			end
		end,
	},
	
	onFinishAlways = function (self)
		for item, state in pairs(self.doors) do
			DD.setDoorState(item, state)
			item.GetComponentString('Door').IsJammed = false
		end
		for item, state in pairs(self.lights) do
			item.GetComponentString('LightComponent').flicker = state.flicker
			item.GetComponentString('LightComponent').flickerSpeed = state.flickerSpeed
			if SERVER then
				local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("Flicker")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			end
			if SERVER then
				local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("FlickerSpeed")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			end
			DD.setLightState(item, state.isOn)
		end
	end
})