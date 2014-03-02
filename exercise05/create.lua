--[[ 
	FUNCTIONS FOR CREATING THE SUGARSCAPE MODEL

	Called by "setSugarscapeModel" in the main program 

    -- builds the cell space 
	createCellSpace (model) 
	-- defines agent behaviour     
	createAgent (model)
	-- creates a society        
	createSociety (model) 
	-- place the society in the cell space       
	createEnvironment (model)  
	-- create visualisations
	createViews (model) 	 
	-- control model execution        
	createTimer (model)          
return model
end
]]
-- ====================================================
--[[
SUGARSCAPE MODEL Cellspace functions 
]]
local luafunc   = require ("luafunc" )
local cellfunc  = require ("cellfunc")
local agentfunc = require ("agentfunc")
local create = {}

--[[  
	Create the cell space, define the neighborhoods, and read the file 
      containing the sugarscape 
]]
function create.CellSpace (model)
 
 	-- read Sugarscape file to get initial configuration 
	-- read Sugarscape file - this file approximates the original Epstein and Axtell grid 
	model.cs = cellfunc.readCellSpaceFromTxtFile {
		xdim        = model.dimSpace, 
		ydim        = model.dimSpace, 
		attr_name   = "maxsugar", 
		txtfile     = "sugar-map.txt", 
		charsize    = 1, 
		whitespaces = 1
	}
	assert (model.cs ~= nil )
	-- create different rook neighborhoods for agents of different visions
	for i = model.agentVision.min, model.agentVision.max do
		cellfunc.createRookNeighborhood(model.cs, i, model.dimSpace)
	end
	-- initialize the sugar and color attributes of the cell 
	forEachCell(model.cs, function(cell)
		cell.sugar = cell.maxsugar
		cell.color = cell.maxsugar
		cell.socialNetwork = 0
		cell.harvestTime   = 0
		cell.production    = 0
		cell.consumption   = 0 
		cell.pollution     = 0
	end)

	if (model.hasSeasons) then
		model.north, model.south = createNorthSouthTrajectories (model.cs)
	end

	model.cs:synchronize("pollution")
end

function createNorthSouthTrajectories (cellspace)
	north = Trajectory { 
		target = cellspace,
		select = function (cell)
			return cell.y < (DIM_SPACE/2)
		end
	}
	south = Trajectory { 
		target = cellspace,
		select = function (cell)
			return cell.y >= (DIM_SPACE/2)
		end
	}
return north, south
end
-- ====================================================

--[[
In Sugarscape, the agent has attributes: age, wealth (the amount of sugar), 
life-expectancy (the maximum age that can be reached), 
metabolism (how much sugar an agent eats each time period), and  vision (how many cells ahead an agent can see). 
The agent’s life-expectancy, metabolism and vision do not change, while age and wealth do change.
]]
function create.Agent (model)
	model.agent = Agent
	{
		init = function(self)
			self.wealth     = luafunc.randomLCG(model.agentWealth.min,     model.agentWealth.max    )
			self.metabolism = luafunc.randomLCG(model.agentMetabolism.min, model.agentMetabolism.max)
			self.maxage     = luafunc.randomLCG(model.agentLifetime.min,   model.agentLifetime.max  )
			self.vision     = luafunc.randomLCG(model.agentVision.min,     model.agentVision.max    )
			self.age        = 0 
			self.sn         = SocialNetwork()
		end,

		execute = function(self) 
		end
	}
end

-- Creates a society of agents 
function create.Society (model)
	model.society = Society {
		instance       = model.agent, 
		quantity       = model.numAgents,
		wealthHist     = {},
		histValues     = {},
		giniIndex      = 0
	}
	assert (model.society ~= nil )
end


--[[
SUGARSCAPE MODEL Placement functions 
These functions deal with placing agents in the cellspace
]]

-- Place the society of agents in the cell space
function create.Environment (model) 
	assert (model.society ~= nil )
	assert (model.cs ~= nil )
	model.env = Environment {model.cs, model.society}

	model.env:createPlacement {
		strategy = "void"
	}
	model:placementRule()
end


-- ====================================================
--[[
SUGARSCAPE MODEL View functions 
These function deal with visualisation
]]


--[[ Create model visualizations ]]
function create.Views (model)
	if (model.showGiniIndex) then 
		model.giniPlot = create.GiniPlot (model)
	end
	if (model.showNumAgents) then
		model.nagentsPlot = create.NumAgentsPlot (model)
	end

	model.mapcs = create.MapCellSpace (model)

	if (model.showSocialNetworks) then
		model.mapsn = create.MapSocialNetworks (model)
	end
end

--[[  
	Create plots to see the Gini coeficient and the number of agents
]]
function create.GiniPlot(model)
	assert (model.society ~= nil )
	giniPlot = Observer {
			subject     = model.society,
			attributes  = {"giniIndex"},
			curveLabels = {"giniIndex"},
			title       = {"Gini Index - Sugarscape"},
			xLabel      = {"time"},
			yLabel      = {"Gini index"},
			type = "chart"
		}
return giniPlot 
end

function create.NumAgentsPlot(model)
	nagentsPlot = Observer {
			subject     = model.society,
			attributes  = {"quantity"},
			curveLabels = {"numAgents"},
			title       = {"Agents in the model"},
			xLabel      = {"time"},
			yLabel      = {"agents"},
			type        = "chart"
		} 
return nAgentsPlot
end

--[[  
	Create a map to view the sugarscape 
]]
function create.MapCellSpace (model)
	assert (model.cs ~= nil )
	leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = 0, color = {255,255,212}},
		{value = 1, color = {218,176,130}},
		{value = 2, color = {218,160, 98}},
		{value = 3, color = {180,117, 49}},
		{value = 4, color = {117, 69, 16}},
		{value = 5, color = {117, 33, 16}}
		}
	}
	local map = Observer {
		subject = model.cs,
		attributes = {"color"},
		legends = {leg}
	}
return map
end
--[[  
	Create a map to view the sugarscape 
]]
function create.MapSocialNetworks (model)
	assert (model.cs ~= nil )
	leg = Legend {
	grouping = "uniquevalue",
	colorBar = {
		{value = 0, color = {255,255,212}},
		{value = 1, color = {218,176,130}},
		{value = 2, color = {218,160, 98}},
		{value = 3, color = {180,117, 49}},
		{value = 4, color = {117, 69, 16}},
		{value = 5, color = {117, 33, 16}}
		}
	}
	local map = Observer {
		subject = model.cs,
		attributes = {"socialNetwork"},
		legends = {leg}
	}
return map
end

--[[ Creates the timer and defines how the model is executed ]]

function create.Timer (model)	
	model.timer = Timer {
		Event {time = 1, period = 1, priority = 1, action = function(ev)
					model.currentTime = ev:getTime()
					model:movementRule()
					model:metabolismRule()
					model:pollutionFormationRule()
					model:pollutionDiffusionRule()
					model:replacementRule()
					model:socialNetworkRule()
					model:growbackRule()
					model:viewRule()
					luafunc.wait (model.viewWait)
		end},
		Event {time = 1, period = 50, priority = 2, action = function(ev)
					create.WealthHistogram(model)
		end}
	}
end
--[[  
	Rule to save the wealth distribution histogram 
]]
function create.WealthHistogram(model)
	if (model.showWealthDist) then
		hist = luafunc.histogram (luafunc.distribution (agentfunc.attrValues(model.society, "wealth")), model.histSteps)
		filename = model.histFile .. "_" .. model.currentTime ..".csv"
		luafunc.saveHistogram (hist, filename)
	end 
end

return create