-- Implement a function that takes an integer value
-- as argument and invert the order of its numerals.

local function invert(integer)
        return tonumber(string.reverse(tostring(integer)))
end

print(invert(531))
