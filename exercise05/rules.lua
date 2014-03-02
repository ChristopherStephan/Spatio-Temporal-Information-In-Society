--[[  RULES MODULE]]

local luafunc   = require ("luafunc"  )
local cellfunc  = require ("cellfunc" )
local agentfunc = require ("agentfunc")
local color     = require ("color"    )


local rules = {}

--[[  
	RULES FOR SUGAR GROWTH
]]

--[[
	Grow sugar according to a rate 
]]
function rules.growSugar (cs, rate)
	forEachCell (cs, function (cell)
		if (cell.sugar < cell.maxsugar) then 
			cell.sugar = cell.sugar + rate
		end
	end)
end
--[[
	Grow back to maximum sugar value immediately
]]
function rules.immediateGrowth(model)
	assert (model.cs ~= nil )
	forEachCell (model.cs, function (cell)
			cell.sugar = cell.maxsugar
	end)
end

--[[
	Normal growth rule for the sugarscape model
]]

function rules.normalGrowth (model)
	assert (model.cs ~= nil )
	rules.growSugar (model.cs, model.growthRate)
end

--[[ 
	Delayed growth rule: wait one time step before growing again
]]

function rules.delayedGrowth (model)
	assert (model.cs ~= nil )
	forEachCell (model.cs, function (cell)
		if (cell.sugar < cell.maxsugar) then 
			if (cell.harvestTime < model.currentTime) then
				cell.sugar = cell.sugar + model.growthRate
			end
		end
	end)
end
--[[ 
	Seasonal growth rule: seasons have different growth rates
]]

function rules.seasonalGrowth (model)
	if ((math.floor (model.currentTime / model.seasonDuration ) % 2 ) == 0) then
		-- summer in the North, winter in the South
		rules.growSugar (model.north, model.summerGrowthRate) 
		rules.growSugar (model.south, model.winterGrowthRate)
	else
		-- winter in the North, summer in the South
		rules.growSugar (model.north, model.winterGrowthRate) 
		rules.growSugar (model.south, model.summerGrowthRate)
	end
end

--[[  
	RULES FOR AGENT MOVEMENT
]]

--[[
	Default movement rule - gradient search rule
	Look out as far as vision pennits in the four principal lattice directions and 
	identify the unoccupied site(s) maximizing the search criteria
	If the maximum searched value appears on multiple sites then select the nearest one.
	Move to this site and collect all the sugar at this new position.

	The maximization criteria is given by the searchMaxRule (model, cell). 
	In most cases this function searches for the maximum amount of sugar in the cell.
	In some examples, this is changed to a different criteria. In simulation II-8 the
	search criteria is changed to the maximum sugar/pollution ratio for the cell. 
]]
function rules.gradientSearch (model)
	assert (model.society ~= nil )
	forEachAgent (model.society, function (agent)
		assert (agent:getCell() ~= nil, "agent is not placed in the cell space")
		local cell     = agent:getCell()            -- cell where the agent is now
		local max      = model:searchMaxRule (cell) -- function to maximize for the search (usually the sugar in the cell)
		local bestcell = cell                       -- cell where the agent is moving to

		-- agent has a variable neighborhood depending on his vision (varies between 1 and 6) 
		-- select a pre-computed neighborhood based on the agent's vision
		local name = string.format ("%d", agent.vision) 

		-- find the vacant cell with the most sugar nearest to the agent
		forEachNeighbor (cell, name, function (cell, neigh)
			occupants = neigh:getAgents()
			if (#occupants == 0 ) then   -- is the cell vacant? 
				if model:searchMaxRule (neigh) > max then  
					max = model:searchMaxRule (neigh)
					bestcell = neigh
				else 
					-- two cells with same sugar, select the closest one 
					-- if the distance is the same, throw a coin
					if (model:searchMaxRule (neigh) == max) then
						if (cellfunc.cityBlockDistance (cell, neigh) < cellfunc.cityBlockDistance (cell, bestcell)) or
						   ((cellfunc.cityBlockDistance(cell, neigh) == cellfunc.cityBlockDistance (cell, bestcell)) and luafunc.randomLCG (0, 1) == 1) then
							bestcell = neigh
						end
					end
				end
			end
		end)
		agent:move(bestcell)
	end)
end
--[[
	Maximization criteria for agent search

	The maximization criteria is given by the searchMaxRule (model, cell). 
	In most cases this function searches for the maximum amount of sugar in the cell.
	In some examples, this is changed to a different criteria. In simulation II-8 the
	search criteria is changed to the maximum sugar/pollution ratio for the cell. 

	Function searchMax (model, cell) calls one of the maximization criteria below.
	In most cases 
		searchMax(model, cell) = maxSugar (model, cell)
	for the pollution example
		searchMax(model, cell) = 
]]
function rules.maxSugar (model, cell)
return cell.sugar
end

--[[
	In the pollution examples, the agent movement rule is changed to
	look out as far as vision permits in the four principal lattice
	directions and identify the unoccupied site(s) having the maximum sugar to pollution ratio.
]]
function rules.maxSugarToPollution (model, cell)
return cell.sugar/(1 + cell.pollution)
end

--[[  
	RULES FOR AGENT METABOLISM
]]

--[[
	Default Metabolism Rule 
	If there is any sugar at the current cell, eat it;
	If sugar level of the current cell exceeds metabolism, add the extra sugar to wealth.
]]
function rules.eatAllSugar (model)
	assert (model.society ~= nil )
	forEachAgent (model.society, function (agent)
		-- eat as much as you can
		agent.wealth = agent.wealth - agent.metabolism + agent:getCell().sugar
		-- set up the production and consumption values for the cell
		agent:getCell().production  = agent:getCell().sugar 
		agent:getCell().consumption = agent.metabolism
		-- cell has no more sugar
		agent:getCell().sugar = 0
		-- cell remembers when the sugar has been harvested
		agent:getCell().harvestTime = model.currentTime 
	end)
end
--[[  
	RULES FOR AGENT PLACEMENT, LIFETIME, AND REPLACEMENT
]]
--[[
	Random Placement Rule (default)
	place agents randomly in cell space
]]
function rules.randomPlacement (model)
	assert (model.society ~= nil )
	assert (model.cs ~= nil )
	agentfunc.placeAgentsRandomly (model.society, model.cs)
end

--[[
	Block Placement Rule (default)
	place agents in block in cell space
	block definition must be provided by the model
]]
function rules.blockPlacement (model)
	assert (model.society ~= nil )
	assert (model.cs ~= nil )
	agentfunc.placeAgentsInBlock  (model.society, model.cs, model.block)
end
--[[
	No Replacement Rule (default)
	If age exceeds life-expectancy or there is no more sugar, die.
]]
function rules.noReplacement (model)
	assert (model.society ~= nil )

	forEachAgent (model.society, function (agent)
		if agent.wealth <= 0 then agent:die() end
	end)
end

--[[
	Age Replacement Rule 
	If age exceeds life-expectancy or there is no more sugar, beget a son and die.
]]
function rules.ageReplacement (model)
	assert (model.society ~= nil, "ageReplacementRule: model does not have a society" )

	forEachAgent (model.society, function (agent)
		agent.age = agent.age + 1 
		if agent.wealth <= 0 or (agent.age == agent.maxage) then
			son = agent:reproduce()
			son:move (cellfunc.findEmptyRandomCell(model.cs))
			agent:die()
		end
	end)
end

--[[
	Social background Replacement Rule
	
	This rule is based on the idea that the individual's behavior in society
	is influenced by his social background. The social background of an agent
	determines his wealth, metabolism and vision. Wealth can be seen as an
	equivalent of income. The metabolic rate is an indicator for the agent's
	health since a slower metabolic rate could prolong lifespan. Vision can
	be seen as an factor describing a mixture of intelligence and knowledge.
	Thus it is calculated as a mean of the new born's neighbors.
]]

function rules.socialBackgroundReplacement (model)
	assert (model.society ~= nil, "socialBackgroundRule: model does not have a society" )
	
	forEachAgent (model.society, function (agent)
		agent.age = agent.age + 1 
		if agent.wealth <= 0 or (agent.age == agent.maxage) then
			
			son = agent:reproduce()
			son.wealth = agent.wealth -- inherits parent's wealth
			son.metabolism = agent.metabolism --inhertis parent's metabolism 
			placeOfBirth = agent:getCell()
			agent:die()
			son:move (placeOfBirth) -- is set in the cell where his parents died
			
			-- calculating the vision of the son, which is dependent on its neighbors
			local visionTable = {}
			forEachNeighbor(son:getCell(), function(cell, neighbor)
				if cell:getAgent().vision ~= nil then
					table.insert(visionTable, cell:getAgent().vision)
				end
			end)
			son.vision = math.ceil(myMean(visionTable))
		end
	end)
end

-- calculates the mean function for a table
function myMean(t)
  local sum = 0
  local count= 0

  for k,v in pairs(t) do
    if type(v) == 'number' then
      sum = sum + v
      count = count + 1
    end
  end

  return (sum / count)
end


--[[  
	RULES FOR POLLUTION
]]

function rules.noPollution (model)
return true
end

--[[  
	Production - Consumption Rule

	Pollution formation rule: when sugar S is gathered from the sugarscape, an amount of 
	production pollution is generated in quantity ALPHA*S. When sugar amount M is metabolized, 
	consumption pollution is generated according to BETA*M. 
	The total pollution on a site at time t, P(T), is the sum of the
	pollution present at the previous time, plus the pollution
	resulting from production and consumption activities.
]]
function rules.pollutionProdCons (model)
	if (model.currentTime > model.pollutionStartTime) then
		forEachCell (model.cs, function (cell)
			cell.pollution = cell.past.pollution + model.pollutionProductionRate * cell.production +
						     model.pollutionConsumptionRate * cell.consumption
			end)
		model.cs:synchronize("pollution")
	end
end
--[[

	Pollution diffusion rule: Diffusion on a sugarscape is simply
	implemented as a local averaging procedure. 
	That is, diffusion transports pollution from sites of high levels to sites of low levels.

	The new agent movement rule modified for pollution is
	Look out as far as vision permits in the four principal lattice
	directions and identify the unoccupied site(s) having the maximum sugar to pollution ratio.
]]
function rules.pollutionLocalDiffusion(model)
	if (model.currentTime > model.diffusionStartTime) then
		forEachCell (model.cs, function (cell)
			size = cell:getNeighborhood(model.csVonNeumanNeighborhood):size()
			assert (size == 4)
			local p = cell.past.pollution
			forEachNeighbor (cell, model.csVonNeumanNeighborhood, function (cell, neigh)
			  	p = p + neigh.past.pollution
			end)
			cell.pollution = p/(size + 1)
		end)
		model.cs:synchronize("pollution")
	end
end
--[[
	RULES FOR SOCIAL NETWORKS
]]

function rules.noSocialNetworks (model)
return true
end

--[[
	Build a social network. The neighbor connection network is a directed graph with agents 
	as the nodes and edges drawn to the agents who have been their neighbors.
    It is constructed as follows . Imagine that agents are positioned on the sugarscape and 
    that none has moved. The first agent now executes M, moves to a new site, and then
    builds a list of its von Neumann neighbors, which it maintains until its next move. 
    The second agent then moves and builds its list of (post-move) neighbors. 
    The third agent moves and builds its list, and so on until all agents have moved. 
    At this point, lines are drawn from each agent to all agents on its list. 
    The resulting graph- a social network of neighbors - is redrawn after every cycle 
    through the agent population.
]]
function rules.buildSocialNetworks(model)
	if (model.showSocialNetworks) then
		forEachAgent(model.society, function (agent)
			assert (agent:getCell() ~= nil, "buildSocialNetwork: agent is not placed in the cell space")
			agent.sn:clear()    -- clear previous social network
			local cell = agent:getCell()       -- cell where the agent is now

			-- agent has a variable neighborhood depending on his vision (varies between 1 and 6) 
			-- select a pre-computed neighborhood based on the agent's vision
			local name = string.format ("%d", agent.vision) 

			-- find all the agents connected to the agent
			forEachNeighbor (cell, name, function (cell, neigh)
				local occupants = neigh:getAgents() 
				assert (#occupants <= 1, "buildSocialNetwork: more than one agent per cell")
				if (#occupants == 1 ) then   -- there is an agent in the cell
					agent2 = neigh:getAgent()
					agent.sn:add(agent2)
				end
			end)
		end)
	end
end

--[[
	RULES FOR VISUALIZATION
]]

function rules.updateViews (model)
	rules.updatePlots (model)
	rules.updateMaps  (model)
end
--[[  
	Update the plots
]]
function rules.updatePlots(model)
	assert (model.society ~= nil )
	if ( model.showNumAgents ) then
		 model.society.quantity  = model.society:size()
	end
	if ( model.showGiniIndex ) then
		 model.society.giniIndex = luafunc.giniIndex (agentfunc.attrValues(model.society, "wealth"))
	end
	if ( model.showNumAgents or model.showGiniIndex or model.showWealthHist ) then
		 model.society:notify(model.currentTime)
	end
end

--[[  
	Update the map to view the sugarscape 
]]
function rules.updateMaps (model)
	assert (model.cs ~= nil )
	color.Sugarscape (model)
	if (model.showSocialNetworks) then
		color.SocialNetworks (model)
	end
	model.cs:notify (model.currentTime)
end

return rules
