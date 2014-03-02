local cellfunc = require "cellfunc"
local agentfunc ={}
agentfunc.version="1.0"

--[[
	Find out all the values of an attribute of the society
]]
function agentfunc.attrValues (society, attr_name)
	local vals = {}
	forEachAgent (society, function(agent)
		vals[#vals + 1 ] = agent[attr_name]
	end)
return vals
end

--[[
	Places agents in a block of a cellspace 
]]
function agentfunc.placeAgentsInBlock (society, cellspace, block)
	nagents = society:size()
	assert (block.xmax > block.xmin)
	assert (block.ymax > block.ymin)
	assert (nagents <= (block.xmax - block.xmin + 1)*( block.ymax - block.ymin + 1), "block not big enough to contain all agents")
	iagent = 1
	for icell = block.ymin, block.ymax do
		for jcell = block.xmin, block.xmax do
			agent = society:getAgents()[iagent]
			cell  = cellspace:getCell (Coord{x = jcell, y = icell})
			agent:move(cell)
			if (iagent >= nagents) then break end
			iagent = iagent + 1
		end
	end
end

--[[
	Places agents randomly in empty cells
]]
function agentfunc.placeAgentsRandomly (society, cellspace)
	forEachAgent (society, function (agent)
			agent:move(cellfunc.findEmptyRandomCell (cellspace))
	end)
end

return agentfunc