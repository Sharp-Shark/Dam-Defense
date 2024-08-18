DD.saving = {}

-- The path to the save file
DD.saving.savePath = DD.path .. '/save.json'

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
DD.saving.load = function (keys)
	local tbl = json.parse(File.Read(DD.saving.savePath))
	local keys = keys or DD.saving.keys
	for key in keys do
		if tbl[key] ~= nil then
			DD.saving.set(key, tbl[key])
		end
	end
	return json.parse(File.Read(DD.saving.savePath))
end

-- Saves to file
DD.saving.save = function (keys)
	local tbl = {}
	if keys ~= nil then tbl = json.parse(File.Read(DD.saving.savePath)) end
	local keys = keys or DD.saving.keys
	for key in keys do
		tbl[key] = DD.saving.get(key)
	end
	File.Write(DD.saving.savePath, json.serialize(tbl))
	return json.serialize(tbl)
end

-- Print save file
DD.saving.debug = function ()
	DD.tablePrint(json.parse(File.Read(DD.saving.savePath)), nil, 1)
end

-- Create save file if none is found
DD.saving.boot = function ()
	if not File.Exists(DD.saving.savePath) then
		table.insert(DD.warnings, 'No save file was found, so one was created at ' .. DD.saving.savePath)
		DD.saving.save()
	else
		DD.saving.load()
		DD.saving.save()
	end
end