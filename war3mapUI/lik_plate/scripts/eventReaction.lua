---@param ui UI_LikPlate
function likPlate_eventReaction(ui)
    
    ---@param evtData noteOnPropChange
    event.reactRegister(EVENT.Prop.Change, ui:kit(), function(evtData)
        if (evtData.triggerPlayer) then
            if (evtData.key == "selection") then
                async.call(evtData.triggerPlayer, function()
                    ui:updatePlate()
                    ui:updateAbility()
                    ui:updateItem()
                end)
                -- 注册变化事件
                if (isClass(evtData.old, UnitClass)) then
                    event.syncRegister(evtData.old, EVENT.Unit.ItemSlotChange, ui:kit(), nil)
                    event.syncRegister(evtData.old, EVENT.Unit.AbilitySlotChange, ui:kit(), nil)
                end
                if (isClass(evtData.new, UnitClass)) then
                    ---@param ed noteOnUnitItemSlotChangeData
                    event.syncRegister(evtData.new, EVENT.Unit.ItemSlotChange, ui:kit(), function(ed)
                        async.call(ed.triggerUnit:owner(), function()
                            ui:updateItem()
                        end)
                    end)
                    ---@param ed noteOnUnitAbilitySlotChangeData
                    event.syncRegister(evtData.new, EVENT.Unit.AbilitySlotChange, ui:kit(), function(ed)
                        async.call(ed.triggerUnit:owner(), function()
                            ui:updateAbility()
                        end)
                    end)
                end
            end
        elseif (evtData.triggerUnit) then
            if (evtData.triggerUnit == PlayerLocal():selection()) then
                async.call(PlayerLocal(), function()
                    ui:updatePlate()
                end)
            end
        end
    end)
    
    -- 注册变化事件
    PlayersForeach(function(enumPlayer, _)
        event.syncRegister(enumPlayer, EVENT.Player.WarehouseSlotChange, ui:kit(), function()
            ui:updateWarehouse()
        end)
    end)

end