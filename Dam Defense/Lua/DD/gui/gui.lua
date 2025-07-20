if SERVER then return end

-- set up GUI table
DD.gui = {
	debugLine = {
		point1 = Vector2(),
		point2 = Vector2()
	},
	characterRole = {}
}

-- get text to be displayed below name
local getInfoText = function (character, pov)
	local pov = pov or Character.Controlled
	local text = ''
	local priotiy = 0
	local assignText = function (thisText, thisPriotiy)
		if (thisPriotiy or 0) >= priotiy then
			text = thisText
			priotiy = thisPriotiy or 0
		end
	end
	local characterHasRole = function (character, role)
		if DD.gui.characterRole[tostring(character.ID)] == nil then return end
		return DD.gui.characterRole[tostring(character.ID)][role]
	end
	-- for spectators
	if pov == nil then
		if characterHasRole(character, 'arresttarget') or character.JobIdentifier == 'assistant' then
			if DD.isCharacterArrested(character) then
				assignText('prisoner', 1)
			else
				assignText('wanted', 1)
			end
		end
		if character.TeamID ~= CharacterTeamType.Team1 then
			if character.TeamID == CharacterTeamType.FriendlyNPC then
				assignText('friendly', 2)
			else
				assignText('hostile', 2)
			end
		else
			assignText('neutral')
		end
		if DD.isCharacterSecurity(character) then
			assignText('security')
		elseif DD.isCharacterMedical(character) then
			assignText('medical')
		elseif DD.isCharacterStaff(character) then
			assignText('damstaff')
		end
		if characterHasRole(character, 'rebel') then
			assignText('rebel', 3)
		end
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'enlightened') then
			assignText('cultist', 3)
		end
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'serialkiller') then
			assignText('serialkiller', 3)
		end
		if character.JobIdentifier == 'gangster' then
			assignText('gangleader', 3)
		end
		if character.JobIdentifier == 'wizard' then
			assignText('wizard', 3)
		end
		return text
	end
	-- for the living
	if DD.tableHas(pov.CharacterHealth.GetActiveAfflictionTags(), 'enlightened') then
		if DD.tableHas(character.CharacterHealth.GetActiveAfflictionTags(), 'enlightened') then
			assignText('comradecultist', 3)
		else
			assignText('target', 1)
		end
	end
	if DD.tableHas(pov.CharacterHealth.GetActiveAfflictionTags(), 'serialkiller') then
		assignText('target', 1)
	end
	if characterHasRole(character, 'victim') then
		assignText('target', 1)
	end
	if (characterHasRole(character, 'arresttarget') or character.JobIdentifier == 'assistant') and not character.Info.IsDisguisedAsAnother then
		if DD.isCharacterArrested(character) then
			assignText('prisoner', 1)
		else
			assignText('wanted', 1)
		end
	end
	if character.TeamID == CharacterTeamType.FriendlyNPC then
		assignText('friendly', 2)
	end
	if characterHasRole(character, 'rebel') then
		if characterHasRole(pov, 'rebel') then
			assignText('comrade', 2)
		elseif not character.Info.IsDisguisedAsAnother then
			assignText('rebel', 2)
		end
	end
	if characterHasRole(character, 'goon') then
		if characterHasRole(pov, 'boss') then
			assignText('subordinate', 2)
		else
			assignText('comrade', 2)
		end
	end
	if DD.isCharacterSecurity(character) and characterHasRole(pov, 'rebel') then
		assignText('target', 1)
	end
	if character.IsOnFriendlyTeam(pov) then
		if character.TeamID == CharacterTeamType.Team1 then
			assignText('neutral')
		else
			assignText('comrade', 2)
		end
	else
		if (pov.TeamID == CharacterTeamType.Team2 and characterHasRole(character, 'rebel')) or
		(character.TeamID == CharacterTeamType.Team2 and characterHasRole(pov, 'rebel')) then
			assignText('comrade', 2)
		else
			assignText('hostile', 2)
		end
	end
	if character.JobIdentifier == 'wizard' then
		assignText('wizard', 3)
	end
	if character.JobIdentifier == 'gangster' then
		assignText('gangleader', 3)
	end
	if characterHasRole(character, 'boss') then
		assignText('boss', 3)
	end
	if characterHasRole(character, 'guard') then
		assignText('bodyguard', 3)
	end
	if characterHasRole(character, 'vip') then
		assignText('protect', 3)
	end
	local job = tostring(character.JobIdentifier)
	if (character.Info ~= nil) and character.Info.IsDisguisedAsAnother then
		if character.Inventory.GetItemInLimbSlot(InvSlotType.Card) ~= nil then
			local identifier = tostring(character.Inventory.GetItemInLimbSlot(InvSlotType.Card).GetComponentString('IdCard').OwnerJobId)
			if DD.securityJobs[identifier] then
				assignText('security')
			elseif DD.medicalJobs[identifier] then
				assignText('medical')
			elseif DD.staffJobs[identifier] then
				assignText('damstaff')
			end
		end
	end
	if DD.isCharacterSecurity(character) then
		assignText('security')
	elseif DD.isCharacterMedical(character) then
		assignText('medical')
	elseif DD.isCharacterStaff(character) then
		assignText('damstaff')
	end
	
	return text
end
-- override getNameColor. Name color is also used for color of text below name
GameMain = LuaUserData.CreateStatic('Barotrauma.GameMain')
GUIColor = LuaUserData.RegisterType('Barotrauma.GUIColor')
DD.gui.guiCharacterInfoTextColorTable = {
	[''] = GUI.GUIStyle.TextColorNormal,
	neutral = GUI.GUIStyle.TextColorNormal,
	-- friendly or teammate (blue)
	friendly = Color.SkyBlue,
	comrade = Color.SkyBlue,
	comradecultist = Color.SkyBlue,
	bodyguard = Color.SkyBlue,
	protect = Color.SkyBlue,
	boss = Color.SkyBlue,
	subordinate = Color.SkyBlue,
	-- hostile or public antagonist (red)
	hostile = GUI.GUIStyle.Red,
	-- arrest on sight or prisoner (orange)
	rebel = GUI.GUIStyle.Orange,
	wanted = GUI.GUIStyle.Orange,
	prisoner = GUI.GUIStyle.Orange,
	-- target for assasination (yellow)
	target = GUI.GUIStyle.Yellow,
	-- special role or secret antagonist (purple)
	cultist = Color.Lerp(Color.MediumPurple, GUI.GUIStyle.TextColorNormal, 0.35),
	serialkiller = Color.Lerp(Color.MediumPurple, GUI.GUIStyle.TextColorNormal, 0.35),
	wizard = Color.Lerp(Color.MediumPurple, GUI.GUIStyle.TextColorNormal, 0.35),
	gangleader = Color.Lerp(Color.MediumPurple, GUI.GUIStyle.TextColorNormal, 0.35),
	-- job specific title (job colored)
	security = Color.Lerp(JobPrefab.Get('securityofficer').UIColor, GUI.GUIStyle.TextColorNormal, 0.5),
	medical = Color.Lerp(JobPrefab.Get('medicaldoctor').UIColor, GUI.GUIStyle.TextColorNormal, 0.5),
	damstaff = Color.Lerp(JobPrefab.Get('mechanic').UIColor, GUI.GUIStyle.TextColorNormal, 0.5),
}
local guiCharacterInfoTextColorTable = DD.gui.guiCharacterInfoTextColorTable
local guiCharacterInfoText = {}
local guiCharacterInfoColor = {}
Hook.Patch("Barotrauma.Character", "GetNameColor", function(instance, ptable)
	ptable.PreventExecution = true
	local color = guiCharacterInfoColor[instance] or GUI.GUIStyle.TextColorNormal
	ptable['ReturnValue'] = color
	return color
end, Hook.HookMethodType.Before)

-- main gui hook
local DefaultHudInfoHeight = 78
local hudInfoHeights = {}
Hook.Patch("Barotrauma.GUI", "Draw", function (instance, ptable)
	local spriteBatch = ptable["spriteBatch"]
	-- debug line
	if DD.debugMode then
		GUI.GUI.DrawLine(spriteBatch, Screen.Selected.Cam.WorldToScreen(DD.gui.debugLine.point1), Screen.Selected.Cam.WorldToScreen(DD.gui.debugLine.point2), Color.Red, 0, 1)
	end
	-- update hud info height
	for character in Character.CharacterList do
		local paddingBelowCeiling = 30.0;
		if hudInfoHeights[character] == nil then hudInfoHeights[character] = DefaultHudInfoHeight end
		if ((character.CurrentHull ~= nil) and (character.DrawPosition.Y + DefaultHudInfoHeight > character.CurrentHull.WorldRect.Y - paddingBelowCeiling)) then
			local lowerAmount = (character.DrawPosition.Y + DefaultHudInfoHeight) - (character.CurrentHull.WorldRect.Y - paddingBelowCeiling);
			hudInfoHeights[character] = DD.lerp(0.1, hudInfoHeights[character], DefaultHudInfoHeight - lowerAmount);
			hudInfoHeights[character] = math.max(hudInfoHeights[character], 20.0);
		else
			hudInfoHeights[character] = DD.lerp(0.1, hudInfoHeights[character], DefaultHudInfoHeight);
		end
	end
end)
local requestUpdateGUICharacterRoleCooldown = 60 * 5
local updateCharacterInfo = 0
Hook.Patch("Barotrauma.Character", "DrawFront", function (instance, ptable)
	-- send network request for character role information
	if Game.IsMultiplayer then
		if requestUpdateGUICharacterRoleCooldown > 0 then
			requestUpdateGUICharacterRoleCooldown = requestUpdateGUICharacterRoleCooldown - 1
		else
			local message = Networking.Start("requestUpdateGUICharacterRole")
			Networking.Send(message)
			requestUpdateGUICharacterRoleCooldown = 60 * 5
		end
	end
	-- update character name info
	if updateCharacterInfo > 0 then
		updateCharacterInfo = updateCharacterInfo - 1
	else
		updateCharacterInfo = 60
		
		for character in Character.CharacterList do
			local text = getInfoText(character) or ''
			if text == '' then
				guiCharacterInfoText[character] = ''
			else
				guiCharacterInfoText[character] = DD.stringLocalize('gui_' .. text)
			end
			guiCharacterInfoColor[character] = guiCharacterInfoTextColorTable[text]
		end
	end
	-- declare variables
	local character = instance
	local spriteBatch = ptable["spriteBatch"]
	local cam = ptable['cam']
	local screenSize = Vector2(GameMain.GraphicsWidth, GameMain.GraphicsHeight);
	local viewportSize = Vector2(cam.WorldView.Width, cam.WorldView.Height);
	if hudInfoHeights[character] == nil then hudInfoHeights[character] = DefaultHudInfoHeight end
	-- verify text should be rendered
	if GUI.DisableHUD or character.IsDead or (character.InvisibleTimer > 0) or (character.SpeciesName ~= 'human') and (character.SpeciesName ~= 'humanundead') or (cam.Zoom <= 0.4) then return end
	if Character.Controlled ~= nil then
		if (Character.Controlled.FocusedCharacter == character) or (Character.Controlled == character) then return end
		if (character.WorldPosition.X > cam.WorldView.X and character.WorldPosition.X < cam.WorldView.Right and
		character.WorldPosition.Y < cam.WorldView.Y and character.WorldPosition.Y > cam.WorldView.Y - cam.WorldView.Height) then
			if not Character.Controlled.CanSeeTarget(character) then return end
		else
			return
		end
		if Character.Controlled.Submarine then
			local yPos = Character.Controlled.AnimController.FloorY - 1.5
			if Character.Controlled.AnimController.Stairs ~= nil then
				yPos = Character.Controlled.AnimController.Stairs.SimPosition.Y - Character.Controlled.AnimController.Stairs.RectHeight * 0.5;
			end
			if character.AnimController.FloorY < yPos then return end
		end
	end
	-- get localized text and text color
	local text = guiCharacterInfoText[character] or ''
	if text == '' then return end
	local textColor = character.GetNameColor()
	-- get transparency
	local hoverRange = 300;
	local fadeOutRange = 200;
	local cursorDist = Vector2.Distance(character.WorldPosition, cam.ScreenToWorld(PlayerInput.MousePosition));
	local hudInfoAlpha = math.min(math.max((1.0 - (cursorDist - (hoverRange - fadeOutRange)) / fadeOutRange), 0.2), 1.0)
	-- get position
	local size = GUI.GUIStyle.Font.MeasureString(text)
	local pos = character.DrawPosition
	pos.Y = pos.Y + hudInfoHeights[character] + size.Y * 0.7 / cam.Zoom
	pos.Y = -pos.Y
	local textPos = Vector2(pos.X, pos.Y - 5.0 - (5.0 / cam.Zoom)) - size * 0.5 / cam.Zoom
	textPos.X = textPos.X - cam.WorldView.X
	textPos.Y = textPos.Y + cam.WorldView.Y
	textPos = textPos * screenSize / viewportSize
	textPos.X = math.floor(textPos.X)
	textPos.Y = math.floor(textPos.Y)
	textPos = textPos * viewportSize / screenSize
	textPos.X = textPos.X + cam.WorldView.X
	textPos.Y = textPos.Y - cam.WorldView.Y
	-- draw
	GUI.GUIStyle.Font.DrawString(spriteBatch, text, textPos + Vector2(1.0 / cam.Zoom, 1.0 / cam.Zoom), Color.Black, 0.0, Vector2.Zero, 1.0 / cam.Zoom, 0, 0.001)
	GUI.GUIStyle.Font.DrawString(spriteBatch, text, textPos, textColor * hudInfoAlpha, 0.0, Vector2.Zero, 1.0 / cam.Zoom, 0, 0.0)
end)