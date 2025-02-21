DD.saving = {}

-- The path to the save file
DD.saving.folderPath = 'LocalMods/_DamDefenseData/'
DD.saving.savePath = DD.saving.folderPath .. 'save.json'

-- Auto saving
DD.saving.autoSave = true

-- Which keys should have their values saved
DD.saving.keys = {
	'debugMode',
	'eventDirector.enabled',
	'jobBans',
}

-- Get any value from the table DD
DD.saving.get = function (path)
	local value = DD
	for key in DD.stringSplit(path, '.') do
		if value == nil then return end
		value = value[key]
	end
	return value
end

-- Set any value from the table DD
DD.saving.set = function (path, new)
	local value = DD
	local counter = DD.tableSize(DD.stringSplit(path, '.'))
	for key in DD.stringSplit(path, '.') do
		if value == nil then return end
		if counter == 1 then
			value[key] = new
		end
		value = value[key]
		counter = counter - 1
	end
	return value
end

-- Loads from file
DD.saving.load = function (keys, filePath)
	local filePath = filePath or DD.saving.savePath
	
	local tbl = json.parse(File.Read(filePath))
	local keys = keys or DD.saving.keys
	for key in keys do
		if tbl[key] ~= nil then
			DD.saving.set(key, tbl[key])
		end
	end
	return json.parse(File.Read(filePath))
end

-- Saves to file
DD.saving.save = function (keys, filePath)
	local filePath = filePath or DD.saving.savePath
	
	local tbl = {}
	if keys ~= nil then tbl = json.parse(File.Read(filePath)) end
	local keys = keys or DD.saving.keys
	for key in keys do
		tbl[key] = DD.saving.get(key)
	end
	File.Write(filePath, json.serialize(tbl))
	return json.serialize(tbl)
end

-- Autosave function
DD.saving.autoSave = function (keys)
	if DD.saving.autoSave and not DD.debugMode then DD.saving.save(keys) end
end

-- Print save file
DD.saving.debug = function ()
	DD.tablePrint(json.parse(File.Read(DD.saving.savePath)), nil, 1)
end

-- Does setup. Then loads and updates save file if it exists
DD.saving.boot = function ()
	if not File.DirectoryExists(DD.saving.folderPath) then
        File.CreateDirectory(DD.saving.folderPath)
		DD.warn('Data folder not found, so one was created at ' .. DD.saving.folderPath)
	end
	if not File.Exists(DD.saving.savePath) then
		if File.Exists('LocalMods/Dam Defense.json') then
			local oldSavePath = 'LocalMods/Dam Defense.json'
			DD.saving.load(nil, oldSavePath)
			os.remove(oldSavePath)
			DD.saving.save()
			DD.warn('Old save file was moved to ' .. DD.saving.savePath)
		else
			DD.saving.save()
			DD.warn('No save file was found, so one was created at ' .. DD.saving.savePath)
		end
	else
		DD.saving.load()
		DD.saving.save()
	end
end