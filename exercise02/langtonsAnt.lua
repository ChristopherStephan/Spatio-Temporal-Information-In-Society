-- states of the automaton (black or white)

WHITE = 1
BLACK = 2

-- encoding directions
WEST = 3
NORTH = 4
SOUTH = 5 
EAST = 6

-- initial parameters
heading = NORTH
antPosition = Coord{x = 35, y = 40}

--[[function that creates an observer to show the cellular automaton
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

--[[function that creates a "map" Observer based on a cellular space 
(langtonsAnt.map) and a legend that we have defined for the model.
After creating the "map" Observer, the function calls the notify 
function of TerraME so that the map Observer shows the initial 
state of the model
]] 

function createMap (langtonsAnt)
	createObserverMap(langtonsAnt.cells, langtonsAnt.legend)
	langtonsAnt.cells:notify(0) 
end

--[[ 
function that creates a Timer (clock) for the "langtonsAnt" model. The Timer
has a single Event which performs three actions at the start of 
a new time cycle (a new tick of the clock):
(a) synchronize the cell space (makes the past equal to the present)
(b) executes the rules of the CA
(c) notifies the observer so we can see the result
]] 

function createTimer (langtonsAnt)
	langtonsAnt.timer = Timer {
		Event{action = function()	
			langtonsAnt.cells:synchronize()
			rules(langtonsAnt)    -- 
			langtonsAnt.cells:notify()
			-- wait (10) 
		end}
	}
end


-- rules for ant movement
function rules (langtonsAnt)

	if (langtonsAnt.cells:getCell(antPosition).state == WHITE) then
		if (heading == NORTH) then
			heading = EAST
			langtonsAnt.cells:getCell(antPosition).state = BLACK
			antPosition:set{x = antPosition:get().x + 1, y = antPosition:get().y}
			return
		elseif (heading == SOUTH) then
			heading = WEST
			langtonsAnt.cells:getCell(antPosition).state = BLACK
			antPosition:set{x = antPosition:get().x - 1, y = antPosition:get().y}
			return
		elseif (heading == EAST) then
			heading = SOUTH
			langtonsAnt.cells:getCell(antPosition).state = BLACK
			antPosition:set{x = antPosition:get().x, y = antPosition:get().y + 1}
			return
		elseif (heading == WEST) then
			heading = NORTH
			langtonsAnt.cells:getCell(antPosition).state = BLACK
			antPosition:set{x = antPosition:get().x , y = antPosition:get().y - 1}
			return
		end
		
		
	elseif (langtonsAnt.cells:getCell(antPosition).state == BLACK) then
		if (heading == NORTH) then
			heading = WEST
			langtonsAnt.cells:getCell(antPosition).state = WHITE
			antPosition:set{x = antPosition:get().x - 1, y = antPosition:get().y}
			return
		elseif (heading == SOUTH) then
			heading = EAST
			langtonsAnt.cells:getCell(antPosition).state = WHITE
			antPosition:set{x = antPosition:get().x + 1, y = antPosition:get().y}
			return
		elseif (heading == EAST) then
			heading = NORTH
			langtonsAnt.cells:getCell(antPosition).state = WHITE
			antPosition:set{x = antPosition:get().x , y = antPosition:get().y - 1}
			return
		elseif (heading == WEST) then
			heading = SOUTH
			langtonsAnt.cells:getCell(antPosition).state = WHITE
			antPosition:set{x = antPosition:get().x, y = antPosition:get().y + 1}
			return
		end
	end
		
	-- print("Cell with undefined state.")	
end

-- set starting point of ant
function initCA (langtonsAnt)

	forEachCell(langtonsAnt.cells, function(cell)
		cell.state = WHITE
	end)
	

	--langtonsAnt.cells:synchronize()
	langtonsAnt.cells:createNeighborhood{
		strategy = "moore",
		self = false,
		wrap = true
	}
end

--run the CA - execute it for the desired number of iterations
function run (langtonsAnt, time)
	langtonsAnt.timer:execute(time)
end


function CellularAutomata(langtonsAnt)

	initCA(langtonsAnt)

	-- create Plot
	createMap(langtonsAnt)
	
	-- timer
	createTimer(langtonsAnt)

	return langtonsAnt
end

--define the CA (size, legend) 
langtonsAnt =  CellularAutomata {
	cells = CellularSpace{ 
		xdim = 80, 
		ydim = 80,
		attribute = {"state"}
	},
	legend = Legend {
		grouping = "uniquevalue",
		colorBar = {
			{value = WHITE, color = "white"},
			{value = BLACK, color = "black"}
		}
	}
}

function wait(n) 
	for i = 0, n*100000 do io.write("") end -- do nothing 100.000 times
end

-----
run (langtonsAnt, 12000) 
