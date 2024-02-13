-- Base event code
DD.eventBase = DD.class(nil, function (self)
	self.seed = tostring(math.floor(math.random() * 10^8)) -- is also often used as a function's unique identifier
end, {
	paramType = {}, -- correct type for each parameter of the constructor function of this class
	clientKeys = {}, -- keys of properties of this event that are a client or a client list (useful for finding what clients are participanting in an event)

	started = false,
	start = function (self)
		if DD.debugMode then print('start: ' .. self.name .. self.seed) end
		
		-- Flags
		self.started = true
		self.failed = false
		self.finished = false
		
		-- Create hooks
		DD.newThinkFunctions[self.name .. self.seed] = function () self.onThink() end
		DD.characterDeathFunctions[self.name .. self.seed] = function (character) self.onCharacterDeath(character) end
		DD.chatMessageFunctions[self.name .. self.seed] = function (message, sender) return self.onChatMessage(message, sender) end
		DD.roundEndFunctions[self.name .. self.seed] = function () self.finish() end
		
		-- onStart
		self.onStart()
		
		-- Add self to eventDirector events list
		if not self.failed then table.insert(DD.eventDirector.events, self) end
		
		return self
	end,
	
	finished = false,
	finish = function (self)
		if DD.debugMode then print('finish: ' .. self.name .. self.seed) end
		
		-- Delete hooks
		DD.newThinkFunctions[self.name .. self.seed] = nil
		DD.thinkFunctions[self.name .. self.seed] = nil
		DD.characterDeathFunctions[self.name .. self.seed] = nil
		DD.chatMessageFunctions[self.name .. self.seed] = nil
		DD.roundEndFunctions[self.name .. self.seed] = nil
		
		-- onFinish
		if not (self.failed or DD.roundEnding) then self.onFinish() end
		self.onFinishAlways()
		
		-- Flags
		self.finished = true
		
		return self
	end,
	
	failed = false,
	fail = function (self) -- self.fail() is like a self.cancel() but I've already named it self.fail() and it's too late to go back
		if DD.debugMode then print('fail: ' .. self.name .. self.seed) end
		self.failed = true
		self.finish()
	end,
	
	name = 'name',
	isMainEvent = false, -- for eventDirector
	cooldown = 60 * 1, -- for eventDirector
	weight = 1, -- for eventDirector
	goodness = 0, -- for eventDirector
	
	onStart = function (self) return end,
	
	onThink = function (self) self.finish() end,
	
	onCharacterDeath = function (self, character) end,
	
	onChatMessage = function (self, message, sender) end,
	
	onFinish = function (self) return end,
	
	onFinishAlways = function (self) return end -- use this if you have some code that ALWAYS must be executed upon event end no matter what
})