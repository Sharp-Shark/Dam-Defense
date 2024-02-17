-- Used to make classes
DD.class = function (inherit, func, tbl)
	local func = func or function () end
	local tbl = tbl or {}
	
	-- Inheritance
	if inherit ~= nil then
		-- Inherit func
		local myFunc = func
		func = function (build, ...) inherit.func(build, ...) myFunc(build, ...) end
		-- Inherit tbl
		local myTbl = tbl
		tbl = {}
		for key, value in pairs(inherit.tbl) do
			tbl[key] = value
		end
		for key, value in pairs(myTbl) do
			tbl[key] = value
		end
	end

	-- Makes instances
	local newFunc = function (...)
		local build = {}
		
		for key, value in pairs(tbl) do
			if type(value) == 'function' then
				build[key] = function (...) return value(build, ...) end
			else
				build[key] = value
			end
		end
		
		func(build, ...)
		
		return build
	end
	
	-- DD.class(...) to define a class
	-- DD.class(...).new(...) to create an instance of that class
	return {new = newFunc, inherit = inherit, func = func, tbl = tbl}
end

-- 2D Vector class to demonstrate Object-Oriented logic
DD.vector = DD.class(nil, function (self, x, y)
	self.x = x or self.x
	self.y = y or self.y
end, {
	x = 0,
	y = 0,
	translate = function (self, other)
		return DD.vector.new(self.x + other.x, self.y + other.y)
	end
})