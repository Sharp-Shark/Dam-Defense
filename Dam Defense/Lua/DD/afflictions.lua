-- Warning: how the mod interacts with husk is hard-coded since husk infection is different from the mod's diseases in some pretty fundamental ways
if CLIENT and Game.IsMultiplayer then return end

--[[
displayName: self-explanatory
immune: multiplier for effective the immune system is at fighting the disease
immuneVisibility: multiplier for how quickly the immune system will respond to this disease
immuneVisibleStrength: strength needed for affliction to be recognized by immune system
spreadChance: chance for spreading the disease when a spread event occurs
necrotic: can corpses spread the disease
item: item obtained when blood sampler is used on an infected
--]]
DD.diseaseData = {
	flu = {displayName = 'Flu', immune = 2, immuneVisibility = 1, immuneVisibleStrength = 50, spreadChance = 0.5},
	bacterial = {displayName = 'Bacterial', immune = 2, immuneVisibility = 1, immuneVisibleStrength = 50, spreadChance = 0.1, necrotic = true},
	tb = {displayName = 'Tuberculosis', immune = 1, immuneVisibility = 1, immuneVisibleStrength = 50, spreadChance = 0.2, necrotic = true},
	anthrax = {displayName = 'Anthrax', immune = 0, immuneVisibility = 2, immuneVisibleStrength = 50, spreadChance = 0.1, necrotic = true},
	husk = {displayName = 'Velonaceps Calyx', immune = 0, immuneVisibility = 4, immuneVisibleStrength = 25, spreadChance = 0.1, necrotic = true, item = 'huskeggs'},
}
local getDiseaseStat = function (diseaseName, statName)
	local stat = DD.diseaseData[diseaseName][statName]
	if stat == nil then
		if statName == 'immune' then return 1 end
		if statName == 'immuneVisibility' then return 1 end
		if statName == 'immuneVisibleStrength' then return 1 end
		if statName == 'spreadChance' then return 0 end
		if statName == 'necrotic' then return false end
		if statName == 'spreadToCorpses' then return false end
		if statName == 'item' then return diseaseName .. 'syringe' end
	else
		return stat
	end
end

local airborneSpread = function (entity, targets, range, callback)
	if entity.CurrentHull == nil then return end
	local affectedHulls = {[entity.CurrentHull] = true}
	for hull in entity.CurrentHull.GetConnectedHulls(false, 3, true) do affectedHulls[hull] = true end

	for target in targets do
		local usingHullOxygen = true
		if (LuaUserData.TypeOf(target) == 'Barotrauma.Character') or (LuaUserData.TypeOf(target) == 'Barotrauma.AICharacter') then
			usingHullOxygen = target.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) <= 0
		end
		local inDistance = affectedHulls[target.CurrentHull] and (Vector2.Distance(entity.WorldPosition, target.WorldPosition) < range)
		if (target ~= entity) and usingHullOxygen and inDistance then
			callback(target)
		end
	end
end

local characterSpreadAfflictions = function (character)
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) >= 1 then return end
	
	local callback = function (other)
		if other.IsDead then return end
		for diseaseName, data in pairs(DD.diseaseData) do
			local toCharacterInfection = other.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
			local fromCharacterInfection = character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
			if DD.isCharacterHusk(other) and (diseaseName == 'husk') then
				fromCharacterInfection = 100
			end
			fromCharacterInfection = math.random() * math.min(getDiseaseStat(diseaseName, 'immuneVisibleStrength'), fromCharacterInfection)
			if (toCharacterInfection <= 0) and (math.random() <= getDiseaseStat(diseaseName, 'spreadChance')) and (fromCharacterInfection > 0) then
				DD.giveAfflictionCharacter(other, diseaseName .. 'infection', fromCharacterInfection)
			end
		end
	end
	airborneSpread(character, Character.CharacterList, 750, callback)
end

local corpseItems = {}
for item in Item.ItemList do
	if item.HasTag('corpse') then
		table.insert(corpseItems, item)
	end
end
Hook.Add("DD.corpse.register", "DD.corpse.register", function(effect, deltaTime, item, targets, worldPosition, element)
	table.insert(corpseItems, item)
end)
local itemSpreadAfflictions = function (item)
	local callback = function (other)
		if other.IsDead then return end
		for diseaseName, data in pairs(DD.diseaseData) do
			local characterInfection = other.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
			if (characterInfection <= 0) and (math.random() <= getDiseaseStat(diseaseName, 'spreadChance') / 2) and item.HasTag(diseaseName) then
				DD.giveAfflictionCharacter(other, diseaseName .. 'infection', 1)
			end
		end
	end
	airborneSpread(item, Character.CharacterList, 750, callback)
	
	local callback = function (other)
		local tags = ''
		for diseaseName, data in pairs(DD.diseaseData) do
			if (not other.HasTag(diseaseName)) and (math.random() <= getDiseaseStat(diseaseName, 'spreadChance') / 2) and item.HasTag(diseaseName) then
				tags = tags .. ',' .. diseaseName
			end
		end
		if tags ~= '' then
			other.Tags = other.Tags .. tags
			if SERVER then
				local prop = other.SerializableProperties[Identifier("Tags")]
				Networking.CreateEntityEvent(other, Item.ChangePropertyEventData(prop, other))
			end
		end
	end
	airborneSpread(item, corpseItems, 750, callback)
end

-- Although this is a luahook (<LuaHook name="..." />) I'm keeping it in this file instead of luahooks.lua
Hook.Add("DD.afflictions.spread", "DD.afflictions.spread", function(effect, deltaTime, item, targets, worldPosition, element)
    if CLIENT and Game.IsMultiplayer then return end
	if targets[1] == nil then return end
	local entity = targets[1]
	
	if LuaUserData.TypeOf(entity) == 'Barotrauma.Item' then
		itemSpreadAfflictions(entity)
	else
		characterSpreadAfflictions(entity)
	end
end)

Hook.Add("afflictionUpdate", "DD.bacterialgangrene", function (affliction, characterHealth, limb)
	local character = characterHealth.Character
	if (character.SpeciesName ~= 'human') or (character.IsDead) then return end
	
	-- Bacterial gangrene from bleeding
	if (affliction.Prefab.AfflictionType == 'bleeding') or (affliction.Prefab.Identifier == 'bitewounds') then
		if affliction.Strength > 1 then
			DD.giveAfflictionCharacter(character, 'bacterialgangrene', 5 / 60 / 90, limb)
		end
	end
	-- Bacterial gangrene will spread from limb to limb
	if affliction.Prefab.Identifier == 'bacterialgangrene' then
		if affliction.Strength <= 5 then
			local bleeding = character.CharacterHealth.GetAffliction('bleeding', limb)
			local bitewounds = character.CharacterHealth.GetAffliction('bitewounds', limb)
			if (character.CharacterHealth.GetAfflictionStrengthByIdentifier('bacterialgangrene', true) < 35) and
			((bleeding == nil) or (bleeding.Strength <= 1)) and
			((bitewounds == nil) or (bitewounds.Strength <= 1)) then
				character.CharacterHealth.ReduceAfflictionOnLimb(limb, 'bacterialgangrene', 1 / 60)
			end
		elseif affliction.Strength >= affliction.Prefab.MaxStrength then
			local winnerLimb = nil
			local winnerStrength = -1
			for limb in character.AnimController.Limbs do
				local strength = character.CharacterHealth.GetAffliction('bacterialgangrene', limb)
				if strength ~= nil then
					strength = strength.Strength
				else
					strength = 0
				end
				if (strength < affliction.Prefab.MaxStrength) and (strength > winnerStrength) then
					winnerLimb = limb
					winnerStrength = strength
				end
			end
			if winnerLimb ~= nil then
				DD.giveAfflictionCharacter(character, 'bacterialgangrene', 1 / 60, winnerLimb)
			end
		end
	end
end)

-- Reset husk regen on damage
Hook.Add("character.applyDamage", "DD.resetHuskRegenOnDamage", function (characterHealth, attackResult, hitLimb, allowStacking)
	local character = characterHealth.Character
	if character == nil then return end
	
	if (DD.isCharacterHusk(character) or character.SpeciesName == 'humanundead') and
	(not character.IsDead) and
	(attackResult.Damage >= 0.1) and
	(character.CharacterHealth.GetAffliction('huskregen', true) ~= nil) and
	(character.CharacterHealth.GetAffliction('huskregen', true).Strength > 5) then
		character.CharacterHealth.GetAffliction('huskregen', true).SetStrength(5)
	end

	return
end)

local afflictionNetworkCooldown = {}
DD.thinkFunctions.afflictions = function ()
	if not Game.RoundStarted then return end

	for character in Character.CharacterList do
		local affliction = character.CharacterHealth.GetAffliction('blastjumping', true)
		if (affliction ~= nil) and (affliction.Strength <= 1) and (character.AnimController.OnGround or character.AnimController.InWater or character.AnimController.IsClimbing) then
			affliction.SetStrength(0)
		end
		-- Handcuffed living characters can be dragged at full speed by anyone
		local affliction = character.CharacterHealth.GetAffliction('firemanscarrytemporary', true)
		if (character.SelectedCharacter ~= nil) and character.SelectedCharacter.IsHandcuffed and (not character.SelectedCharacter.IsDead) then
			local affliction = character.CharacterHealth.GetAffliction('firemanscarrytemporary', true)
			if affliction ~= nil then
				affliction.SetStrength(1)
			else
				DD.giveAfflictionCharacter(character, 'firemanscarrytemporary', 1)
			end
		else
			if affliction ~= nil then
				affliction.SetStrength(0)
			end
		end
		-- Burning affliction (and some other afflictions) reduce if a limb is underwater
		for limb in character.AnimController.Limbs do
			if limb.InWater then
				character.CharacterHealth.ReduceAfflictionOnLimb(limb, 'burning', 10)
				character.CharacterHealth.ReduceAfflictionOnLimb(limb, 'noxiousspray', 10)
				character.CharacterHealth.ReduceAfflictionOnLimb(limb, 'cyanpaint', 10)
				character.CharacterHealth.ReduceAfflictionOnLimb(limb, 'yellowpaint', 10)
				character.CharacterHealth.ReduceAfflictionOnLimb(limb, 'magentapaint', 10)
			end
		end
		-- Husk regen
		if (DD.isCharacterHusk(character) or character.SpeciesName == 'humanundead') and (not character.IsDead) then
			local damage = 0
			damage = damage + character.CharacterHealth.GetAfflictionStrengthByIdentifier('bloodloss', true)
			damage = damage + character.CharacterHealth.GetAfflictionStrengthByType('damage', true)
			if ((character.Vitality < 0) or character.IsRagdolled) and (damage >= 1) then
				if character.Vitality < 0 then
					DD.giveAfflictionCharacter(character, 'huskregen', 0.5 * (1/60) * character.MaxVitality / 100)
				else
					DD.giveAfflictionCharacter(character, 'huskregen', 1 * (1/60) * character.MaxVitality / 100)
				end
			else
				local affliction = character.CharacterHealth.GetAffliction('huskregen', true)
				if (affliction ~= nil) and ((damage < 1) or (affliction.Strength <= 10)) then
					character.CharacterHealth.GetAffliction('huskregen', true).SetStrength(0)
				end
			end
		end
		-- Airborne protection affliction to show character is immune to giving/getting airborne infections
		if (character.SpeciesName == 'human') then
			if DD.isCharacterUsingHullOxygen(character) then
				if character.CharacterHealth.GetAffliction('airborneprotection', true) ~= nil then
					character.CharacterHealth.GetAffliction('airborneprotection', true).SetStrength(0)
				end
			else
				if character.CharacterHealth.GetAffliction('airborneprotection', true) == nil then
					DD.giveAfflictionCharacter(character, 'airborneprotection', 1)
				else	
					character.CharacterHealth.GetAffliction('airborneprotection', true).SetStrength(1)
				end
			end
		end
		-- Dead characters
		if character.IsDead then
			-- Specific to humans
			if character.SpeciesName == 'human' then
				-- after 10s of being dead, cardiac arrest will reach maxstrength
				if character.CharacterHealth.GetAfflictionStrengthByIdentifier('cardiacarrest', true) < 1 then
					DD.giveAfflictionCharacter(character, 'cardiacarrest', 1/60/10)
					if character.CharacterHealth.GetAfflictionStrengthByIdentifier('cardiacarrest', true) >= 1 then
						if SERVER then
							Networking.CreateEntityEvent(character, Character.CharacterStatusEventData.__new(true))
							
							afflictionNetworkCooldown[character] = 60 * 5
						end
					end
				end
			end
			
			-- after 60s a corpse will despawn
			affliction = character.CharacterHealth.GetAffliction('despawn', true)
			DD.giveAfflictionCharacter(character, 'despawn', 1/60/60)
			-- max strength has been reached
			if (affliction ~= nil) and (affliction.Strength >= 1) then
				affliction.SetStrength(0)
				-- corpse
				local diseaseSet = {}
				local tags = ''
				for diseaseName, data in pairs(DD.diseaseData) do
					if getDiseaseStat(diseaseName, 'necrotic') and ((character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection') > 0) or 
					(DD.isCharacterHusk(character) and diseaseName == 'husk') or
					((not DD.isCharacterHusk(character)) and (not DD.isCharacterHumanoid(character)) and diseaseName == 'anthrax')) then
						diseaseSet[diseaseName] = true
						tags = tags .. ',' .. diseaseName
					end
				end
				if character.Mass > 9 then
					Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('corpse'), character.WorldPosition, nil, nil, function (spawnedItem)
						spawnedItem.Tags = spawnedItem.Tags .. tags
						if SERVER then
							local prop = spawnedItem.SerializableProperties[Identifier("Tags")]
							Networking.CreateEntityEvent(spawnedItem, Item.ChangePropertyEventData(prop, spawnedItem))
						end
					end)
				end
				-- drop items
				if character.Inventory ~= nil then
					-- humans (or previously human humanoids) have their items put in a duffelbag when they despawn
					if character.IsHumanoid and (string.lower(string.sub(tostring(character.SpeciesName), 1, 5)) == 'human') then
						Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('duffelbag'), character.WorldPosition, nil, nil, function (spawnedItem)
							for itemCount = 0, character.Inventory.Capacity do
								local item = character.Inventory.GetItemAt(itemCount)
								if item ~= nil then
									item.Drop()
									spawnedItem.OwnInventory.TryPutItem(item, character, nil, true, true)
								end
							end
						end)
					-- creatures just have their items dropped on the floor
					else
						for itemCount = 0, character.Inventory.Capacity do
							local item = character.Inventory.GetItemAt(itemCount)
							if item ~= nil then item.Drop() end
						end
					end
				end
				-- despawn
				Timer.Wait(function ()
					Entity.Spawner.AddEntityToRemoveQueue(character)
					afflictionNetworkCooldown[character] = nil
				end, 10)
			end
			
			-- network update for dead character (and also spread infections)
			if SERVER then
				if (afflictionNetworkCooldown[character] ~= nil) and (afflictionNetworkCooldown[character] > 0) then
					afflictionNetworkCooldown[character] = afflictionNetworkCooldown[character] - 1
				else
					Networking.CreateEntityEvent(character, Character.CharacterStatusEventData.__new(true))
				
					afflictionNetworkCooldown[character] = 60 * 5
				end
			end
		end
		-- Disease and immune stuff for living humans
		if (character.SpeciesName == 'human') and (not character.IsDead) then
			local characterGangrene = character.CharacterHealth.GetAfflictionStrengthByIdentifier('bacterialgangrene', true)
			if characterGangrene >= 200 then
				DD.giveAfflictionCharacter(character, 'bacterialinfection', 1 / 60)
			end
		
			local characterImmune = character.CharacterHealth.GetAfflictionStrengthByType('immune', true)
			characterImmune = characterImmune - character.CharacterHealth.GetAfflictionStrengthByType('immunedebuff', true)
			characterImmune = math.max(0, characterImmune)
			
			-- Infection recognized by immune-system
			local characterInfectionRecognized = 0
			for diseaseName, data in pairs(DD.diseaseData) do
				characterInfectionRecognized = characterInfectionRecognized + math.max(0, (character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true) - getDiseaseStat(diseaseName, 'immuneVisibleStrength')) * getDiseaseStat(diseaseName, 'immuneVisibility'))
			end
			-- Immunu-response
			if characterInfectionRecognized > 0 then
				local amount = characterInfectionRecognized / 150
				DD.giveAfflictionCharacter(character, 'immuneresponse', 2 * amount / 60)
				DD.giveAfflictionCharacter(character, 'fever', 1 * amount / 60)
			else
				if character.CharacterHealth.GetAfflictionStrengthByType('infection', true) <= 0 then
					character.CharacterHealth.ReduceAfflictionOnAllLimbs('immuneresponse', 2 / 60, nil)
					character.CharacterHealth.ReduceAfflictionOnAllLimbs('fever', 1 / 60, nil)
				end
			end
			if characterImmune > 0 then
				for diseaseName, data in pairs(DD.diseaseData) do
					character.CharacterHealth.ReduceAfflictionOnAllLimbs(diseaseName .. 'infection', characterImmune * getDiseaseStat(diseaseName, 'immune') / 100 / 60, nil)
				end
			end
		end
	end
end

--[[
-- If someone gives in as husk, instead they will be set to spectator and the husk will continue alive but as a NPC
Hook.Patch("Barotrauma.Character", "Kill", function(instance, ptable)
	if (instance.SpeciesName == 'humanhusk') and (instance.Vitality > 0 - instance.MaxVitality) then
		if CLIENT and Game.IsSingleplayer then
			if Character.Controlled ~= instance then return end
			Character.Controlled = nil
			ptable.PreventExecution = true
		else
			local client = DD.findClientByCharacter(instance)
			if client == nil then return end
			client.SetClientCharacter(nil)
			ptable.PreventExecution = true
		end
	end
end, Hook.HookMethodType.Before)
-]]