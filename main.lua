local mod = RegisterMod("Reward Knife Pieces", 1)
local game = Game()
local hadKnife1 = false
local hadKnife2 = false
local anyOneHasKnifePiece1 = false
local anyOneHasKnifePiece2 = false
local DarkItemPool = {}
local mscMng = MusicManager()
local escapeTrigger = 0
local json = require("json")

local function GetRandomDarkPoolItem(seed)
    local rng = RNG()
    if seed and type(seed) == "number" then
        rng:SetSeed(seed,35)
    end
    local newt = 0
    if #DarkItemPool > 0 then
        local idx = rng:RandomInt(#DarkItemPool) + 1
        newt = DarkItemPool[idx]
        table.remove(DarkItemPool,idx)
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
    local room = game:GetRoom()
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
        CollectibleType.COLLECTIBLE_BFF,
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
    mod:SaveData(json.encode({hadKnife1,hadKnife2,anyOneHasKnifePiece1,anyOneHasKnifePiece2,DarkItemPool}))
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
    local level = game:GetLevel()
    local room = game:GetRoom()
    local itemPool = game:GetItemPool()
    anyOneHasKnifePiece1 = false
    anyOneHasKnifePiece2 = false
    local anyHasChaos = false
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
    if level:GetStageType() == StageType.STAGETYPE_REPENTANCE or level:GetStageType() == StageType.STAGETYPE_REPENTANCE_B then
        local isCurseLabyrinth = level:GetCurses() & LevelCurse.CURSE_OF_LABYRINTH == LevelCurse.CURSE_OF_LABYRINTH
        if level:GetAbsoluteStage() == LevelStage.STAGE1_2 and not isCurseLabyrinth or level:GetAbsoluteStage() == LevelStage.STAGE1_1 and isCurseLabyrinth then
            if not room:IsMirrorWorld() then
                for i = 0,4 do
                    if room:GetDoor(i) then
                        local door = room:GetDoor(i)
                        if door.TargetRoomIndex == GridRooms.ROOM_MIRROR_IDX then
                            if room:IsFirstVisit() and hadKnife1 and not anyOneHasKnifePiece1 then
                                local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1, room:GetCenterPos(), Vector.Zero,nil):ToPickup()
                                pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                            elseif not hadKnife1 and anyOneHasKnifePiece1 then
                                hadKnife1 = true
                                mod:SaveData(json.encode({hadKnife1,hadKnife2,anyOneHasKnifePiece1,anyOneHasKnifePiece2,DarkItemPool}))
                            end
                            break
                        end
                    end
                end            
            elseif room:IsMirrorWorld() and room:GetType() == RoomType.ROOM_TREASURE and hadKnife1 and room:IsFirstVisit() then
                local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
                if items[1] then
                    local item = items[1]:ToPickup()
                    local newitem = itemPool:GetCollectible(itemPool:GetLastPool(),true,item.InitSeed)
                    item:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, newitem,true,true)
                end
            end
        end
        if level:GetAbsoluteStage() == LevelStage.STAGE2_2 and not isCurseLabyrinth or level:GetAbsoluteStage() == LevelStage.Stage2_1 and isCurseLabyrinth then
            if not room:HasCurseMist() then
                for i = 0,4 do
                    if room:GetDoor(i) then
                        local door = room:GetDoor(i)
                        if door.TargetRoomIndex == GridRooms.ROOM_MINESHAFT_IDX then
                            if room:IsFirstVisit() and hadKnife2 and not anyOneHasKnifePiece2 then
                                local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2, room:GetCenterPos() + Vector(0,100), Vector.Zero,nil):ToPickup()
                                pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                                pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                                break
                            elseif not hadKnife2 and anyOneHasKnifePiece2 then
                                hadKnife2 = true
                                mod:SaveData(json.encode({hadKnife1,hadKnife2,anyOneHasKnifePiece1,anyOneHasKnifePiece2,DarkItemPool}))
                            end
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
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.SpawnKnifePieces)