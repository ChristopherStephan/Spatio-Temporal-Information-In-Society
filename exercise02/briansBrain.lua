-- states of a cell
ON = 1
OFF = 2
DYING = 3


--[[
function that creates an observer to show the cellular automaton
this function follows the TerraME syntax for creating a "map" observer
please look at the TerraME documentation for "Observer"
]]

function createObserverMap (cells, legend)
	Observer {
		subject     = cells,
		attributes  = cells.attribute,
		legends     = {legend},
		type = "map"
	}
end

--[[ 
function that creates a "map" Observer based on a cellular space 
(briansBrain.map) and a legend that we have defined for the model.
After creating the "map" Observer, the function calls the notify 
function of TerraME so that the map Observer shows the initial 
state of the model
]] 

function createMap (briansBrain)
	createObserverMap(briansBrain.cells, briansBrain.legend)
	briansBrain.cells:notify(0) 
end

--[[ 
function that creates a Timer (clock) for the "briansBrain" model. The Timer
has a single Event which performs three actions at the start of 
a new time cycle (a new tick of the clock):
(a) synchronize the cell space (makes the past equal to the present)
(b) executes the rules of the CA
(c) notifies the observer so we can see the result
]] 

function createTimer (briansBrain)
	briansBrain.timer = Timer {
		Event{action = function()	
			briansBrain.cells:synchronize()
			rules(briansBrain)    -- 
			briansBrain.cells:notify()
			wait (100) 
		end}
	}
end
--[[ 
helper function to find out if a cell has exactly two cells with the state ON
]]
function hasTwoNeighborsOn(cell)
	count = 0
	forEachNeighbor(cell, function(cell, neighbor)
		if neighbor.state == ON then
			count = count + 1
		end
	end)

	if (count == 2) then 
		return true
	end
	
	return false
end


--[[ 
the rules of the Brian's Brain
]]

function rules (briansBrain)
	forEachCell(briansBrain.cells, function(cell)
		if(cell.state == OFF and hasTwoNeighborsOn(cell)) then
			cell.state = ON
			return
		end
		if(cell.state == ON) then
			cell.state = DYING
			return
		end
		if(cell.state == DYING) then
			cell.state = OFF
			return
		end
	end)
end

--[[ 
initialization - random states (not very interesting)
]]

function initCA (briansBrain)

	forEachCell(briansBrain.cells, function(cell)
		cell.state = math.random(1, 3)
	end)
	--briansBrain.cells:synchronize()

	briansBrain.cells:createNeighborhood{
		strategy = "moore",
		self = false,
		wrap = true
	}
end


--[[
run the CA - execute it for the desired number of iterations
]]

function run (briansBrain, time)
	briansBrain.timer:execute (time)
end

--[[
create the CA: 
(a) initialize the CA
(b) create an observer
(c) create a timer (clock)
]]
function CellularAutomata(briansBrain)

	initCA (briansBrain)

	-- create Plot
	createMap (briansBrain)

	-- timer
	createTimer (briansBrain)

	return briansBrain
end
--[[ 
define the CA (size, legend)
]]
briansBrain =  CellularAutomata {
	cells = CellularSpace{ 
		xdim = 150, 
		ydim = 150,
		attribute = {"state"}
	},
	legend = Legend {
		grouping = "uniquevalue",
		colorBar = {
			{value = ON, color = "white"},
			{value = OFF, color = "black"},
			{value = DYING, color = "red"}
		}
	}
}

--[[
function that wait for a certain time - to see the simulation better
]]
function wait(n) 
	for i = 0, n*100000 do io.write("") end -- do nothing 100.000 times
end

-----
run (briansBrain, 120000) 



