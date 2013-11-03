-- Given a list of integers, write a Lua function
-- that extracts all odd numbers from it.

local function odds(list)
        for i=1, #list do
                if (list[i] % 2) ~= 0 then
                        print(list[i])
                end
        end
end

odds({1,7,2,3,0,6})
