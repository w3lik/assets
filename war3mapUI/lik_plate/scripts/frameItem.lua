---@param stage UI_LikPlateStage
function likPlate_frameItem(kit, stage)
    
    local kitIt = kit .. "->item"
    
    stage.item = FrameBackdrop(kitIt, FrameGameUI)
        :block(true)
        :relation(FRAME_ALIGN_LEFT_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0.111, 0)
        :size(0.078, 0.098)
    
    ---@type FrameButton[]
    stage.itemButton = {}
    
    ---@type FrameText[]
    stage.itemCharges = {}
    
    stage.itemSizeX = 0.032
    stage.itemSizeY = 0.0294
    stage.itemMarginX = 0.008
    stage.itemMarginY = 0.009
    
    local raw = 2
    for i = 1, stage.itemMAX do
        local xo = 0.0040 + (i - 1) % raw * (stage.itemSizeX + stage.itemMarginX)
        local yo = 0.0132 - (math.ceil(i / raw) - 1) * (stage.itemMarginY + stage.itemSizeY)
        stage.itemButton[i] = FrameButton(kit .. '->btn->' .. i, stage.item)
            :relation(FRAME_ALIGN_LEFT_TOP, stage.item, FRAME_ALIGN_LEFT_TOP, xo, yo)
            :size(stage.itemSizeX, stage.itemSizeY)
            :fontSize(7.5)
            :mask('Framework\\ui\\black.tga')
            :show(false)
            :onEvent(EVENT.Frame.Leave,
            function(evtData)
                evtData.triggerFrame:childHighlight():show(false)
                FrameTooltips():show(false)
            end)
            :onEvent(EVENT.Frame.Enter,
            function(evtData)
                if (cursor.isFollowing() or cursor.isDragging()) then
                    return
                end
                local selection = evtData.triggerPlayer:selection()
                if (false == isClass(selection, UnitClass)) then
                    return nil
                end
                local slot = selection:itemSlot()
                if (slot == nil) then
                    return
                end
                local storage = slot:storage()
                if (storage == nil) then
                    return
                end
                evtData.triggerFrame:childHighlight():show(true)
                local content = tooltipsItem(storage[i])
                if (content ~= nil) then
                    FrameTooltips()
                        :kit(kit)
                        :fontSize(10)
                        :textAlign(TEXT_ALIGN_LEFT)
                        :relation(FRAME_ALIGN_BOTTOM, stage.item, FRAME_ALIGN_TOP, 0, 0.04)
                        :content(content)
                        :show(true)
                end
            end)
            :onEvent(EVENT.Frame.LeftClick,
            function(evtData)
                if (cursor.isFollowing() or cursor.isDragging()) then
                    return
                end
                local selection = evtData.triggerPlayer:selection()
                if (isClass(selection, UnitClass) == false) then
                    return
                end
                local slot = selection:itemSlot()
                if (slot == nil) then
                    return
                end
                local storage = slot:storage()
                if (storage == nil) then
                    return
                end
                if (storage[i]) then
                    local ab = storage[i]:ability()
                    if (isClass(ab, AbilityClass)) then
                        cursor.quote(ab:targetType(), { ability = ab })
                    end
                end
            end)
            :onEvent(EVENT.Frame.RightClick,
            function(evtData)
                if (cursor.isQuoting()) then
                    return
                end
                local selection = evtData.triggerPlayer:selection()
                if (false == isClass(selection, UnitClass)) then
                    return
                end
                if (evtData.triggerPlayer ~= selection:owner()) then
                    return
                end
                local slot = selection:itemSlot()
                if (nil == slot) then
                    return
                end
                local storage = slot:storage()
                if (nil == storage) then
                    return
                end
                local ob = storage[i]
                local triggerFrame = evtData.triggerFrame
                japi.DZ_FrameSetAlpha(triggerFrame:handle(), 0)
                audio(Vcm("war3_MouseClick1"))
                cursor.quote("follow", {
                    object = ob,
                    frame = triggerFrame,
                    over = function()
                        japi.DZ_FrameSetAlpha(triggerFrame:handle(), triggerFrame:alpha())
                    end,
                    ---@param evt evtOnMouseRightClickData
                    rightClick = function(evt)
                        local p = evt.triggerPlayer
                        local sel = p:selection()
                        if (isClass(sel, UnitClass) and sel:owner() == p) then
                            local tarIdx = -1
                            local tarType, tarObj
                            local sto = sel:itemSlot():storage()
                            for j = 1, stage.itemMAX do
                                local it = sto[j]
                                local btn = stage.itemButton[j]
                                if (btn:isInner(evt.rx, evt.ry, false)) then
                                    tarObj, tarType, tarIdx = it, "item", j
                                    break
                                end
                            end
                            if (-1 == tarIdx and stage.warehouseDrag:show()) then
                                sto = p:warehouseSlot():storage()
                                for w = 1, stage.warehouseMAX do
                                    local it = sto[w]
                                    local btn = stage.warehouseButton[w]
                                    if (btn:isInner(evt.rx, evt.ry, false)) then
                                        tarObj, tarType, tarIdx = it, "warehouse", w
                                        break
                                    end
                                end
                            end
                            if (-1 ~= tarIdx and false == table.equal(ob, tarObj)) then
                                if (tarType == "item") then
                                    sync.send("slotSync", { "item_push", ob:id(), tarIdx, triggerFrame:id() })
                                elseif (tarType == "warehouse") then
                                    sync.send("slotSync", { "item_to_warehouse", ob:id(), tarIdx, triggerFrame:id() })
                                end
                                audio(Vcm("war3_MouseClick1"))
                            else
                                cursor.quoteOver()
                            end
                        else
                            cursor.quoteOver()
                        end
                    end,
                })
            end)
        
        stage.itemButton[i]:childMask():alpha(180)
        stage.itemButton[i]:childBorder():size(stage.itemSizeX * 1.05, stage.itemSizeY * 1.04)
        
        -- 物品使用次数
        stage.itemCharges[i] = FrameButton(kit .. '->charges->' .. i, stage.itemButton[i])
            :relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.itemButton[i], FRAME_ALIGN_RIGHT_BOTTOM, -0.0014, 0.0014)
            :texture(TEAM_COLOR_BLP_BLACK)
            :fontSize(7)
    end

end