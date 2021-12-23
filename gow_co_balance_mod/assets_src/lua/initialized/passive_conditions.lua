local Wargroove = require "wargroove/wargroove"
local OriginalPassiveConditions = require "wargroove/passive_conditions"

local neighbours = { {x = -1, y = 0}, {x = 1, y = 0}, {x = 0, y = -1}, {x = 0, y = 1} }

local function getNeighbour(pos, i)
    local n = neighbours[i]
    return Wargroove.getUnitAt({ x = n.x + pos.x, y = n.y + pos.y })
end

local PassiveConditions = {}

-- This is called by the game when the map is loaded.
function PassiveConditions.init()
    OriginalPassiveConditions.getPassiveConditions().harpy = PassiveConditions.harpy
end

-- Harpies now crit enemies on mountains
function PassiveConditions.harpy(payload)
    local terrainNameAttacker = Wargroove.getTerrainNameAt(payload.attackerPos)
    local terrainNameDefender = Wargroove.getTerrainNameAt(payload.defenderPos)
    return terrainNameAttacker == "mountain" or terrainNameDefender == "mountain"
end

return PassiveConditions