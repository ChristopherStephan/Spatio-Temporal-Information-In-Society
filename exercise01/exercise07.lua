-- Write a Lua function that calculates the 50 first Fibonnaci numbers,
-- defined as F(n) = F(n-­‐1) + F(n-­‐2) with F(0) = 0 and F(1) = 1.

local function fibonacci(number)
        if number > 1 then
                number = fibonacci(number - 1) + fibonacci(number - 2)
        end
        return number
end

print(fibonacci(7))
