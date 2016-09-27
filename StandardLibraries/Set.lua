local Set = {}
Set.__index = Set

-- Creates a new set with a varying number of items.
function Set.new(...)
	local arguments = {...}
	
	local self = setmetatable({}, Set)
	self.Count = 0
	self.Items = setmetatable({}, {
		__call = function()
			return pairs(self.Items)
		end;
	})
	
	for _, argument in ipairs(arguments) do
		self:Add(argument)
	end
	
	return self
end

-- Adds an item to the set.
function Set:Add(item)
	if not self:Contains(item) then
		self.Items[item] = true
		self.Count = self.Count + 1
	end
end

function Set:CartesianProduct(otherSet)
	local newSet = Set.new()

	for item in self:Items() do
		for otherItem in otherSet:Items() do
			newSet:Add({ item, otherItem })
		end
	end

	return newSet
end

-- Creates a shallow copy of the set.
function Set:Clone()
	local items = {}
	
	for item in pairs(self.Items) do
		table.insert(items, item)
	end
	
	return Set.new(unpack(items))
end

-- Returns the complement of the first set and the second set.
-- Effectively performs a 'subtraction' on the first set using the second set.
-- All shared items will be removed from the first set.
function Set:Complement(otherSet)
	local complement = Set.new()
	
	for item in pairs(self.Items) do
		if not otherSet:Contains(item) then
			complement:Add(item)
		end
	end
	
	return complement
end

-- Returns whether the set contains an item (or a duck-equality equivalent).
function Set:Contains(item)
	local flag = self.Items[item] == true
	
	if flag then
		return true
	else
		-- ROBLOX types, e.g. Vector3s or CFrames, are not interned.
		-- Vector3.new(0, 0, 0) creates a new Vector3 each time it is called.
		-- This means that simply checking if Items contains a specific item is insufficient.
		-- The set may contain a value that is equivalent to that object (e.g. two Vector3s with the same coordinates)
		-- But they may not be the same object in memory. Using a search allows us a chance to
		-- employ custom equality operators.
		for testItem in pairs(self.Items) do
			if testItem == item then
				return true
			end
		end
	end
	
	return false
end

-- Returns whether the set is a subset of another set, i.e. all of its values are contained in the other set.
function Set:IsSubsetOf(otherSet)
	for item in pairs(self.Items) do
		if not otherSet:Contains(item) then
			return false
		end
	end
	
	return true
end

-- Returns a set containing all items that are shared across both sets.
function Set:Intersection(otherSet)
	local intersect = Set.new()
	
	for item in pairs(self.Items) do
		if otherSet:Contains(item) then
			intersect:Add(item)
		end
	end
	
	return intersect
end

-- Removes an item from a set.
function Set:Remove(item)
	if self:Contains(item) then
		-- self.Items[item] may not be set even if self:Contains(item) is true
		-- See notes on Set:Contains
		for testItem in pairs(self.Items) do
			if testItem == item then
				self.Items[testItem] = nil
				break
			end
		end

		self.Count = self.Count - 1
	end
end

-- Returns a set containing all items of both sets.
function Set:Union(otherSet)
	local copy = self:Clone()
	
	for item in pairs(otherSet.Items) do
		copy:Add(item)
	end
	
	return copy
end

function Set:__add(otherSet)
	return self:Union(otherSet)
end

-- Shorthand for Set:Complement, which can sometimes be written as A - B (read as the relative complement of B in A).
function Set:__sub(otherSet)
	return self:Complement(otherSet)
end

-- Shorthand for Set:Intersection, which is sometimes written as A * B
function Set:__mul(otherSet)
	return self:Intersection(otherSet)
end

-- Shorthand for Set:Complement, which is usually expressed as A \ B (read as the relative complement of B in A).
function Set:__div(otherSet)
	return self:Complement(otherSet)
end

function Set:__eq(otherSet)
	-- Easy check: If they don't have the same number of elements, they cannot be equal.
	if self.Count ~= otherSet.Count then
		return false
	end
	
	-- Scan their items.
	for item in pairs(self.Items) do
		if not otherSet:Contains(item) then
			return false
		end
	end
	
	return true
end

function Set:__tostring()
	local str = "{ "
	
	-- Cannot use table.concat because it errors for userdatas
	for item in pairs(self.Items) do
		str = str..tostring(item).."; "
	end
	
	str = str.." }"
	
	return str
end

return Set