if CLIENT and Game.IsMultiplayer then return end

-- blood sampler
Hook.Add("DD.bloodsampler.bloodsample", "DD.bloodsampler.bloodsample", function(effect, deltaTime, item, targets, worldPosition)
	local user = item.ParentInventory
	if user == nil then return end
	user = user.Owner
	local userClient = DD.findClientByCharacter(user)
	
	if targets[1] == nil then return end
	local character = targets[1]
	local client = DD.findClientByCharacter(character)
	
	-- item has been used and thus will be deleted
	Entity.Spawner.AddEntityToRemoveQueue(item)
	
	local speciesName = string.lower(tostring(character.SpeciesName))
	if speciesName ~= 'human' then
		if DD.isCharacterHusk(character) then
			local inventory = item.ParentInventory
			Entity.Spawner.AddEntityToRemoveQueue(item)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('huskeggs'), inventory, nil, nil, function (spawnedItem) end)
		end
		if character.IsDead then
			local inventory = item.ParentInventory
			Entity.Spawner.AddEntityToRemoveQueue(item)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('anthraxsyringe'), inventory, nil, nil, function (spawnedItem) end)
		end
		return
	end
	
	local characterInfection = character.CharacterHealth.GetAfflictionStrengthByType('infection', true)
	
	local getCharacterInfection = function (character, diseaseName)
		local total = 0
		total = total + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		return total
	end
	
	local inventory = item.ParentInventory
	
	local testResults = {['Crystal meth'] = false}
	for event in DD.eventDirector.events do
		if event.name == 'gang' then
			if event.gangstersSet[client] then
				testResults['Crystal meth'] = true
			end
		end
	end
	
	local characterInfections = {}
	for diseaseName, data in pairs(DD.diseaseData) do
		characterInfections[diseaseName] = character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		if characterInfections[diseaseName] > 0 then
			testResults[DD.diseaseData[diseaseName].displayName .. ' infection'] = true
		else
			testResults[DD.diseaseData[diseaseName].displayName .. ' infection'] = false
		end
	end
	
	local winnerName = ''
	local winnerStrength = 0
	for infectionName, infectionStrength in pairs(characterInfections) do
		if infectionStrength > winnerStrength then
			winnerName = infectionName
			winnerStrength = infectionStrength
		end
	end
	
	if userClient ~= nil then
		local text = ''
		for name, value in pairs(testResults) do
			if value then
				text = text .. name .. ': ' .. 'positive. '
			end
		end
		text = string.sub(text, 1, #text - 1)
		if text == '' then text = 'Negative on all tests.' end
		if not DD.isCharacterMedical(user) then text = 'No test results due to lack of medical expertise.' end
		DD.messageClient(userClient, text, {preset = 'bloodsample'})
	end
	
	if winnerName == '' then return end
	local itemIdentifier = winnerName .. 'syringe'
	if DD.diseaseData[winnerName].item ~= nil then itemIdentifier = DD.diseaseData[winnerName].item end
	
	if characterInfection <= 0 then return end
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(itemIdentifier), inventory, nil, nil, function (spawnedItem) end)
end)

-- heal gun healing is cut by a 1/2 if target has been recently attacked
Hook.Add("DD.healgunround.heal", "DD.healgunround.heal", function(effect, deltaTime, item, targets, worldPosition)
	local character = targets[1]
	
	local multiplier = DD.lerp(math.max(0, 5 - character.CharacterHealth.GetAfflictionStrengthByIdentifier('recentlyattacked', true)) / 5, 1/2, 1)
	character.CharacterHealth.ReduceAfflictionOnAllLimbs('damage', 10 * multiplier, nil, effect.user)
	character.CharacterHealth.ReduceAfflictionOnAllLimbs('bloodloss', 6 * multiplier, nil, effect.user)
	character.CharacterHealth.ReduceAfflictionOnAllLimbs('burn', 4 * multiplier, nil, effect.user)
	character.CharacterHealth.ReduceAfflictionOnAllLimbs('bleeding', 4 * multiplier, nil, effect.user)
end)

-- attaches generator to wall
Hook.Add("DD.portablegenerator.attach", "DD.portablegenerator.attach", function(effect, deltaTime, item, targets, worldPosition)
	item.GetComponentString('Holdable').AttachToWall()
end)

-- changes the job of an idcard or clothing
Hook.Add("DD.idcardprinter.apply", "DD.idcardprinter.apply", function(effect, deltaTime, item, targets, worldPosition)
	local containedItem = targets[1]
	if (containedItem == nil) or ((containedItem.Prefab.Identifier ~= 'idcard') and (not containedItem.HasTag('clothing'))) then return end
	local tags = item.tags
	if (tags == nil) or (#DD.stringSplit(tostring(tags), ',') < 2) then return end
	tags = tostring(tags)
	
	-- get needed data from printer tags
	local characterName
	local identifier
	for tag in DD.stringSplit(tostring(tags), ',') do
		if string.sub(tag, 1, 5) == 'name:' then
			characterName = string.sub(tag, 6, #tag)
		elseif tag ~= 'light' then
			identifier = DD.tableJoin(DD.stringSplit(string.lower(tag), ' '))
		end
	end
	
	-- special case scenario for renaming ID card without changing the job
	if identifier == nil then
		if containedItem.Prefab.Identifier == 'idcard' then
			local tags = ''
			for tag in DD.stringSplit(containedItem.Tags, ',') do
				if string.sub(tag, 1, 5) ~= 'name:' then
					tags = tags .. tag .. ','
				end
			end
			containedItem.tags = tags .. 'name:' .. characterName
			-- Sync changes for clients
			if SERVER then
				local item = containedItem
				local tags = item.SerializableProperties[Identifier("Tags")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
			end
		end
		return
	end
	
	-- custom cards that do not have a job related to them
	local customCards = {
		shop = {
			name = 'Shopkeeper',
			tags = 'id_shop,id_laborer',
			clothing = {'commonerclothes1'},
			color = Color(55, 155, 0),
			trueColor = true,
			shortcuts = {
				'shop',
				'shopowner',
				'shopkeep',
				'shopkeeper',
				'store',
				'storeowner',
				'storekeep',
				'storekeeper',
				'vendor',
				'merchant',
				'retailer',
				'trader',
				'clerk',
				'seller',
			}
		},
		miner = {
			name = 'Miner',
			tags = 'id_miner,id_laborer',
			clothing = {'minerclothes'},
			color = Color(100, 10, 24),
			shortcuts = {
				'miner',
			}
		},
		vip = {
			clothing = {'vipclothes1', 'vipclothes2', 'vipclothes3'},
			clothingOnly = true,
			shortcuts = {
				'vip',
			}
		},
		admin = {
			clothing = {'administratorclothes'},
			clothingOnly = true,
			shortcuts = {
				'administrator',
				'admin',
				'nazi',
			}
		},
		cultist = {
			clothing = {'faultycultistrobes'},
			clothingOnly = true,
			shortcuts = {
				'huskcultist',
				'cultist',
				'cultie',
				'cult',
				'zealot',
				'husk',
			}
		},
	}
	local customCard
	for key, value in pairs(customCards) do
		if DD.tableHas(value.shortcuts, identifier) then
			customCard = value
		end
	end
	
	-- alternative names for jobs
	local shortcuts = {
		-- mayor
		mayor = 'captain',
		cap = 'captain',
		-- diver
		div = 'diver',
		-- foreman
		headengineer = 'foreman',
		headengi = 'foreman',
		headeng = 'foreman',
		chiefengineer = 'foreman',
		chiefengi = 'foreman',
		chiefeng = 'foreman',
		-- researcher
		res = 'researcher',
		scientist = 'researcher',
		sci = 'researcher',
		-- medical doctor
		doctor = 'medicaldoctor',
		doc = 'medicaldoctor',
		medic = 'medicaldoctor',
		med = 'medicaldoctor',
		-- security officer
		enforcer = 'securityofficer',
		security = 'securityofficer',
		officer = 'securityofficer',
		sec = 'securityofficer',
		cop = 'securityofficer',
		police = 'securityofficer',
		-- engineer
		engi = 'engineer',
		eng = 'engineer',
		-- janitor
		jani = 'janitor',
		jan = 'janitor',
		-- bodyguard
		guard = 'bodyguard',
		goon = 'bodyguard',
		bouncer = 'bodyguard',
		bg = 'bodyguard',
		-- mechanic
		laborer = 'mechanic',
		labor = 'mechanic',
		labo = 'mechanic',
		lab = 'mechanic',
		mech = 'mechanic',
		mec = 'mechanic',
		worker = 'mechanic',
		work = 'mechanic',
		-- convict
		convict = 'assistant',
		prisoner = 'assistant',
		inmate = 'assistant',
		-- mercs
		merc = 'mercs',
		-- mercs evil
		mercevil = 'mercsevil',
		deathsquad = 'mercsevil',
	}
	if (shortcuts[identifier] ~= nil) and (customCard == nil) then identifier = shortcuts[identifier] end
	
	-- handle containedItem possibly being clothing
	local idcard
	if containedItem.Prefab.Identifier ~= 'idcard' then
		if customCard then
			if customCard.clothing == nil then return end
			identifier = customCard.clothing[math.random(#customCard.clothing)]
		else
			local waypoint = DD.findRandomWaypointByJob(identifier)
			if waypoint == nil then return end
			
			local jobPrefab = JobPrefab.Get(identifier)
			local itemSet = jobPrefab.JobItems[math.random(0, #jobPrefab.JobItems)]
			
			for value in itemSet do
				if value.Outfit then
					identifier = value.ItemIdentifier
					break
				end
			end
		end
		
		if containedItem.OwnInventory ~= nil then
			for slot = 0, containedItem.OwnInventory.Capacity do
				local count = 99
				while containedItem.OwnInventory.GetItemAt(slot) ~= nil do
					containedItem.OwnInventory.GetItemAt(slot).Drop()
					-- safety agaisnt infinite looping
					count = count - 1
					if count <= 0 then break end
				end
			end
		end
		
		Entity.Spawner.AddEntityToRemoveQueue(containedItem)
		Timer.Wait(function ()
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)
		end, 1)
		
		return
	else
		idcard = containedItem
	end
	
	-- get character name from ID card
	if characterName == nil then
		for tag in DD.stringSplit(idcard.Tags, ',') do
			if string.sub(tag, 1, 5) == 'name:' then
				characterName = string.sub(tag, 6, #tag)
				break
			end
		end
		characterName = characterName or CharacterInfo('human', 'John Doe').GetRandomName(1)
	end
	
	-- give idcard tags
	local jobPrefab
	if customCard == nil then
		-- find a spawnpoint to see what idcard tags are associated with the job
		local waypoint = DD.findRandomWaypointByJob(identifier)
		if waypoint == nil then return end
		idcard.tags = DD.tableJoin(waypoint.IdCardTags, ',')
		jobPrefab = JobPrefab.Get(waypoint.AssignedJob.Identifier)
	else
		if customCard.clothingOnly then return end
		idcard.tags = customCard.tags
	end
	
	-- Set the idcard's color to be the job's UIColor
	local color = jobPrefab and jobPrefab.UIColor or customCard.color
	if (customCard == nil) or (not customCard.trueColor) then color = Color.Lerp(color, Color.White, 0.25) end
	idcard.SpriteColor = color
	idcard['set_InventoryIconColor'](color)
	
	-- Set the name and jobid tags
	idcard.tags = idcard.tags .. ',name:' .. characterName .. ',jobid:' .. identifier
			
	-- Sync changes for clients
	if SERVER then
		local item = idcard
		local tags = item.SerializableProperties[Identifier("Tags")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
		local sprcolor = item.SerializableProperties[Identifier("SpriteColor")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(sprcolor, item))
		local invColor = item.SerializableProperties[Identifier("InventoryIconColor")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(invColor, item))
	end
end)

-- deletes raw material to create an idcard/clothing
Hook.Add("DD.idcardprinter.create", "DD.idcardprinter.create", function(effect, deltaTime, item, targets, worldPosition)
	local containedItem = targets[1]
	if containedItem == nil then return end
	
	local identifier
	if containedItem.Prefab.Identifier == 'plastic' then
		identifier = 'idcard'
	elseif containedItem.Prefab.Identifier == 'organicfiber' then
		identifier = 'commonerclothes2'
	end
	if identifier == nil then return end
	
	Entity.Spawner.AddEntityToRemoveQueue(containedItem)
	Timer.Wait(function ()
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)
	end, 1)
end)

-- deletes idcard/clothing to create raw material
Hook.Add("DD.idcardprinter.delete", "DD.idcardprinter.delete", function(effect, deltaTime, item, targets, worldPosition)
	local containedItem = targets[1]
	if containedItem == nil then return end
	
	local identifier
	if containedItem.Prefab.Identifier == 'idcard' then
		identifier = 'plastic'
	elseif containedItem.HasTag('clothing') then
		identifier = 'organicfiber'
	end
	if identifier == nil then return end
	
	if containedItem.OwnInventory ~= nil then
		for slot = 0, containedItem.OwnInventory.Capacity do
			local count = 99
			while containedItem.OwnInventory.GetItemAt(slot) ~= nil do
				containedItem.OwnInventory.GetItemAt(slot).Drop()
				-- safety agaisnt infinite looping
				count = count - 1
				if count <= 0 then break end
			end
		end
	end
	
	Entity.Spawner.AddEntityToRemoveQueue(containedItem)
	Timer.Wait(function ()
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)
	end, 1)
end)

-- wifi trigger
Hook.Add("DD.wifitrigger.use", "DD.wifitrigger.use", function(effect, deltaTime, item, targets, worldPosition)
	component = item.GetComponentString('WifiComponent').TransmitSignal(Signal('true'), false)
end)

-- whaling gun uses powder when fired
Hook.Add("DD.whalinggun.use", "DD.whalinggun.use", function(effect, deltaTime, item, targets, worldPosition)
	local powder = targets[#targets]
	for target in targets do
		if (LuaUserData.TypeOf(target) == 'Barotrauma.Item') and (target.HasTag('whalinggunpowder') or target.HasTag('munition_propulsion')) then
			target.Condition = target.Condition - 50
			break
		end
	end
end)

-- some armor absorbs damage, but in return, will break down
-- this hook also applies the recentlyattacked affliction which serves as a flag
Hook.Patch("Barotrauma.Character", "ApplyAttack", function(instance, ptable)
    local character = instance
	local hitLimb = ptable['targetLimb']
	
	-- prevent undead from attacking cultists and other undead
	if (ptable['attacker'] ~= nil) and (ptable['attacker'].SpeciesName == 'humanundead') and
	((character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) > 99) or (character.SpeciesName == 'humanundead')) then
		ptable.PreventExecution = true
	end
	
	-- flag affliction
	DD.giveAfflictionCharacter(character, 'recentlyattacked', 999)
	
	if hitLimb == nil then return end
	local afflictions = ptable['attack'].Afflictions
	local penetration = ptable['penetration']
	local multiplier = 1.0
	
    if character.Inventory == nil then return end
    local armor
	if hitLimb.type == LimbType.Head then
		armor = character.Inventory.GetItemAt(DD.invSlots.head)
		multiplier = 2.0
	else
		armor = character.Inventory.GetItemAt(DD.invSlots.suit)
	end
	if armor == nil then return end
	local set = {
		ironhelmet = true,
		makeshiftarmor = true,
	}
	if not set[tostring(armor.Prefab.Identifier)] then return end

    local damage = 0

    for affliction, value in pairs(afflictions) do
		if affliction.Identifier == 'gunshotwound' then
			damage = damage + affliction.Strength * (1 - penetration) * multiplier
		end
    end

	if armor.Condition > 0 then
		armor.Condition = armor.Condition - damage
		if armor.Condition <= 0 then
			for v in armor.GetComponentString('Wearable').DamageModifiers do
				if v.AfflictionIdentifiers == 'gunshotwound' then
					v['set_DamageMultiplier'](0.5)
					break
				end
			end
			-- Sound effect
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('armorbreakfx'), armor.WorldPosition, nil, nil, function (spawnedItem) end)
			-- Make armor grey when it is broken
			local color = Color(155, 155, 155)
			armor.SpriteColor = color
			armor['set_InventoryIconColor'](color)
			-- Sync changes for clients
			if SERVER then
				local item = armor
				local sprcolor = item.SerializableProperties[Identifier("SpriteColor")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(sprcolor, item))
				local invColor = item.SerializableProperties[Identifier("InventoryIconColor")]
				Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(invColor, item))
			end
		end
	end
end, Hook.HookMethodType.Before)

-- toggles repairtool between wrench and screwdriver mode
Hook.Add("DD.repairtool.toggle", "DD.repairtool.toggle", function(effect, deltaTime, item, targets, worldPosition)
	if item == nil then return end
	if item.HasTag('wrench') then
		local tags = ''
		for tag in item.GetTags() do
			if tag ~= 'wrench' then tags = tags .. ',' .. tostring(tag) end
		end
		tags = tags .. ',screwdriver'
		item.Tags = tags
	else
		local tags = ''
		for tag in item.GetTags() do
			if tag ~= 'screwdriver' then tags = tags .. ',' .. tostring(tag) end
		end
		tags = tags .. ',wrench'
		item.Tags = tags
	end
	if SERVER then
		local tags = item.SerializableProperties[Identifier("Tags")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
	end
end)

-- wizard staff and spellbooks
LuaUserData.MakeMethodAccessible(Descriptors["Barotrauma.WayPoint"], "set_IdCardTags")
LuaUserData.MakeMethodAccessible(Descriptors['Barotrauma.Items.Components.RangedWeapon'], 'set_MaxChargeTime')
Hook.Patch("Barotrauma.Items.Components.RangedWeapon", "Use", function(instance, ptable)
    local item = instance.Item
	if item.Prefab.Identifier == 'merasmusstaff' then
		local character = ptable['character']
		if character == nil then
			ptable.PreventExecution = true
		else
			local book = character.Inventory.GetItemAt(DD.invSlots.lefthand)
			if (book == nil) or (not book.HasTag('merasmusspellbook')) or (character.CharacterHealth.GetAfflictionStrengthByIdentifier('wizard', true) < 1) then
				ptable.PreventExecution = true
				return
			end
			local identifier = string.sub(tostring(book.Prefab.Identifier), 1, #tostring(book.Prefab.Identifier) - 4)
			if item.OwnInventory.GetItemAt(0) ~= nil then
				if tostring(item.OwnInventory.GetItemAt(0).Prefab.Identifier) == identifier then
					return
				else
					Entity.Spawner.AddEntityToRemoveQueue(item.OwnInventory.GetItemAt(0))
				end
			end
			local component = item.GetComponentString('RangedWeapon')
			if identifier == 'merasmusblastjump' then
				component.Reload = 0.1
			else
				component.Reload = 1.2
			end
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(identifier), item.OwnInventory, nil, nil, function (spawnedItem) end)	
		end
	end
end, Hook.HookMethodType.Before)
Hook.Add("DD.staff.use", "DD.staff.use", function(effect, deltaTime, item, targets, worldPosition)
	local character = targets[1]
	local phrases = {
		'Basbus Brontu!',
		'Bontu Barsoma!',
		'Babmo Bibrundo!',
		'Bravus Abimbus!',
		'Barbo Cabarto!',
		'Abo Alabasbas!',
		'Lesbo Barrabus!',
		'Barraparraf Brubus!',
		'Binto Bartum!',
		'Bemilus Bronte!',
		'Mictor Ate!',
	}
	character.Speak(phrases[math.random(#phrases)], ChatMessageType.Default)
end)
Hook.Add("DD.staff.update", "DD.staff.update", function(effect, deltaTime, item, targets, worldPosition)
	local character = targets[1]
	if character == nil then return end
	local book = character.Inventory.GetItemAt(DD.invSlots.lefthand)
	if (book == nil) or (not book.HasTag('merasmusspellbook')) or (character.CharacterHealth.GetAfflictionStrengthByIdentifier('wizard', true) < 1) then
		item.Condition = 0
	else
		item.Condition = 100
	end 
end)
-- Wizard death
DD.characterDeathFunctions.wizardDeath = function (character)
	if character.JobIdentifier ~= 'wizard' then return end
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('wizardfx'), character.WorldPosition, nil, nil, function (spawnedItem) end)
	Timer.Wait(function ()
		Entity.Spawner.AddEntityToRemoveQueue(character)
	end, 100)
end

-- fistful of frags
Hook.Add("DD.brassknuckle.disarm", "DD.brassknuckle.disarm", function(effect, deltaTime, item, targets, worldPosition)
	local character = item
	local limb = targets[1]
	local limbSlot
	if limb.type == LimbType.LeftHand then
		limbSlot = InvSlotType.LeftHand
	elseif limb.type == LimbType.RightHand then
		limbSlot = InvSlotType.RightHand
	else
		return
	end
	local item = character.Inventory.GetItemInLimbSlot(limbSlot)
	if item == nil then return end
	if item.Prefab.Identifier == 'brassknuckle' then return end
	item.Drop(character, true, true)
end)

-- barricade
Hook.Patch("Barotrauma.Items.Components.Holdable", "OnPicked", {'Barotrauma.Character'}, function(instance, ptable)
    local item = instance.Item
	if item.Prefab.Identifier == 'barricade' then
		if item.linkedTo[1] ~= nil then
			item.Condition = item.linkedTo[1].Condition
			Entity.Spawner.AddItemToRemoveQueue(item.linkedTo[1])
		end
	end
end, Hook.HookMethodType.Before)
Hook.Patch("Barotrauma.Items.Components.Holdable", "AttachToWall", function(instance, ptable)
	if CLIENT and Game.IsSingleplayer and Game.IsSubEditor then return end
    local item = instance.Item
	if item.Prefab.Identifier == 'barricade' then
		if item.Condition <= 0 then
			ptable.PreventExecution = true
			return
		end
		if (item.linkedTo[1] == nil) and (Entity.Spawner ~= nil) then
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('barricadestatic'), item.WorldPosition, item.Condition, nil, function (spawnedItem)
				spawnedItem.Condition = item.Condition
				item.AddLinked(spawnedItem)
				spawnedItem.AddLinked(item)
			end)
		end
	end
end, Hook.HookMethodType.Before)
Hook.Add("DD.barricade.break", "DD.barricade.break", function(effect, deltaTime, item, targets, worldPosition)
	if item.linkedTo[1] ~= nil then
		item.linkedTo[1].Condition = 0
	end
end)

-- more intense and better blast jumping
Hook.Add("DD.jumpergrenade.blastjump", "DD.jumpergrenade.blastjump", function(effect, deltaTime, item, targets, worldPosition)
	local normalizedDot = function (vector1, vector2)
		return math.cos(math.atan2(vector1.y, vector1.x) - math.atan2(vector2.y, vector2.x))
	end

	local character = effect.user
	local vector = Vector2.Normalize(character.AnimController.MainLimb.WorldPosition - item.WorldPosition + Vector2(0, 100))
	local distance = Vector2.Distance(character.AnimController.MainLimb.WorldPosition, item.WorldPosition)
	local scaler = 600
	if distance <= 400 then
		character.Stun = math.max(0.5, character.Stun)
		local velocity = character.AnimController.Collider.LinearVelocity
		character.AnimController.Collider.LinearVelocity = velocity * normalizedDot(vector, velocity)
		character.AnimController.Collider.ApplyForce(vector * scaler)
		for limb in character.AnimController.Limbs do
			velocity = limb.body.LinearVelocity
			limb.body.LinearVelocity = velocity * normalizedDot(vector, velocity)
			limb.body.ApplyForce(vector * scaler)
		end
		DD.giveAfflictionCharacter(character, 'blastjumping', 2)
	end
end)
Hook.Add("DD.merasmusblastjump.blastjump", "DD.merasmusblastjump.blastjump", function(effect, deltaTime, item, targets, worldPosition)
	local normalizedDot = function (vector1, vector2)
		return math.cos(math.atan2(vector1.y, vector1.x) - math.atan2(vector2.y, vector2.x))
	end

	local user = effect.user
	local character = targets[1]
	local vector
	local deltaX = character.WorldPosition.X - user.WorldPosition.X
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('blastjumping') > 0 then
		vector = Vector2.Normalize(Vector2(deltaX / math.abs(deltaX), 1))
	else
		vector =  Vector2.Normalize(Vector2(deltaX / math.abs(deltaX), 10))
	end
	local distance = Vector2.Distance(character.AnimController.MainLimb.WorldPosition, item.WorldPosition)
	local scaler = 400
	
	if distance <= 400 then
		character.Stun = math.max(1, character.Stun)
		local velocity = character.AnimController.Collider.LinearVelocity
		character.AnimController.Collider.LinearVelocity = Vector2()
		character.AnimController.Collider.ApplyForce(vector * scaler)
		for limb in character.AnimController.Limbs do
			velocity = limb.body.LinearVelocity
			limb.body.LinearVelocity = Vector2()
			limb.body.ApplyForce(vector * scaler)
		end
		DD.giveAfflictionCharacter(character, 'blastjumping', 2)
	end
end)

-- casts a raycast to repair barricades (static barricades otherwise do not collide)
Hook.Patch("Barotrauma.Items.Components.RepairTool", "Use", function(instance, ptable)
	local item = instance.Item
	if not item.HasTag('weldingequipment') then return end
	local component = item.GetComponentString('RepairTool')
	local pos = item.WorldPosition
	local deltaPos = component.TransformedBarrelPos
	local angle = (item.body.Dir == 1) and item.body.Rotation or (item.body.Rotation + math.pi)
	local point1 = pos + deltaPos
	local point2 = pos + deltaPos + component.range * Vector2(math.cos(angle), math.sin(angle))
	
	if DD.gui ~= nil then
		DD.gui.debugLine.point1 = point1
		DD.gui.debugLine.point2 = point2
	end
	
	local collisionCategory = bit32.bor(Physics.CollisionCharacter, Physics.CollisionWall)
	local result = DD.raycast(Submarine.MainSub, point1, point2, collisionCategory, callback)
	
	local blacklist = {}
	for entity in result.bodies do
		if LuaUserData.IsTargetType(entity, 'Barotrauma.Item') then
			if entity.HasTag('barricade') then
				entity.Condition = math.min(200, entity.Condition + 1)
			else
				break
			end
		elseif LuaUserData.IsTargetType(entity, 'Barotrauma.Structure') then
			break
		end
	end
end, Hook.HookMethodType.Before)
-- cast a raycast to burn corpses
Hook.Patch("Barotrauma.Items.Components.RepairTool", "Use", function(instance, ptable)
	local item = instance.Item
	if not item.HasTag('flamer') then return end
	local user = item.GetRootInventoryOwner()
	local component = item.GetComponentString('RepairTool')
	local pos = item.WorldPosition
	local deltaPos = component.TransformedBarrelPos
	local angle = (item.body.Dir == 1) and item.body.Rotation or (item.body.Rotation + math.pi)
	local point1 = pos + deltaPos
	local point2 = pos + deltaPos + component.range * Vector2(math.cos(angle), math.sin(angle))
	
	if DD.gui ~= nil then
		DD.gui.debugLine.point1 = point1
		DD.gui.debugLine.point2 = point2
	end
	
	local collisionCategory =  bit32.bor(Physics.CollisionItem, Physics.CollisionWall)
	local result = DD.raycast(Submarine.MainSub, point1, point2, collisionCategory, callback)
	
	local blacklist = {}
	for entity in result.bodies do
		if LuaUserData.IsTargetType(entity, 'Barotrauma.Item') then
			if entity.HasTag('corpse') then
				entity.Condition = entity.Condition - 2
				if entity.Condition <= 0 then
					Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('smokefx'), entity.WorldPosition - Vector2(0, 86) / 4, nil, nil, function (spawnedItem) end)
					local client = DD.findClientByCharacter(user)
					if client ~= nil then
						DD.giveMoneyToClient(client, 1, DD.stringLocalize('giveMoneyReasonCorpseDisposal'))
					end
				end
			else
				break
			end
		elseif LuaUserData.IsTargetType(entity, 'Barotrauma.Structure') then
			break
		end
	end
end, Hook.HookMethodType.Before)

-- displacer cannon teleport
Hook.Add("DD.displacercannon.teleport", "DD.displacercannon.teleport", function(effect, deltaTime, item, targets, worldPosition, element)
	local magic = element.GetAttributeBool("magic", false)

	local item = targets[1]
	if magic then
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('wizardfx'), effect.user.WorldPosition, nil, nil, function (spawnedItem) end)
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('wizardfx'), item.WorldPosition, nil, nil, function (spawnedItem) end)
	end
	effect.user.TeleportTo(item.WorldPosition)
	
	if magic then
		DD.giveAfflictionCharacter(effect.user, 'blastjumping', 2)
	end
end)

-- displacer cannon light component responds to item condition
Hook.Add("DD.displacercannon.update", "DD.displacercannon.teleport", function(effect, deltaTime, item, targets, worldPosition)
	local lerpFactor = (item.Condition / 100) ^ 2
	item.GetComponentString('LightComponent').LightColor = Color(Byte(70), Byte(200), Byte(250), Byte(DD.lerp(lerpFactor, 0, 255)))
	item.GetComponentString('LightComponent').Range = DD.lerp(lerpFactor, 0, 80)
	if SERVER then
		local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
		local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("Range")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
	end
end)

-- spraycan pepperspray
Hook.Add("DD.spraycan.use", "DD.spraycan.use", function(effect, deltaTime, item, targets, worldPosition)
	local limb = targets[1]
	if limb == nil then return end
	
	local character = limb.character
	if limb.type == LimbType.Head then
		local afflictionIdentifier = DD.stringSplit(tostring(item.Prefab.Identifier), 'spraycan')[1] .. 'paint'
		DD.giveAfflictionCharacter(character, afflictionIdentifier, 0.5 * deltaTime, limb)
		if character.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) < 1 then
			DD.giveAfflictionCharacter(character, 'noxiousspray', 0.5 * deltaTime, limb)
		end
	end
end)

-- smoking crystal meth makes user join the respective gang
Hook.Add("DD.meth.use", "DD.meth.use", function(effect, deltaTime, item, targets, worldPosition)
	if item.ParentInventory == nil then return end
	local pipe = item.ParentInventory.Owner
	if pipe.ParentInventory == nil then return end
	local character = pipe.ParentInventory.Owner
	local client = DD.findClientByCharacter(character)
	if client == nil then return end
	
	if (character.SpeciesName ~= 'human') or DD.isCharacterSecurity(character) then return end
	
	local color = DD.stringSplit(tostring(item.Prefab.Identifier), 'meth')[1]
	
	for event in DD.eventDirector.events do
		if (event.name == 'gang') and (event.gangColor == color) then
			event.addClientToGang(client)
		end
	end
end)

-- blood cult enlightened
Hook.Add("DD.enlightened.givetalent", "DD.enlightened.givetalent", function(effect, deltaTime, item, targets, worldPosition)
    local character = targets[1]
	if character == nil then return end
	
	-- talent
	if character.HasTalent('enlightenedmind') then return end
    character.GiveTalent('enlightenedmind', true)
	
	-- heal a character when he gets converted using a book
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlighteneddecaypause') > 0 then
		character.SetAllDamage(0, 0, 0)
		character.Oxygen = 100
		character.Bloodloss = 0
		character.SetStun(0, true)
		
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('bloodcultfx'), item.WorldPosition, nil, nil, function (spawnedItem) end)
	end
	
	-- play tchernobog sfx and flashes a image 1 second after player transforms
	Timer.Wait(function ()
		DD.giveAfflictionCharacter(character, 'enlightenedfx', 999)
	end, 1000)
	
	-- resets the time pressure for all cultists
	for character in Character.CharacterList do
		if character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) >= 99 then
			if character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
				character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
	end
	
	-- pop-up
	local client = DD.findClientByCharacter(character)
	if client == nil then return end
	if character.SpeciesName ~= 'humanundead' then
		DD.messageClient(client, DD.stringLocalize('bloodCultCultistInfo'), {preset = 'crit'})
		return
	end

	-- notify other cultists
	for otherClient in Client.ClientList do
		if (client ~= otherClient) and DD.isClientCharacterAlive(otherClient) and (otherClient.Character.SpeciesName == 'human') and (otherClient.Character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened') > 99) then
			DD.messageClient(otherClient, DD.stringLocalize('bloodCultRecruitmentNotice', {name = client.Name}), {preset = 'goodinfo'})
		end
	end
end)

-- blood cult sacrificial dagger
Hook.Add("DD.sacrificialdagger.sacrifice", "DD.sacrificialdagger.sacrifice", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	
	if targets[1] == nil then return end
	local character = targets[1]
	
	if character.SpeciesName == 'humanUndead' then return end
	if character.Vitality > 0 then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('cardiacarrest', true) >= 1 then return end
	
	local inventory = item.ParentInventory
	if (inventory.Owner == nil) or (inventory.Owner.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) < 99) then return end
	
	DD.giveAfflictionCharacter(character, 'cardiacarrest', 999)
	if SERVER then
		Networking.CreateEntityEvent(character, Character.CharacterStatusEventData.__new(true))
	end
	if inventory.Owner.SpeciesName == 'humanundead' then
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('lifeessence'), inventory.Owner.WorldPosition, nil, nil, function (spawnedItem) end)
	else
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('lifeessence'), inventory, nil, nil, function (spawnedItem) end)
	end
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('smokefx'), item.WorldPosition, nil, nil, function (spawnedItem) end)
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('bloodcultfx'), item.WorldPosition, nil, nil, function (spawnedItem) end)
end)


-- blood cult the 1998
Hook.Add("DD.the1998.use", "DD.the1998.use", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	
	if item.SpeciesName ~= 'human' then return end
	if item.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) > 99 then return end
	if effect.user.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) < 99 then return end
	
	DD.giveAfflictionCharacter(item, 'enlighteneddecaypause', 999)
	DD.giveAfflictionCharacter(item, 'enlightened', 30)
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('smokefx'), item.WorldPosition, nil, nil, function (spawnedItem) end)
end)

-- When a cultist dies, he will come back as a zombie
DD.characterDeathFunctions.cultistDeath = function (character)
	if character.SpeciesName ~= 'human' then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('timepressure', true) >= 59 then return end
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('enlightened', true) < 99 then return end
	if (character.Inventory.GetItemAt(DD.invSlots.innerclothing) == nil) or (tostring(character.Inventory.GetItemAt(DD.invSlots.innerclothing).Prefab.Identifier.Value) ~= 'bloodcultistrobes') then return end
	local client = DD.findClientByCharacter(character)
	
	-- Find items to be regiven (clothing, ID Card, etc)
	local slotItems = {}
	for itemCount = 0, character.Inventory.Capacity do
		local item = character.Inventory.GetItemAt(itemCount)
		if (item ~= nil) and (itemCount ~= DD.invSlots.lefthand) and (itemCount ~= DD.invSlots.righthand) and (tostring(item.Prefab.Identifier.Value) ~= 'handcuffs') and (tostring(item.Prefab.Identifier.Value) ~= 'bodybag') then
			slotItems[itemCount] = item
		end
		if (item ~= nil) and ((itemCount == DD.invSlots.lefthand) or (itemCount == DD.invSlots.righthand)) then
			item.Drop()
		end
	end
	
	local newCharacter = DD.spawnHuman(client, 'undeadjob', character.WorldPosition, character.Name, nil, 'humanUndead')
	newCharacter.SetOriginalTeamAndChangeTeam(CharacterTeamType.None, true)
	newCharacter.UpdateTeam()
	
	-- message
	if client ~= nil then
		local undeadInfo = DD.stringLocalize('undeadInfo')
		if #DD.eventDirector.getEventInstances('bloodCult') >= 1 then
			undeadInfo = undeadInfo .. ' ' .. DD.stringLocalize('undeadInfoBloodCult')
		end
		DD.messageClient(client, undeadInfo, {preset = 'crit'})
	end
	
    -- Spawn a duffel bag at the player's feet to put the dropped items inside
	local duffelbag
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('duffelbag'), character.WorldPosition, nil, nil, function (spawnedItem)
		duffelbag = spawnedItem
	end)
	-- Give items back to player after a delay
	Timer.Wait(function ()
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('smokefx'), newCharacter.WorldPosition, nil, nil, function (spawnedItem) end)
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('bloodcultfx'), newCharacter.WorldPosition, nil, nil, function (spawnedItem) end)
		-- Give clothing items to their correct slot
		for itemCount, item in pairs(slotItems) do
			newCharacter.Inventory.TryPutItem(item, itemCount, true, true, newCharacter, true, true)
			if itemCount == DD.invSlots.innerclothing then
				for itemCount = 0, item.OwnInventory.Capacity do
					local item = item.OwnInventory.GetItemAt(itemCount)
					if item ~= nil then
						item.Drop()
						duffelbag.OwnInventory.TryPutItem(item, character, nil, true, true)
					end
				end
				item.NonInteractable = true
				if SERVER then
					local tags = item.SerializableProperties[Identifier("NonInteractable")]
					Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(tags, item))
				end
			end
		end
		-- Delete old character
		Entity.Spawner.AddEntityToRemoveQueue(character)
	end, 100)
end

-- Give undead items
Hook.Add("character.created", 'DD.giveUndeadItems', function(createdCharacter)
	if createdCharacter.SpeciesName ~= 'humanUndead' then return end
	if createdCharacter.JobIdentifier ~= 'undeadjob' then
		Timer.Wait(function ()
			local client = DD.findClientByCharacter(createdCharacter)
			local character = DD.spawnHuman(client, createdCharacter.JobIdentifier, createdCharacter.WorldPosition, createdCharacter.Name)
			if Game.IsMultiplayer and (client ~= nil) then client.SetClientCharacter(character) end
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
			Entity.Spawner.AddEntityToRemoveQueue(createdCharacter)
		end, 100)
		return
	end
	Timer.Wait(function ()
		DD.giveAfflictionCharacter(createdCharacter, 'stun', 2)
		DD.giveAfflictionCharacter(createdCharacter, 'enlightened', 999)
		-- Give undead weapons
		local weapons = {
			{identifier = 'cultistmace', offhand = 'cultistshield'},
			{identifier = 'boardingaxe'},
			{identifier = 'cultistpitchfork'},
		}
		local weapon = weapons[math.random(#weapons)]
		Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(weapon.identifier), createdCharacter.Inventory, nil, nil, function (spawnedItem)
			Timer.Wait(function ()
				createdCharacter.Inventory.TryPutItem(spawnedItem, DD.invSlots.righthand, true, true, createdCharacter, true, true)
			end, 1)
			if weapon.script ~= nil then weapon.script(spawnedItem) end
		end)
		if weapon.offhand ~= nil then
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(weapon.offhand), createdCharacter.Inventory, nil, nil, function (spawnedItem)
				Timer.Wait(function ()
					createdCharacter.Inventory.TryPutItem(spawnedItem, DD.invSlots.lefthand, true, true, createdCharacter, true, true)
				end, 1)
			end)
			if weapon.script ~= nil then weapon.script(spawnedItem) end
		end
		
		if createdCharacter.Inventory.GetItemAt(DD.invSlots.innerclothes) == nil then
			DD.giveAfflictionCharacter(createdCharacter, 'enlightened', 999)
			Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('bloodcultistrobes'), createdCharacter.Inventory, nil, nil, function (spawnedItem)
				Timer.Wait(function ()
					createdCharacter.Inventory.TryPutItem(spawnedItem, DD.invSlots.innerclothes, true, true, createdCharacter, true, true)
				end, 1)
			end)
		end
	end, 100)
end)

-- time pressure
Hook.Add("DD.timepressure.explode", "DD.timepressure.explode", function(effect, deltaTime, item, targets, worldPosition)
    local character = targets[1]
	if character == nil then return end
	
	if character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
		character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
	end
	
	-- head goes kaboom
	for index, limb in pairs(character.AnimController.Limbs) do
		if index == 2 then
			Game.Explode(limb.WorldPosition, 1, 999, 999, 0, 0, 0, 0)
		end
	end
end)

-- Execute when a human puts on a goblin mask
Hook.Add("DD.goblinMask.wear", "DD.goblinMask.wear", function (effect, deltaTime, item, targets, worldPosition)
	-- Guard clause
	local character = targets[1]
	if (character == nil) or (character.SpeciesName ~= 'human') then return end
	
	-- Reset time pressure for all the trolls and goblins
	for character in Character.CharacterList do
		if (character.SpeciesName == 'humanGoblin') or (character.SpeciesName == 'humanTroll') then
			if character.CharacterHealth.GetAffliction('timepressure', true) ~= nil then
				character.CharacterHealth.GetAffliction('timepressure', true).SetStrength(0)
			end
		end
	end
	
	-- Is Troll
	local conversionTrollPercentage = 20
	local isTroll = math.random(100) <= conversionTrollPercentage
	
	-- For safety
	local greenskinInfo = DD.stringLocalize('greenskinInfo')
	local client = DD.findClientByCharacter(character)
	if client ~= nil then
		DD.messageClient(client, greenskinInfo, {preset = 'crit'})
	end
	
	-- Find items to be regiven (clothing, ID Card, etc)
	local slotItems = {}
	for itemCount = 0, character.Inventory.Capacity do
		local item = character.Inventory.GetItemAt(itemCount)
		if ((item == nil) or ((tostring(item.Prefab.Identifier.Value) ~= 'handcuffs') and (tostring(item.Prefab.Identifier.Value) ~= 'bodybag'))) and ((DD.tableHas({0, 1, 3, 4, 5, 6, 7}, itemCount) and (not isTroll)) or (DD.tableHas({0, 1, 3, 4, 7}, itemCount) and isTroll)) then
			local conversion = {[0] = 0, [1] = 1, [3] = 2, [4] = 3, [5] = 4, [6] = 6, [7] = 6}
			slotItems[conversion[itemCount]] = item
		end
	end
	-- Find items to drop
	local dropItems = {}
	local hasRemovedMask = false
	for item in character.Inventory.AllItems do
		if not DD.tableHas(slotItems, item) then
			if (item.Prefab.identifier ~= 'goblinmask') or hasRemovedMask then
				table.insert(dropItems, item)
			else
				hasRemovedMask = true
			end
		end
	end
	
	-- Make goblin (or troll)
	local speciesName = 'humanGoblin'
	if isTroll then speciesName = 'humanTroll' end
	local newCharacter = DD.spawnHuman(client, 'greenskinjob', character.WorldPosition, character.Name, nil, speciesName)
	newCharacter.SetOriginalTeamAndChangeTeam(CharacterTeamType.None, true)
	newCharacter.UpdateTeam()

    -- Spawn a duffel bag at the player's feet to put the dropped items inside
	local duffelbag
	Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('duffelbag'), character.WorldPosition, nil, nil, function (spawnedItem)
		duffelbag = spawnedItem
	end)
	-- Give items back to player after a delay
	Timer.Wait(function ()
		-- Remove goblin card
		Entity.Spawner.AddEntityToRemoveQueue(newCharacter.Inventory.GetItemAt(0))
		-- Give clothing items to their correct slot
		for itemCount, item in pairs(slotItems) do
			--newCharacter.Inventory.ForceToSlot(item, itemCount)
			newCharacter.Inventory.TryPutItem(item, itemCount, true, true, newCharacter, true, true)
		end
		-- Put other items in the duffel bag
		for item in dropItems do
			if not foundSlot then
				item.Drop()
				duffelbag.OwnInventory.TryPutItem(item, character, nil, true, true)
			end
		end
		-- Delete old character
		Entity.Spawner.AddEntityToRemoveQueue(character)
	end, 100)
	
end)

-- Give goblin/troll the greenskin talent(s) + fix to a bug introduced by the Summer Update (Barotrauma v1.5.7.0)
Hook.Add("character.created", 'DD.greenskinTalent', function(createdCharacter)
	if (createdCharacter.SpeciesName ~= 'humanGoblin') and (createdCharacter.SpeciesName ~= 'humanTroll') then return end
	
	Timer.Wait(function ()
		if createdCharacter.JobIdentifier ~= 'greenskinjob' then
			local client = DD.findClientByCharacter(createdCharacter)
			local character = DD.spawnHuman(client, createdCharacter.JobIdentifier, createdCharacter.WorldPosition, createdCharacter.Name)
			character.SetOriginalTeamAndChangeTeam(CharacterTeamType.Team1, true)
			character.UpdateTeam()
			if Game.IsMultiplayer and (client ~= nil) then client.SetClientCharacter(character) end
			Entity.Spawner.AddEntityToRemoveQueue(createdCharacter)
		else
			createdCharacter.GiveTalent('greenskinknowledge', true)
			local items = {
				humangoblin = {
					'idcard',
					'bikehorn',
					'midazolam',
					'midazolam',
					'meth',
					'meth',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblinmask'
				},
				humantroll = {
					'idcard',
					'midazolam',
					'midazolam',
					'meth',
					'meth',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblincrate',
					'goblinmask',
					'goblinmask'
				}
			}
			for item in items[string.lower(tostring(createdCharacter.SpeciesName))] do
				Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab(item), createdCharacter.Inventory, nil, nil, function (spawnedItem) end)
			end
		end
	end, 100)
end)

-- Sends a message to husks telling them about their objective and abilities
Hook.Add("character.created", "DD.huskMessage", function (createdCharacter)
	if createdCharacter.SpeciesName ~= 'humanhusk' then return end
	Timer.Wait(function()
		local client = DD.findClientByCharacter(createdCharacter)
		if client == nil then return end
		DD.messageClient(client, DD.stringLocalize('huskInfo'), {preset = 'crit'})
	end, 100)
end)

-- radiation
local fuelrodDecayNetworkCooldown = {}
Hook.Add("DD.fuelrod.decay", "DD.fuelrod.decay", function(effect, deltaTime, item, targets, worldPosition)
	local containerMultiplier = {
		artifactcontainer = 0.0,
		exosuit = 0.0,
		clownexosuit = 0.0,
		nucleargun = 0.5,
		reactor1 = 0.5,
		outpostreactor = 0.5,
	}
	local multiplier = 1.0
	if (item.ParentInventory ~= nil) and (LuaUserData.TypeOf(item.ParentInventory.Owner) == 'Barotrauma.Item') and
	(containerMultiplier[tostring(item.ParentInventory.Owner.Prefab.Identifier)] ~= nil) then
		multiplier = multiplier * containerMultiplier[tostring(item.ParentInventory.Owner.Prefab.Identifier)]
	end
	
	if item.Condition <= 2 then
		if (item.ParentInventory ~= nil) and (LuaUserData.TypeOf(item.ParentInventory.Owner) == 'Barotrauma.Item') then
			item.Condition = 0
		else
			item.Condition = 2
		end
	end
	
	local lerpFactor = item.Health / item.Prefab.Health
	local minAlpha = 0
	local maxAlpha = 255
	local minRange = 0
	local maxRange = 400
	if item.Prefab.Identifier == 'fulguriumfuelrodvolatile' then
		minAlpha = 64
		minRange = 100
	end
	if item.Prefab.Identifier == 'skyholderartifact' then
		lerpFactor = 0
	end
	local range = DD.lerp(lerpFactor, maxRange, minRange)
	local alpha = DD.lerp(lerpFactor, maxAlpha, minAlpha)
	item.GetComponentString('LightComponent').IsOn = true
	item.GetComponentString('LightComponent').LightColor = Color(Byte(70), Byte(200), Byte(250), Byte(alpha))
	item.GetComponentString('LightComponent').Range = range * 2
	if SERVER then
		if (fuelrodDecayNetworkCooldown[item] ~= nil) and (fuelrodDecayNetworkCooldown[item] > 0) then
			fuelrodDecayNetworkCooldown[item] = fuelrodDecayNetworkCooldown[item] - 1
		else
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("IsOn")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("LightColor")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("Range")]
			Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
			
			fuelrodDecayNetworkCooldown[item] = 30
		end
	end
	
	local maxAmount = item.Prefab.Health - item.Health
	if item.Prefab.Identifier == 'fulguriumfuelrodvolatile' then
		maxAmount = maxAmount + 50
	end
	if item.Prefab.Identifier == 'skyholderartifact' then
		maxAmount = 300
	end
	maxAmount = maxAmount * multiplier
	local minDistance = 50
	local maxDistance = math.sqrt(maxAmount / 0.005)
	for character in Character.CharacterList do
		local limb = character.AnimController.Limbs[1]
		local distance = Vector2.Distance(item.WorldPosition, limb.WorldPosition)
		if item.InWater then distance = distance * 2 end
		if distance <= maxDistance then
			distance = math.max(minDistance, distance)
			local amount = maxAmount / distance ^ 2
			local attackResult = limb.AddDamage(limb.SimPosition, {AfflictionPrefab.Prefabs['radiationsickness'].Instantiate(amount * #character.AnimController.Limbs)}, false, 1, 0.0, nil)
			character.CharacterHealth.ApplyDamage(limb, attackResult, nil)
			-- geiger counter visual effect
			local amountfx = DD.clamp((1 - lerpFactor) * DD.invLerp(distance, maxDistance, minDistance))
			local affliction = character.CharacterHealth.GetAffliction('geigerfx', true)
			if (affliction ~= nil) and (amountfx >= affliction.Strength) then
				affliction.SetStrength(amountfx)
			else
				DD.giveAfflictionCharacter(character, 'geigerfx', amountfx)
			end
		end
	end
end)

-- ballot box
local vote = function (bool, targets)
	local count = 0
	for target in targets do
		if (LuaUserData.TypeOf(target) == 'Barotrauma.Item') and (target.HasTag('money')) then
			count = count + 1
			Entity.Spawner.AddItemToRemoveQueue(target)
		end
	end
	if count == 0 then return end
	
	for event in DD.eventDirector.events do
		if event.name == 'election' then
			if bool then
				event.yesVotes = event.yesVotes + count
			else
				event.noVotes = event.noVotes + count
			end
		end
	end
	if SERVER then DD.messageAllClients(DD.stringLocalize('electionVoteCast'), {preset = 'info'}) end
end
Hook.Add("DD.ballotbox.voteYes", "DD.ballotbox.voteYes", function(effect, deltaTime, item, targets, worldPosition)
	vote(true, targets)
end)
Hook.Add("DD.ballotbox.voteNo", "DD.ballotbox.voteNo", function(effect, deltaTime, item, targets, worldPosition)
	vote(false, targets)
end)

-- for debugging/testing
Hook.Add("DD.debug", "DD.debug", function(effect, deltaTime, item, targets, worldPosition)
	print(item)
	DD.tablePrint(targets, nil, 1)
end)

-- fix from evil factory for goblin/troll respawn bug
if SERVER then
local characterInfoDictRedux = {}
Hook.Patch("Barotrauma.Networking.GameServer", "UpdateCharacterInfo", function(instance, ptable)
	local sender = ptable["sender"]
	characterInfoDictRedux[sender] = sender.CharacterInfo
end, Hook.HookMethodType.After)
Hook.Patch("Barotrauma.Networking.RespawnManager", "DispatchShuttle", function(instance, ptable)
	for client in Client.ClientList do
		if not client.Character or client.Character.IsDead then
			if characterInfoDictRedux[client] then
				client.CharacterInfo = characterInfoDictRedux[client]
			end
		end
	end
end, Hook.HookMethodType.Before)
end