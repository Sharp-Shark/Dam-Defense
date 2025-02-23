-- Warning: how the mod interacts with husk is hard-coded since husk infection is different from the mod's diseases in some pretty fundamental ways
if CLIENT and Game.IsMultiplayer then return end

DD.diseaseData = {
	flu = {displayName = 'Flu', immune = 3, immuneVisibility = 0.5, spreadChance = 0.3, symptomChance = 1.0},
	bacterial = {displayName = 'Bacterial', immune = 3, immuneVisibility = 0.5, spreadChance = 0.15, necrotic = true, symptomChance = 1.0},
	tb = {displayName = 'Tuberculosis', immune = 1.5, immuneVisibility = 0.5, spreadChance = 0.3, necrotic = true, symptomChance = 1.0}
}
local getDiseaseStat = function (diseaseName, statName)
	local stat = DD.diseaseData[diseaseName][statName]
	if stat == nil then
		if statName == 'immune' then return 2.5 end
		if statName == 'immuneVisibility' then return 1 end
		if statName == 'spreadChance' then return 0 end
		if statName == 'necrotic' then return false end
		if statName == 'symptomChance' then return 1.0 end
	else
		return stat
	end
end

-- Although this is a luahook (<LuaHook name="..." />) I'm keeping it in this file instead of luahooks.lua
Hook.Add("DD.afflictions.spread", "DD.afflictions.spread", function(effect, deltaTime, item, targets, worldPosition)
    if CLIENT and Game.IsMultiplayer then return end
	if targets[1] == nil then return end
	local character = targets[1]
	if character.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) >= 1 then return end
	
	local spreadDiseaseToCharacter = function (toCharacter, fromCharacter, diseaseName, chance)
		-- Get fromCharacter infection amount
		local amount = fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'hidden', true)
		amount = amount + fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'payload', true)
		amount = amount + fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		amount = amount * math.random()
		-- If toCharacter is already infected, do not infect
		local infection = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true)
		local hidden = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'hidden', true)
		-- Edge case for husk
		if diseaseName == 'husk' then
			amount = fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
			infection = toCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true)
			hidden = 0
		end
		-- If the infection is hidden lower the chance
		local chance = chance
		if (amount - fromCharacter.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'hidden', true)) <= 0 then
			chance = chance * 0.5
		end
		-- Spread
		if (infection + hidden <= 0) and (math.random() <= chance) and (amount > 0) then
			if diseaseName == 'husk' then
				DD.giveAfflictionCharacter(toCharacter, 'huskinfection', amount)
			else
				DD.giveAfflictionCharacter(toCharacter, diseaseName .. 'hidden', amount)
			end
		end
	end
	
	local hull = character.CurrentHull
	if hull == nil then return end
	
	local affectedHulls = {[hull] = true}
	for otherHull in character.CurrentHull.GetConnectedHulls(false, 3, true) do affectedHulls[otherHull] = true end
	
	for other in Character.CharacterList do
		local isOtherUsingHullOxygen = other.CharacterHealth.GetAfflictionStrengthByIdentifier('airborneprotection', true) <= 0
		local isOtherInDistance = affectedHulls[other.CurrentHull] and (Vector2.Distance(character.WorldPosition, other.WorldPosition) < 750)
		if (other ~= character) and (other.SpeciesName == 'human') and (not other.IsDead) and isOtherUsingHullOxygen and isOtherInDistance then
			spreadDiseaseToCharacter(other, character, 'husk', 0.15)
			for diseaseName, data in pairs(DD.diseaseData) do
				if (not character.IsDead) or getDiseaseStat(diseaseName, 'necrotic') then
					local chance = getDiseaseStat(diseaseName, 'spreadChance')
					if character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true) > 0 then
						spreadDiseaseToCharacter(other, character, diseaseName, chance)
					elseif character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'hidden', true) > 0 then
						spreadDiseaseToCharacter(other, character, diseaseName, chance / 2)
					end
				end
			end
		end
	end
end)

Hook.Add("afflictionUpdate", "DD.bacterialgangrene", function (affliction, characterHealth, limb)
	local character = characterHealth.Character
	if (character.SpeciesName ~= 'human') or (character.IsDead) then return end
	
	-- End infection incubation and give payload
	if affliction.Prefab.AfflictionType == 'infectionhidden' then
		if (math.random() * 2 * 10^3 < 1) or (affliction.Strength >= affliction.Prefab.MaxStrength) then
			local name = DD.stringSplit(tostring(affliction.Prefab.Identifier), 'hidden')[1]
			if math.random() < getDiseaseStat(name, 'symptomChance') then
				DD.giveAfflictionCharacter(character, name .. 'payload', affliction.Strength * (0.5 + math.random()))
			end
			affliction.SetStrength(0)
		end
	end

	-- Bacterial gangrene from burns (only regular burns) and bleeding
	if (affliction.Prefab.Identifier ~= 'burn') and (affliction.Prefab.AfflictionType ~= 'bleeding') then return end
	--local characterBurn = character.CharacterHealth.GetAfflictionStrengthByType('burn', true)
	local characterBurn = character.CharacterHealth.GetAfflictionStrengthByIdentifier('burn', true)
	local characterBleeding = character.CharacterHealth.GetAfflictionStrengthByType('bleeding', true)
	if ((characterBurn > 8) or (characterBleeding > 8)) and
	(math.random() * 10^4 < 1) then
		DD.giveAfflictionCharacter(character, 'bacterialgangrene', 0.1, limb)
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
				for diseaseName, data in pairs(DD.diseaseData) do
					if not getDiseaseStat(diseaseName, 'necrotic') then
						character.CharacterHealth.ReduceAfflictionOnAllLimbs(diseaseName .. 'infection', 5 * (1/60), nil)
					end
				end
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
			
			-- after 90s of a corpse being underwater, it will despawn
			if character.InWater then
				local affliction = character.CharacterHealth.GetAffliction('despawn', true)
				DD.giveAfflictionCharacter(character, 'despawn', 1/60/90)
				-- max strength has been reached
				if (affliction ~= nil) and (affliction.Strength >= 1) then
					-- drop items
					if character.Inventory ~= nil then
						for itemCount = 0, character.Inventory.Capacity do
							local item = character.Inventory.GetItemAt(itemCount)
							if item ~= nil then
								item.Drop()
							end
						end
					end
					-- despawn
					Timer.Wait(function ()
						Entity.Spawner.AddEntityToRemoveQueue(character)
					end, 10)
				end
			end
			
			-- network update for dead character
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
			local characterBacterialInfection = character.CharacterHealth.GetAfflictionStrengthByIdentifier('bacterialinfection', true)
			local characterBacterialGangrene = character.CharacterHealth.GetAfflictionStrengthByIdentifier('bacterialgangrene', true)
			
			local characterInfection = character.CharacterHealth.GetAfflictionStrengthByType('infection', true)
			characterInfection = characterInfection + math.max(0, character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true) - 35)
			
			local characterImmune = character.CharacterHealth.GetAfflictionStrengthByType('immune', true)
			characterImmune = characterImmune - character.CharacterHealth.GetAfflictionStrengthByType('immunedebuff', true)
			characterImmune = characterImmune - math.min(50, characterInfection / 2)
			characterImmune = math.max(0, characterImmune)
			
			-- Broad Bacterial Infection from bacterial gangrene (septic shock)
			if characterBacterialGangrene > 5 and
			(math.random() * 10^6 < characterBacterialGangrene ^ 2) then
				DD.giveAfflictionCharacter(character, 'bacterialpayload', characterBacterialGangrene)
			end
			-- Broad Bacterial Infection from other infections
			if (characterInfection - characterBacterialInfection > 20) and
			(math.random() * 10^6 < (character.MaxVitality - character.Vitality)) then
				DD.giveAfflictionCharacter(character, 'bacterialpayload', (character.MaxVitality - character.Vitality) * math.random())
			end
			-- Infection recognized by immune-system
			local characterInfectionRecognized = 0
			for diseaseName, data in pairs(DD.diseaseData) do
				characterInfectionRecognized = characterInfectionRecognized + character.CharacterHealth.GetAfflictionStrengthByIdentifier(diseaseName .. 'infection', true) * getDiseaseStat(diseaseName, 'immuneVisibility')
			end
			characterInfectionRecognized = characterInfectionRecognized + math.max(0, character.CharacterHealth.GetAfflictionStrengthByIdentifier('huskinfection', true) - 35)
			-- Immunu-response
			if characterInfectionRecognized > 0 then
				local amount = math.random() * (0.5 + math.max(0, character.Vitality / character.MaxVitality)) * (characterInfectionRecognized / 100) * (1/60)
				amount = amount + amount * character.CharacterHealth.GetAfflictionStrengthByIdentifier('immuneboost', true) / 50
				DD.giveAfflictionCharacter(character, 'immuneresponse', 5 * amount)
				if character.CharacterHealth.GetAfflictionStrengthByIdentifier('fever', true) < characterInfectionRecognized then
					DD.giveAfflictionCharacter(character, 'fever', 5 * amount)
				elseif character.CharacterHealth.GetAfflictionStrengthByIdentifier('fever', true) > characterInfectionRecognized + 1 then
					character.CharacterHealth.ReduceAfflictionOnAllLimbs('fever', 5 / 60, nil)
				end
				for diseaseName, data in pairs(DD.diseaseData) do
					character.CharacterHealth.ReduceAfflictionOnAllLimbs(diseaseName .. 'infection', characterImmune * (getDiseaseStat(diseaseName, 'immune') / 100) * (1/60), nil)
				end
			else
				character.CharacterHealth.ReduceAfflictionOnAllLimbs('immuneresponse', 5 / 60, nil)
				character.CharacterHealth.ReduceAfflictionOnAllLimbs('fever', 10 / 60, nil)
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