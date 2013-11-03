-- Implement a function that gets a list of integer numbers
-- and a number n and prints all the values smaller than n.

local function list(array, max)
        for i=1, #array do
                if array[i] < max then
                        print(array[i])
                end
        end
end

list({1,7,2,3,0,6}, 4)
