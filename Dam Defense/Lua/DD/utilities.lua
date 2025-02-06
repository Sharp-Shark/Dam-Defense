-- Debug guard clause
DD.expectTypes = function (funcName, values, types)
	local funcName = funcName or 'funcName'
	
	local errorCount = 0
	local text = ''
	for key, target in pairs(types) do
		local value = values[key]
		
		-- check if value is not any of the target type(s) and also build a neater string of target types for display ("nil,number,string" becomes "nil, number or string")
		local bool = true
		local build = ''
		local expectedTypes = ''
		for count = 1, #target do
			local char = string.sub(target, count, count)
			if char ~= ',' then
				build = build .. char
			end
			if (char == ',') or (count == #target) then
				if build == 'notnil' then
					if value ~= nil then
						bool = false
					end
					build = 'not nil'
				else
					if type(value) == build then
						bool = false
					end
				end
				if expectedTypes == '' then
					expectedTypes = build
				else
					if count == #target then
						expectedTypes = expectedTypes .. ' or ' .. build
					else
						expectedTypes = expectedTypes .. ', ' .. build
					end
				end
				build = ''
			end
		end
		
		-- build error message if value type is invalid
		if bool then
			local index = (type(key) == 'number') and ('#' .. key) or (string.format("'%s'", tostring(key)))
			text = text .. string.format("bad argument %s to '%s' (%s expected, got %s)\n", index, funcName, expectedTypes, type(value))
			errorCount = errorCount + 1
		end
	end
	
	-- error if any value was of an invalid type
	if errorCount > 0 then
		if errorCount > 1 then text = '\n' .. text end
		error(text .. '\n' .. debug.traceback(), 2)
	end
end

-- Warnings are printed once mod finishes loading
DD.warn = function (text)
	table.insert(DD.warnings, text)
end

-- Special character for special string formatting
-- print(DD.sc .. 'color:red' .. DD.sc .. 'red' .. DD.sc .. 'end' .. DD.sc)
DD.specialChar = '‖'

-- Short for DD.specialChar for live inputting lua commands in debug menu
if sc == nil then
	sc = DD.specialChar
end
DD.sc = DD.specialChar

-- https://github.com/evilfactory/LuaCsForBarotrauma/blob/master/Barotrauma/BarotraumaShared/SharedSource/Networking/NetworkMember.cs#L221
DD.clientLogName = function (client)
	DD.expectTypes('clientLogName', {client}, {'userdata'})
	
	local text = DD.sc
	if client.Karma < 40 then
		text = text .. 'color:#ff9900;'
	end
	text = text .. 'metadata:' ..  client.AccountId.ToString() .. DD.sc .. client.Name .. DD.sc .. 'end' .. DD.sc
	return text
end

-- Set of antag safe jobs
DD.antagSafeJobs = {
	captain = true,
	securityofficer = true,
	diver = true,
	foreman = true,
	researcher = true,
	medicaldoctor = true,
	bodyguard = true,
	mercs = true,
}

-- Couldn't be bothered to recall what number is used for each inventory slot so I made this table
DD.invSlots = {
	idcard = 0,
	headset = 1,
	head = 2,
	innerclothes = 3,
	innerclothing = 3,
	clothes = 3,
	clothing = 3,
	outerclothes = 4,
	outerclothing = 4,
	suit = 4,
	lefthand = 5,
	righthand = 6,
	bag = 7,
	any1 = 8 + 0,
	any2 = 8 + 1,
	any3 = 8 + 2,
	any4 = 8 + 3,
	any5 = 8 + 4,
	any6 = 8 + 5,
	any7 = 8 + 6,
	any8 = 8 + 7,
	any9 = 8 + 8,
	any10 = 8 + 9,
	healthinterface = 18,
	health = 18
}

-- Output table in a neat way
DD.tablePrint = function (t, output, long, depth, chars, history)
	if t == nil then
		out = 'nil'
		if not output then print(out) end
		return out
	end
	
	-- avoids infinite recursion
	local historyCopy = {}
	for k, v in pairs(history or {}) do
		historyCopy[k] = v
	end
	local history = historyCopy
	history[t] = true
	
	local chars = chars or {}
	local quoteChar = chars['quote'] or '"'
	local lineChar = chars['line'] or '\n'
	local spaceChar = chars['space'] or '    '
	local depth = depth or 0
	local long = long or -1
	
	local out = '{'
	if long >= 0 then
		out = out .. lineChar
	else
		out = out .. ' '
	end
	local first = true
	for key, value in pairs(t) do
		if not first then
			if long >= 0 then
				out = out .. ',' .. lineChar
			else
				out = out .. ', '
			end
		else
			first = false
		end
		if long >= 0 then
			out = out .. string.rep(spaceChar, (depth + 1) * long)
		end
		if type(key) == 'function' then
			out = out .. 'FUNCTION'
		elseif type(key) == 'boolean' then
			if key then
				out = out .. 'true'
			else
				out = out .. 'false'
			end
		elseif type(key) == 'userdata' then
			if not pcall(function ()
				out = out .. 'UD:' ..key.Name
			end) then
				if not pcall(function ()
					out = out .. key.Info.Name
				end) then
					out = out .. 'USERDATA'
				end
			end
		elseif type(key) == 'table' then
			if history[key] then
				out = out + 'RECURSION'
			else
				out = out .. DD.tablePrint(key, true, long, depth + 1, chars, history)
			end
		elseif type(key) == 'string' then
			out = out .. quoteChar .. key .. quoteChar
		else
			out = out .. key
		end
		out = out .. ' = '
		if type(value) == 'function' then
			out = out .. 'FUNCTION'
		elseif type(value) == 'boolean' then
			if value then
				out = out .. 'true'
			else
				out = out .. 'false'
			end
		elseif type(value) == 'userdata' then
			if not pcall(function ()
				out = out .. 'UD:' ..value.Name
			end) then
				if not pcall(function ()
					out = out .. value.Info.Name
				end) then
					out = out .. 'USERDATA'
				end
			end
		elseif type(value) == 'table' then
			if history[value] then
				out = out .. 'RECURSION'
			else
				out = out .. DD.tablePrint(value, true, long, depth + 1, chars, history)
			end
		elseif type(value) == 'string' then
			out = out .. quoteChar .. value .. quoteChar
		else
			out = out .. value
		end
	end
	if long >= 0 then
		out = out .. lineChar .. string.rep(spaceChar, depth * long) .. '}'
	else
		out = out .. ' }'
	end
	if not output then print(out) end
	return out
end

-- Get the size of a table (for tables that aren't like an array, #t won't work)
DD.tableSize = function (t)
	DD.expectTypes('tableSize', {t}, {'table'})
	local size = 0
	for item in t do size = size + 1 end
	return size
end

-- See if table has a value
DD.tableHas = function (t, query)
	DD.expectTypes('tableHas', {t, query}, {'table', 'notnil'})
	for value in t do if value == query then return true end end
	return false
end

-- Returns an array of the keys of a table
DD.tableKeys = function (t)
	DD.expectTypes('tableKeys', {t}, {'table'})
	local build = {}
	for key, value in pairs(t) do table.insert(build, key) end
	return build
end

-- Returns an array of the values of a table
DD.tableValues = function (t)
	DD.expectTypes('tableValues', {t}, {'table'})
	local build = {}
	for key, value in pairs(t) do table.insert(build, value) end
	return build
end

-- Returns a string
DD.tableJoin = function (t, join)
	DD.expectTypes('tableJoin', {t, join}, {'table', 'nil,string'})
	local str = ''
	local join = join or ''
	for item in t do
		str = str .. item .. join
	end
	return string.sub(str, 1, #str - #join)
end

-- My version of string.format
DD.stringReplace = function(str, tbl)
	DD.expectTypes('stringReplace', {str, tbl}, {'string', 'nil,table'})
	local formatted = ''
	local build = ''
	local open = false
	for letterCount = 1, #str do
		local letter = string.sub(str, letterCount, letterCount)
		if (letter == '}') and open then
			open = false
			if tbl[build] == nil then
				formatted = formatted .. 'nil'
			elseif tbl[build] == true then
				formatted = formatted .. 'true'
			elseif tbl[build] == false then
				formatted = formatted .. 'false'
			elseif type(tbl[build]) == 'table' then
				formatted = formatted .. DD.tablePrint(tbl[build], true)
			elseif type(tbl[build]) == 'string' then
				formatted = formatted .. tbl[build]
			elseif type(tbl[build]) == 'userdata' then
				formatted = formatted .. tbl[build].Name
			else
				formatted = formatted .. tostring(tbl[build])
			end
			build = ''
		elseif open then
			build = build .. letter
		elseif (letter == '{') then
			open = true
		else
			formatted = formatted .. letter
		end
	end
	return formatted
end

-- Localizes a string
DD.stringLocalize = function (key, tbl)
	DD.expectTypes('stringLocalize', {key}, {'string'})
	local language
	if CLIENT then
		language = string.lower(tostring(Game.Settings.CurrentConfig.language))
		if DD.localizations[language] == nil then language = 'english' end
	else
		language = 'english'
	end
	if DD.localizations[language][key] == nil then language = 'english' end
	
	local str = DD.localizations[language][key]
	if tbl == nil then
		return str
	else
		return DD.stringReplace(str, tbl)
	end
end

-- Checks if a string has another string
DD.stringHas = function (strMain, strSub)
	DD.expectTypes('stringHas', {strMain, strSub}, {'string', 'string'})
	local build = ''
	local letter = ''
	for letterCount = 1, #strMain do
		letter = string.sub(strMain, letterCount, letterCount)
		if letter == string.sub(strSub, #build + 1, #build + 1) then
			build = build .. letter
		else
			build = ''
		end
		if build == strSub then
			return true
		end
	end
	return false
end


-- Search for any instances of a substring in a string and return a table (array) with their start positions
DD.stringFind = function (str, substr)
	DD.expectTypes('stringFind', {str, substr}, {'string', 'string'})
	local tbl = {}
	local build = ''
	local start = 0
	for count = 1, #str do
		local char = string.sub(str, count, count)
		if char == string.sub(substr, #build + 1, #build + 1) then
			if build == '' then start = count end
			build = build .. char
		elseif char == string.sub(substr, 1, 1) then
			start = count
			build = char
		else
			build = ''
		end
		if build == substr then
			table.insert(tbl, start)
			build = ''
		end
	end
	return tbl
end

-- Splits a string into a table
DD.stringSplit = function (str, split)
	DD.expectTypes('stringSplit', {str, split}, {'string', 'string'})
	local tbl = {}
	local build = ''
	local temp = ''
	local splitPoint = nil
	for count = 1, #str do
		local char = string.sub(str, count, count)
		build = build .. char
		if char == string.sub(split, #temp + 1, #temp + 1) then
			temp = temp .. char
		elseif char == string.sub(split, 1, 1) then
			temp = char
		else
			temp = ''
		end
		if temp == split then
			table.insert(tbl, string.sub(build, 1, #build - #temp))
			build = ''
			temp = ''
		end
	end
	table.insert(tbl, build)
	return tbl
end

-- Turns a table into a set
DD.toSet = function (t)
	DD.expectTypes('toSet', {t}, {'table'})
	local build = {}
	for value in t do
		build[value] = true
	end
	return build
end

-- Return union between 2 sets
DD.setUnion = function (t1, t2)
	DD.expectTypes('setUnion', {t1, t2}, {'table', 'table'})
	local build = {}
	for key, value in pairs(t1) do
		build[key] = true
	end
	for key, value in pairs(t2) do
		build[key] = true
	end
	return build
end

-- Return intersection between 2 sets
DD.setIntersection = function (t1, t2)
	DD.expectTypes('setIntersection', {t1, t2}, {'table', 'table'})
	local build = {}
	for key, value in pairs(t1) do
		if t2[key] then
			build[key] = true
		end
	end
	for key, value in pairs(t2) do
		if t1[key] then
			build[key] = true
		end
	end
	return build
end

-- Return subtraction between 2 sets
DD.setSubtract = function (t1, t2)
	DD.expectTypes('setSubtract', {t1, t2}, {'table', 'table'})
	local build = {}
	for key, value in pairs(t1) do
		if not t2[key] then
			build[key] = true
		end
	end
	return build
end

-- Return difference between 2 sets
DD.setXor = function (t1, t2)
	DD.expectTypes('setXor', {t1, t2}, {'table', 'table'})
	return DD.setSubtract(DD.setUnion(t1, t2), DD.setIntersection(t1, t2))
end

-- Xor
DD.xor = function (b1, b2)
	DD.expectTypes('xor', {b1, b2}, {'boolean', 'boolean'})
	return (b1 or b2) and not (b1 and b2)
end

-- Turns a table into an array
DD.toArr = function (t)
	return DD.tableValues(t)
end

-- Like string.sub but for array tables
DD.arrSub = function (array, start, finish)
	DD.expectTypes('arrSub', {array, start, finish}, {'table', 'number', 'number'})
	local tbl = {}
	for count = start, finish do
		table.insert(tbl, array[count])
	end
	return tbl
end

-- Shuffles a table (assumes it has an array-like structure)
DD.arrShuffle = function (array)
	DD.expectTypes('arrShuffle', {array}, {'table'})
	local shuffledArray = {}
	local originalArray = {}
	for key, value in pairs(array) do
		originalArray[key] = value
	end
	while #originalArray > 0 do
		table.insert(shuffledArray, table.remove(originalArray, math.random(#originalArray)))
	end
	return shuffledArray
end

DD.weightedRandomTest = function (x)
	local tbl = {'apple', 'banana', 'cherry', 'donut', 'elephant', 'frag', 'grape'}
	local weights = {1, 2, 1, 0, 0, 0, 4}
	local count = {}
	for value in tbl do count[value] = 0 end
	
	for n = 1, x do
		local chosen = DD.weightedRandom(tbl,weights)
		count[chosen] = count[chosen] + 1
	end
	
	for key,value in pairs(count) do
		print(key .. ': ' .. math.round(value / x, 2))
	end
end

-- Weighted random (weights can be floats)
DD.weightedRandom = function(tbl, weights)
	DD.expectTypes('weightedRandom', {tbl, weights}, {'table', 'nil,table'})
	local weights = weights or {}
	local maximun = 0
	local ranges = {}
	for key, value in pairs(tbl) do
		local weight = weights[key] or 0
		if weight > 0 then
			maximun = maximun + weight
			ranges[maximun] = value
		end
	end
	local number = math.random() * maximun
	for range, value in pairs(ranges) do
		if range >= number then
			return value
		end
	end
	return nil
end

-- Gives an affliction to a character
DD.giveAfflictionCharacter = function (character, identifier, amount, limb)
	DD.expectTypes('giveAfflictionCharacter', {character, identifier, amount, limb}, {'userdata', 'string', 'number', 'nil,userdata'})
	local limb = limb or character.AnimController.MainLimb
	character.CharacterHealth.ApplyAffliction(limb, AfflictionPrefab.Prefabs[identifier].Instantiate(amount))
end

-- Returns the item whose key matches the value
DD.find = function (tbl, key, value)
	for item in tbl do
		if item[key] == value then
			return item
		end
	end
	return nil
end

-- Return the character whose key matches the value
DD.findCharacter = function(key, value)
	return DD.find(Character.CharacterList, key, value)
end

-- Return the client whose key matches the value
DD.findClient = function(key, value)
	return DD.find(Client.ClientList, key, value)
end

-- Returns the client whose character matches
DD.findClientByCharacter = function (character)
	DD.expectTypes('findClientByCharacter', {character}, {'userdata'})
	return DD.findClient('Character', character)
end

-- Finds the locations that matches the filter
DD.getLocations = function (filterFunc, items)
	local filterFunc = filterFunc or (function (item) return true end)
	local items = items or Item.ItemList
	
	local locations = {}
	for item in items do
		if (item.Prefab.Identifier == 'dd_location') and (filterFunc(item)) then
			table.insert(locations, item)
		end
	end
	
	return locations
end

-- Finds a location that matches the filter
DD.getLocation = function (filterFunc, items)
	local locations = DD.getLocations(filterFunc, items)
	return locations[math.random(#locations)]
end

-- Find waypoints by job
DD.findWaypointsByJob = function (job)
	local waypoints = {}
	for waypoint in Submarine.MainSub.GetWaypoints(false) do
		if (waypoint.AssignedJob ~= nil) and (waypoint.AssignedJob.Identifier == job) then
			table.insert(waypoints, waypoint)
		end
	end
	if (job == '') and (table.size(waypoints) < 1) then
		for waypoint in Submarine.MainSub.GetWaypoints(false) do
			if waypoint.SpawnType == SpawnType.Human then
				table.insert(waypoints, waypoint)
			end
		end
		
	end
	return waypoints
end

-- Find one random waypoint of a job
DD.findRandomWaypointByJob = function (job)
	local waypoints = DD.findWaypointsByJob(job)
	return waypoints[math.random(#waypoints)]
end

DD.isCharacterUsingHullOxygen = function (character, ignoreHeadInWater)
	DD.expectTypes('isCharacterUsingHullOxygen', {character, ignoreHeadInWater}, {'userdata', 'nil,boolean'})
	if character.Inventory == nil then return end
	local headslot = character.Inventory.GetItemAt(DD.invSlots.head)
	local suitslot = character.Inventory.GetItemAt(DD.invSlots.suit)
	local clothingslot = character.Inventory.GetItemAt(DD.invSlots.innerclothes)
	
	if character.AnimController.HeadInWater and not ignoreHeadInWater then return false end
	if not character.UseHullOxygen then return false end
	if (suitslot ~= nil) and ((suitslot.Prefab.Identifier == 'pucs') or (suitslot.Prefab.Identifier == 'nexsuit')) then return false end
	if (clothingslot ~= nil) and (clothingslot.Prefab.Identifier == 'hazmatsuit') then return false end
	
	--[[
	if (headslot ~= nil) and headslot.HasTag('diving') then return false end
	if(suitslot ~= nil) and suitslot.HasTag('diving') and (suitslot.Prefab.Identifier ~= 'brokendivingsuit') then return false end
	--]]
	
	return true
end

DD.isCharacterAntagSafe = function (character)
	DD.expectTypes('isCharacterAntagSafe', {character}, {'userdata'})
	return DD.antagSafeJobs[tostring(character.JobIdentifier)]
end

DD.isCharacterHusk = function (character)
	DD.expectTypes('isCharacterHusk', {character}, {'userdata'})
	local speciesNames = {'humanhusk', 'husk', 'husk_chimera', 'husk_prowler', 'husk_exosuit', 'huskcontainer', 'crawlerhusk'}
	return DD.tableHas(speciesNames, string.lower(tostring(character.SpeciesName)))
end

DD.isCharacterSecurity = function (character)
	DD.expectTypes('isCharacterSecurity', {character}, {'userdata'})
	local jobs = {'captain', 'securityofficer', 'diver', 'foreman', 'mercs'}
	return DD.tableHas(jobs, character.JobIdentifier)
end

DD.isCharacterProletariat = function (character)
	DD.expectTypes('isCharacterProletariat', {character}, {'userdata'})
	local jobs = {'mechanic', 'clown'}
	return DD.tableHas(jobs, character.JobIdentifier)
end

DD.isCharacterMedical = function (character)
	DD.expectTypes('isCharacterMedical', {character}, {'userdata'})
	local jobs = {'medicaldoctor', 'researcher'}
	return DD.tableHas(jobs, character.JobIdentifier)
end

DD.isCharacterArrested = function (character)
	DD.expectTypes('isCharacterArrested', {character}, {'userdata'})
	if character.IsDead then return false end
	if character.IsHandcuffed then return true end
	if character.CurrentHull == nil then return false end
	if character.Inventory.GetItemAt(DD.invSlots.innerclothes) == nil then return false end
	
	if (character.CurrentHull.RoomName == 'roomname.brig') and (character.Inventory.GetItemAt(DD.invSlots.innerclothes).Prefab.Identifier == 'prisonerclothes') then
		return true
	end
	
	return false
end

DD.isClientCharacterAlive = function (client)
	DD.expectTypes('isClientCharacterAlive', {client}, {'userdata'})
	return (client.Character ~= nil) and (not client.Character.IsDead)
end

DD.lerp = function (n, a, b)
	DD.expectTypes('lerp', {n, a, b}, {'number', 'number', 'number'})
	return a*(1-n) + b*n
end

-- Turns a number (represents seconds) into a formatted string for hours, minutes and seconds
DD.numberToTime = function (n, data)
	DD.expectTypes('numberToTime', {n, data}, {'number', 'nil,table'})
	local data = data or {}
	local spacing = data.spacing or 1
	local unitSpacing = data.unitSpacing or spacing
	local showNonRelevant
	if data.showNonRelevant or (data.showNonRelevant == nil) then showNonRelevant = 1 else showNonRelevant = 0 end
	if not data.allowNegative then n = math.max(0, n) end
	
	local text = ''
	if n < 0 then text = '-' .. string.rep(' ', spacing) end
	
	n = math.abs(n)
	local seconds = n
	local minutes = math.floor(seconds / 60)
	local hours = math.floor(minutes / 60)
	seconds = seconds - minutes * 60
	minutes = minutes - hours * 60
	seconds = math.floor(seconds + 0.5)
	
	if hours > 0 then
		text = text .. tostring(hours) .. string.rep(' ', unitSpacing) .. 'h' .. string.rep(' ', spacing)
	end
	if minutes + hours * showNonRelevant > 0 then
		text = text .. tostring(minutes) .. string.rep(' ', unitSpacing) .. 'min' .. string.rep(' ', spacing)
	end
	if seconds + (minutes + hours) * showNonRelevant > 0 then
		text = text .. tostring(seconds) .. string.rep(' ', unitSpacing) .. 's'
	end
	
	if text == '' then text = '0' .. string.rep(' ', unitSpacing) .. 's' end
	
	return text
end

-- Spawns a human with a job somewhere
DD.spawnHuman = function (client, job, pos, name, subclass, speciesName)
	local speciesName = speciesName or 'human'
	
	local info
	if name ~= nil then
		info = CharacterInfo(speciesName, name)
	elseif client == nil then
		info = CharacterInfo(speciesName, CharacterInfo(speciesName, 'John Doe').GetRandomName(1))
	elseif client.CharacterInfo == nil then
		info = CharacterInfo(speciesName, client.Name)
	else
		if speciesName == 'human' then info = client.CharacterInfo
		else info = CharacterInfo(speciesName, client.Name)
		end
	end
	
	local jobPrefab = JobPrefab.Get(job)
	if subclass == nil then
		info.Job = Job(jobPrefab, false)
		info.Job.Variant = math.random(jobPrefab.Variants) - 1
	else
		info.Job = Job(jobPrefab, false)
		info.Job.Variant = subclass
	end
	if info.Job.Variant > (jobPrefab.Variants - 1) then info.Job.Variant = (jobPrefab.Variants - 1) end
	
	local character
	if client == nil then
		character = Character.Create(speciesName, pos, info.Name, info, 0, false, true)
	else
		character = Character.Create(speciesName, pos, info.Name, info, 0, true, false)
	end
	
	if speciesName == 'human' then character.GiveJobItems(false) end
	if client ~= nil then
		client.SetClientCharacter(character)
	end
	
	return character
end

-- Test message client colors
DD.messageAllClientsTest = function ()
	DD.messageAllClients('You have received 1000$ dollars for free!', {preset = 'goodinfo'})
	DD.messageAllClients('Idk pretty meh news it seems.', {preset = 'info'})
	DD.messageAllClients('Oh shit the aurora borealis? Entirely within my kitchen?! SHIT', {preset = 'badinfo'})
	DD.messageAllClients('OH MY GOD EVERYONE IS FUCKING DEAD JESUS CHRIST', {preset = 'crit'})
	DD.messageAllClients('Booooo spooky ghost stuff! Are you scared?', {preset = 'ghostRole'})
	DD.messageAllClients('Self-destruction initiated. Explosion in T-60 seconds.', {preset = 'command'})
	DD.messageAllClients('Yknow, it could be a debug message...', {preset = 'debug'})
end

-- Messages a message to a client
DD.messageClient = function (client, text, data)
	if CLIENT then return end
	DD.expectTypes('messageClient', {client, text, data}, {'userdata', 'nil,string,number,boolean', 'nil,table'})
	
	local data = data or {}
	
	local sender = data.sender or ''
	local messageType = data.type or 'Default'
	local icon = data.icon
	local color = data.color
	local senderCharacter = data.senderCharacter
	local sendAnother = data.sendAnother
	if sendAnother == nil then sendAnother = false end
	local sendMain = data.sendMain
	if sendMain == nil then sendMain = true end
	
	if data.preset == 'goodinfo' then
		sender = '[Good Info]'
		color = Color(100, 200, 155)
		messageType = 'ServerMessageBoxInGame'
		icon = 'WorkshopMenu.InfoButton'
		sendAnother = true		
	end
	if data.preset == 'info' then
		sender = '[Neutral Info]'
		color = Color(155, 200, 100)
		messageType = 'ServerMessageBoxInGame'
		icon = 'WorkshopMenu.InfoButton'
		sendAnother = true
	end
	if data.preset == 'badinfo' then
		sender = '[Bad Info]'
		color = Color(200, 155, 100)
		messageType = 'ServerMessageBoxInGame'
		icon = 'WorkshopMenu.InfoButton'
		sendAnother = true
	end
	if data.preset == 'crit' then
		sender = '[Crit Info]'
		color = Color(255, 55, 55)
		messageType = 'MessageBox'
		icon = 'WorkshopMenu.InfoButton'
		sendAnother = true
	end
	if data.preset == 'ghostRole' then
		sender = '[Ghost Role]'
		color = Color(155, 100, 200)
		messageType = 'Dead'
	end
	if data.preset == 'command' then
		sender = '[Command]'
		color = Color(190, 215, 255)
		sendMain = false
		sendAnother = true
	end
	if data.preset == 'commandError' then
		sender = '[Error]'
		color = Color(255, 55, 55)
		sendMain = false
		sendAnother = true
	end
	if data.preset == 'bloodsample' then
		sender = '[Blood Sample]'
		color = Color(255, 55, 55)
		sendMain = false
		sendAnother = true
	end
	if data.preset == 'debug' then
		messageType = 'Console'
	end
	
	local chatMessage = ChatMessage.Create(sender, text, ChatMessageType.Default, nil, nil)
	if color ~= nil then
		chatMessage.Color = color
	end
	if sendAnother then
		Game.SendDirectChatMessage(chatMessage, client)
	end
	
	if sendMain then
		Game.SendDirectChatMessage(sender, text, senderCharacter, ChatMessageType[messageType], client, icon)
	end
end

-- Messages clients
DD.messageClients = function (clients, text, data)
	for client in clients do
		DD.messageClient(client, text, data)
	end
end

-- Message all clients
DD.messageAllClients = function (text, data)
	if CLIENT then return end
	DD.messageClients(Client.ClientList, text, data)
end

-- Opens or closes a door
DD.setDoorState = function (item, state)
	if (state == false) and (item.Condition <= 0) then return end
	item.GetComponentString('Door').isOpen = state
	if SERVER then
		local prop = item.GetComponentString('Door').SerializableProperties[Identifier("IsOpen")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('Door')))
	end
end

-- Enables or disables a light
DD.setLightState = function (item, state)
	item.GetComponentString('LightComponent').isOn = state
	if SERVER then
		local prop = item.GetComponentString('LightComponent').SerializableProperties[Identifier("IsOn")]
		Networking.CreateEntityEvent(item, Item.ChangePropertyEventData(prop, item.GetComponentString('LightComponent')))
	end
end

-- Enables or disables respawning
DD.setAllowRespawning = function (state)
	DD.expectTypes('setAllowRespawning', {state}, {'boolean'})
	Game.OverrideRespawnSub(not state)
	DD.allowRespawning = state
end