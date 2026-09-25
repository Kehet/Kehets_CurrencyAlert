# Kehet's CurrencyAlert

A World of Warcraft addon that warns you before a currency reaches its cap, so you do not lose gains to overflow.

## Alerts

When a tracked currency goes up and is at or above its alert threshold, the addon shows a raid warning, prints a chat message and plays an alarm sound. The message looks like `Justice Points soon full! (3950/4000)`.

When a currency is already at its cap, you get a different alarm and a `... is full!` message.

## Tracked currencies

| Category | Currencies |
|---|---|
| Archaeology | Dwarf, Troll, Fossil, Night Elf, Orc, Draenei, Vrykul, Nerubian, Tol'vir, Pandaren, Mogu and Mantid fragments |
| Dungeon | Justice Points, Valor Points, Fissure Stone Fragment, August Stone Fragment, Elder Charm of Good Fortune |
| PvP | Honor Points |

Valor Points tracking is off by default. All other currencies are on.

The default threshold depends on the cap:

| Cap | Default threshold |
|---|---|
| Over 1000 | Cap minus 500 |
| 101 to 1000 | Cap minus 25 |
| 11 to 100 | Cap minus 10 |
| 10 or less | Cap minus 1 |

## Settings

Open Options > AddOns > Kehet's CurrencyAlert. Each currency has a toggle for tracking and a slider for its alert threshold. The settings become available a few seconds after login.

## Requirements

- World of Warcraft: Mists of Pandaria Classic
- The [Ace3](https://www.curseforge.com/wow/addons/ace3) addon
