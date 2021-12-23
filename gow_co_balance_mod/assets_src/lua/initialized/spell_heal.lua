local Wargroove = require "wargroove/wargroove"
local Verb = require "wargroove/verb"
local OldSpellHeal = require "verbs/spell_heal"

local SpellHeal = Verb:new()

function SpellHeal:init()
	OldSpellHeal.execute = SpellHeal.execute
end

local spellCost = 300
local healAmount = 20
local costScoreFactor = 0.5


function SpellHeal:getCostAt(unit, endPos, targetPos)
    return spellCost
end


function SpellHeal:execute(unit, targetPos, strParam, path)
    Wargroove.changeMoney(unit.playerId, -spellCost)
    local targets = Wargroove.getTargetsInRange(targetPos, 1, "unit")

    local function distFromTarget(a)
        return math.abs(a.x - targetPos.x) + math.abs(a.y - targetPos.y)
    end
    table.sort(targets, function(a, b) return distFromTarget(a) < distFromTarget(b) end)

    Wargroove.spawnMapAnimation(targetPos, 1, "fx/heal_spell", "idle", "over_units", {x = 11, y = 11})
    Wargroove.playMapSound("mageSpell", targetPos)
    Wargroove.waitTime(0.7)

    for i, pos in ipairs(targets) do
        local u = Wargroove.getUnitAt(pos)
        if u ~= nil then
            local uc = u.unitClass
            local lastHealedTurn = tonumber(Wargroove.getUnitState(u, "lastHealedTurn"))
            local lastHealedPlayer = tonumber(Wargroove.getUnitState(u, "lastHealedPlayer"))
            local neverHealed = lastHealedTurn == nil or lastHealedPlayer == nil
            if Wargroove.areAllies(u.playerId, unit.playerId) and (not uc.isStructure) and (neverHealed or (lastHealedTurn < Wargroove.getTurnNumber() or lastHealedPlayer ~= Wargroove.getCurrentPlayerId())) then
                Wargroove.playMapSound("unitHealed", pos)
				--Only heals when below 100 hp to prevent removing Overheal
				if u.health < 100 then
					u:setHealth(u.health + healAmount, unit.id)
                    Wargroove.setUnitState(u, "lastHealedTurn", Wargroove.getTurnNumber())
                    Wargroove.setUnitState(u, "lastHealedPlayer", Wargroove.getCurrentPlayerId())
				end
                Wargroove.updateUnit(u)
                Wargroove.spawnMapAnimation(pos, 0, "fx/heal_unit")
                Wargroove.waitTime(0.2)
            end
        end
    end
    Wargroove.waitTime(0.3)
end


function SpellHeal:generateOrders(unitId, canMove)
    local orders = {}

    local unit = Wargroove.getUnitById(unitId)
    if not self:canExecuteAnywhere(unit) then
        return orders
    end

    local unitClass = Wargroove.getUnitClass(unit.unitClassId)
    local movePositions = {}
    if canMove then
        movePositions = Wargroove.getTargetsInRange(unit.pos, unitClass.moveRange, "empty")
    end
    table.insert(movePositions, unit.pos)

    for i, pos in ipairs(movePositions) do
        Wargroove.pushUnitPos(unit, pos)
        local targets = Wargroove.getTargetsInRange(pos, self:getMaximumRange(unit, pos), "all")
        for j, target in ipairs(targets) do
            local targetUnitPositions = Wargroove.getTargetsInRange(target, 1, "unit")
            local healsAlly = false
            for k, targetUnitPos in ipairs(targetUnitPositions) do
                local u = Wargroove.getUnitAt(targetUnitPos)
                if u ~= nil then
                    local uc = u.unitClass
                    if Wargroove.areAllies(u.playerId, unit.playerId) and (not uc.isStructure) and u.health ~= 100 then
                        healsAlly = true
                    end
                end
            end
            if healsAlly then
                table.insert(orders, { targetPosition = target, strParam = "", movePosition = pos, endPosition = pos })
            end
        end
        Wargroove.popUnitPos()
    end

    return orders
end

function SpellHeal:getScore(unitId, order)
    local unit = Wargroove.getUnitById(unitId)

    Wargroove.pushUnitPos(unit, order.movePosition)

    local healScore = 0

    local selfHealAmount = 0
    local targetUnitPositions = Wargroove.getTargetsInRange(order.targetPosition, 1, "unit")
    for i, targetUnitPos in ipairs(targetUnitPositions) do
        local u = Wargroove.getUnitAt(targetUnitPos)
        if u ~= nil then
            local uc = u.unitClass
            if Wargroove.areAllies(u.playerId, unit.playerId) and (not uc.isStructure) then
                local healing = math.min(healAmount, 100 - u.health)
                if u.id == unitId then
                    selfHealAmount = healing
                end
                local unitValue = math.sqrt(uc.cost / 100)
                if uc.isCommander then
                    unitValue = 10
                end
                healScore = healScore + (healing / 100) * unitValue
            end
        end
    end

    local costScore = -math.sqrt(spellCost / 100) * costScoreFactor
    local score = healScore + costScore

    Wargroove.popUnitPos()
    return { score = score, healthDelta = selfHealAmount, introspection = {
        { key = "healScore", value = healScore },
        { key = "cost", value = spellCost },
        { key = "costScore", value = costScore },
        { key = "selfHealAmount", value = selfHealAmount }}}
end

return SpellHeal
