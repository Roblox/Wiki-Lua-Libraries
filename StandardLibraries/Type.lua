-- Type contains the following functions:

local Type = {} -- Returned table. Not to be confused with the Types table that contains type matchers.

local ObjectCache = {}

local function TypeCheck(class, property)
	return function(value)
		local object = ObjectCache[class]

		if not object then
			object = Instance.new(class)
			ObjectCache[class] = object
		end

		local success = pcall(function() object[property] = value end)
		return success
	end
end

local Types = {
	-- Types that can be checked with the TypeCheck functor
	["Axes"] = TypeCheck("ArcHandles", "Axes");
	["BrickColor"] = TypeCheck("BrickColorValue", "Value");
	["CFrame"] = TypeCheck("CFrameValue", "Value");
	["Color3"] = TypeCheck("Color3Value", "Value");
	["ColorSequence"] = TypeCheck("ParticleEmitter", "Color");
	["Faces"] = TypeCheck("Handles", "Faces");
	["Instance"] = TypeCheck("Folder", "Parent"); -- Parent cannot be set to anything other than an Instance
	["NumberRange"] = TypeCheck("ParticleEmitter", "Lifetime");
	["NumberSequence"] = TypeCheck("ParticleEmitter", "Size");
	["Ray"] = TypeCheck("RayValue", "Value");
	-- Types that cannot have checkers generated for them (only used in methods) or can be checked without an Instance
	["Region3"] = function(value)
		success = pcall(function() workspace:IsRegion3Empty(value) end)
		return success
	end;
	["Region3int16"] = function(value)
		success = pcall(function() workspace.Terrain:CopyRegion(value) end)
		return success
	end;
	["Vector3int16"] = function(value)
		success = pcall(function() return value + Vector3int16.new(0, 0, 0) end)
		return success
	end;
	["Vector2int16"] = function(value)
		success = pcall(function() return value + Vector2int16.new(0, 0) end)
		return success
	end;
	["UDim"] = function(value)
		success = pcall(function() return value + UDim.new(0, 0) end)
		return success
	end;
	["UDim2"] = function(value)
		success = pcall(function() return value + UDim2.new(0, 0, 0, 0) end)
		return success
	end;
	["Vector2"] = function(value)
		success = pcall(function() return value + Vector2.new(0, 0) end)
		return success
	end;
	["Vector3"] = function(value)
		-- CFrame + Vector3 works, but Vector3 + CFrame does not, meaning this successfully checks Vector3s and doesn't result in false positives for CFrames
		success = pcall(function() return Vector3.new(0, 0, 0) + value end)
		return success
	end;
	["Enum"] = function(value)
		-- hacky; this errors if `value` is not an Enum by calling GetEnumItems with the value instead of Enum.Material (. instead of :)
		success = pcall(function() return Enum.Material.GetEnumItems(value) end)
		return success
	end;
	["EnumItem"] = function(value, enum)
		-- this will be called by GetType without a second argument; we don't need to check this if that's the case.
		if not enum then return end

		for _, item in ipairs(enum:GetEnumItems()) do
			if item == value or item.Name == value or item.Value == value then
				return true
			end
		end

		return false
	end;
}

function Type.GetType(value)
	local luaType = type(value)
	if luaType == "userdata" then
		for name, checker in pairs(Types) do
			if checker(value) then
				return name
			end
		end
	else
		return luaType
	end
end

function Type.IsA(value, typeName)
	return Type.GetType(value) == typeName
end

setmetatable(Type, {
	__index = function(_, index)
		local typeName = index:match("[^Is[A]?]+")
		if Types[typeName] then
			return Types[typeName]
		end
	end;
})

return Type
