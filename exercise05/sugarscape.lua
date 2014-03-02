--[[
SUGARSCAPE MODEL 
Based on the book J. Epstein and R. Axtell, "Growing artificial societies: social science from the bottom up".

Implemented in TerraME by Gilberto Câmara (December, 2013)
Based on earlier version by Pedro Andrade (June, 2013)

Sugarscape is an abstract agent-based model of artificial societies developed by 
Epstein and Axtell to investigate the emergence of social processes.

The model represents an artificial society in which agents move over a 50 × 50 cell grid. 
Each cell has a gradually renewable quantity of ‘sugar’, which the agent located at that cell can eat. 
However, the amount of sugar at each location varies. Agents have to consume sugar in order to survive.
If they harvest more sugar than they need immediately, they can save it and eat it later 
(or, in more complex variants of the model, can trade it with other agents). 

Agents can look to the north, south, east and west of their current locations and can see a distance 
which varies randomly, so that some agents can see many cells away while others can only see adjacent cells.

Agents also differ in their ‘metabolic rate’, the rate at which they use sugar. 
If their sugar level ever drops to zero, they die. 
In some simulations, new agents replace the dead ones with a random initial allocation of sugar. 

Thus there is an element of the ‘survival of the fittest’ in the model, since those agents 
that are relatively unsuited to the environment because they have high metabolic rates, 
poor vision, or are in places where there is little sugar for harvesting, die relatively 
quickly of starvation. 

Epstein and Axtell (1996) present a series of elaborations of this basic model 
in order to illustrate a variety of features of societies. The basic model shows that even 
if agents start with an approximately symmetrical distribution of wealth (the amount of sugar 
each agent has stored), a strongly skewed wealth distribution soon develops. This is because 
a few relatively well-endowed agents (<- really :D ?) are able to accumulate more and more sugar,
while the majority only barely survive or die.
]]

--[[ 
 	 This replication assumes you have Epstein and Axtell's book
	 Please also read and download Anthony Bigbee MsC thesis 
	 "Replication of Sugarscape using MASON"
	 http://mason-sugarscape.googlecode.com/svn-history/r22/trunk/docs/ajb_thesis_revised.pdf
]]
-- Auxiliary modules
luafunc = require("luafunc")
create  = require("create")
rules   = require("rules")

-- Defines the default "Sugarscape" model

-- Basic parameters 
DIM_SPACE = 50    -- dimension of the cell space
NUM_RUNS  = 500   -- number of iterations

-- Default model parameters
Sugarscape = {
	-- name of the file with the initial values of the sugarscape
	sugarscapeFile           = "sugar_map.txt",
	-- model keeps track of the current time 
	currentTime              =  0,
	-- dimension of cell space 
	dimSpace                 =  DIM_SPACE,
	-- number of iterations
	numRuns                  =  NUM_RUNS, 
	-- number of agents          
	numAgents                =  400,           
	-- initial sugar available per agent
	agentWealth              =  { min = 5,  max = 25 }, 
	-- consumption per agent per time interval
	agentMetabolism          =  { min = 1, max = 4   },
	-- vision in horizontal and vertical directions
	agentVision              =  { min = 1, max = 6   },
	-- agent lifetime (by default, agents have no lifetime limits)
	agentLifetime            =  { min = math.huge, max = math.huge},
      -- minimum sugar per cell
	cellSugar                =  { min = 0,  max = 4},
	-- reference to cell's von Neumann neighborhood
	csVonNeumanNeighborhood  = "1",
	-- normal growth rate 
	growthRate               =  1, 
	-- pollution coeficients
	pollutionProductionRate  =  0,
	pollutionConsumptionRate =  0,
	pollutionStartTime       =  math.huge,
	diffusionStartTime       =  math.huge,
	-- seasonal duration?
	hasSeasons               =  false,
	seasonDuration           =  math.huge,
	-- block (if agents are placed in blocks)
	block                    =  { xmin = 0, ymin = 0, xmax = DIM_SPACE - 1, ymax = DIM_SPACE - 1 },

	-- Agent and Sugarscape Rules 
	-- how agents are placed in the cell space
	placementRule            =  rules.randomPlacement,
	-- how agents move in the cell space
	movementRule             =  rules.gradientSearch,
	-- search maximization Criteria
	searchMaxRule            =  rules.maxSugar,
	-- how agents' metabolism works
	metabolismRule           =  rules.eatAllSugar,
	-- how agents are replaced if the die
	replacementRule          =  rules.noReplacement,
	-- how the agents pollute the space
	pollutionFormationRule   =  rules.noPollution,
	pollutionDiffusionRule   =  rules.noPollution,
	-- how sugar grows back in the cell space
	growbackRule             =  rules.normalGrowth,
	-- how social networks are handled
	socialNetworkRule        =  rules.noSocialNetworks,
	-- model visualization
	viewRule                 =  rules.updateViews,

	-- Visualization parameters and functions
	-- show how numagents evolve?
	showNumAgents            =  false,
	-- show Gini coefficient?    
	showGiniIndex            =  false,
	-- show social networks?
	showSocialNetworks       =  false,
	-- show wealth distribution?	   
	showWealthDist           =  false, 
	-- how to show the agents in the sugarscape?
	agentColor               =  5, 
	-- how to show the social network in the sugarscape?
	socialNetworkColor       =  1,
	-- show original sugarscape?
	showOriginalSugarscape   =  true,
	-- number of steps in histogram  
	histSteps                =  10, 
	-- file to save histogram      
	histFile                 =  "sugarscape_hist",  
	-- used to wait some time before next iteration
	viewWait                 =  10   
}
-- Step by step creation of the model
function Sugarscape.setup(model) 
    -- builds the cell space 
	create.CellSpace (model) 
	-- defines agent behaviour     
	create.Agent (model)
	-- creates a society        
	create.Society (model) 
	-- place the society in the cell space       
	create.Environment (model)  
	-- create visualisations
	create.Views (model) 	 
	-- control model execution        
	create.Timer (model)          
end
--[[ 
	This function runs the sugarscape model
	It sets up the model, and executes it
]]
function Sugarscape.run (model)
	-- set up the model
	model:setup ()
	-- execute the model 
	model.timer:execute (NUM_RUNS)
end
--[[ To build the sugarscape scenarios, we use Lua's metatable.
     Metatables allow a table to use values from another one. 
     In our case, we define a metatable (Sugarscape) that is common
     to all sugarscape scenarios. The metatable Sugarscape contains
     all the default values needed by the different sugarscape models.

     Each sugarscape scenario only defines what the parameters and rules 
     that are different from defaults ]]

-- defines that Sugarscape (see above) is a metatable 
metaTableSugarscape = {__index = Sugarscape}

--[[ This function is used to implement all sugarscape model ]]
function SugarscapeModel (argv)
	-- the model first gets the scenario-specific parameters
	local model = argv
	-- all other parameters are accessed via the metatable
	setmetatable(model, metaTableSugarscape)
return model
end

--[[ Sugarscape scenarios - parameters and rules that are different from defaults ]]

--[[ Animation II-1 - immediate growth, default movement and metabolism
	For this first run, we take the initial population to be 400
	agents arranged in a random spatial distribution. 
	For the first run, the sugarscape will follow "immediate growback rule".
	The sugarscape grows back to full capacity immediately.
]]
sc_II_1 = SugarscapeModel {
	growbackRule    =  rules.immediateGrowth,
	showNumAgents   =  true
}

--[[ Animation II-2 - normal growth, default movement and metabolism
	For this second run we again take the initial population to be 400
	agents arranged in a random spatial distribution. 
	Each agent again executes the default rules for movement and metabolism. 
	But now let us change the sugarscape growth rule: Every site
	whose level is less than its capacity grows back at 1 unit per time period. 
]]
sc_II_2 = SugarscapeModel {
	growbackRule    =  rules.normalGrowth,
	showNumAgents   =  true
}
--[[ Animation II-3 - normal growth, agent replacement, default movement and metabolism
	 
	 Shows how giniIndex and wealth distribution evolve 
	 
	 We set each agent's maximum achievable age- beyond which it cannot live - 
	 to a random number drawn from some interval [a,b]. Of course, agents can still die 
	 of starvation, as before.
	 Given that agents are to have finite lifetimes, the second modification
	 that must be implemented is a rule of agent replacement. 
	 However, to ensure a stationary wealth distribution it is desirable to use a 
	 replacement rule that produces a constant population .
	
	 When an agent dies it is replaced by an agent of age 0 having random genetic attributes, 
	 random wealth and position on the sugarscape, and a maximum age randomly selected 
	 from the range [a,b].

	 We want to track the distribution of wealth, and we show a histogram of wealth. 
	 While initially quite symmetrical, the distribution ends up highly skewed.
	 Such skewed wealth distributions are produced for wide ranges of agent and environment 
	 specifications. They seem to be characteristic
	 of heterogeneous agents extracting resources from a landscape of fixed capacity.

	 The animation also displays a real-time computation of the Gini coefficient. 
	 Note that it starts out quite small (about 0.230) and ends up fairly large (0.500). 
]]
sc_II_3 = SugarscapeModel {
	numAgents            =  250,
	growbackRule         =  rules.normalGrowth,
	replacementRule      =  rules.ageReplacement,         
	agentLifetime        =  { min = 60, max = 100},
	showNumAgents        =  false,
	showGiniIndex        =  true,
	showWealthDist       =  true
}
--[[ Animation II-4 is the same as II-3 ]]

--[[ Animation II-5 - normal growth, default movement and metabolism, showing socialnetworks
	We want to keep track of each agent's neighbors.
	In what follows we shall always employ the von Neumann neighborhood.
	When an agent moves to a new position on the sugarscape it has
	from zero to four neighbors. Each agent keeps track of these neighboring
	agents internally until it moves again, when it replaces its old neighbors with its new neighbors.
]]
sc_II_5 = SugarscapeModel {
	growbackRule         =  rules.normalGrowth,
	showNumAgents        =  true,
	showSocialNetworks   =  true,
	socialNetworkRule    =  rules.buildSocialNetworks
}
--[[
	Animation II-6 - initial distribution of agents in a block

	We turn now to a different kind of emergent structure, this one
	spatial in nature.  Instead of the random initial distribution of agents 
	on the sugarscape used earlier, suppose they are initially clustered in the dense block.
    In all other respects the agents and sugarscape are exactly as in animation II-2. 
    How will this block start affect the dynamics? A succession of coherent waves results, 
    a phenomenon we did not expect.

	N.B: This animation is not reproducible directly following the descriptions of the E&A book.
	GROWBACK must be delayed by one time step (sugar does not growback as it is consumed)
	MIN_VISION must be increased to 5 
	MAX_VISION must be increased to 15
]]
sc_II_6 = SugarscapeModel {
	block               =  {xmin = 0, ymin = DIM_SPACE - 20, xmax = 19, ymax = DIM_SPACE - 1 },
	placementRule       =  rules.blockPlacement,
	growbackRule        =  rules.delayedGrowth,
	agentVision         =  {min = 5, max = 15}
}

--[[ Animation II-7 Seasonal growback rule
    Initially it is summer in the top half of the sugarscape and winter in the bottom half.
    Then, every Y time periods the seasons flip - in the region where it was summer it becomes
    winter and vice versa. For each site, if the season is summer then sugar grows back at a 
    rate of A units per time interval; if the season is winter then the growback rate 
    is A units per B time intervals

]]
sc_II_7 = SugarscapeModel {
	showNumAgents       =  true,
	hasSeasons      	  =  true,
	growbackRule        =  rules.seasonalGrowth,
	seasonDuration   	  =  50,
	summerGrowthRate    =  1,
	winterGrowthRate    =  0.125
}

--[[ 
	Animation II-8: Pollution in the sugarscape 

	Pollution formation rule: when sugar S is gathered from the sugarscape, an amount of 
	production pollution is generated in quantity ALPHA*S. When sugar amount M is metabolized, 
	consumption pollution is generated according to BETA*M. 
	The total pollution on a site at time t, P(T), is the sum of the
	pollution present at the previous time, plus the pollution
	resulting from production and consumption activities.

	Pollution diffusion rule: Diffusion on a sugarscape is simply
	implemented as a local averaging procedure. 
	That is, diffusion transports pollution from sites of high levels to sites of low levels.

	The new agent movement rule modified for pollution is
	Look out as far as vision permits in the four principal lattice
	directions and identify the unoccupied site(s) having the maximum sugar to pollution ratio.
]]

sc_II_8 = SugarscapeModel {
	showNumAgents              = true,
	searchMaxRule              = rules.maxSugarToPollution,  	-- search maximization Criteria
	pollutionProductionRate    = 1,
	pollutionConsumptionRate   = 1,
	pollutionStartTime         = 50,
	diffusionStartTime         = 100,
	-- how the agents pollute the space
	pollutionFormationRule     = rules.pollutionProdCons,
	pollutionDiffusionRule     = rules.pollutionLocalDiffusion
} 

--[[ 
	Animation II-9: Wealth is depending on your social background (parent and neighbors)
	
	If an agent dies it is replaced within his cell by a new agent with attributes
	gathered from its parent and neighbors. The wealth is a It should have a high vision which decreases 
	as the agent gets older.
	 
	
	
]]

sc_II_9 = SugarscapeModel {
	replacementRule      =  rules.socialBackgroundReplacement,
	showNumAgents        =  true,
	showGiniIndex        =  true
}
--[[ 
	We now can choose our model from the available scenarios
]]
MODEL_SCENARIOS   = {sc_II_1, sc_II_2, sc_II_3, sc_II_5, sc_II_6, sc_II_7, sc_II_8}
-- Choose from one of the above
model             =  sc_II_9  
-- Run the model!!
model:run ()


