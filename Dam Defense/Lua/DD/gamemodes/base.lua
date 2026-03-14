-- Base gamemode code
DD.gamemodeBase = DD.class(nil, nil, {
	tempSetPathValue = {},
	tempSet = function (self, path, value)
		if self.tempSetPathValue[path] == nil then self.tempSetPathValue[path] = DD.saving.get(path) end
		DD.saving.set(path, value)
	end,
	
	dispose = function (self)
		for path, value in pairs(self.tempSetPathValue) do
			DD.saving.set(path, value)
		end
		self.tempSetPathValue = {}
	end,
	
	name = 'base',
	displayName = 'regular',
	votable = true,
	
	commandOverride = {},
	eventBlacklist = {},
	
	onRoundStart = function (self)
	end,
	
	onThink = function (self)
	end,
	
	onRoundEnd = function (self)
		local data = {hourSymbol = 'hour', minuteSymbol = 'minute', secondSymbol = 'second'}
		if DD.roundTimer / 3600 >= 2 then data.hourSymbol = 'hours' end
		if (DD.roundTimer % 3600) / 60 >= 2 then data.minuteSymbol = 'minutes' end
		if DD.roundTimer % 60 >= 2 then data.secondSymbol = 'seconds' end
		DD.messageAllClients(DD.stringLocalize('baseRoundEnd', {timer = DD.numberToTime(DD.roundTimer, data)}), {preset = 'crit'})
	end,
})