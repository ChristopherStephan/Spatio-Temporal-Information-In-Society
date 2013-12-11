CELL_SPACE_DIM = 50
SOCIETY_DIM = 500

PROP_UPHILL = 0.9

EMPTY = -1995
OCCUPIED = -999

GROUND_LEVEL = 0 --
MAX_SUMMIT_HIGHT = 15


function createMap (cellspace)

	legend = Legend { 
  		grouping = "equalsteps", 
 		slices = MAX_SUMMIT_HIGHT, 
  		colorBar = { 
   			{value = GROUND_LEVEL, color = "white"}, 
   			{value = MAX_SUMMIT_HIGHT - 1, color = "black"}
 		}
 	}
 	
 	legend2 = Legend {
 		grouping = "uniquevalue",
 		colorBar = {
  			{value = OCCUPIED, color = "red"},
  			{value = EMPTY, color ="white"}
 		}
 	}

	
	map = Observer {
		type = "map",
		subject     = cellspace,
		attributes  = {"elevation", "butterfly"},
		legends = {legend, legend2}
	}
end

function createHill (cellspace, x, y, summitHeight)
	level = 1
	while summitHeight ~= 0 do
		for i = -summitHeight, summitHeight do
			for j = -summitHeight, summitHeight do
				cellspace:getCell(Coord{x = y - i, y = y - j}).elevation = level
			end
		end
		summitHeight = summitHeight - 1
		level = level + 1
	end
end

	
function createCellSpace(model)

	model.cellspace = CellularSpace {
				xdim = model.cellSpaceDim,
				ydim = model.cellSpaceDim
	}
	
	model.cellspace:createNeighborhood{
		self = false,
		strategy = "moore"
	}

	forEachCell(model.cellspace, function(cell)
		 cell.elevation = GROUND_LEVEL
		 cell.butterfly = EMPTY
	end)
	
	createHill(model.cellspace, 11, 35, 13)
	createHill(model.cellspace, 36, 10, 10)

end


function goUphill(agent)
	r = math.random()
	if r < PROP_UPHILL then
		forEachNeighbor(agent:getCell(), function(cell, neighbor)
			if neighbor.elevation > agent:getCell().elevation then
				agent:move(neighbor)
				agent:getCell().butterfly = OCCUPIED
			else
				agent:randomWalk()
				agent:getCell().butterfly = OCCUPIED
			end
		end)
	else 
		agent:randomWalk()
		agent:getCell().butterfly = OCCUPIED	
	end
end


function createAgent (model)
	model.family = Agent {
		init = function(self)
		end,
	
		execute = function(self)
			local halfedSocietyDim = math.floor(model.cellSpaceDim / 2)
			local halfedSocietyDim = math.floor(model.cellSpaceDim / 2)
			local center = Coord{ x = halfedSocietyDim - 2, y = halfedSocietyDim-2} 
			model.center = model.cellspace:getCell(center)
			self:move(model.center)
			goUphill(self) 
		end
	}
end

function createSociety (model)
	model.society = Society{
		instance = model.family,
		quantity = model.societyDim
	}
end


function createEnvironment (model)
	model.env = Environment {model.cellspace, model.society}
	-- consider changing the max when multiple butterflies lives in one cell
	model.env:createPlacement{strategy = "void", max = 1}				
end


function run (model)
	forEachAgent(model.society, function(agent)
		agent:execute()
    	model.cellspace:notify()
	end)	
end

function AgentModel(model)
	createCellSpace(model)
	createAgent(model)
	createSociety(model)
	createEnvironment(model)
	createMap(model.cellspace)

	return model
end


model = AgentModel {
	cellSpaceDim  =  CELL_SPACE_DIM,
	societyDim    =  SOCIETY_DIM
}

run(model)
