--[[
Generic Utility functions 
These function can be reused - they are pure Lua functions 
]]

local luafunc ={}
luafunc.version="1.0"

--[[  Parameters for the LCG random number generator ]]

luafunc.LCGprevious   = tonumber(tostring(os.time()):reverse():sub(1,6))
luafunc.LCGnext       = 0
luafunc.LCGmodulus    = 2^31 - 1
luafunc.LCGmultiplier = 48271   -- MINSTD
luafunc.LCGincrement  = 0
--[[

A linear congruential generator (LCG) is an algorithm that yields a sequence of 
randomized numbers calculated with a linear equation. 
The method represents one of the oldest and best-known pseudorandom number generator algorithms
]]
function luafunc.randomLCG (min, max)
    luafunc.LCGnext = (luafunc.LCGmultiplier*luafunc.LCGprevious + luafunc.LCGincrement) % luafunc.LCGmodulus 
	local rand = (luafunc.LCGnext % (max - min + 1)) + min  
	luafunc.LCGprevious = luafunc.LCGnext
	return rand
end

--[[
	Wait some time before the next iteration 
	to help visualize the model better
]]
function luafunc.wait(n)
	for i = 0, n*100000 do io.write("") end -- do nothing 100.000 times
end

--[[ 
	Find out if an element is one of the values of a table
]]
function luafunc.isOneOf(element, table)
  	for k, v in ipairs(table) do
    	if v == element then
      	return true
    	end
  	end
  	return false
end

--[[ find minimum and maximum keys of a table ]]
function luafunc.minmaxKeys (tab)
    local max = -math.huge
    local min = math.huge

    for k,v in pairs ( tab ) do
        max= math.max( max, k )
        min= math.min( min, k )
    end
    assert (min <= max,  "minmax: range of values is not valid")
return min, max
end

--[[ find minimum and maximum values of a table ]]
function luafunc.minmaxVals (tab)
    local max = -math.huge
    local min = math.huge

    for k,v in pairs ( tab ) do
        max= math.max( max, v )
        min= math.min( min, v )
    end
    assert (min <= max,  "minmax: range of values is not valid")
return min, max
end

--[[
  print values of a lua Table
]]
function luafunc.printTab (luaTable)
    for key,val in pairs(luaTable) do
        if type(val) == 'table' then
            printTab (val)
        end
        print (key, value)
    end
    return newTable
end

--[[
  Clone a lua Table
]]
function luafunc.clone (luaTable)
    local newTable = {}
    for key,val in pairs(luaTable) do
        if type(val) == 'table' then
            val = clone (val)
        end
        newTable [key] = val
    end
    return newTable
end
--[[
  Count the occurences of an element in a table
]]
function luafunc.table_count(tab, elem)
    local count
    count = 0
    for k,v in pairs(tab) do
        if elem == v then count = count + 1 end
    end
    return count
end
--[[
  Calculate a cumulative distribution function 
]]
function luafunc.distribution (tab)
    assert (#tab >= 1, "distribution: number of entries is positive")
    table.sort (tab) 

    min, max = luafunc.minmaxVals (tab)
    assert (min >= 1, "distribution: minimum value should be greater than 1")

    local dist = {}
    for elem = 1, max do
        dist[elem] = luafunc.table_count (tab, elem) 
    end

return dist 
end 
--[[
  Calculate a histogram
]]

function luafunc.histogram (tab, steps)
    assert (steps > 0, "histogram: steps must be a positive integer")
   
    min, max = luafunc.minmaxKeys (tab)
    assert (min >= 1,   "histogram: only works for positive integers")

    step = math.ceil ( max /steps )
    
    local hist = {}
    for i = 1, steps do
        local bin = {}
        bin.min = (i - 1)*step + 1
        bin.max = i*step 
        bin.num = 0 
        for k, v in pairs (tab) do
            if (k >= bin.min) and (k <= bin.max) then bin.num = bin.num + v end
        end
        hist[i] = bin
    end
return hist
end

function luafunc.histogramAxis (hist)

    local xAxis = {}
    local yAxis = {}
    for i = 1, #hist do
        xAxis[i] = hist[i].min
        yAxis[i] = hist[i].num
    end
return xAxis, yAxis
end

--[[
    Save a histogram as a CSV file
]]
function luafunc.saveHistogram(histogram, filename)
    fh = io.open (filename, "w")

    fh:write("min; max; value","\n")
    for k, v in ipairs(histogram) do
        fh:write(v.min, "; ", v.max,"; ", v.num,"\n")
    end
    fh:close()
end

--[[
    Calculate the Gini Index of table of numeric values
]]
function luafunc.giniIndex (tab)
    assert (#tab > 1, "giniIndex: table with no values")
    table.sort (tab)
    local top = 0
    local bot = 0
    local num = #tab
    for i=1, num do
        top = top + (num + 1 - i)*tab [i]
        bot = bot + tab [i]
    end
    local gindex = ((num + 1 - 2*(top/bot))/num)
return gindex
end

--[[ 
    Test if valid, if not, use a default value
]]

function luafunc.useOneOf ( val, def )
    if (val == nil ) then return def
    else return val end
end

-- replace the values of a table

function luafunc.getDefaults (tab, default)
    for k,v in pairs (default) do
        if tab[k] == nil then tab[k] = v end
    end
end

function luafunc.replaceIfDefined (current, option)
    for k,v in pairs (option) do
            current[k] = v
    end
end

function luafunc.chooseBetween (result, option1, option2)
    for k,v in pairs (option2) do
        if option1[k] ~= nil then
            result[k] = option1[k]
        else 
            result[k] = v
        end
    end
end

--[[ Functional programming in Lua ]]
function luafunc.map (tab, f)
    local mapped = {}
        for k, v in pairs(tab) do
            mapped[k] = f(v)
        end
return mapped
end

return luafunc