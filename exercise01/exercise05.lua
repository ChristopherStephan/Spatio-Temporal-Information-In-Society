-- Write a Lua function that calculates the factorial
-- of a number n (the product of all numbers equals or smaller than n.

local function factorial(n)
        if n == 0 then
                return 1
        else
                return n * factorial(n-1)
        end
end

print(factorial(4))
