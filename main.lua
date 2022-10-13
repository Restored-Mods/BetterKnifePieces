local mod = RegisterMod("Reward Knife Pieces", 1)
local game = Game()
local hadKnife1 = false
local hadKnife2 = false
local mscMng = MusicManager()
local escapeTrigger = 0
local json = require("json")

function mod:Load(isLoad)
    if mod:HasData() then
        local load = json.decode(mod:LoadData())
        hadKnife1 = load[1]
        hadKnife2 = load[2]
    end
end
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.Load)

function mod:PlayEscape()
    if escapeTrigger > 0 then
        escapeTrigger = escapeTrigger - 1
    else
        mscMng:Play(Music.MUSIC_MINESHAFT_ESCAPE, Options.MusicVolume)
        mod:RemoveCallback(ModCallbacks.MC_POST_RENDER,mod.PlayEscape)
    end
end

function mod:SpawnKnifePieces()
    local level = game:GetLevel()
    local room = game:GetRoom()
    local anyOneHasKnifePiece1 = false
    local anyOneHasKnifePiece2 = false
    for _,p in ipairs(Isaac.FindByType(EntityType.ENTITY_PLAYER,-1,-1)) do
        p = p:ToPlayer()
        if p:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) then
            anyOneHasKnifePiece1 = true
        end
        if p:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) then
            anyOneHasKnifePiece2 = true
        end
    end
    if level:GetAbsoluteStage() == LevelStage.STAGE1_2 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE and hadKnife1 
    and room:IsFirstVisit() then
        if not room:IsMirrorWorld() and not anyOneHasKnifePiece1 then
            for i = 0,4 do
                if room:GetDoor(i) then
                    local door = room:GetDoor(i)
                    if door.TargetRoomIndex == GridRooms.ROOM_MIRROR_IDX then
                        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1, room:GetCenterPos(), Vector.Zero,nil):ToPickup()
                        pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                        break
                    end
                end
            end
        elseif room:IsMirrorWorld() and room:GetType() == RoomType.ROOM_TREASURE then
            local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_1)
            if items[1] then
                local item = items[1]:ToPickup()
                local itemPool = game:GetItemPool()
                local newitem = itemPool:GetCollectible(itemPool:GetLastPool(),true,item.InitSeed)
                item:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, newitem,true,true)
            end
        end
    end
    if level:GetAbsoluteStage() == LevelStage.STAGE2_2 and level:GetStageType() == StageType.STAGETYPE_REPENTANCE and hadKnife2
    and room:IsFirstVisit() then
        if not room:HasCurseMist() and not anyOneHasKnifePiece2 then
            for i = 0,4 do
                if room:GetDoor(i) then
                    local door = room:GetDoor(i)
                    if door.TargetRoomIndex == GridRooms.ROOM_MINESHAFT_IDX then
                        local pickup = Isaac.Spawn(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2, room:GetCenterPos() + Vector(0,100), Vector.Zero,nil):ToPickup()
                        pickup:ClearEntityFlags(EntityFlag.FLAG_APPEAR)
                        pickup:ClearEntityFlags(EntityFlag.FLAG_ITEM_SHOULD_DUPLICATE)
                        break
                    end
                end
            end
        elseif room:HasCurseMist() then
            local items = Isaac.FindByType(EntityType.ENTITY_PICKUP, PickupVariant.PICKUP_COLLECTIBLE, CollectibleType.COLLECTIBLE_KNIFE_PIECE_2)
            if items[1] then
                local item = items[1]:ToPickup()
                local itemPool = game:GetItemPool()
                local newitem = itemPool:GetCollectible(itemPool:GetLastPool(),true,item.InitSeed)
                item:ToPickup():Morph(EntityType.ENTITY_PICKUP,PickupVariant.PICKUP_COLLECTIBLE, newitem,true,true)
                mscMng:Play(Music.MUSIC_MOTHERS_SHADOW_INTRO, Options.MusicVolume)
                escapeTrigger = 450
                mod:AddCallback(ModCallbacks.MC_POST_RENDER, mod.PlayEscape)
            end
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, mod.SpawnKnifePieces)

function mod:UpdateKnifeProgress(p)
    if not hadKnife1 or not hadKnife2 then
        if p.QueuedItem.Item then
            if p.QueuedItem.Item.ID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_1 then
                hadKnife1 = true
            end
            if p.QueuedItem.Item.ID == CollectibleType.COLLECTIBLE_KNIFE_PIECE_2 then
                hadKnife2 = true
            end
            mod:SaveData(json.encode({hadKnife1,hadKnife2}))
        end
        if p:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_1) and not hadKnife1 then
            hadKnife1 = true
            mod:SaveData(json.encode({hadKnife1,hadKnife2}))
        end
        if p:HasCollectible(CollectibleType.COLLECTIBLE_KNIFE_PIECE_2) and not hadKnife2 then
            hadKnife2 = true
            mod:SaveData(json.encode({hadKnife1,hadKnife2}))
        end
    end
end
mod:AddCallback(ModCallbacks.MC_POST_PEFFECT_UPDATE, mod.UpdateKnifeProgress)