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
	end,
})