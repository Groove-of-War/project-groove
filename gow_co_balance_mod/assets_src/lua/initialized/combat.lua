local OriginalCombat = require "wargroove/combat"
local Wargroove = require("wargroove/wargroove")

local Combat = {}

local defencePerShield = 0.10
local damageAt0Health = 0.0
local damageAt100Health = 1.0

function Combat:init()
    --OriginalCombat.solveDamage = Combat.solveDamage
    Combat.originalGetDamage = OriginalCombat.getDamage
    OriginalCombat.getDamage = Combat.getDamage
end

function Combat:getDamage(attacker, defender, solveType, isCounter, attackerPos, defenderPos, attackerPath, isGroove, grooveWeaponIdOverride)
    if attacker.unitClass.isStructure or defender.unitClass.isStructure then
        solveType = "NoRng"
    end
    if type(solveType) ~= "string" then
        error("solveType should be a string. Value is " .. tostring(solveType))
    end

    local delta = {x = defenderPos.x - attackerPos.x, y = defenderPos.y - attackerPos.y }
    local moved = attackerPath and #attackerPath > 1

    local defenderUnitClass = Wargroove.getUnitClass(defender.unitClassId)
    local defenderIsInAir = defenderUnitClass.inAir
    local defenderIsStructure = defenderUnitClass.isStructure

    local terrainDefence
    if defenderIsInAir then
        terrainDefence = Wargroove.getSkyDefenceAt(defenderPos)
    elseif defenderIsStructure then
        terrainDefence = 0
    else
        terrainDefence = Wargroove.getTerrainDefenceAt(defenderPos)
    end

    local randomValue = 0.5
    local bestRand = 0.5
    if terrainDefence == 4 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 0.6
    end
    if terrainDefence == 3 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 0.7
    end

    if terrainDefence == 2 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 0.8
    end
    if terrainDefence == 1 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 0.9
    end
    if terrainDefence == 0 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 1.0
    end
    if terrainDefence == -1 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 1.1
    end
    if terrainDefence == -2 and (solveType == "simulationOptimistic" or solveType == "simulationPessimistic") then
        bestRand = 1.2
    end
    if solveType == "random" and Wargroove.isRNGEnabled() then
        local values = { attacker.id, attacker.unitClassId, attacker.startPos.x, attacker.startPos.y, attackerPos.x, attackerPos.y,
            defender.id, defender.unitClassId, defender.startPos.x, defender.startPos.y, defenderPos.x, defenderPos.y,
            isCounter, Wargroove.getTurnNumber(), Wargroove.getCurrentPlayerId() }
        local str = ""
        for i, v in ipairs(values) do
            str = str .. tostring(v) .. ":"
        end
        local terrainRandomInfluence = 8 - (terrainDefence + 2)
        local rand = Wargroove.pseudoRandomFromString(str)
        if terrainDefence == 4 then
            bestRand = 0.6
            if rand < 0.5 then
                randomValue = 0.5
            else
                randomValue =  0.6
            end
        end
        if terrainDefence == 3 then
            bestRand = 0.7
            if rand < 0.33 then
                randomValue = 0.5
            elseif rand < 0.66 then
                randomValue =  0.6
            else
                randomValue =  0.7
            end
        end

        if terrainDefence == 2 then
            bestRand = 0.8
            if rand < 0.25 then
                randomValue = 0.5
            elseif rand < 0.5 then
                randomValue =  0.6
            elseif rand < 0.75 then
                randomValue =  0.7
            else
                randomValue =  0.8
            end
        end
        if terrainDefence == 1 then
            bestRand = 0.9
            if rand < 0.2 then
                randomValue = 0.5
            elseif rand < 0.4 then
                randomValue =  0.6
            elseif rand < 0.6 then
                randomValue =  0.7
            elseif rand < 0.8 then
                randomValue =  0.8
            else
                randomValue =  0.9
            end
        end
        if terrainDefence == 0 then
            bestRand = 1.0
            if rand < 0.17 then
                randomValue = 0.5
            elseif rand < 0.33 then
                randomValue =  0.6
            elseif rand < 0.5 then
                randomValue =  0.7
            elseif rand < 0.66 then
                randomValue =  0.8
            elseif rand < 0.83 then
                randomValue =  0.9
            else
                randomValue =  1.0
            end
        end
        if terrainDefence == -1 then
            bestRand = 1.1
            if rand < 0.14 then
                randomValue = 0.5
            elseif rand < 0.29 then
                randomValue =  0.6
            elseif rand < 0.43 then
                randomValue =  0.7
            elseif rand < 0.57 then
                randomValue =  0.8
            elseif rand < 0.71 then
                randomValue =  0.9
            elseif rand < 0.86 then
                randomValue =  1.0
            else
                randomValue =  1.1
            end
        end
        if terrainDefence == -2 then
            bestRand = 1.2
            if rand < 0.13 then
                randomValue = 0.5
            elseif rand < 0.25 then
                randomValue =  0.6
            elseif rand < 0.38 then
                randomValue =  0.7
            elseif rand < 0.5 then
                randomValue =  0.8
            elseif rand < 0.62 then
                randomValue =  0.9
            elseif rand < 0.75 then
                randomValue =  1.0
            elseif rand < 0.88 then
                randomValue =  1.1
            else
                randomValue =  1.2
            end
        end

    end
    if solveType == "simulationOptimistic" then
        if isCounter then
            randomValue = 0.5
        else
            randomValue = bestRand
        end
    end
    if solveType == "simulationPessimistic" then
        if isCounter then
            randomValue = bestRand
        else
            randomValue = 0.5
        end
    end

    local attackerHealth = isGroove and 100 or attacker.health
    local attackerEffectiveness = (attackerHealth * 0.01) * (damageAt100Health - damageAt0Health) + damageAt0Health
    local defenderEffectiveness = (defender.health * 0.01) * (damageAt100Health - damageAt0Health) + damageAt0Health

    -- For structures, check if there's a garrison; if so, attack as if it was that instead
    local effectiveAttacker
    if attacker.garrisonClassId ~= '' then
        effectiveAttacker = {
            id = attacker.id,
            pos = attacker.pos,
            startPos = attacker.startPos,
            playerId = attacker.playerId,
            unitClassId = attacker.garrisonClassId,
            unitClass = Wargroove.getUnitClass(attacker.garrisonClassId),
            health = attackerHealth,
            state = attacker.state,
            damageTakenPercent = attacker.damageTakenPercent
        }
        attackerEffectiveness = 1.0
    else
        effectiveAttacker = attacker
    end

    local passiveMultiplier = self:getPassiveMultiplier(effectiveAttacker, defender, attackerPos, defenderPos, attackerPath, isCounter, attacker.state)

    local terrainDefenceBonus = terrainDefence * defencePerShield

    local baseDamage
    if (isGroove) then
        local weaponId
        if (grooveWeaponIdOverride ~= nil) then
            weaponId = grooveWeaponIdOverride
        else
            weaponId = attacker.unitClass.weapons[1].id
        end
        baseDamage = Wargroove.getWeaponDamageForceGround(weaponId, defender)
    else
        local weapon
        weapon, baseDamage = self:getBestWeapon(effectiveAttacker, defender, delta, moved, attackerPos.facing)

        if weapon == nil or (isCounter and not weapon.canMoveAndAttack) or baseDamage < 0.01 then
            return nil, false
        end

        if #(weapon.terrainExclusion) > 0 then
            local targetTerrain = Wargroove.getTerrainNameAt(defenderPos)
            for i, terrain in ipairs(weapon.terrainExclusion) do
                if targetTerrain == terrain then
                    return nil, false
                end
            end
        end
    end

    local multiplier = 1.0
    if Wargroove.isHuman(defender.playerId) then
        multiplier = Wargroove.getDamageMultiplier()

        -- If the player is on "easy" for damage, make the AI overlook that.
        if multiplier < 1.0 and solveType == "aiSimulation" then
            multiplier = 1.0
        end
    end

    -- Damage reduction
    multiplier = multiplier * defender.damageTakenPercent / 100

    local damage = self:solveDamage(baseDamage, attackerEffectiveness, defenderEffectiveness, terrainDefenceBonus, randomValue, passiveMultiplier, multiplier)

    local hasPassive = passiveMultiplier > 1.01
    return damage, hasPassive
end

return Combat
