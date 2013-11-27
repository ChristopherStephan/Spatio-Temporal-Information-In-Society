--[[
function that wait for a certain time - to see the simulation better
]]
function wait(n) 
	for i = 0, n*100000 do io.write("") end -- do nothing 100.000 times
end

-- for more pattern, look at the "oscillators" and the "spaceships"
-- in http://www.conwaylife.com/wiki/Main_Page

function insert_pattern (cs1, cs2, x0, y0)
	for i = 0, (cs2.ydim - 1) do
		for j = 0, (cs2.xdim - 1) do
			local st2 = cs2:getCell(Coord{x = j, y = i}).state
			cs1:getCell(Coord{x=x0 + j ,y = y0 + i}).state = st2
		end
	end
end 

function glider()
	local cs = CellularSpace{ 
		xdim = 3, 
		ydim = 3
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=1,y=0}).state = ALIVE
	cs:getCell(Coord{x=2,y=1}).state = ALIVE
	cs:getCell(Coord{x=0,y=2}).state = ALIVE
	cs:getCell(Coord{x=1,y=2}).state = ALIVE
	cs:getCell(Coord{x=2,y=2}).state = ALIVE

return cs
end

--[[  
Pulsar oscillator in Life 

..OOO...OOO

O....O.O....O
O....O.O....O
O....O.O....O
..OOO...OOO

..OOO...OOO
O....O.O....O
O....O.O....O
O....O.O....O

..OOO...OOO
]]
function pulsar()
	local cs = CellularSpace{ 
		xdim = 13, 
		ydim = 13
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=2,y=0}).state = ALIVE
	cs:getCell(Coord{x=3,y=0}).state = ALIVE
	cs:getCell(Coord{x=4,y=0}).state = ALIVE

	cs:getCell(Coord{x=8,y=0}).state = ALIVE
	cs:getCell(Coord{x=9,y=0}).state = ALIVE
	cs:getCell(Coord{x=10,y=0}).state = ALIVE

	cs:getCell(Coord{x=0,y=2}).state = ALIVE
	cs:getCell(Coord{x=5,y=2}).state = ALIVE
	cs:getCell(Coord{x=7,y=2}).state = ALIVE
	cs:getCell(Coord{x=12,y=2}).state = ALIVE

	cs:getCell(Coord{x=0,y=3}).state = ALIVE
	cs:getCell(Coord{x=5,y=3}).state = ALIVE
	cs:getCell(Coord{x=7,y=3}).state = ALIVE
	cs:getCell(Coord{x=12,y=3}).state = ALIVE

	cs:getCell(Coord{x=0,y=4}).state = ALIVE
	cs:getCell(Coord{x=5,y=4}).state = ALIVE
	cs:getCell(Coord{x=7,y=4}).state = ALIVE
	cs:getCell(Coord{x=12,y=4}).state = ALIVE

	cs:getCell(Coord{x=2,y=5}).state = ALIVE
	cs:getCell(Coord{x=3,y=5}).state = ALIVE
	cs:getCell(Coord{x=4,y=5}).state = ALIVE

	cs:getCell(Coord{x=8,y=5}).state = ALIVE
	cs:getCell(Coord{x=9,y=5}).state = ALIVE
	cs:getCell(Coord{x=10,y=5}).state = ALIVE

	cs:getCell(Coord{x=2,y=7}).state = ALIVE
	cs:getCell(Coord{x=3,y=7}).state = ALIVE
	cs:getCell(Coord{x=4,y=7}).state = ALIVE

	cs:getCell(Coord{x=8,y=7}).state = ALIVE
	cs:getCell(Coord{x=9,y=7}).state = ALIVE
	cs:getCell(Coord{x=10,y=7}).state = ALIVE

	cs:getCell(Coord{x=0,y=8}).state = ALIVE
	cs:getCell(Coord{x=5,y=8}).state = ALIVE
	cs:getCell(Coord{x=7,y=8}).state = ALIVE
	cs:getCell(Coord{x=12,y=8}).state = ALIVE

	cs:getCell(Coord{x=0,y=9}).state = ALIVE
	cs:getCell(Coord{x=5,y=9}).state = ALIVE
	cs:getCell(Coord{x=7,y=9}).state = ALIVE
	cs:getCell(Coord{x=12,y=9}).state = ALIVE

	cs:getCell(Coord{x=0,y=10}).state = ALIVE
	cs:getCell(Coord{x=5,y=10}).state = ALIVE
	cs:getCell(Coord{x=7,y=10}).state = ALIVE
	cs:getCell(Coord{x=12,y=10}).state = ALIVE

	cs:getCell(Coord{x=2,y=12}).state = ALIVE
	cs:getCell(Coord{x=3,y=12}).state = ALIVE
	cs:getCell(Coord{x=4,y=12}).state = ALIVE

	cs:getCell(Coord{x=8,y=12}).state = ALIVE
	cs:getCell(Coord{x=9,y=12}).state = ALIVE
	cs:getCell(Coord{x=10,y=12}).state = ALIVE

return cs
end

--[[ Figure-eight oscillator in Life 

OO
OO.O
....O
.O
..O.OO
....OO
]]

function figureeight()
	local cs = CellularSpace{ 
		xdim = 6, 
		ydim = 6
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=0,y=0}).state = ALIVE
	cs:getCell(Coord{x=1,y=0}).state = ALIVE

	cs:getCell(Coord{x=0,y=1}).state = ALIVE
	cs:getCell(Coord{x=1,y=1}).state = ALIVE
	cs:getCell(Coord{x=3,y=1}).state = ALIVE

	cs:getCell(Coord{x=4,y=2}).state = ALIVE

	cs:getCell(Coord{x=1,y=3}).state = ALIVE

	cs:getCell(Coord{x=2,y=4}).state = ALIVE
	cs:getCell(Coord{x=4,y=4}).state = ALIVE
	cs:getCell(Coord{x=5,y=4}).state = ALIVE

	cs:getCell(Coord{x=4,y=5}).state = ALIVE
	cs:getCell(Coord{x=5,y=5}).state = ALIVE


return cs
end
--[[ 
...OO
..O..O
.O....O
O......O
O......O
.O....O
..O..O
...OO

]]

function octagon()
	local cs = CellularSpace{ 
		xdim = 8, 
		ydim = 8
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=3,y=0}).state = ALIVE
	cs:getCell(Coord{x=4,y=0}).state = ALIVE

	cs:getCell(Coord{x=2,y=1}).state = ALIVE
	cs:getCell(Coord{x=5,y=1}).state = ALIVE

	cs:getCell(Coord{x=1,y=2}).state = ALIVE
	cs:getCell(Coord{x=6,y=2}).state = ALIVE

	cs:getCell(Coord{x=0,y=3}).state = ALIVE
	cs:getCell(Coord{x=7,y=3}).state = ALIVE

	cs:getCell(Coord{x=0,y=4}).state = ALIVE
	cs:getCell(Coord{x=7,y=4}).state = ALIVE

	cs:getCell(Coord{x=1,y=5}).state = ALIVE
	cs:getCell(Coord{x=6,y=5}).state = ALIVE

	cs:getCell(Coord{x=2,y=6}).state = ALIVE
	cs:getCell(Coord{x=5,y=6}).state = ALIVE
	
	cs:getCell(Coord{x=3,y=7}).state = ALIVE
	cs:getCell(Coord{x=4,y=7}).state = ALIVE

return cs
end

--[[ 
..O....O
OO.OOOO.OO
..O....O
]]

function pentadecathlon()

	local cs = CellularSpace{ 
		xdim = 10, 
		ydim = 3
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=2,y=0}).state = ALIVE
	cs:getCell(Coord{x=7,y=0}).state = ALIVE

	cs:getCell(Coord{x=0,y=1}).state = ALIVE
	cs:getCell(Coord{x=1,y=1}).state = ALIVE
	cs:getCell(Coord{x=3,y=1}).state = ALIVE
	cs:getCell(Coord{x=4,y=1}).state = ALIVE
	cs:getCell(Coord{x=5,y=1}).state = ALIVE
	cs:getCell(Coord{x=6,y=1}).state = ALIVE
	cs:getCell(Coord{x=8,y=1}).state = ALIVE
	cs:getCell(Coord{x=9,y=1}).state = ALIVE

	cs:getCell(Coord{x=2,y=2}).state = ALIVE
	cs:getCell(Coord{x=7,y=2}).state = ALIVE
return cs
end

--[[
.OO
OO
.O
]]

function rpentomino()
	local cs = CellularSpace{ 
		xdim = 3, 
		ydim = 3
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=1,y=0}).state = ALIVE
	cs:getCell(Coord{x=2,y=0}).state = ALIVE
	cs:getCell(Coord{x=0,y=1}).state = ALIVE
	cs:getCell(Coord{x=1,y=1}).state = ALIVE
	cs:getCell(Coord{x=1,y=2}).state = ALIVE

return cs
end

--LWSS - The smallest known orthogonally moving spaceship
--[[
.O..O
O
O...O
OOOO
]]
function spaceship()
	local cs = CellularSpace{ 
		xdim = 5, 
		ydim = 4
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=1,y=0}).state = ALIVE
	cs:getCell(Coord{x=4,y=0}).state = ALIVE
	cs:getCell(Coord{x=0,y=1}).state = ALIVE
	cs:getCell(Coord{x=0,y=2}).state = ALIVE
	cs:getCell(Coord{x=4,y=2}).state = ALIVE
	cs:getCell(Coord{x=0,y=3}).state = ALIVE
	cs:getCell(Coord{x=1,y=3}).state = ALIVE
	cs:getCell(Coord{x=2,y=3}).state = ALIVE
	cs:getCell(Coord{x=3,y=3}).state = ALIVE

return cs
end

-- Blinker - The smallest and most common oscillator.
-- OOO

function oscillator()
	local cs = CellularSpace{ 
		xdim = 4, 
		ydim = 3
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=0,y=0}).state = ALIVE
	cs:getCell(Coord{x=1,y=0}).state = ALIVE
	cs:getCell(Coord{x=2,y=0}).state = ALIVE
	
return cs
end

-- Century - A methuselah with lifespan of 103.
--[[
..OO
OOO
.O
]]
function methuselah()
	local cs = CellularSpace{ 
		xdim = 4, 
		ydim = 3
	}
	forEachCell(cs, function(cell)
		cell.state = DEAD
	end)

	cs:getCell(Coord{x=2,y=0}).state = ALIVE
	cs:getCell(Coord{x=3,y=0}).state = ALIVE
	cs:getCell(Coord{x=0,y=1}).state = ALIVE
	cs:getCell(Coord{x=1,y=1}).state = ALIVE
	cs:getCell(Coord{x=2,y=1}).state = ALIVE
	cs:getCell(Coord{x=1,y=2}).state = ALIVE
	

return cs
end
