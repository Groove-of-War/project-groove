# Project Groove

A Wargroove mod for re-balanced and enhanced competitive play compatible with game version 2.1

Balance and Design:
- Barrett

Contributors:
- Unicarn
- FlySniper
- CMAvelis
- Emo Tarquin

## Changes:
### Commanders:
- Caesar 
    - charge speed: medium -> slow
- Dark Mercia
    - groove changes:
        - charge speed: slow -> medium
        - damage: 30 -> 25
        - can **overheal** (see Game Mechanics) to a maximum of 200 HP, which lasts until the start of your next turn
            - see Game Mechanics for information on Overhealing
- Elodie 
    - charge speed: slow -> medium
- Errol & Orla
    - groove mechanics:
        - both grooves may be used once groove is charged, instead of one or the other
        - Scorching Fire is shown as the only groove, then Cooling Water appears as an option afterward (due to simplicity of programming it this way)
        - choosing "Wait" while the Twins can use Cooling Water will reset groove charge to 0 (use it or lose it)
- Mercia
    - groove can now **overheal** units (and self) to a maximum of 105 HP
        - see Game Mechanics for information on Overhealing
- Mercival
    - groove replaced: Diplomacy
        - Fast charge
        - 2 range: Convert an enemy structure to yours at full HP
        - steals 100 gold from enemy as well
        - HQ not included, but production buildings convert with action ready
- Nuru
    - groove can no longer summon "non-formation" units:
        - Golems, Trebuchets, Ballista, Wagons, Dragons, Balloons, Warships, Harpoon Ships and Barges
        - "non-formation" refers to their appearance in fight animations as a single unit, instead of multiple
- Ryota
    - groove damage ramp per jump: +5% -> -3%
    - damage floor set to 0
- Sigrid
    - 2-range teleport added to groove prior to targeting enemy
- Vesper
    - groove change:
        - Vesper now teleports to the targeted location
        - smoke AoE range 2 -> 1

### Units:
- Giant
    - movement type: walking -> riding (what knights use)
- Harpy
    - damage edits
        - spears 0.45 -> 0.5
- Mage
    - damage edits
        - harpy 1.4 -> 1.3
        - witch 1.3 -> 1.2
- Trebuchet
    - min range: 2 -> 4
    - structure base damage: 0.85 -> 0.65
- Thief
    - Steal can now target transports, which will take it over AND kill the thief
- Barge, Turtle, Harpoon Ship, Warship
    - New mechanic: If the unit's action is to "wait", it gets an additional move-only turn
        - Turtle move-only movement range: 6  (rest of ships have same mvt for 1st and 2nd action)
    - Barge has a special action that's only activated if it's not carrying any units
- Barge
    - new action: Free Turn
        - Barges may activate this action to refresh their action if they are not carrying units
    - movement range: 10 -> 12
- Turtle
    - new action: Swim Under
        - Turtle can go to the other side of an enemy air unit or ship (barge, harpoon, warship)
- Harpoon Ship
    - movement range: 4 -> 8
    - attack range: 3-6 -> 3-4
- Warship
    - movement range: 8 -> 9
    - attack range: 2-4 -> 2-3

### Game Mechanics:
#### Terrain:
- Tile movement for "sailing" type units, i.e. non-merfolk naval
    - Ocean: 1 -> 2
    - Beach: 2 -> 3
    - Sea: 2 -> 3
    - Bridge: 2 -> 3
    - Reef: 4 -> 6
- Reef terrain defense: 2 -> 3

#### Damage Calculations:
- Damage variance capped to +/- 10% of the median damage, or +/- 3 HP damage, whichever is lower
    - e.g. for median damage 20, the range will now be 18-22 instead of 17-23
    - However, for median damage 90, the range is 87-93, as before. (not +/- 9)
- All combat engagements involving a CO or structure will have RNG turned off
    - e.g. A spear attacking a CO will have no RNG
    - e.g. A CO attacking a spear will have no RNG
    - e.g. A spear attacking any village/stronghold/barracks/crystal/structure will have no RNG
    - e.g. An archer attacking a CO/structure will have no RNG
    - e.g. A sword attacking a theif/sword/any unit will still have RNG

#### Overhealing (NEW):
- Certain abilities will now cause units to "overheal", i.e. go above 100% HP
- Mage heal is not one of them
- As of 0.7-beta:
    - Commander health will go back down to 100% at the beginning of the CO's turn, when they regenerate
    - units will retain overhealed HP indefinitely
    - damage scales with overhealed HP like normal
    - defense does NOT scale with overhealed HP
    
#### Mana (NEW RESOURCE):
- Mage heal and Witch hex now cost 1 mana instead of 300 gold
- Recruiting a golem, mage, dragon or witch now costs 1 mana in addition to the gold cost
- New structure: Mana Crystal:
    - Can be captured, and neutralized
    - Cannot reinforce
    - Adds 1 mana to the owner's pool
    - When consumed, it's turn is spent
    - All mana is restored at the start of the player's turn
- A crystal indicator will now display your total mana on your HQ
- All villagers are transformed into mana crystals at the start of the first turn


## Implementation Notes
 - All double actions (turtle, harpoon, warship) currently uses temp_units.lua to modify:
    - Wait:onPostUpdateUnit
    - buff_loader.lua
 - Twins double-groove modifies the following:
    - Verb:onPostUpdateUnit
