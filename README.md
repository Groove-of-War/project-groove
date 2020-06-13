# Project Groove

A Wargroove mod for re-balanced and enhanced competitive play compatible with game version 2.1

Balance and Design:
- Gimble

Contributors:
- Unicarn
- CMAvelis

## Changes:
### Commanders:
- Caesar 
    - charge speed: medium -> slow
- Dark Mercia
    - charge speed: slow -> medium
    - damage: 30 -> 25
- Elodie 
    - charge speed: slow -> medium
- Errol & Orla
    - groove mechanics:
        - both grooves may be used once groove is charged, instead of one or the other
        - Scorching Fire is shown as the only groove, then Cooling Water appears as an option afterward (due to simplicity of programming it this way)
        - choosing "Wait" while the Twins can use Cooling Water will reset groove charge to 0 (use it or lose it)
- Mercival
    - groove replaced: Diplomacy
        - Medium charge
        - 2 range: Convert an enemy structure to yours at full HP
        - HQ not included, but production buildings convert with action ready
- Nuru
    - groove can no longer summon "non-formation" units:
        - Golems, Trebuchets, Ballista, Wagons, Dragons, Balloons, Warships, Harpoon Ships and Barges
        - "non-formation" refers to their appearance in fight animations as a single unit, instead of multiple
- Ryota
    - groove damage ramp per jump: +5% -> -5%
- Sigrid
    - 2-range teleport added to groove prior to targeting enemy

### Units:
- Giant
    - movement type: walking -> riding (what knights use)
- Mage
    - damage edits
        - harpy 1.4 -> 1.3
        - witch 1.3 -> 1.2
- Trebuchet
    - min range: 2 -> 4
    - structure base damage: 0.85 -> 0.65

- Barge, Turle, Harpoon Ship, Warship
    - New mechanic: If the unit's action is to "wait", it gets an additional move-only turn
        - Turtle move-only movement range: 6  (rest of ships have same mvt for 1st and 2nd action)
    - Barge has a special action that's only activated if it's not carrying any units
- Barge
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
- Tile movement for "sailing" type units, i.e. non-merfolk naval
    - Ocean: 1 -> 2
    - Beach: 2 -> 3
    - Sea: 2 -> 3
    - Bridge: 2 -> 3
    - Reef: 4 -> 6


## Implementation Notes
 - All double actions (turtle, harpoon, warship) currently uses temp_units.lua to modify:
    - Wait:onPostUpdateUnit
    - buff_loader.lua
 - Twins double-groove modifies the following:
    - Verb:onPostUpdateUnit
