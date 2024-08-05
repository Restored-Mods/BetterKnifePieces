local mod = RegisterMod("Reward Knife Pieces", 1)
BKP = mod
local game = Game()
local hadKnife1 = false
local hadKnife2 = false
local anyOneHasKnifePiece1 = false
local anyOneHasKnifePiece2 = false
local DarkItemPool = {}
local mscMng = (MMC and MMC.Manager or MusicManager)()
local escapeTrigger = 0
local json = require("json")

local dssdata = {}

local CustomMirrorDoorNames = {"FFGMirrorDoor"}

local function GetRandomDarkPoolItem(seed)
    local newt = 0
    if REPENTOGON then
        local pool = Isaac.GetPoolIdByName("dark mineshaft")
        newt = game:GetItemPool():GetCollectible(pool, true, seed)
        for idx,col in ipairs(DarkItemPool) do
            if col == newt then
                table.remove(DarkItemPool, idx)
            end
        end
    else
        local rng = RNG()
        if seed and type(seed) == "number" then
            rng:SetSeed(seed,35)
        end
        
        if #DarkItemPool > 0 then
            local idx = rng:RandomInt(#DarkItemPool) + 1
            newt = DarkItemPool[idx]
            table.remove(DarkItemPool,idx)
        end
    end
    return newt
end

local function GetMaxCollectibleID()
    return Isaac.GetItemConfig():GetCollectibles().Size -1
end

local function isCollectibleUnlocked(collectibleID, itemPoolOfItem)
    local itemPool = game:GetItemPool()
    for i= 1, GetMaxCollectibleID() do
        if ItemConfig.Config.IsValidCollectible(i) and i ~= collectibleID then
            itemPool:AddRoomBlacklist(i)
        end
    end
    local isUnlocked = false
    for i = 0,50 do -- some samples to make sure
        local collID = itemPool:GetCollectible(itemPoolOfItem, false)
        if collID == collectibleID then
            isUnlocked = true
            break
        end
    end
    itemPool:ResetRoomBlacklist()
    return isUnlocked
end

local function CurseLabyrinth(stage1, stage2)
    local level = game:GetLevel()
    local isCurseLabyrinth = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH
    return level:GetAbsoluteStage() == stage2 and not isCurseLabyrinth or level:GetAbsoluteStage() == stage1 and isCurseLabyrinth
end

local function IsFirstKnifePieceLevel()
    local level = game:GetLevel()
    return level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B and CurseLabyrinth(LevelStage.STAGE1_1, LevelStage.STAGE1_2)
    or StageAPI and StageAPI.GetCurrentStage() and StageAPI.GetCurrentStage():HasMirrorDimension()
end

local function IsSecondKnifePieceLevel()
    local level = game:GetLevel()
    return level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B and CurseLabyrinth(LevelStage.STAGE2_1, LevelStage.STAGE2_2)
    or StageAPI and StageAPI.GetCurrentStage() and StageAPI.GetCurrentStage():HasMineshaftDimension()
end

local function IsMirrorWorld()
    local room = game:GetRoom()
    return StageAPI and StageAPI.IsMirrorDimension() or room:IsMirrorWorld()
end

local function IsThereAMirror()
    if StageAPI and StageAPI.InOverriddenStage() and StageAPI.GetCurrentStage() then
        for _, name in ipairs(CustomMirrorDoorNames) do
            if #StageAPI.GetCustomDoorData(name) > 0 then
                return true
            end
        end
    else
        local room = game:GetRoom()
        for i = 0,4 do
            if room:GetDoor(i) then
                local door = room:GetDoor(i)
                if door.TargetRoomIndex == GridRooms.ROOM_MIRROR_IDX then
                    return true
                end
            end
        end
    end
    return false
end

function mod:Load(isLoad)
    DarkItemPool = {
        CollectibleType.COLLECTIBLE_BOOK_OF_BELIAL,
        CollectibleType.COLLECTIBLE_BOOK_OF_SIN,
        CollectibleType.COLLECTIBLE_PONY,
        CollectibleType.COLLECTIBLE_GUPPYS_PAW,
        CollectibleType.COLLECTIBLE_GUPPYS_HEAD,
        CollectibleType.COLLECTIBLE_D8,
        CollectibleType.COLLECTIBLE_MEGA_BLAST,
        CollectibleType.COLLECTIBLE_CLICKER,
        CollectibleType.COLLECTIBLE_MAMA_MEGA,
        CollectibleType.COLLECTIBLE_BOOK_OF_THE_DEAD,
        CollectibleType.COLLECTIBLE_WAVY_CAP,
        CollectibleType.COLLECTIBLE_LEMEGETON,
        CollectibleType.COLLECTIBLE_ANIMA_SOLA,
        CollectibleType.COLLECTIBLE_SPINDOWN_DICE,
        CollectibleType.COLLECTIBLE_20_20,
        CollectibleType.COLLECTIBLE_LUMP_OF_COAL,
        CollectibleType.COLLECTIBLE_BALL_OF_TAR,
        CollectibleType.COLLECTIBLE_BBF,
        CollectibleType.COLLECTIBLE_BLACK_CANDLE,
        CollectibleType.COLLECTIBLE_BLACK_LOTUS,
        CollectibleType.COLLECTIBLE_BOBBY_BOMB,
        CollectibleType.COLLECTIBLE_CAT_O_NINE_TAILS,
        CollectibleType.COLLECTIBLE_CELTIC_CROSS,
        CollectibleType.COLLECTIBLE_CEREMONIAL_ROBES,
        CollectibleType.COLLECTIBLE_CHARM_VAMPIRE,
        CollectibleType.COLLECTIBLE_DARK_BUM,
        CollectibleType.COLLECTIBLE_DEAD_BIRD,
        CollectibleType.COLLECTIBLE_DEAD_CAT,
        CollectibleType.COLLECTIBLE_DEATHS_TOUCH,
        CollectibleType.COLLECTIBLE_DEMON_BABY,
        CollectibleType.COLLECTIBLE_DISTANT_ADMIRATION,
        CollectibleType.COLLECTIBLE_EVES_MASCARA,
        CollectibleType.COLLECTIBLE_GIMPY,
        CollectibleType.COLLECTIBLE_GUPPYS_TAIL,
        CollectibleType.COLLECTIBLE_HALO_OF_FLIES,
        CollectibleType.COLLECTIBLE_JUDAS_SHADOW,
        CollectibleType.COLLECTIBLE_LEECH,
        CollectibleType.COLLECTIBLE_LIL_BRIMSTONE,
        CollectibleType.COLLECTIBLE_LITTLE_GISH,
        CollectibleType.COLLECTIBLE_LITTLE_STEVEN,
        CollectibleType.COLLECTIBLE_LOKIS_HORNS,
        CollectibleType.COLLECTIBLE_MAGIC_8_BALL,
        CollectibleType.COLLECTIBLE_PYRO,
        CollectibleType.COLLECTIBLE_SAD_BOMBS,
        CollectibleType.COLLECTIBLE_SAMSONS_CHAINS,
        CollectibleType.COLLECTIBLE_SPIDER_BITE,
        CollectibleType.COLLECTIBLE_STEVEN,
        CollectibleType.COLLECTIBLE_STRANGE_ATTRACTOR,
        CollectibleType.COLLECTIBLE_BLACK_BEAN,
        CollectibleType.COLLECTIBLE_ATHAME,
        CollectibleType.COLLECTIBLE_BLACK_POWDER,
        CollectibleType.COLLECTIBLE_CAR_BATTERY,
        CollectibleType.COLLECTIBLE_EMPTY_VESSEL,
        CollectibleType.COLLECTIBLE_INCUBUS,
        CollectibleType.COLLECTIBLE_MY_SHADOW,
        CollectibleType.COLLECTIBLE_SCATTER_BOMBS,
        CollectibleType.COLLECTIBLE_SPEAR_OF_DESTINY,
        CollectibleType.COLLECTIBLE_SUCCUBUS,
        CollectibleType.COLLECTIBLE_ANALOG_STICK,
        CollectibleType.COLLECTIBLE_BROKEN_MODEM,
        CollectibleType.COLLECTIBLE_DARK_PRINCES_CROWN,
        CollectibleType.COLLECTIBLE_EUTHANASIA,
        CollectibleType.COLLECTIBLE_FAST_BOMBS,
        CollectibleType.COLLECTIBLE_FLAT_STONE,
        CollectibleType.COLLECTIBLE_JUMPER_CABLES,
        CollectibleType.COLLECTIBLE_LITTLE_HORN,
        CollectibleType.COLLECTIBLE_POKE_GO,
        CollectibleType.COLLECTIBLE_4_5_VOLT,
        CollectibleType.COLLECTIBLE_POUND_OF_FLESH,
        CollectibleType.COLLECTIBLE_AZAZELS_RAGE,
        CollectibleType.COLLECTIBLE_BRIMSTONE_BOMBS,
        CollectibleType.COLLECTIBLE_EMPTY_HEART,
        CollectibleType.COLLECTIBLE_ISAACS_TOMB,
        CollectibleType.COLLECTIBLE_KEEPERS_SACK,
        CollectibleType.COLLECTIBLE_KEEPERS_KIN,
        CollectibleType.COLLECTIBLE_LIL_ABADDON,
        CollectibleType.COLLECTIBLE_LIL_PORTAL,
        CollectibleType.COLLECTIBLE_LODESTONE,
        CollectibleType.COLLECTIBLE_QUINTS,
        CollectibleType.COLLECTIBLE_ROCKET_IN_A_JAR,
        CollectibleType.COLLECTIBLE_STAPLER,
        CollectibleType.COLLECTIBLE_INTRUDER,
        CollectibleType.COLLECTIBLE_SWARM,
        CollectibleType.COLLECTIBLE_TINYTOMA,
        CollectibleType.COLLECTIBLE_TOOTH_AND_NAIL,
        CollectibleType.COLLECTIBLE_TWISTED_PAIR
    }

    if mod:HasData() then
        local load = json.decode(mod:LoadData())
        hadKnife1 = load[1]
        hadKnife2 = load[2]
        if isLoad then
            anyOneHasKnifePiece1 = load[3]
            anyOneHasKnifePiece2 = load[4]
            DarkItemPool = load[5]
        else
            anyOneHasKnifePiece1 = false
            anyOneHasKnifePiece2 = false
        end
        if load[6] ~= nil then
            dssdata = load[6]
        else
            dssdata = {}
        end
    end
    
    local i = 1
    while i <= #DarkItemPool do
        if isCollectibleUnlocked(DarkItemPool[i],-1) then
            table.remove(DarkItemPool,i)
        else
            i = i + 1
        end
    end
    
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.Load)

function mod:Save(isSave)
    mod:SaveData(json.encode({hadKnife1,hadKnife2,anyOneHasKnifePiece1,anyOneHasKnifePiece2,DarkItemPool,dssdata}))
end
mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.Save)

function mod:PlayEscape()
    if escapeTrigger > 0 then
        escapeTrigger = escapeTrigger - 1
    else
        mscMng:Play(Music.MUSIC_MINESHAFT_ESCAPE, Options.MusicVolume)
        mod:RemoveCallback(ModCallbacks.MC_POST_RENDER,mod.PlayEscape)
    end
end

function mod:UpdateDarkPool(id,itempool,decrease,seed)
    for i = 1, #DarkItemPool do
        if id == DarkItemPool[i] then
            table.remove(DarkItemPool,i)
            break
        end
    end
    return nil
end
mod:AddCallback(ModCallbacks.MC_POST_GET_COLLECTIBLE, mod.UpdateDarkPool)

function mod:SpawnKnifePieces()
    local room = game:GetRoom()
    local itemPool = game:GetItemPool()
    anyOneHasKnifePiece1 = false
    anyOneHasKnifePiece2 = false
    local anyHasChaos = false
    if REPENTOGON then
        anyOneHasKnifePiece1 = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
        anyOneHasKnifePiece2 = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
        anyHasChaos = PlayerManager.AnyoneHasCollectible(CollectibleType.COLLECTIBLE_CHAOS)
    else
        for _,p in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER,-1,-1)) do
            p = p:ToPlayer()
            if p:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
                anyOneHasKnifePiece1 = true
            end
            if p:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) then
                anyOneHasKnifePiece2 = true
            end
            if p:HasCollectible(CollectibleType.COLLECTIBLE_CHAOS) then
                anyHasChaos = true
            end
        end
    end
    
    if IsFirstKnifePieceLevel() then
        if not IsMirrorWorld() then
            if IsThereAMirror() then
                if room:IsFirstVisit() and hadKnife1 and not anyOneHasKnifePiece1 then
                    local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1, room:GetCenterPos(), Vector.Zero,nil):ToPickup()
                    pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1, true, true, true)
                    pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                    pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                elseif not hadKnife1 and anyOneHasKnifePiece1 then
                    hadKnife1 = true
                    mod:SaveData(json.encode({hadKnife1,hadKnife2,anyOneHasKnifePiece1,anyOneHasKnifePiece2,DarkItemPool}))
                end
            end
        elseif IsMirrorWorld() and room:GetType() == RoomType.ROOM_TREASURE and hadKnife1 and room:IsFirstVisit() then
            local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
            if items[1] then
                local item = items[1]:ToPickup()
                local newitem = itemPool:GetCollectible(itemPool:GetLastPool(),true,item.InitSeed)
                item:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, newitem,true,true)
            end
        end
    end
    if IsSecondKnifePieceLevel() then
        if not room:HasCurseMist() then
            for i = 0,4 do
                if room:GetDoor(i) then
                    local door = room:GetDoor(i)
                    if door.TargetRoomIndex == GridRooms.ROOM_MINESHAFT_IDX then
                        if room:IsFirstVisit() and hadKnife2 and not anyOneHasKnifePiece2 then
                            local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2, room:GetCenterPos() + Vector(0,100), Vector.Zero,nil):ToPickup()
                            pickup:Morph(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2, true, true, true)
                            pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                            pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                        elseif not hadKnife2 and anyOneHasKnifePiece2 then
                            hadKnife2 = true
                            mod:SaveData(json.encode({hadKnife1,hadKnife2,anyOneHasKnifePiece1,anyOneHasKnifePiece2,DarkItemPool}))
                        end
                        break
                    end
                end
            end
        elseif room:HasCurseMist() and hadKnife2 and room:IsFirstVisit() then
            local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
            if items[1] then
                local item = items[1]:ToPickup()
                local newitem = GetRandomDarkPoolItem(item.InitSeed)
                if newitem == 0 or anyHasChaos then
                    newitem = itemPool:GetCollectible(itemPool:GetLastPool(),true,item.InitSeed)
                end
                item:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, newitem,true,true)
                mscMng:Play(Music.MUSIC_MOTHERS_SHADOW_INTRO, Options.MusicVolume)
                escapeTrigger = 450
                mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PlayEscape)
            end
        end
    end
    
end
mod:AddPriorityCallback(ModCallbacks.MC_POST_NEW_ROOM, 999, mod.SpawnKnifePieces)


if REPENTOGON then
    function mod:SaveSlotLoaded()
        if mod:HasData() then
            local load = json.decode(mod:LoadData())
            hadKnife1 = load[1]
            hadKnife2 = load[2]
        end
    end
    mod:AddCallback(ModCallbacks.MC_POST_SAVESLOT_LOAD, mod.SaveSlotLoaded)

    if not ImGui.ElementExists("tcMods") then
        ImGui.CreateMenu("tcMods", "TC Mods")
    end

    if not ImGui.ElementExists("betterKnifePieces") then
        ImGui.AddElement("tcMods", "betterKnifePieces", ImGuiElement.MenuItem, "Better Knife Pieces")
    end

    if not ImGui.ElementExists("betterKnifePiecesWindow") then
        ImGui.CreateWindow("betterKnifePiecesWindow", "Better Knife Pieces")
    end

    ImGui.LinkWindowToElement("betterKnifePiecesWindow", "betterKnifePieces")
    ImGui.SetWindowSize("betterKnifePiecesWindow", 350, 170)

    if ImGui.ElementExists("betterKnifePiecesCollected1") then
        ImGui.RemoveElement("betterKnifePiecesCollected1")
    end

    ImGui.AddCheckbox("betterKnifePiecesWindow", "betterKnifePiecesCollected1", "Knife Piece 1 collected", function(val)
        hadKnife1 = val
    end, false)

    if ImGui.ElementExists("betterKnifePiecesCollected2") then
        ImGui.RemoveElement("betterKnifePiecesCollected2")
    end

    ImGui.AddCheckbox("betterKnifePiecesWindow", "betterKnifePiecesCollected2", "Knife Piece 2 collected", function(val)
        hadKnife2 = val
    end, false)

    ImGui.AddCallback("betterKnifePiecesWindow", ImGuiCallback.Render, function()
        ImGui.UpdateData("betterKnifePiecesCollected1", ImGuiData.Value, hadKnife1)
        ImGui.UpdateData("betterKnifePiecesCollected2", ImGuiData.Value, hadKnife2)
    end)
end

-- Change this variable to match your mod. The standard is "Dead Sea Scrolls (Mod Name)"
local DSSModName = "Dead Sea Scrolls (Better Knife Pieces)"

-- DSSCoreVersion determines which menu controls the mod selection menu that allows you to enter other mod menus.
-- Don't change it unless you really need to and make sure if you do that you can handle mod selection and global mod options properly.
local DSSCoreVersion = 7

-- Every MenuProvider function below must have its own implementation in your mod, in order to handle menu save data.
local MenuProvider = {}

function MenuProvider.SaveSaveData()
    mod:Save()
end

function MenuProvider.GetPaletteSetting()
    return dssdata.MenuPalette
end

function MenuProvider.SavePaletteSetting(var)
    dssdata.MenuPalette = var
end

function MenuProvider.GetHudOffsetSetting()
    if not REPENTANCE then
        return dssdata.HudOffset
    else
        return Options.HUDOffset * 10
    end
end

function MenuProvider.SaveHudOffsetSetting(var)
    if not REPENTANCE then
       dssdata.HudOffset = var
    end
end

function MenuProvider.GetGamepadToggleSetting()
    return dssdata.GamepadToggle
end

function MenuProvider.SaveGamepadToggleSetting(var)
   dssdata.GamepadToggle = var
end

function MenuProvider.GetMenuKeybindSetting()
    return dssdata.MenuKeybind
end

function MenuProvider.SaveMenuKeybindSetting(var)
   dssdata.MenuKeybind = var
end

function MenuProvider.GetMenuHintSetting()
    return dssdata.MenuHint
end

function MenuProvider.SaveMenuHintSetting(var)
   dssdata.MenuHint = var
end

function MenuProvider.GetMenuBuzzerSetting()
    return dssdata.MenuBuzzer
end

function MenuProvider.SaveMenuBuzzerSetting(var)
   dssdata.MenuBuzzer = var
end

function MenuProvider.GetMenusNotified()
    return dssdata.MenusNotified
end

function MenuProvider.SaveMenusNotified(var)
   dssdata.MenusNotified = var
end

function MenuProvider.GetMenusPoppedUp()
    return dssdata.MenusPoppedUp
end

function MenuProvider.SaveMenusPoppedUp(var)
    dssdata.MenusPoppedUp = var
end

local DSSInitializerFunction = include("dssmenucore")

-- This function returns a table that some useful functions and defaults are stored on
local dssmod = DSSInitializerFunction(DSSModName, DSSCoreVersion, MenuProvider)


-- Adding a Menu


-- Creating a menu like any other DSS menu is a simple process.
-- You need a "Directory", which defines all of the pages ("items") that can be accessed on your menu, and a "DirectoryKey", which defines the state of the menu.
local bkpdirectory = {
    -- The keys in this table are used to determine button destinations.
    main = {
        -- "title" is the big line of text that shows up at the top of the page!
        title = 'better knife pieces',

        -- "buttons" is a list of objects that will be displayed on this page. The meat of the menu!
        buttons = {
            -- The simplest button has just a "str" tag, which just displays a line of text.
            
            -- The "action" tag can do one of three pre-defined actions:
            --- "resume" closes the menu, like the resume game button on the pause menu. Generally a good idea to have a button for this on your main page!
            --- "back" backs out to the previous menu item, as if you had sent the menu back input
            --- "openmenu" opens a different dss menu, using the "menu" tag of the button as the name
            {str = 'resume game', action = 'resume'},

            -- The "dest" option, if specified, means that pressing the button will send you to that page of your menu.
            -- If using the "openmenu" action, "dest" will pick which item of that menu you are sent to.
            {str = 'settings', dest = 'settings'},

            -- A few default buttons are provided in the table returned from DSSInitializerFunction.
            -- They're buttons that handle generic menu features, like changelogs, palette, and the menu opening keybind
            -- They'll only be visible in your menu if your menu is the only mod menu active; otherwise, they'll show up in the outermost Dead Sea Scrolls menu that lets you pick which mod menu to open.
            -- This one leads to the changelogs menu, which contains changelogs defined by all mods.
            dssmod.changelogsButton,

            -- Text font size can be modified with the "fsize" tag. There are three font sizes, 1, 2, and 3, with 1 being the smallest and 3 being the largest.
        },

        -- A tooltip can be set either on an item or a button, and will display in the corner of the menu while a button is selected or the item is visible with no tooltip selected from a button.
        -- The object returned from DSSInitializerFunction contains a default tooltip that describes how to open the menu, at "menuOpenToolTip"
        -- It's generally a good idea to use that one as a default!
        tooltip = dssmod.menuOpenToolTip
    },
    settings = {
        title = 'settings',
        buttons = {
            -- These buttons are all generic menu handling buttons, provided in the table returned from DSSInitializerFunction
            -- They'll only show up if your menu is the only mod menu active
            -- You should generally include them somewhere in your menu, so that players can change the palette or menu keybind even if your mod is the only menu mod active.
            -- You can position them however you like, though!
            dssmod.gamepadToggleButton,
            dssmod.menuKeybindButton,
            dssmod.paletteButton,
            dssmod.menuHintButton,
            dssmod.menuBuzzerButton,

            {
                str = 'knife piece 1',

                -- The "choices" tag on a button allows you to create a multiple-choice setting
                choices = {'was not collected', 'was collected'},
                -- The "setting" tag determines the default setting, by list index. EG "1" here will result in the default setting being "choice a"
                setting = 1,

                -- "variable" is used as a key to story your setting; just set it to something unique for each setting!
                variable = 'hadKnife1',
                
                -- When the menu is opened, "load" will be called on all settings-buttons
                -- The "load" function for a button should return what its current setting should be
                -- This generally means looking at your mod's save data, and returning whatever setting you have stored
                load = function()
                    return hadKnife1 and 2 or 1
                end,

                -- When the menu is closed, "store" will be called on all settings-buttons
                -- The "store" function for a button should save the button's setting (passed in as the first argument) to save data!
                store = function(var)
                    if var == 1 then
                        hadKnife1 = false
                        hadKnife2 = false
                    else
                        hadKnife1 = true
                    end
                end,

                -- A simple way to define tooltips is using the "strset" tag, where each string in the table is another line of the tooltip
                tooltip = {strset = {'option for', 'knife piece 1.', 'this option', ' will affect','\'knife piece 2\'', 'option below','when leaving', 'dss menu'}}
            },

            {
                str = 'knife piece 2',

                -- The "choices" tag on a button allows you to create a multiple-choice setting
                choices = {'was not collected', 'was collected'},
                -- The "setting" tag determines the default setting, by list index. EG "1" here will result in the default setting being "choice a"
                setting = 1,

                -- "variable" is used as a key to story your setting; just set it to something unique for each setting!
                variable = 'hadKnife2',
                
                -- When the menu is opened, "load" will be called on all settings-buttons
                -- The "load" function for a button should return what its current setting should be
                -- This generally means looking at your mod's save data, and returning whatever setting you have stored
                load = function()
                    return hadKnife2 and 2 or 1
                end,

                -- When the menu is closed, "store" will be called on all settings-buttons
                -- The "store" function for a button should save the button's setting (passed in as the first argument) to save data!
                store = function(var)
                    if var == 1 or not hadKnife1 then
                        hadKnife2 = false
                    else
                        hadKnife2 = true
                    end
                end,

                -- A simple way to define tooltips is using the "strset" tag, where each string in the table is another line of the tooltip
                tooltip = {strset = {'option for', 'knife piece 2.', 'this option','can be set to', '\'was collected\'', 'only when', '\'knife piece 1\'','option set to', '\'was collected\''}}
            },

            {
                -- Creating gaps in your page can be done simply by inserting a blank button.
                -- The "nosel" tag will make it impossible to select, so it'll be skipped over when traversing the menu, while still rendering!
                str = '',
                fsize = 2,
                nosel = true
            },
           
        }
    }
}

local bkpdirectorykey = {
    Item = bkpdirectory.main, -- This is the initial item of the menu, generally you want to set it to your main item
    Main = 'main', -- The main item of the menu is the item that gets opened first when opening your mod's menu.

    -- These are default state variables for the menu; they're important to have in here, but you don't need to change them at all.
    Idle = false,
    MaskAlpha = 1,
    Settings = {},
    SettingsChanged = false,
    Path = {},
}

--#region AgentCucco pause manager for DSS
local OldTimer
local OldTimerBossRush
local OldTimerHush
local OverwrittenPause = false
local AddedPauseCallback = false
local function OverridePause(self, player, hook, action)
	if not AddedPauseCallback then return nil end

	if OverwrittenPause then
		OverwrittenPause = false
		AddedPauseCallback = false
		return
	end

	if action == ButtonAction.ACTION_SHOOTRIGHT then
		OverwrittenPause = true
		for _, ember in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.FALLING_EMBER, -1)) do
			if ember:Exists() then
				ember:Remove()
			end
		end
		if REPENTANCE then
			for _, rain in ipairs(Isaac.FindByType(EntityType.ENTITY_EFFECT, EffectVariant.RAIN_DROP, -1)) do
				if rain:Exists() then
					rain:Remove()
				end
			end
		end
		return true
	end
end
mod:AddCallback(ModCallbacks.MC_INPUT_ACTION, OverridePause, InputHook.IS_ACTION_PRESSED)

local function FreezeGame(unfreeze)
	if unfreeze then
		OldTimer = nil
        OldTimerBossRush = nil
        OldTimerHush = nil
        if not AddedPauseCallback then
			AddedPauseCallback = true
		end
	else
		if not OldTimer then
			OldTimer = Game().TimeCounter
		end
        if not OldTimerBossRush then
            OldTimerBossRush = Game().BossRushParTime
		end
        if not OldTimerHush then
			OldTimerHush = Game().BlueWombParTime
		end
		
        Isaac.GetPlayer(0):UseActiveItem(CollectibleType.COLLECTIBLE_PAUSE, UseFlag.USE_NOANIM)
		
		Game().TimeCounter = OldTimer
		Game().BossRushParTime = OldTimerBossRush
		Game().BlueWombParTime = OldTimerHush
	end
end

local function RunDSSMenu(tbl)
    FreezeGame()
    dssmod.runMenu(tbl)
end

local function CloseDSSMenu(tbl, fullClose, noAnimate)
    FreezeGame(true)
    dssmod.closeMenu(tbl, fullClose, noAnimate)
end

--#endregion

DeadSeaScrollsMenu.AddMenu("Better Knife Pieces", {
    -- The Run, Close, and Open functions define the core loop of your menu
    -- Once your menu is opened, all the work is shifted off to your mod running these functions, so each mod can have its own independently functioning menu.
    -- The DSSInitializerFunction returns a table with defaults defined for each function, as "runMenu", "openMenu", and "closeMenu"
    -- Using these defaults will get you the same menu you see in Bertran and most other mods that use DSS
    -- But, if you did want a completely custom menu, this would be the way to do it!
    
    -- This function runs every render frame while your menu is open, it handles everything! Drawing, inputs, etc.
    Run = RunDSSMenu,
    -- This function runs when the menu is opened, and generally initializes the menu.
    Open = dssmod.openMenu,
    -- This function runs when the menu is closed, and generally handles storing of save data / general shut down.
    Close = CloseDSSMenu,

    -- If UseSubMenu is set to true, when other mods with UseSubMenu set to false / nil are enabled, your menu will be hidden behind an "Other Mods" button.
    -- A good idea to use to help keep menus clean if you don't expect players to use your menu very often!
    UseSubMenu = false,

    Directory = bkpdirectory,
    DirectoryKey = bkpdirectorykey
})