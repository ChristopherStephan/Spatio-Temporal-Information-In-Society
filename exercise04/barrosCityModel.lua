EMPTY  = 0  

-- agents are divided in economic groups (breeds)
LOW_INCOME = 1
MEDIUM_INCOME = 2
HIGH_INCOME = 3

-- proportion of each economic group
PROP_LOW = 0.5    
PROP_MEDIUM = 0.4 
PROP_HIGH  = 0.1 

CELL_SPACE_DIM = 45 -- size of the cell space
SOCIETY_DIM = 800 -- amount of agents

function createMap (cellspace)
	leg = Legend {
		grouping = "uniquevalue",
		colorBar = {
			{value = EMPTY, color = "black"},
			{value = LOW_INCOME, color = "blue"},
			{value = MEDIUM_INCOME,  color = "yellow"},
			{value = HIGH_INCOME,  color = "red"}
		}
	}
	
	map = Observer {
		type = "map",
		subject     = cellspace,
		attributes  = {"state"},
		legends = {leg}
	}
end


function createCellSpace(model)

	model.cellspace = CellularSpace {
				xdim = model.cellSpaceDim,
				ydim = model.cellSpaceDim
	}
	
	model.cellspace:createNeighborhood{
		strategy = "moore",
		self = false
	}

	forEachCell(model.cellspace, function(cell)
			cell.state = EMPTY
	end)
end

-- recursive function
function findPlace(agent)

	local foundPlace = false
	repeat		
		place  = agent:getCell():getNeighborhood():sample()
		agent:move(place) 
		occupants = place:getAgents()
		
		if #(occupants) == 1 then
			place.state = agent.economicGroup
			foundPlace = true
		else
			forEachAgent(place, function(occupant)
				if (occupant.economicGroup < agent.economicGroup) then
					place.state = agent.economicGroup
					findPlace(occupant)
					foundPlace = true
				end
			end)
		end
	until foundPlace   
end


function createAgent (model)

	model.family = Agent {
		init = function(self)
			randomValue = math.random()
			if randomValue < PROP_LOW then
				self.economicGroup = LOW_INCOME
			elseif randomValue < (PROP_LOW + PROP_MEDIUM) then
				self.economicGroup = MEDIUM_INCOME
			else 
				self.economicGroup = HIGH_INCOME
			end
		end,
	
		execute = function(self)
			local halfedSocietyDim = math.floor(model.cellSpaceDim / 2)
			local center = Coord{ x = halfedSocietyDim, y = halfedSocietyDim} 
			model.center = model.cellspace:getCell(center)
			self:enter(model.center)
			findPlace(self) 
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
	model.env:createPlacement{strategy = "void", max = 1}				
end


function createTimer (model)
	model.timer = Timer {
		Event {time = 1, period = 1, action = model.society},
		Event {time = 1, period = 1, action = model.cellspace}
	}
end 


function AgentModel(model)
	createCellSpace (model)
	createAgent (model)
	createSociety (model)
	createEnvironment (model)
	createTimer (model)
	createMap (model.cellspace)
	
	return model
end


model = AgentModel {
	cellSpaceDim  =  CELL_SPACE_DIM,
	societyDim    =  SOCIETY_DIM
}

function run (model, time)
	model.timer:execute (time)
	
	forEachAgent(model.society, function(agent)
		agent:execute()
	 	model.cellspace:notify()
	end)
end

run(model, 0)
