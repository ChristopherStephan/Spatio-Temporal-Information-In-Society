--[[  
	Color the sugarscape map -- used to see the agents
]]

local cellfunc = require ("cellfunc")
local color={}

function color.Sugarscape (model)
	assert (model.cs ~= nil )
	forEachCell (model.cs, function (cell)
		occupants = cell:getAgents()
		assert (#occupants <= 1, "colorSugarscape: more than one agent per cell")
		if (#occupants == 0 ) then  
			if (model.showOriginalSugarscape == true) then 
				cell.color = cell.maxsugar
			else
				cell.color = cell.sugar
			end
		else
			cell.color = model.agentColor 
		end
	end)
end

--[[  
	Color the social Network -- used to see the agents
]]
function color.SocialNetworks (model)
	assert (model.cs ~= nil, "colorSocialNetwork: model does not have a cell space" )
	forEachCell (model.cs, function (cell) cell.socialNetwork = 0 end)

	forEachAgent (model.society, function (agent)
		for k,v in pairs(agent.sn.connections) do
			color.Path (model, agent, v)
		end
	end)
end
--[[  
	Color a path between two agents
]]
function color.Path (model, agent1, agent2)
	assert (agent1:getCell() ~= nil, "colorPath: agent1 is not placed in the cell space")
	assert (agent2:getCell() ~= nil, "colorPath: agent2 is not placed in the cell space")
	cell1 = agent1:getCell()
	cell2 = agent2:getCell()
	path = cellfunc.findStraigthPath (cell1, cell2) 
	for k,v in pairs (path) do
		model.cs:getCell(v).socialNetwork = model.socialNetworkColor
	end
	cell1.socialNetwork = model.agentColor 
end

return color
