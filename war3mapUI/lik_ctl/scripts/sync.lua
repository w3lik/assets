--- right-sync
sync.receive("slotSync", function(syncData)
    local syncPlayer = syncData.syncPlayer
    local command = syncData.transferData[1]
    if (command == "ability_push") then
        local abId = syncData.transferData[2]
        local i = tonumber(syncData.transferData[3])
        ---@type Ability
        local ab = i2o(abId)
        if (isClass(ab, AbilityClass)) then
            syncPlayer:selection():abilitySlot():insert(ab, i)
        end
    elseif (command == "item_push") then
        local itId = syncData.transferData[2]
        local i = tonumber(syncData.transferData[3])
        ---@type Item
        local it = i2o(itId)
        if (isClass(it, ItemClass)) then
            syncPlayer:selection():itemSlot():insert(it, i)
        end
    elseif (command == "warehouse_push") then
        local itId = syncData.transferData[2]
        local i = tonumber(syncData.transferData[3])
        ---@type Item
        local it = i2o(itId)
        if (isClass(it, ItemClass)) then
            syncPlayer:warehouseSlot():insert(it, i)
        end
    elseif (command == "item_to_warehouse") then
        local itId = syncData.transferData[2]
        local wIdx = tonumber(syncData.transferData[3])
        ---@type Item
        local it = i2o(itId)
        if (isClass(it, ItemClass)) then
            local itIdx = it:itemSlotIndex()
            syncPlayer:selection():itemSlot():remove(itIdx)
            local wIt = syncPlayer:warehouseSlot():storage()[wIdx]
            if (isClass(wIt, ItemClass)) then
                syncPlayer:warehouseSlot():remove(wIdx)
                syncPlayer:selection():itemSlot():insert(wIt, itIdx)
            end
            syncPlayer:warehouseSlot():insert(it, wIdx)
        end
    elseif (command == "warehouse_to_item") then
        local wItId = syncData.transferData[2]
        local itIdx = tonumber(syncData.transferData[3])
        ---@type Item
        local wIt = i2o(wItId)
        if (isClass(wIt, ItemClass)) then
            local wIdx = wIt:warehouseSlotIndex()
            syncPlayer:warehouseSlot():remove(wIdx)
            local it = syncPlayer:selection():itemSlot():storage()[itIdx]
            if (isClass(it, ItemClass)) then
                syncPlayer:selection():itemSlot():remove(it, itIdx)
                syncPlayer:warehouseSlot():insert(it, wIdx)
            end
            syncPlayer:selection():itemSlot():insert(wIt, itIdx)
        end
    end
    async.call(syncPlayer, function()
        cursor.quoteOver("follow")
    end)
end)
