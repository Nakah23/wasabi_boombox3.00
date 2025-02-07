# wasabi_boombox

This resource was created as a ESX/QB free portable boombox script capable of playing youtube links.

<b>Features:</b>
- Usable boombox
- Full animations and boombox prop
- Ability to save songs for later use
- Play any youtube song
- Adjust volume
- Stop music on boombox pick-up
- Play music truly anywhere
- Uses 0.00ms on idle and 0.01ms~ when boombox prop attached to hand
- Optional Discord webhooks(Set in `server.lua`)


## Installation

- Download this script
- Import if framework ESX use this one > `ESXSQL.sql` if framework is QB use this one > `QBSQL.sql` file to database.
- For QBCore Add item Name Into Items Table.
- Download ox_lib(If you don't have): https://github.com/overextended/ox_lib/releases.
- Download qtarget or ox_target(If using ESX): https://github.com/overextended/qtarget.
- Download qb-target(If using QB): https://github.com/qbcore-framework/qb-target.
- Download xsound(If you don't have): https://github.com/Xogy/xsound.
- Put script in your `resources` directory.
- Make sure the following are running in your `server.cfg`:

##QBCore SQl
```
CREATE TABLE IF NOT EXISTS `boombox_songs` (
  `citizenid` varchar(64) NOT NULL,
  `label` varchar(30) NOT NULL,
  `link` longtext NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
```

```
#ensure rpemotes-reborn or HERE?
ensure ox_lib
ensure qtarget or ensure qb-target
#ensure rpemotes-reborn or HERE?
ensure xsound
ensure rpemotes-reborn
ensure wasabi_boombox
```

### Extra Information
- Inventory image included in the `InventoryImages` directory
- You must add the item `boombox`(or whatever config item is set as) to your items database/table.

## Preview
https://www.youtube.com/watch?v=P4VfaLsN_U8

# Support
<a href='https://discord.gg/79zjvy4JMs'>![Discord Banner 2](https://discordapp.com/api/guilds/1025493337031049358/widget.png?style=banner2)</a>


ADD SNIPPET WITH ALL CREDS TO OX AND RPEMOTES-REBORN SCRIPTS TO MAKE IT POSSIBLE UPDATE. MAYBE WASABI HAS ANOTHER PLAN TO THIS?
ALL CREDS TO WASABI, FIRST SCRIPTS EVER HAD!


OX DATA ITEMS:

```
	["prop_boombox_01"] = {
		label = "BoomBox",
		weight = 2000,
		stack = false,
		close = true,
		buttons = {{ 
			label = 'Drop Boombox', 
			action = function(slot) 
				TriggerEvent("wasabi_boombox:useBoombox", "prop_boombox_01") 
			end 
		}},
		client = {
			use = function(slot) 
				handleBoomboxUse('prop_boombox_01', "boombox", "boombox2") 
			end,
			usetime = 2500,
			disable = {move = true, car = true, combat = true, mouse = true, sprint = true} --this will be only the time to active on usetime.
		} 
	},
	["prop_ghettoblast_02"] = {
		label = "GhettoBlaster",
		weight = 2000,
		stack = false,
		close = true,
		buttons = {{ 
			label = 'Drop GhettoBlaster', 
			action = function(slot) 
				TriggerEvent("wasabi_boombox:useBoombox", "prop_ghettoblast_02") 
			end 
		}},
		client = {
			use = function(slot) 
				handleBoomboxUse('prop_ghettoblast_02', "ghettoblast", "ghettoblast2") 
			end,
			usetime = 2500,
			disable = {move = true, car = true, combat = true, mouse = true, sprint = true} --this will be only the time to active on usetime.
		} 
	},

```
OX INV MODULES/ITEMS/CLIENT:
```
local function handleBoomboxUse(itemName, emote1, emote2)
    local options = {
        { value = emote1, label = "SoundSystem en Mano" },
        { value = emote2, label = "SoundSystem en Hombro" }
    }
    local choice = lib.inputDialog("Opciones de SoundSystem", {
        { type = 'select', label = "Emote SoundSystem", options = options } 
    })

    if not choice or not choice[1] then return end

    local selectedEmote = choice[1]
    exports["rpemotes-reborn"]:EmoteCommandStart(selectedEmote, 0)

    local playerPed = PlayerPedId()
    local radio = itemName .. "_" .. GetPlayerServerId(PlayerId())

    if not activeRadios[radio] then
        activeRadios[radio] = { pos = GetEntityCoords(playerPed), data = { playing = false } }
    end
    activeRadios[radio].pos = GetEntityCoords(playerPed)
    TriggerServerEvent('wasabi_boombox:syncActive', activeRadios)

    if not activeRadios[radio].data.playing then
        TriggerEvent("wasabi_boombox:playMenu", { type = 'play', id = radio })
    end

    CreateThread(function()
        while exports["rpemotes-reborn"]:IsEmotePlaying() do
            Wait(1000)
            activeRadios[radio].pos = GetEntityCoords(playerPed)
            TriggerServerEvent('wasabi_boombox:syncActive', activeRadios)
        end
        TriggerEvent('wasabi_boombox:stopMusic', radio)
    end)
end
```


RPEMOTES-REBORN ANIMATIONLIST:
```
    ["boombox"] = {
        "move_weapon@jerrycan@generic",
        "idle",
        "Boombox",
        AnimationOptions = {
            Prop = "prop_boombox_01",
            PropBone = 57005,
            PropPlacement = {
                0.27,
                0.0,
                0.0,
                0.0,
                263.0,
                58.0
            },
            EmoteLoop = true,
            EmoteMoving = true
        }
    },
    ["boombox2"] = {
        "molly@boombox1",
        "boombox1_clip",
        "Boombox 2",
        AnimationOptions = {
            Prop = 'prop_ghettoblast_02',
            PropBone = 10706,
            PropPlacement = {
                -0.2310,
                -0.0770,
                0.2410,
                -179.7256,
                176.7406,
                23.0190
            },
            EmoteLoop = true,
            EmoteMoving = true
        }
    },
    ["ghettoblast"] = {
        "move_weapon@jerrycan@generic",
        "idle",
        "Ghettoblast",
        AnimationOptions = {
            Prop = "prop_ghettoblast_02",
            PropBone = 57005,
            PropPlacement = {
                0.27,
                0.0,
                0.0,
                0.0,
                263.0,
                58.0
            },
            EmoteLoop = true,
            EmoteMoving = true
        }
    },
    ["ghettoblast2"] = {
        "molly@boombox1",
        "boombox1_clip",
        "Ghettoblast 2",
        AnimationOptions = {
            Prop = 'prop_ghettoblast_02',
            PropBone = 10706,
            PropPlacement = {
                -0.2310,
                -0.0770,
                0.2410,
                -179.7256,
                176.7406,
                23.0190
            },
            EmoteLoop = true,
            EmoteMoving = true
        }
    },
```

