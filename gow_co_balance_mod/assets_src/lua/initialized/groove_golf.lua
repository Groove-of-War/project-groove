local Wargroove = require "wargroove/wargroove"
local GrooveVerb = require "wargroove/groove_verb"
local OldGolf = require "verbs/groove_golf"

local Golf = GrooveVerb:new()

local maxDist = 7
local maxGolfRange = maxDist * 2

function Golf:init()
    OldGolf.getMaximumRange = Golf.getMaximumRange
    OldGolf.isInCone = Golf.isInCone
    OldGolf.generateOrders = Golf.generateOrders
end

function Golf:getMaximumRange(unit, endPos)
  if OldGolf.isInPreExecute then
    return maxGolfRange
  end

  return 1
end

function Golf:isInCone(unitPos, movingUnitPos, targetPos)
  local xDiff = targetPos.x - movingUnitPos.x
  local yDiff = targetPos.y - movingUnitPos.y
  local absXDiff = math.abs(xDiff)
  local absYDiff = math.abs(yDiff)
  if movingUnitPos.x > unitPos.x and xDiff < 0 then
    return false
  elseif movingUnitPos.x < unitPos.x and xDiff > 0 then
    return false
  elseif movingUnitPos.y > unitPos.y and yDiff < 0 then
    return false
  elseif movingUnitPos.y < unitPos.y and yDiff > 0 then
    return false
  end

  if (unitPos.x == movingUnitPos.x) then
    if absXDiff > absYDiff or absYDiff > maxDist then
      return false
    end
  else
    if absYDiff > absXDiff or absXDiff > maxDist then
      return false
    end
  end

  return true
end

function Golf:generateOrders(unitId, canMove)
    local orders = {}

    local unit = Wargroove.getUnitById(unitId)
    local unitClass = Wargroove.getUnitClass(unit.unitClassId)
    local movePositions = {}
    if canMove then
        movePositions = Wargroove.getTargetsInRange(unit.pos, unitClass.moveRange, "empty")
    end
    table.insert(movePositions, unit.pos)

    local function canTarget(u)
        if Wargroove.hasAIRestriction(u.id, "dont_target_this") then
            return false
        end
        if Wargroove.hasAIRestriction(unit.id, "only_target_commander") and not u.unitClass.isCommander then
            return false
        end
        return true
    end

    local originalPos = unit.pos
    for i, pos in pairs(movePositions) do
        Wargroove.pushUnitPos(unit, pos)
        local teleportPositionsInRange = Wargroove.getTargetsInRange(pos, maxGolfRange, "empty")

        local moved = originalPos.x ~= pos.x or originalPos.y ~= pos.y

        local targets = Wargroove.getTargetsInRange(pos, 1, "unit")
        for j, targetPos in pairs(targets) do
            local u = Wargroove.getUnitAt(targetPos)

            if u ~= nil and self:canSeeTarget(targetPos) and canTarget(u) then
                local teleportPositions = {}
                for i, teleportPos in ipairs(teleportPositionsInRange) do
                    local unitAtPos = Wargroove.getUnitAt(teleportPos)                    
                    local spaceIsEmpty = (unitAtPos == nil and (teleportPos.x ~= pos.x or teleportPos.y ~= pos.y)) or (unitAtPos.id == unit.id and moved)
                    if self:isInCone(pos, targetPos, teleportPos) and spaceIsEmpty and Wargroove.canStandAt(u.unitClassId, teleportPos) then
                        table.insert(teleportPositions, teleportPos)
                    end
                end

                local uc = Wargroove.getUnitClass(u.unitClassId)
                if not uc.isStructure and (not uc.isCommander or not Wargroove.areEnemies(u.playerId, unit.playerId)) and u.playerId >= 0 then
                    for k, teleportPosition in pairs(teleportPositions) do
                        if (teleportPosition.x ~= pos.x or teleportPosition.y ~= pos.y) and (teleportPosition.x ~= targetPos.x or teleportPosition.y ~= targetPos.y) then
                            local strParam = u.id .. ";" .. teleportPosition.x .. "," .. teleportPosition.y
                            local endPosition = pos
                            local targetPosition = u.pos
                            if u.id == unit.id then
                                endPosition = teleportPosition
                                targetPosition = originalPos
                            end
                            orders[#orders+1] = {targetPosition = targetPosition, strParam = strParam, movePosition = pos, endPosition = endPosition}
                        end
                    end
                end
            end
        end
        Wargroove.popUnitPos()
    end

    return orders
end

return Golf
