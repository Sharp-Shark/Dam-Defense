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
	anthrax = {displayName = 'Anthrax', immune = 0, immuneVisibility = 2, immuneVisibleStrength = 50, spreadChance = 0.1, necrotic = true, spreadToCorpses = true},
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

-- spread infections
local spreadInfections = function(character, ignoreSpreaderAirborneProtection)
	if (character.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) >= 1) and not ignoreSpreaderAirborneProtection then return end
	
	local spreadDiseaseToCharacter = function (toCharacter, fromCharacter, diseaseName)
		-- Get fromCharacter infection amount
		local amount = fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		if DD.isCharacterHusk(fromCharacter) and (diseaseName == 'husk') then
			amount = 100
		end
		if amount <= 0 then return end
		if fromCharacter.IsDead and (amount <= getDiseaseStat(diseaseName, 'immuneVisibleStrength')) then return end
		-- If toCharacter is already infected, do not infect
		local infection = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		-- chance to give disease
		local chance = getDiseaseStat(diseaseName, 'spreadChance')
		if fromCharacter.IsDead then chance = chance / 2 end
		-- randomize amount of disease given
		amount = math.random() * math.min(getDiseaseStat(diseaseName, 'immuneVisibleStrength'), amount)
		-- Spread
		if (infection <= 0) and (math.random() <= chance) and (amount > 0) then
			DD.giveAfflictionCharacter(toCharacter, diseaseName .. 'infection', amount)
		end
	end
	
	local hull = character.CurrentHull
	if hull == nil then return end
	
	local affectedHulls = {[hull] = true}
	for otherHull in character.CurrentHull.GetConnectedHulls(false, 3, true) do affectedHulls[otherHull] = true end
	
	for other in Character.CharacterList do
		local isOtherUsingHullOxygen = other.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) <= 0
		local isOtherInDistance = affectedHulls[other.CurrentHull] and (Vector2.Distance(character.WorldPosition, other.WorldPosition) < 750)
		if (other ~= character) and isOtherUsingHullOxygen and isOtherInDistance then
			for diseaseName, data in pairs(DD.diseaseData) do
				if ((not character.IsDead) or getDiseaseStat(diseaseName, 'necrotic')) and ((not other.IsDead) or getDiseaseStat(diseaseName, 'spreadToCorpses')) then
					spreadDiseaseToCharacter(other, character, diseaseName)
				end
			end
		end
	end
end

-- Although this is a luahook (<LuaHook name="..." />) I'm keeping it in this file instead of luahooks.lua
Hook.Add("DD.afflictions.spread", "DD.afflictions.spread", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	if targets[1] == nil then return end
	local character = targets[1]
	spreadInfections(character)
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
			if (affliction == nil) or (affliction.Strength < 1) then
				affliction = character.CharacterHealth.GetAffliction('despawn', true)
			end
			DD.giveAfflictionCharacter(character, 'despawn', 1/60/60)
			-- max strength has been reached
			if (affliction ~= nil) and (affliction.Strength >= 1) then
				affliction.SetStrength(0)
				-- despawnburn
				if affliction.Identifier == 'despawnburn' then
					Entity.Spawner.AddItemToSpawnQueue(ItemPrefab.GetItemPrefab('smokefx'), character.WorldPosition, nil, nil, function (spawnedItem) end)
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