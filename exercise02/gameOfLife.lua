dofile("patterns.lua")
---
-- states of the automaton (dead or alive)
DEAD = 1
ALIVE = 2

--DEAD = 1
--ALIVE = 2


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
(life.map) and a legend that we have defined for the model.
After creating the "map" Observer, the function calls the notify 
function of TerraME so that the map Observer shows the initial 
state of the model
]] 

function createMap (life)
	createObserverMap(life.cells, life.legend)
	life.cells:notify(0) 
end

--[[ 
function that creates a Timer (clock) for the "life" model. The Timer
has a single Event which performs three actions at the start of 
a new time cycle (a new tick of the clock):
(a) synchronize the cell space (makes the past equal to the present)
(b) executes the rules of the CA
(c) notifies the observer so we can see the result
]] 

function createTimer (life)
	life.timer = Timer {
		Event{action = function()	
			life.cells:synchronize()
			rules(life)    -- 
			life.cells:notify()
			wait (10) 
		end}
	}
end
--[[ 
function to count the neighbors of a cell that are in a given state
	always reads from the past copy of the CA
]]
function count_neighbors(cell, state)
	count = 0
	forEachNeighbor(cell, function(cell, neighbor)
		if neighbor.past.state == state then
			count = count + 1
		end
	end)
	return count
end


--[[ 
the rules of the game of life
]]

function rules (life)

	forEachCell(life.cells, function(cell)
		neighbors_alive = count_neighbors(cell, ALIVE)
		if neighbors_alive < 2 then
			cell.state = DEAD
		elseif neighbors_alive > 3 then
			cell.state = DEAD
		elseif neighbors_alive == 3 and cell.past.state == DEAD then
			cell.state = ALIVE
		end
	end)
end

--[[ 
initialization - random states (not very interesting)
]]

function initCA (life)

	forEachCell(life.cells, function(cell)
		cell.state = DEAD
	end)
	--life.cells:synchronize()

	life.cells:createNeighborhood{
		strategy = "moore",
		self = false,
		wrap = true
	}
end


--[[
run the CA - execute it for the desired number of iterations
]]

function run (life, time)
	life.timer:execute (time)
end

--[[
create the CA: 
(a) initialize the CA
(b) create an observer
(c) create a timer (clock)
]]
function CellularAutomata(life)

	initCA (life)

	-- create Plot
	createMap (life)

	insert_pattern (life.cells, figureeight(), 3, 3)

	insert_pattern (life.cells, pentadecathlon(), 15, 15)
	
	insert_pattern (life.cells, octagon(), 25, 25)

	insert_pattern (life.cells, pulsar(), 45, 45)

	insert_pattern (life.cells, spaceship(), 65, 65)
	
	insert_pattern (life.cells, oscillator(), 85, 85)
	
	insert_pattern (life.cells, methuselah(), 105, 105)

	-- timer
	createTimer (life)

	return life
end
--[[ 
define the CA (size, legend)
]]
life =  CellularAutomata {
	cells = CellularSpace{ 
		xdim = 50, 
		ydim = 50,
		attribute = {"state"}
	},
	legend = Legend {
		grouping = "uniquevalue",
		colorBar = {
			{value = DEAD, color = "white"},
			{value = ALIVE, color = "black"}
		}
	}
}

-----
run (life, 1200) 



