-- Write a Lua function that calculates all integers that are dividers of n.

local function dividers(int)
        for i=1, int do
                if (int % i) == 0 then
                 print(i)
                end
        end
end

print(dividers(4))          

