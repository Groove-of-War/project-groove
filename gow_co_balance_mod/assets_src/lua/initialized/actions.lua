local Events = require "initialized/events"
local Wargroove = require "wargroove/wargroove"

local inspect = require "inspect"

local Actions = {}

function Actions.init()
  Events.addToActionsList(Actions)
end

function Actions.populate(dst)
    dst["overheal_state_update"] = Actions.overhealStateUpdate
end


function Actions.overhealStateUpdate(context)
    print('==Actions.overhealStateUpdate')
    -- print(inspect(context))

    for playerId=0,1 do
        local allUnits = Wargroove.getAllUnitsForPlayer(playerId, true)
        for i, u in ipairs(allUnits) do
            local overhealState = Wargroove.getUnitState(u, "overheal")
            print("overhealstate", overhealState)
            print("health", u.health)
            if (u.health <= 100) then
                print('= overheal state set to 0')
                Wargroove.setUnitState(u, "overheal", 0)
                Wargroove.updateUnit(u)
            end
        end
    end

    
end


return Actions