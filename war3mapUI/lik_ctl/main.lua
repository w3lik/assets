--[[
    控制台
    Author: hunzsig
]]

local kit = "lik_ctl"

---@class UI_LikCtl:UIKit
local ui = UIKit(kit)

ui:onSetup(function(this)
    
    ---@class UI_LikCtlStage
    local stage = this:stage()
    
    likCtl_params(stage)
    likCtl_eventReaction(this)
    
    likCtl_frameBG(kit, stage)
    likCtl_framePlate(kit, stage)
    likCtl_frameAbility(kit, stage)
    likCtl_frameItem(kit, stage)
    likCtl_frameWarehouse(kit, stage)

end)

---@param this UI_LikCtl
ui:onStart(function(this)
    this:updateSkin()
    this:updatePlate()
    this:updateEtc()
end)

---@param this UI_LikCtl
ui:onRefresh(0.1, function(this)
    this:updateAbility()
    this:updateItem()
    this:updateWarehouse()
end)

function ui:updateEtc()
    ---@type UI_LikCtlStage
    local stage = self:stage()
    local whichPlayer = PlayerLocal()
    async.call(whichPlayer, function()
        local w = 0
        local nameW = 0
        if (stage.plate.Unit:show() == true) then
            nameW = stage.plateInfo.portrait:prop("unAdaptiveSize")
            if (nameW) then
                nameW = nameW[1]
                nameW = nameW - 0.035
            end
            local abL = 0
            local sel = whichPlayer:selection()
            if (isClass(sel, UnitClass)) then
                local slot = sel:abilitySlot()
                if (isClass(slot, AbilitySlotClass)) then
                    abL = slot:tail()
                end
            end
            local abW = (stage.abilitySize + stage.abilityMargin) * abL - 0.22
            w = math.max(abW, nameW)
        elseif (stage.plate.Item:show() == true) then
            nameW = vistring.width(stage.plateItemName:text(), stage.plateItemName:fontSize()) * 0.7
            w = nameW or 0
        end
        w = math.max(0.0001, w)
        stage.bgEtc:size(w, stage.bgH)
        stage.bg:relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, -0.05 - w / 2, 0)
        stage.bgShadow:size(math.max(0.05, w + 0.041), stage.bgShadowH)
        stage.plateHP:value(stage.plateHP:value(), stage.plateBarW + w, stage.plateBarH)
        stage.plateMP:value(stage.plateMP:value(), stage.plateBarW + w, stage.plateBarH)
        stage.plateShield:value(stage.plateShield:value(), stage.plateBarW + w, stage.plateBarH / 8)
    end)
end

function ui:updateSkin()
    ---@type UI_LikCtlStage
    local stage = self:stage()
    local whichPlayer = PlayerLocal()
    async.call(whichPlayer, function()
        stage.bg:texture("bg\\" .. whichPlayer:skin() .. "_i")
        stage.bgEtc:texture("bg\\" .. whichPlayer:skin() .. "_ietc")
        stage.bgTail:texture("bg\\" .. whichPlayer:skin() .. "_itail")
        stage.item:texture("bg\\" .. whichPlayer:skin() .. "_item")
        stage.warehouse:texture("bg\\" .. whichPlayer:skin() .. "_warehouse")
    end)
end

function ui:updatePlate()
    ---@type UI_LikCtlStage
    local stage = self:stage()
    local whichPlayer = PlayerLocal()
    async.call(whichPlayer, function()
        local tmpData = {
            class = "Nil",
            selection = whichPlayer:selection(),
            race = whichPlayer:race(),
        }
        if (isClass(tmpData.selection, UnitClass)) then
            tmpData.class = "Unit"
        elseif (isClass(tmpData.selection, ItemClass)) then
            tmpData.class = "Item"
        end
        if (tmpData.class == "Nil") then
            tmpData.nilDisplay = table.concat(table.merge({ Game():name() }, Game():prop("infoIntro")), "|n")
        elseif (tmpData.class == "Unit") then
            if (tmpData.selection:isDead()) then
                whichPlayer:clear("selection")
                return
            end
            local primary = tmpData.selection:primary()
            tmpData.nilDisplay = ""
            tmpData.defend = math.floor(tmpData.selection:defend())
            tmpData.move = math.max(0, math.floor(tmpData.selection:move()))
            tmpData.portraitTexture = "icon\\common"
            if (primary ~= nil) then
                if (tmpData.selection:isMelee()) then
                    tmpData.portraitTexture = "icon\\" .. primary.value .. "_melee"
                else
                    tmpData.portraitTexture = "icon\\" .. primary.value .. "_ranged"
                end
            end
            if (tmpData.selection:properName() ~= nil and tmpData.selection:properName() ~= '') then
                tmpData.properName = tmpData.selection:name() .. "·" .. tmpData.selection:properName()
            else
                tmpData.properName = tmpData.selection:name()
            end
            if (tmpData.selection:level() >= 1) then
                tmpData.properName = colour.hex(colour.gold, "Lv" .. tmpData.selection:level()) .. " " .. tmpData.properName
            end
            if (tmpData.selection:isAttackAble()) then
                local am = tmpData.selection:attackMode()
                if (am == nil) then
                    tmpData.attackTexture = "icon\\attack_melee"
                elseif (am:mode() == "lightning") then
                    tmpData.attackTexture = "icon\\attack_lighting"
                elseif (am:mode() == "missile") then
                    tmpData.attackTexture = "icon\\attack_ranged"
                else
                    tmpData.attackTexture = "icon\\attack_melee"
                end
                tmpData.attackAlpha = 255
                if (tmpData.selection:attackRipple() == 0) then
                    local atk = math.floor(tmpData.selection:attack())
                    if (atk > 0) then
                        tmpData.attack = atk
                    else
                        tmpData.attack = colour.hex(colour.indianred, atk)
                    end
                else
                    local atk = math.floor(tmpData.selection:attack())
                    local atk2 = math.floor(atk + tmpData.selection:attackRipple())
                    if (atk > 0) then
                        tmpData.attack = atk .. "~" .. atk2
                    else
                        tmpData.attack = colour.hex(colour.indianred, atk .. "~" .. atk2)
                    end
                end
                if (tmpData.selection:attackSpeed() < 0) then
                    tmpData.attackSpeed = colour.hex(colour.indianred, math.format(tmpData.selection:attackSpace(), 2) .. " 秒/击")
                else
                    tmpData.attackSpeed = math.format(tmpData.selection:attackSpace(), 2) .. " 秒/击"
                end
            else
                tmpData.attackAlpha = 150
                tmpData.attack = " - "
                tmpData.attackSpeed = " - "
                tmpData.attackTexture = "icon\\attack_no"
            end
            if (tmpData.selection:isInvulnerable()) then
                tmpData.defendTexture = "icon\\defend_gold"
                tmpData.defend = colour.hex(colour.gold, "无敌")
            else
                tmpData.defendTexture = "icon\\defend"
                if (tmpData.selection:defend() <= 9999) then
                    tmpData.defend = math.floor(tmpData.selection:defend())
                else
                    tmpData.defend = math.numberFormat(tmpData.selection:defend(), 2)
                end
            end
            
            local hpCur = math.floor(tmpData.selection:hpCur())
            local hp = math.floor(tmpData.selection:hp() or 0)
            local hpRegen = math.trunc(tmpData.selection:hpRegen(), 2)
            if (hpRegen == 0 or hp == 0 or hpCur >= hp) then
                tmpData.hpRegen = ''
            elseif (hpRegen > 0) then
                tmpData.hpRegen = colour.hex(colour.green, "+" .. hpRegen)
            elseif (hpRegen < 0) then
                tmpData.hpRegen = colour.hex(colour.red, hpRegen)
            end
            tmpData.hpPercent = math.trunc(hpCur / hp, 3)
            tmpData.hpTxt = hpCur .. " / " .. hp
            if (hpCur < hp * 0.35) then
                tmpData.hpTexture = "bar\\red"
            elseif (hpCur < hp * 0.65) then
                tmpData.hpTexture = "bar\\orange"
            else
                tmpData.hpTexture = "bar\\green"
            end
            local mpCur = math.floor(tmpData.selection:mpCur())
            local mp = math.floor(tmpData.selection:mp() or 0)
            local mpRegen = math.trunc(tmpData.selection:mpRegen(), 2)
            if (mpRegen == 0 or mp == 0 or mpCur >= mp) then
                tmpData.mpRegen = ''
            elseif (mpRegen > 0) then
                tmpData.mpRegen = colour.hex(colour.lightcyan, "+" .. mpRegen)
            elseif (mpRegen < 0) then
                tmpData.mpRegen = colour.hex(colour.red, mpRegen)
            end
            if (mp == 0) then
                tmpData.mpPercent = 1
                tmpData.mpTxt = colour.hex(colour.silver, mpCur .. "/" .. mp)
                tmpData.mpTexture = "bar\\blueGrey"
            else
                tmpData.mpPercent = math.trunc(mpCur / mp, 3)
                tmpData.mpTxt = mpCur .. " / " .. mp
                tmpData.mpTexture = "bar\\blue"
            end
            
            local tileValueCount = 0
            local period = tmpData.selection:period()
            if (period > 0) then
                tileValueCount = tileValueCount + 1
                local cur = tmpData.selection:periodRemain() or 0
                tmpData.periodPercent = math.trunc(cur / period, 3)
                tmpData.periodTxt = colour.hex(colour.white, "存在 " .. math.format(cur, 1) .. " 秒")
            end
            local level = tmpData.selection:level()
            if (level > 0) then
                tileValueCount = tileValueCount + 1
                local cur = tmpData.selection:exp() or 0
                local prev = tmpData.selection:expNeed(level) or 0
                local need = tmpData.selection:expNeed() or 0
                tmpData.expPercent = math.trunc((cur - prev) / (need - prev), 3)
                tmpData.expTxt = colour.hex(colour.white, math.integerFormat(cur) .. "/" .. math.integerFormat(need) .. "  " .. level .. " 级")
            end
        elseif (tmpData.class == "Item") then
            if (tmpData.selection:instance() == false) then
                whichPlayer:clear("selection")
                return
            end
            tmpData.itemName = tmpData.selection:name()
            tmpData.iteIcon = tmpData.selection:icon()
            if (tmpData.selection:level() >= 1) then
                tmpData.itemName = colour.hex(colour.gold, "Lv" .. tmpData.selection:level()) .. " " .. tmpData.itemName
            end
            tmpData.itemDesc = table.concat(tmpData.selection:description(), "|n")
        end
        if (tmpData.class == "Nil") then
            stage.plateNilMsg:text(tmpData.nilDisplay)
            stage.plate.Unit:show(false)
            stage.plate.Item:show(false)
            stage.plate.Nil:show(true)
        elseif (tmpData.class == "Unit") then
            stage.plateHP
                 :texture("value", tmpData.hpTexture)
                 :value(tmpData.hpPercent, stage.plateBarW, stage.plateBarH)
                 :text(LAYOUT_ALIGN_CENTER, tmpData.hpTxt)
                 :text(LAYOUT_ALIGN_RIGHT, tmpData.hpRegen)
            stage.plateMP
                 :texture("value", tmpData.mpTexture)
                 :value(tmpData.mpPercent, stage.plateBarW, stage.plateBarH)
                 :text(LAYOUT_ALIGN_CENTER, tmpData.mpTxt)
                 :text(LAYOUT_ALIGN_RIGHT, tmpData.mpRegen)
            stage.plateInfo.portrait
                 :icon(tmpData.portraitTexture)
                 :text(tmpData.properName)
            stage.plateInfo.attack
                 :icon(tmpData.attackTexture)
                 :text(tmpData.attack)
                 :alpha(tmpData.attackAlpha)
            stage.plateInfo.attackSpeed
                 :text(tmpData.attackSpeed)
                 :alpha(tmpData.attackAlpha)
            stage.plateInfo.defend
                 :icon(tmpData.defendTexture)
                 :text(tmpData.defend)
            stage.plateInfo.move
                 :text(tmpData.move)
            stage.plate.Nil:show(false)
            stage.plate.Item:show(false)
            stage.plate.Unit:show(true)
        elseif (tmpData.class == "Item") then
            stage.plateItemName:text(tmpData.itemName)
            stage.plateItemIcon:texture(tmpData.iteIcon)
            stage.plateItemDesc:text(tmpData.itemDesc)
            stage.plate.Nil:show(false)
            stage.plate.Unit:show(false)
            stage.plate.Item:show(true)
        end
    end)
end

function ui:updateAbility()
    ---@type UI_LikCtlStage
    local stage = self:stage()
    local whichPlayer = PlayerLocal()
    async.call(whichPlayer, function()
        local tmpData = {
            ---@type Unit
            selection = whichPlayer:selection(),
            skin = whichPlayer:skin(),
            show = false,
            bedding = {},
            btn = {},
            btnLvUp = {},
        }
        if (isClass(tmpData.selection, "Unit") and tmpData.selection:isAlive()) then
            --- 物品栏
            local abilitySlot = tmpData.selection:abilitySlot()
            if (abilitySlot ~= nil) then
                tmpData.show = true
                -- 初始化数据
                for i = 1, stage.abilityMAX do
                    tmpData.bedding[i] = {}
                    tmpData.btn[i] = {}
                    tmpData.btnLvUp[i] = {}
                end
                --
                local tail = abilitySlot:tail()
                local storage = abilitySlot:storage()
                for i = 1, stage.abilityMAX do
                    if (i > tail) then
                        tmpData.bedding[i].show = false
                        tmpData.btn[i].show = false
                        tmpData.btn[i].maskValue = 0
                    else
                        if (storage[i] == nil) then
                            tmpData.btn[i].show = false
                            tmpData.btn[i].maskValue = 0
                            tmpData.btnLvUp[i].show = false
                        else
                            local tt = storage[i]:targetType()
                            tmpData.btn[i].texture = storage[i]:icon()
                            if (storage[i]:coolDown() > 0 and storage[i]:coolDownRemain() > 0) then
                                tmpData.btn[i].maskValue = math.min(1, storage[i]:coolDownRemain() / storage[i]:coolDown())
                                tmpData.btn[i].border = "Framework\\ui\\nil.tga"
                                tmpData.btn[i].text = math.format(storage[i]:coolDownRemain(), 1)
                            elseif (storage[i]:isProhibiting() == true) then
                                local reason = storage[i]:prohibitReason()
                                tmpData.btn[i].maskValue = 1
                                if (reason == nil) then
                                    tmpData.btn[i].border = "Framework\\ui\\nil.tga" -- ban
                                    tmpData.btn[i].text = ''
                                else
                                    tmpData.btn[i].border = "Framework\\ui\\nil.tga"
                                    tmpData.btn[i].text = reason
                                end
                            else
                                tmpData.btn[i].maskValue = 0
                                tmpData.btn[i].text = ''
                                if (nil == tt or ABILITY_TARGET_TYPE.pas == tt) then
                                    tmpData.btn[i].border = "Framework\\ui\\nil.tga"
                                else
                                    tmpData.btn[i].border = "btn\\border-white"
                                    if (tmpData.selection:owner() == whichPlayer and storage[i] == cursor.currentData().ability) then
                                        tmpData.btn[i].border = "btn\\border-gold"
                                    end
                                end
                            end
                            if (nil == tt or ABILITY_TARGET_TYPE.pas == tt) then
                                tmpData.btn[i].hotkey = ''
                            else
                                tmpData.btn[i].hotkey = Game():abilityHotkey(i)
                            end
                            tmpData.btn[i].show = (nil ~= tt)
                            local lv = storage[i]:level()
                            -- next
                            tmpData.btnLvUp[i].show = false
                            if (nil ~= tt and tmpData.selection:abilityPoint() > 0) then
                                if (lv < storage[i]:levelMax() and storage[i]:levelUpNeedPoint() > 0) then
                                    if (storage[i]:levelUpNeedPoint() <= tmpData.selection:abilityPoint()) then
                                        tmpData.btnLvUp[i].show = true
                                    end
                                end
                            end
                        end
                        tmpData.bedding[i].show = true
                    end
                end
            end
        end
        stage.ability:show(tmpData.show)
        if (tmpData.show) then
            for i = 1, stage.abilityMAX do
                stage.abilityBtn[i]:hotkey(tmpData.btn[i].hotkey)
                stage.abilityBtn[i]:texture(tmpData.btn[i].texture)
                stage.abilityBtn[i]:show(tmpData.btn[i].show)
                stage.abilityBtn[i]:border(tmpData.btn[i].border)
                stage.abilityBtn[i]:maskValue(tmpData.btn[i].maskValue)
                stage.abilityBtn[i]:text(tmpData.btn[i].text)
                stage.abilityBtnLvUp[i]:show(tmpData.btnLvUp[i].show)
                stage.abilityBedding[i]:texture("bg\\" .. tmpData.skin .. "_block")
                stage.abilityBedding[i]:show(tmpData.bedding[i].show)
            end
        end
    end)
end

function ui:updateItem()
    ---@type UI_LikCtlStage
    local stage = self:stage()
    local whichPlayer = PlayerLocal()
    async.call(whichPlayer, function()
        local tmpData = {
            ---@type Unit
            selection = whichPlayer:selection(),
            show = false,
            btn = {},
            charge = {},
        }
        -- 初始化数据
        for i = 1, stage.itemMAX do
            tmpData.btn[i] = {}
            tmpData.charge[i] = 0
        end
        if (isClass(tmpData.selection, "Unit") and tmpData.selection:isAlive()) then
            --- 物品栏
            local itemSlot = tmpData.selection:itemSlot()
            if (itemSlot ~= nil) then
                tmpData.show = true
                --- 物品控制
                local storage = itemSlot:storage()
                for i = 1, stage.itemMAX, 1 do
                    ---@type Item
                    local it = storage[i]
                    if (false == isClass(it, "Item")) then
                        tmpData.btn[i].show = false
                    else
                        tmpData.btn[i].show = true
                        tmpData.btn[i].texture = it:icon()
                        tmpData.btn[i].text = ''
                        tmpData.btn[i].border = "btn\\border-white"
                        tmpData.btn[i].maskValue = 0
                        tmpData.charge[i] = math.round(it:charges())
                        local ab = it:ability()
                        if (isClass(ab, AbilityClass)) then
                            if (ab:coolDown() > 0 and ab:coolDownRemain() > 0) then
                                tmpData.btn[i].maskValue = ab:coolDownRemain() / ab:coolDown()
                                tmpData.btn[i].text = math.trunc(ab:coolDownRemain(), 1)
                            elseif (ab:isProhibiting() == true) then
                                local reason = ab:prohibitReason()
                                tmpData.btn[i].maskValue = 1
                                if (reason == nil) then
                                    tmpData.btn[i].text = ''
                                else
                                    tmpData.btn[i].border = "Framework\\ui\\nil.tga"
                                    tmpData.btn[i].text = reason
                                end
                            end
                            if (ab == cursor.currentData().ability) then
                                tmpData.btn[i].border = "btn\\border-gold"
                            end
                        end
                    end
                end
            end
        end
        stage.item:show(tmpData.show)
        if (tmpData.show) then
            stage.itemWeight:text("物品栏")
            for i = 1, stage.itemMAX do
                stage.itemButton[i]:texture(tmpData.btn[i].texture)
                stage.itemButton[i]:border(tmpData.btn[i].border)
                stage.itemButton[i]:maskValue(tmpData.btn[i].maskValue)
                stage.itemButton[i]:text(tmpData.btn[i].text)
                stage.itemButton[i]:show(tmpData.btn[i].show)
                if (tmpData.charge[i] > 0) then
                    local tw = math.max(0.008, string.len(tostring(tmpData.charge[i])) * 0.004)
                    stage.itemCharges[i]
                         :size(tw, 0.008)
                         :text(tmpData.charge[i])
                         :show(true)
                else
                    stage.itemCharges[i]:show(false)
                end
            end
        end
    end)
end

function ui:updateWarehouse()
    ---@type UI_LikCtlStage
    local stage = self:stage()
    local whichPlayer = PlayerLocal()
    async.call(whichPlayer, function()
        local tmpData = {
            ---@type Unit
            selection = whichPlayer:selection(),
            cell = nil,
            resInfo = {},
            btn = {},
            charge = {},
        }
        -- 初始化数据
        for i = 1, stage.warehouseMAX do
            tmpData.btn[i] = {}
            tmpData.charge[i] = 0
        end
        --- 仓存显示
        local qty = #(whichPlayer:warehouseSlot())
        if (qty >= stage.warehouseMAX) then
            tmpData.cell = "仓库  " .. colour.hex(colour.red, qty .. "/" .. stage.warehouseMAX)
        else
            tmpData.cell = "仓库  " .. qty .. "/" .. stage.warehouseMAX
        end
        --- 资源显示
        local r = whichPlayer:worth()
        for i, k in ipairs(stage.warehouseResAllow) do
            tmpData.resInfo[i] = colour.hex(stage.warehouseResOpt[k].color, math.floor(r[k] or 0))
        end
        --- 仓库物品控制
        local storage = whichPlayer:warehouseSlot():storage()
        for i = 1, stage.warehouseMAX do
            ---@type Item
            local it = storage[i]
            if (false == isClass(it, "Item")) then
                tmpData.btn[i].show = false
            else
                tmpData.btn[i].show = true
                tmpData.btn[i].texture = it:icon()
                tmpData.btn[i].text = ''
                tmpData.btn[i].border = "btn\\border-white"
                tmpData.btn[i].maskValue = 0
                tmpData.charge[i] = math.floor(it:charges())
                local ab = it:ability()
                if (isClass(ab, AbilityClass)) then
                    if (ab:coolDown() > 0 and ab:coolDownRemain() > 0) then
                        tmpData.btn[i].maskValue = ab:coolDownRemain() / ab:coolDown()
                        tmpData.btn[i].text = math.trunc(ab:coolDownRemain(), 1)
                    elseif (ab:isProhibiting() == true) then
                        local reason = ab:prohibitReason()
                        tmpData.btn[i].maskValue = 1
                        if (reason == nil) then
                            tmpData.btn[i].text = ''
                        else
                            tmpData.btn[i].border = "Framework\\ui\\nil.tga"
                            tmpData.btn[i].text = reason
                        end
                    end
                end
            end
        end
        stage.warehouseCell:text(tmpData.cell)
        for i, _ in ipairs(stage.warehouseResAllow) do
            stage.warehouseRes[i]:text(tmpData.resInfo[i])
        end
        for i = 1, stage.warehouseMAX do
            stage.warehouseButton[i]:texture(tmpData.btn[i].texture)
            stage.warehouseButton[i]:border(tmpData.btn[i].border)
            stage.warehouseButton[i]:maskValue(tmpData.btn[i].maskValue)
            stage.warehouseButton[i]:text(tmpData.btn[i].text)
            stage.warehouseButton[i]:show(tmpData.btn[i].show)
            if (tmpData.charge[i] > 0) then
                local tw = math.max(0.008, string.len(tostring(tmpData.charge[i])) * 0.004)
                stage.warehouseCharges[i]
                     :size(tw, 0.008)
                     :text(tmpData.charge[i])
                     :show(true)
            else
                stage.warehouseCharges[i]:show(false)
            end
        end
    end)
end