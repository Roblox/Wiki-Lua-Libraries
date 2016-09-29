-- The Levenshtein module allows you to calculate the Levenshtein edit distance between two strings.
-- For example, the Levenshtein distance between "cot" and "cost" is 1, because you need to make one
-- change to "cot" (specifically, inserting 's' between 'o' and 't') to get "cost".
local function Levenshtein(a, b)
	-- Easy cases
	-- Levenshtein distance when the two are equal is always 0
	if a == b then
		return 0
	end

	local aLength = #a
	local bLength = #b

	-- If the strings are empty, use the length of the counterpart
	if aLength == 0 then
		return bLength
	end

	if bLength == 0 then
		return aLength
	end

	-- Inline some heavily-used functions to improve the inner loop's performance
	local substring = string.sub
	local min = math.min

	-- These are the two rows that we care about
	-- Traditional implementations of Wagner-Fischer use a full matrix
	-- This is unnecessary if the only objective is to retrieve the edit distance.
	-- If the goal is the edit distance alone, we only need to know the last and current rows. 
	local last = {}
	local current = {}

	-- Initialize the starting state of the last row, starting from 0.
	for i = 1, bLength + 1 do
		last[i] = i - 1
	end

	-- For each character in the first string...
	for charA = 1, aLength do
		-- Initialize current to the value of i.
		current[1] = charA

		-- For each character in the second string
		for charB = 1, bLength do
			-- If the two characters differ, we're performing an operation, be it substitution, deletion, or addition.
			if substring(a, charA, charA) ~= substring(b, charB, charB) then
				current[charB + 1] = min(
					current[charB] + 1, -- Insertion
					last[charB + 1] + 1, -- Deletion
					last[charB] + 1 -- Substitution
				)
			-- If they're the same, the edit distance hasn't changed and we can use the one from the previous column and row.
			else
				current[charB + 1] = last[charB]
			end
		end

		-- Overwrite the last row with the current row when we're done.
		-- We don't swap the tables because that would create a new table, with all its allocation and resizing costs.
		for i = 1, bLength + 1 do
			last[i] = current[i]
		end
	end

	-- The final edit distance will be the value in the final column of the final row.
	return current[bLength + 1]
end

return Levenshtein