--[[
	Module with TerraME Utility functions for cell spaces
	These function can be reused - they have functions that can be used in different TerraME models
]]
local luafunc = require ("luafunc")
local cellfunc = {}
cellfunc.version="1.0"

--[[ 
	Manhattan distance
]]
function cellfunc.cityBlockDistance (cell1, cell2)
	return math.abs(cell1.x - cell2.x) + math.abs (cell1.y - cell2.y)
end

--[[  
	Get an random cell in the cell space that is not occupied by any other agent
]]
function cellfunc.findEmptyRandomCell (cellspace)
	found = false
	while not found do
		icell = luafunc.randomLCG (1, cellspace:size())   -- get a random cell index
		cell = cellspace:getCells()[icell]        -- get a random cell
		if (#(cell:getAgents()) == 0 ) then       -- is the cell empty? 
			found = true
		end
	end
return cell
end

--[[
	Create a rook neighborhood of a given length
	The cellspace is a torus, so side cells are connected.
]]

function cellfunc.createRookNeighborhood(cellspace, length, dim)
	-- length: size of neighborhood in cells (von neumann has a size of 1)
	-- dim   : dimension of the cell space
	assert (length >= 1,   "createRookNeighborhood: length is not a positive integer")
	assert (2*length < dim, "createRookNeighborhood: neighboorhood size is greater then cellspace dimension")

	-- TerraME requires a neighbor to have a weigth
	local weight = 1  	
	-- choose a name associated with the length 
	-- TerraME neighborhoods are indexed as strings
	name = string.format ("%d", length)

	-- build the rook neighborhood of size "length"
	for i, cell in ipairs(cellspace.cells) do
		local neigh = Neighborhood()
		for lin = -length, length do 
			for col = -length, length do
					if (lin == 0 or col == 0) and lin ~= col then
						local index = Coord{x = (cell.x + col) % dim, y = (cell.y + lin) % dim}
						neigh:addCell(index, cellspace, weight)
					end
			end
		end
		-- add the neighborhood to each cell
		cell:addNeighborhood(neigh, name)
	end
end

-- find path between cells of the same cell space
function cellfunc.findStraigthPath(cell1, cell2)
	assert (cell1.x == cell2.x or cell1.y == cell2.y, "no straigthPath between cells")
	local path = {}
	if  (cell1.x == cell2.x) then   -- same collumn
		local distY = cell2.y - cell1.y
		if (distY > 0) then step = 1 else step = -1 end
		for i = step, distY, step do
			local c = Coord {x = cell1.x, y = cell1.y + i}
			table.insert (path, c)
		end
	else    -- cells on the same line
		local distX = cell2.x - cell1.x
		if (distX > 0) then step = 1 else step = -1 end
		for i = step, distX, step do
			local c = Coord {x = cell1.x + i, y = cell1.y}
			table.insert (path, c)
		end
	end
return path
end

--[[ 
    read a cellspace from a file 
]]

function cellfunc.readCellSpaceFromTxtFile(argv)
 	-- create a cellular space from a text file
 	-- xdim: horizontal dimension of the cell space
 	-- ydim: vertical dimension of the cell space
 	-- attr_name: name of the attribute to be read from text file
 	-- txtfile: text file - MUST have EXACTLY ydim lines
 	-- charsize: size of each character to be read
 	-- whitespaces: number of whitespaces between characters

	local cs = CellularSpace {
		xdim = argv.xdim,
		ydim = argv.ydim
	}
	local iline = 0
	for line in io.lines(argv.txtfile) do
		assert (#line == (argv.xdim*(argv.charsize + argv.whitespaces) - 1), "readCellSpaceFromTxtFile: wrong input")
		icol  = 0 		
		ichar = 1
		repeat
			local place = Coord { x = icol, y = iline } -- TerraME arrays start at 0, Lua's at 1 
			cs:getCell(place)[argv.attr_name] = tonumber (string.sub (line, ichar, ichar + argv.charsize - 1))
			icol = icol + 1
			ichar = ichar + argv.charsize + argv.whitespaces
		until ichar > #line
		iline = iline + 1
	end
return cs
end

return cellfunc
