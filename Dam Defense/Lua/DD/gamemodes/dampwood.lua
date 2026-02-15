-- PvE gamemode inspired by Gloomwood
DD.eventDampwood = DD.class(DD.eventBase, nil, {
	name = 'dampwood',
	isMainEvent = true,
	weight = 0,
	goodness = 0,
	
	lateJoinSpawn = function (self, client)
		-- get job and job variant
		local job = 'traveller'
		local variant
		for jobVariant in client.JobPreferences do
			if tostring(jobVariant.Prefab.Identifier) == job then
				variant = jobVariant.Variant
			end
		end
		if variant == nil then variant = math.random(JobPrefab.Get(job).Variants) - 1 end
		
		local pos = DD.findRandomWaypointByJob('jet').WorldPosition
		local character = DD.spawnHuman(client, job, pos, nil, variant, nil)
		character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
		character.UpdateTeam()
		
		return true
	end,
	
	onThink = function (self) return end,
})
DD.gamemodeDampwood = DD.class(DD.gamemodeBase, nil, {
	name = 'dampwood',
	displayName = 'dampwood',
	
	commandOverride = {
		credits = false,
		withdraw = false,
		possess = false,
		freecam = false,
		election = false,
	},
	eventBlacklist = {
		'fish',
	},
	
	populationData = {
		maximunTime = 60 * 60, -- in seconds, time for population target amount to reach its maximun
		spawnInterval = 2 * 60, -- in seconds
		populations = {
			crowmen = {
				maximun = 20,
				locationTag = 'dd_wetsewer',
				spawnInterval = 1 * 60,
			},
			goatmen = {
				maximun = 4,
				locationTag = 'dd_wetsewer',
				spawnInterval = 4 * 60,
			},
			huntsman = {
				maximun = 10,
				locationTag = 'dd_carriage',
				speciesName = 'huntsman',
				job = 'hunterjob',
				delay = 4,
				itemfx = 'whistlealarmfx',
				spawnAmount = 2,
				spawnInterval = 2 * 60,
				maximunTime = 30 * 60,
			},
		},
	},
	artifactSpawnInterval = 10 * 60, -- in seconds
	
	resetNextSpawnTime = function (self, populationName)
		local spawnInterval = self.populationData.populations[populationName].spawnInterval or self.populationData.spawnInterval
		self.populationData.populations[populationName].nextSpawnTime = DD.roundTimer + spawnInterval
	end,
	
	getPopulationTargetAmount = function (self, populationName)
		local maximunTime = self.populationData.populations[populationName].maximunTime or self.populationData.maximunTime
		return math.floor(math.min(1, DD.roundTimer / maximunTime) * self.populationData.populations[populationName].maximun)
	end,
	
	onRoundStart = function (self)
		self.tempSet('eventDirector.enabled', false)
		self.tempSet('growCharacter', function () return end)
		self.tempSet('breedCharacter', function () return end)
		self.tempSet('giveMoneyToClient', function () return end)
		self.tempSet('looseVentData', {})
		
		DD.eventDirector.startNewEvent(DD.eventDampwood)
		
		Hook.Add('item.created', 'DD.dampwood.removecorpse', function(item)
			if item.Prefab.Identifier ~= 'corpse' then return end
			Timer.NextFrame(function() Entity.Spawner.AddEntityToRemoveQueue(item) end)
		end)
		
		Timer.NextFrame(function ()
			for item in DD.reactors do
				DD.setItemInteractable(item, false)
			end
			for item in Item.ItemList do
				if item.HasTag('nexshop') or item.HasTag('secnexshop') or item.HasTag('nukieshop') then
					DD.setItemInteractable(item, false)
					DD.setLightState(item, false)
				end
				if (item.Prefab.Identifier == 'printer') or (item.Prefab.Identifier == 'ballotbox') then
					Entity.Spawner.AddEntityToRemoveQueue(item)
				end
				if item.HasTag('dd_dampwood_show') then
					DD.setItemVisible(item, true)
				end
				if item.HasTag('dd_dampwood_hide') then
					DD.setItemVisible(item, false)
				end
				if item.Prefab.Identifier == 'pump' then
					DD.setItemVulnerableToDamage(item, false)
					item.GetComponentString('Pump').MinVoltage = 0
					-- FIX LATER: for some reason this doesn't actually sync the minvoltage so it looks weird (even though it works)
					if SERVER then
						local prop = item.GetComponentString('Pump').SerializableProperties[Identifier("MinVoltage")]
						Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('Pump')))
					end
				end
			end
			
			-- delete initially spawned characters and do a respawn
			for character in Character.CharacterList do
				local client = DD.findClientByCharacter(character)
				if client ~= nil then client.SetClientCharacter(nil) end
				Entity.Spawner.AddEntityToRemoveQueue(character)
			end
			Timer.NextFrame(function ()
				Game.DispatchRespawnSub()
			end)
			
			-- spawn hogs to guard places full of loot
			for waypoint in DD.findWaypointsByJob('hogjob') do
				local pos = waypoint.WorldPosition
				DD.spawnHuman(nil, 'hogjob', pos, nil, nil, 'humanhog')
			end
		end)
	end,
	
	onThink = function (self)
		if CLIENT or (DD.thinkCounter % 30 ~= 0) then return end
		
		for populationName, data in pairs(self.populationData.populations) do
			if self.populationData.populations[populationName].nextSpawnTime == nil then
				self.resetNextSpawnTime(populationName)
			end
			local populationAmount = DD.roundData.populations[populationName] or 0
			if populationAmount < self.getPopulationTargetAmount(populationName) then
				if DD.roundTimer >= self.populationData.populations[populationName].nextSpawnTime then
					local pos
					if data.locationTag ~= nil then
						pos = DD.getLocation(function (item) return item.HasTag(data.locationTag) end).WorldPosition
					end
					if pos ~= nil then
						if data.itemfx ~= nil then
							Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(data.itemfx), pos, nil, nil, function (spawnedItem) end)
						end
						
						local spawnAmount = data.spawnAmount or 1
						local speciesName = data.speciesName or populationName
						Timer.Wait(function ()
							for n = 1, spawnAmount do
								if data.job == nil then
									Entity.Spawner.AddCharacterToSpawnQueue(speciesName, pos, function (character) return end)
								else
									DD.spawnHuman(nil, data.job, pos, nil, nil, speciesName)
								end
							end
						end, (data.delay or 0) * 1000)
					end
					
					self.resetNextSpawnTime(populationName)
				end
			else
				self.resetNextSpawnTime(populationName)
			end
		end
		
		if self.artifactNextSpawnTime == nil then
			self.artifactNextSpawnTime = DD.roundTimer + self.artifactSpawnInterval
		end
		if DD.roundTimer >= self.artifactNextSpawnTime then
			self.artifactNextSpawnTime = DD.roundTimer + self.artifactSpawnInterval
			
			DD.eventDirector.startNewEvent(DD.eventAirdropArtifact)
		end
	end,
	
	onRoundEnd = function (self)
		Hook.Remove('item.created', 'DD.dampwood.removecorpse')
	end,
})

--[[

-> MAYBE the shop could be somehow functional so people can spend nexcredits (enable the shop sec nexshops?) (maybe add a green regular nexshop to the shop because a sec nexshop would be OP and this is despawned outside dampwood gamemode)

NOT URGENT
-> add crowking
-> add batbarber
-> add barbed wire (like NML, ask squall?)

EXPERIMENTAL
-> EXPERIMENT with having constables be given a IDLE order so they won't leave their posts even if the door breaks
-> EXPERIMENT with having a big goatmen who breaks buildings to kill people inside
-> EXPERIMENT adding valuables you can sell for cash (gems, gold cups, rings)
-> EXPERIMENT with having players respawn with additional loot as round goes on

]]--