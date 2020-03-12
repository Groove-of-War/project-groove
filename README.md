# cma-wargroove-mods

A collection of Wargroove mods I've been working on

Mods contained:
- Balance mod
- Logging mod

##Balance Mod

This mod adjusts balance from 2.0

- Koji drone damage taken (`damageMultiplier`) 50% -> 85%
- Giant
    - movement 5 -> 3
    - attack cleaves in shape like this
        ```
        - - X
        - G X
        - - X
        ```
implementation notes:


##Logging Mod

The purpose of this mod is to log information in a replay format for usage in a Javascript web application

Progress:
- Have confirmed access to the following:
    - unit moves
        - path taken
    - unit actions
        - damage dealt ?
    - map terrain
    
