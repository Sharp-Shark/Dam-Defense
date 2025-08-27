-- Base event code
DD.eventBase = DD.class(nil, function (self)
	self.seed = tostring(math.floor(math.random() * 10^8)) -- is also often used as a function's unique identifier
end, {
	paramType = {}, -- correct type for each parameter of the constructor function of this class
	clientKeys = {}, -- keys of properties of this event that are a client or a client list (useful for finding what clients are participanting in an event)
	public = true, -- determines if event will be listed in "/publicevents"
	manuallyTriggered = false, -- if triggered manually by an admin using a command this will be true

	logClients = function (self, set)
		local text = '{clientName} is a member of the "{eventName}" event ({seed}) under the key "{keyName}".'
		for clientKey in self.clientKeys do
			if type(self[clientKey]) == 'table' then
				for client in self[clientKey] do
					if (set == nil) or set[client] then
						Game.Log(DD.stringReplace(text, {clientName = DD.clientLogName(client), eventName = self.name, seed = self.seed, keyName = clientKey}), 12)
					end
				end
			else
				local client = self[clientKey]
				if (set == nil) or set[client] then
					Game.Log(DD.stringReplace(text, {clientName = DD.clientLogName(client), eventName = self.name, seed = self.seed, keyName = clientKey}), 12)
				end
			end
		end
	end,

	started = false,
	start = function (self)
		if DD.debugMode then print('start: ' .. self.name .. self.seed) end
		
		-- Reset some values
		if type(self.lateJoinBlacklistSet) == 'table' then self.lateJoinBlacklistSet = {} end
		
		-- Flags
		self.started = true
		self.failed = false
		self.finished = false
		
		-- Count players
		local players = 0
		local alive = 0
		for client in Client.ClientList do
			if client.InGame and (DD.isClientCharacterAlive(client) or DD.isClientRespawnable(client)) then
				players = players + 1
				if DD.isClientCharacterAlive(client) then
					alive = alive + 1
				end
			end
		end
		players = math.max(1, players)
		local alivePercentage = alive / players
		local deadPercentage = 1 - alivePercentage
		
		-- enforce restrictions
		if not self.manuallyTriggered then
			if self.isMainEvent then self.instanceCap = 1 end
			if DD.roundTimer < self.minimunTimeElapsed then
				self.fail('not enough time has elapsed since the round started')
				return
			end
			if (DD.eventDirector.mainEventCap >= 0) and self.isMainEvent and (#DD.eventDirector.getMainEvents() >= DD.eventDirector.mainEventCap) then
				self.fail('limit on main events has been reached')
				return
			end
			if (self.instanceCap >= 0) and (#DD.eventDirector.getEventInstances(self.name) >= self.instanceCap) then
				self.fail('limit on instances of this event has been reached')
				return
			end
			if (self.minimunAlivePercentage > alivePercentage) or (self.minimunDeadPercentage > deadPercentage) then
				self.fail('minimun alive percentage or minimun dead percentage were not met')
				return
			end
		end
		
		-- Create hooks
		DD.newThinkFunctions[self.name .. self.seed] = function () if self.finished or self.failed then return end self.onThink() end
		DD.characterDeathFunctions[self.name .. self.seed] = function (character) self.onCharacterDeath(character) end
		DD.chatMessageFunctions[self.name .. self.seed] = function (message, sender) return self.onChatMessage(message, sender) end
		DD.roundEndFunctions[self.name .. self.seed] = function () self.finish() end
		
		-- onStart
		self.onStart()
		
		-- Add self to eventDirector events list and log clients
		if not self.failed then
			table.insert(DD.eventDirector.events, self)
			if SERVER then
				Game.Log(DD.stringReplace('"{eventName}" event ({seed}) has started.', {eventName = self.name, seed = self.seed}), 12)
				self.logClients()
			end
		end
		
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
		
		-- Remove self from eventDirector events list
		for key, event in pairs(DD.eventDirector.events) do
			if event == self then
				table.remove(DD.eventDirector.events, key)
			end
		end
		
		-- log event end
		if SERVER and not self.failed then Game.Log(DD.stringReplace('"{eventName}" event ({seed}) has finished.', {eventName = self.name, seed = self.seed}), 12) end
		
		-- Flags
		self.finished = true
		
		return self
	end,
	
	failed = false,
	fail = function (self, failText) -- self.fail() is like a self.cancel() but I've already named it self.fail() and it's too late to go back
		local failText = failText or ''
		if failText ~= '' then failText = ' (' .. failText .. ')' end
		
		if DD.debugMode then print('fail: ' .. self.name .. self.seed .. failText) end
		if SERVER then
			Game.Log(DD.stringReplace('"{eventName}" event ({seed}) has failed{failText}.', {eventName = self.name, seed = self.seed, failText = failText}), 12)
		end
		self.failed = true
		self.finish()
	end,
	
	name = 'name',
	instanceCap = -1, -- how many instances of this event can be active at the same time (negative values mean it is uncapped)
	isMainEvent = false, -- for eventDirector
	cooldown = 60 * 1, -- for eventDirector
	weight = 1, -- for eventDirector
	goodness = 0, -- for eventDirector
	minimunAlivePercentage = 0.0, -- minimun percentage of alive players required when event starts
	minimunDeadPercentage  = 0.0, -- minimun percentage of dead players required when event starts
	minimunTimeElapsed = 0, -- minimun amount of time in seconds elapsed since the round started
	
	onStart = function (self) return end,
	
	onThink = function (self) self.finish() end,
	
	onCharacterDeath = function (self, character) return end,
	
	onChatMessage = function (self, message, sender) return end,
	
	onFinish = function (self) return end,
	
	onFinishAlways = function (self) return end -- use this if you have some code that ALWAYS must be executed upon event end no matter what
})

-- Base for state machine event
DD.eventSMBase = DD.class(DD.eventBase, function (self)
	local tbl = {}
	for key, name in pairs(self.states) do
		local state = {}
		for key, value in pairs(self[name]) do
			state[key] = value
		end
		tbl[key] = state
		tbl[key].parent = self
	end
	self.states = tbl
end, {
	start = function (self)
		DD.eventBase.tbl.start(self)
		if self.failed then return end
		
		for state in self.states do
			if state.onStart ~= nil then state:onStart() end
		end
		
		self.changeState('start')
	end,

	states = {start = 'stateStart'},
	
	stateStart = {
		onStart = function (self) return end,
		onChange = function (self, state) return end,
		onThink = function (self) return end,
	},
	
	setupStates = function (self) -- I don't think this method is used? I'll later check if this is true, and if it is, I'll remove it to avoid confusion
	end,
	
	changeState = function (self, state)
		self.state = state
		self.states[self.state]:onChange(state)
	end,
	
	onThink = function (self)
		if self.finished or self.failed then return end	
		self.states[self.state]:onThink()
	end
})

-- Base for events with an initial start state and then a main state
DD.eventWithStartBase = DD.class(DD.eventSMBase, nil, {
	states = {start = 'stateStart', main = 'stateMain'},
	
	stateStartInitialTimer = 60 * 1, -- in seconds
	
	stateStart = {
		onStart = function (self) return end,
		onChange = function (self, state)
			self.timer = self.parent.stateStartInitialTimer
		end,
		onThink = function (self)
			if (DD.thinkCounter % 30 ~= 0) or (not Game.RoundStarted) then return end
			local timesPerSecond = 2
			
			if self.parent.getShouldFinish ~= nil then
				if self.parent.getShouldFinish() then
					self.parent.finish()
					return
				end
			end
		
			if self.timer > 0 then
				self.timer = self.timer - 1 / timesPerSecond
			else
				self.parent.changeState('main')
				return
			end
		end,
	},
	
	stateMain = {
		onStart = function (self) return end,
		onChange = function (self, state) return end,
		onThink = function (self) return end,
	},
})