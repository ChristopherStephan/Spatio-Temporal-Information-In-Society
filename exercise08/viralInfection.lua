--[[
@author 	Christopher Stephan
@copyright	Christopher Stephan 2014

This is a cellular automaton model of a viral infection
that has been developed and described in the following 
paper:

A simple cellular automaton model for influenza A viral infections
Catherine Beauchemin, John Samuel, Jack Tuszynski

Please find the rules either in the source or in the comments
given in line.
--]]

GRID_WIDTH 		= 50	-- Width of the grid
GRID_HEIGHT 		= 50	-- Height of the grid
CELL_LIFESPAN		= 380	-- Lifespan of a healthy epithelial cell
INFECT_INIT 		= 0.3 	-- Fraction of initially infected cells, increased for better visualization (former 0.01 )
IMM_LIFESPAN		= 168 	-- Lifespan of an immune cell
BASE_IMM_CELL		= 0.3	-- Minimum density of virgin immune cells / number of agents / society
RECRUITMENT		= 0.25 	-- Number of immune cells recruited upon positive recognition
RECRUIT_DELAY		= 7		-- Delay between recruitment call and addition of immune cells
INFECT_RATE  		= 2 	-- The number of its neighbors that an infectious cell will infect per hour
EXPRESS_DELAY 		= 4		-- Delay from infected to viral expression
INFECT_DELAY 		= 6		-- Delay from infected to infectious
INFECT_LIFESPAN 	= 24  	-- Lifespan of an infected epithelial cell
DIVISION_TIME 		= 12 	-- Duration of an epithelial cell division


-- display states
HEALTHY		= 0
INFECTED	= 1
EXPRESSING	= 2
INFECTIOUS	= 3
DEAD 		= 4

-- states for immun cells
VIRGIN 		= 5
MATURE 		= 6

function wait(n)
	for i = 0, n*100000 do io.write("") end -- do nothing 100.000 times
end

function createMap (cellspace)
	leg = Legend {
		grouping = "uniquevalue",
		colorBar = {
			{value = HEALTHY, 		color = "white"},
			{value = INFECTED, 	color = "yellow"},
			{value = EXPRESSING,  	color = "cyan"},
			{value = INFECTIOUS,	color = "red"},
			{value = DEAD, 			color = "black"}
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
				xdim = model.cellSpaceDimWidth,
				ydim = model.cellSpaceDimHeight
	}
	
	model.cellspace:createNeighborhood{
		strategy = "moore",
		self = false
	}

	forEachCell(model.cellspace, function(cell)
		-- A simulation is initialized with each epithelial cell being
		-- assigned a random age between 0 and CELL_LIFESPAN inclusively
		cell.age = math.random(0, CELL_LIFESPAN)
		
		-- All epithelial cells start in the healthy state
		-- with the exception of a fraction INFECT_INIT of the total
		-- number of epithelial cells which, chosen at random, are
		-- set to the infected state.
		if (math.random() <= INFECT_INIT) then
			cell.state = INFECTED
			cell.infectedSince = 0
		else
			cell.state = HEALTHY
			cell.infectedSince = nil
		end
		
		cell.divisionState = nil
	end)
end

-- agents represent the moving immune cells (not visible)
function createAgent (model)
	model.family = Agent {
		init = function(self)
			self.age = 0
			-- initial state is virgin, later mature
			self.state = VIRGIN
			-- a table is needed in case agent moves
			-- directly from expressing to infectious cells
			self.recruitDelayTable = nil
		end,
		
		execute = function(self)
			-- an immune cell is removed if it is older than IMM_LIFESPAN
			if (self.age > IMM_LIFESPAN) then
				self:die()
				print("Agent died")
				return
			end
			
			-- An encounter between an immune cell and an
			-- expressing or infectious epithelial cell requires the
			-- immune cell to be in the same site as the expressing or
			-- infectious cell.
			local currentCell = self:getCell()
			if ((currentCell.state == EXPRESSING) or (currentCell.state == INFECTIOUS)) then
				-- A virgin immune cell becomes a mature immune cell if
				-- the lattice site it is occupying is in the expressing or
				-- infectious states
				self.state = MATURE
				
				-- A mature immune cell occupying an expressing or
				-- infectious lattice site "recognizes" the epithelial cell
				-- and causes it to become dead (recognition).
				currentCell.state = DEAD
				currentCell.infectedSince = nil
				currentCell.divisionState = 0

				-- Each recognition event causes RECRUITMENT mature
				-- immune cells to be added at random sites on the CA
				-- lattice after a delay of RECRUIT_DELAY:
				self.recruitDelayTable = {}
				table.insert(self.recruitDelayTable, 0)
			end
			
			local rdt = self.recruitDelayTable
			-- amount of new recruited cells reduced for the sake of runtime performance in TerraME
			-- original amount as described in the paper is as the following line
			-- amountRecruitet = GRID_WIDTH * GRID_HEIGHT * RECRUITMENT
			local amountRecruitet = 1
			if (rdt ~= nil) then
				for delayTimeKey, delayTimeValue in pairs(rdt) do
					if (delayTimeValue > RECRUIT_DELAY) then
						repeat
							self:reproduce{age = 0, state = MATURE, recruitDelayTable = nil}
							amountRecruitet = amountRecruitet - 1
						until amountRecruitet == 0
						
						table.remove(rdt, delayTimeKey)
					end
				end
			end
			
			-- Immune cells move randomly on the CA lattice at a
			-- speed of one lattice site per time step.
			-- TODO self:randomWalk("moore") retrieves non interpretable error. Why???
			self:randomWalk()
			
			-- update age
			self.age = self.age + 1
		end
	}
end

function createSociety (model)
	model.society = Society{
		instance = model.family,
		quantity = model.societyDim,
	}
end


-- placements of immune cells
function createEnvironment (model)
	model.env = Environment {model.cellspace, model.society}
	model.env:createPlacement{ strategy = "random", max = 1}				
end



function createTimer (model)
	model.timer = Timer {
		-- update the cellspace at each time step
		Event {time = 1, period = 1, action = function()
			forEachCell(model.cellspace, function(cell)
				-- update the delays in each step
				if (cell.infectedSince ~= nil) then
					cell.infectedSince = cell.infectedSince + 1
				elseif (cell.divisionState ~= nil) then
					cell.divisionState = cell.divisionState + 1
				end 
		
				-- check age of each cell
				if (cell.age > CELL_LIFESPAN) then
					cell.state = DEAD
					cell.infectedSince = nil
					cell.divisionState = 0
				else
					-- update age of cell in each step
					cell.age = cell.age + 1
				end
		
				-- A healthy epithelial cell becomes infected with
				-- probability INFECT RATE/(8 nearest neighbours) for
				-- each infectious nearest neighbour.
				if (cell.state == HEALTHY) then
					local infectiousNeighbors = 0
					local countInfectiousNeighbors = function(cell, neighbor)
						if neighbor.state == INFECTIOUS then
							infectiousNeighbors = infectiousNeighbors + 1
						end
					end
					
					-- applying countInfectiousNeighbors to each cell
					forEachNeighbor(cell, countInfectiousNeighbors)
					
					if (infectiousNeighbors >= INFECT_RATE) then
						cell.state = INFECTED
						cell.infectedSince = 0
					end
				end
				
				-- An infected cell becomes expressing, i.e. begins
				-- expressing the viral peptide, after having been infected
				-- for EXPRESS_DELAY
				if (cell.state == INFECTED and cell.infectedSince > EXPRESS_DELAY) then
					cell.state = EXPRESSING
				end
				
				-- An expressing cell becomes infectious after
				-- having been infected for INFECT_DELAY > EXPRESS_DELAY:
				if (cell.state == EXPRESSING and cell.infectedSince > INFECT_DELAY) then
					cell.state = INFECTIOUS
				end
				
				-- Infected, expressing, and infectious cells become dead
				-- after having been infected for INFECT_LIFESPAN
				-- (cell.state == (INFECTED or EXPRESSING or INFECTIOUS)) and
				if ((cell.infectedSince ~= nil) and ((cell.state == INFECTED) or (cell.state == EXPRESSING) or (cell.state == INFECTIOUS)) and (cell.infectedSince > INFECT_LIFESPAN)) then
					cell.state = DEAD
					cell.infectedSince = nil
					cell.divisionState = 0
				end
				
				-- A dead cell is revived at a rate DIVISION_TIME.
				-- When revived, a dead cell becomes a healthy cell or an
				-- infected cell with probability INFECT RATE /(8 nearest neighbors)
				-- for each infectious nearest neighbor.
				if (cell.state == DEAD and cell.divisionState > DIVISION_TIME) then
					local infectiousNeighbors = 0
					local countInfectiousNeighbors = function(cell, neighbor)
						if neighbor.state == INFECTIOUS then
							infectiousNeighbors = infectiousNeighbors + 1
						end
					end
					-- applying countInfectiousNeighbors to each cell
					forEachNeighbor(cell, countInfectiousNeighbors)
					if (infectiousNeighbors >= INFECT_RATE) then
						cell.state = INFECTED
						cell.infectedSince = 0
					else
						cell.state = HEALTHY
						cell.infectedSince = nil
					end
					cell.divisionState = nil
				end
			end)
		end
		},
		Event {time = 1, period = 1, action = model.society},
		Event {time = 1, period = 1, action = model.cellspace},
		Event {time = 1, period = 1, action = function () 	
			forEachAgent(model.society, function(agent)
				local rdt = agent.recruitDelayTable
				if (rdt ~= nil) then
					for delayTimeKey, delayTimeValue in pairs(rdt) do
						rdt[delayTimeKey] = rdt[delayTimeKey] + 1
					end
				end
			end)
		end}
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
	cellSpaceDimWidth  =  GRID_WIDTH,
	cellSpaceDimHeight = GRID_HEIGHT,
	-- Virgin immune cells are added at random lattice sites
	-- as needed to maintain a minimum density of
	-- BASE IMM CELL virgin immune cells.
	societyDim = GRID_WIDTH * GRID_HEIGHT * BASE_IMM_CELL
}

function run (model, time)
	model.timer:execute (time)
end

run(model, 150)