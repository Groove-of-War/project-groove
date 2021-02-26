local OriginalCombat = require "wargroove/combat"

local Combat = {}

local randomDamageMin = 0.02
local randomDamageMax = 0.08
local randomDamagePercent = 0.1

function Combat:init()
    OriginalCombat.solveDamage = Combat.solveDamage
    Combat.originalGetDamage = OriginalCombat.getDamage
    OriginalCombat.getDamage = Combat.getDamage
end

function Combat:getDamage(attacker, defender, solveType, isCounter, attackerPos, defenderPos, attackerPath, isGroove, grooveWeaponIdOverride)
    if attacker.unitClass.isCommander or attacker.unitClass.isStructure or defender.unitClass.isCommander or defender.unitClass.isStructure then
        solveType = "NoRng"
    end
    return Combat.originalGetDamage(OriginalCombat, attacker, defender, solveType, isCounter, attackerPos, defenderPos, attackerPath, isGroove, grooveWeaponIdOverride)
end

function Combat:solveDamage(weaponDamage, attackerEffectiveness, defenderEffectiveness, terrainDefenceBonus, randomValue, crit, multiplier)
    -- weaponDamage: the base damage, e.g. soldiers do 0.55 base vs soldiers
    -- attackerEffectiveness: the health of the attacker divided by 100. e.g. a soldier at half health is 0.5
    -- defenderEffectiveness: the health of the defender divided by 100
    -- terrainDefenceBonus: 0.1 * number of shields, or -0.1 * number of skulls. e.g. 0.3 for forests and -0.2 for rivers
    -- randomValue: a random number from 0.0 to 1.0
    -- crit: a damage multiplier from critical damage. 1.0 if not critical, > 1.0 for crits (depending on the attacker)
    -- multiplier: a general multiplier, from campaign difficulty and map editor unit damage multiplier

    -- Adjust RNG as follows: rng' = rng * rngMult + rngAdd
    -- This ensures that the average damage remains the same, but clamps the rng range to 10%
    local rngTerrainMult = 0.0
    if terrainDefenceBonus < 0.0 then
        rngTerrainMult = -terrainDefenceBonus
    end
    local rngMult = (1.0 - rngTerrainMult) / math.max(1.0, crit)
    local rngAdd = (1.0 - rngMult) * 0.5
    local randomBonus = randomDamageMin + (randomDamageMax - randomDamageMin) * (randomValue * rngMult + rngAdd)
    local randomPercent = (randomValue - 0.5) * 2.0 * randomDamagePercent

    -- Compute the offence and defence based on the different stats
    local offence = weaponDamage + randomBonus
    local averageOffence = weaponDamage + (randomDamageMax - randomDamageMin) / 2.0
    local defence = 1.0 - (math.min( 1.0, defenderEffectiveness) * math.max(0, terrainDefenceBonus) - math.max(0, -terrainDefenceBonus))

    -- Multiply everything together for final damage (in percent space, not unit health space - still needs to be multiplied by 100)
    local averageDamage = attackerEffectiveness * averageOffence * defence * multiplier * crit

    if averageDamage * randomDamagePercent < 0.03 then
        damage = attackerEffectiveness * averageOffence * defence * multiplier * crit
        damage = damage + damage * randomPercent
    else
        damage = attackerEffectiveness * offence * defence * multiplier * crit
    end

    -- Minimum of 1 damage, if any damage is dealt
    local wholeDamage = math.floor(100 * damage + 0.5)
    if damage > 0.001 and wholeDamage < 1 then
        wholeDamage = 1
    end
    return wholeDamage
end

return Combat
