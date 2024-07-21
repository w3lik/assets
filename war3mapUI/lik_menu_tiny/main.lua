--[[
    顶部菜单
    Author: hunzsig
]]

local kit = "lik_menu_tiny"

---@class UI_LikMenuTiny:UIKit
local ui = UIKit(kit)

ui:onSetup(function(this)
    local stage = this:stage()
    stage.menu = FrameBackdrop(kit, FrameGameUI)
        :adaptive(true)
        :block(true)
        :absolut(FRAME_ALIGN_TOP, 0, 0)
        :size(0.65, 0.0375)
    stage.menu_fns = {
        { "F9", "F9 帮助" },
        { "F10", "F10 菜单" },
        { "F11", "F11 队伍" },
        { "F12", "F12 消息" },
    }
    stage.menu_mapName = FrameText(kit .. "->mn", stage.menu)
        :relation(FRAME_ALIGN_LEFT, stage.menu, FRAME_ALIGN_TOP, 0.055, -0.0085)
        :textAlign(TEXT_ALIGN_LEFT)
        :fontSize(8)
    
    stage.menu_player = FrameText(kit .. "->msv", stage.menu)
        :relation(FRAME_ALIGN_LEFT_TOP, stage.menu, FRAME_ALIGN_RIGHT_TOP, -0.058, -0.0032)
        :textAlign(TEXT_ALIGN_LEFT)
        :fontSize(10)
    
    stage.menu_info = FrameText(kit .. "->info", stage.menu)
        :relation(FRAME_ALIGN_TOP, stage.menu, FRAME_ALIGN_TOP, 0, -0.007)
        :textAlign(TEXT_ALIGN_CENTER)
        :fontSize(9)
        :text("")
    
    stage.menu_fn = {}
    for i, _ in ipairs(stage.menu_fns) do
        stage.menu_fn[i] = {}
        stage.menu_fn[i].btn = Frame(kit .. "->" .. i, japi.DZ_FrameGetUpperButtonBarButton(i - 1), stage.menu)
            :relation(FRAME_ALIGN_LEFT_TOP, stage.menu, FRAME_ALIGN_LEFT_TOP, (i - 1) * 0.071, 0.002)
            :size(0.064, 0.02)
        stage.menu_fn[i].txt = FrameText(kit .. "->txt->" .. i, stage.menu)
            :relation(FRAME_ALIGN_CENTER, stage.menu_fn[i].btn, FRAME_ALIGN_CENTER, 0, 0)
            :textAlign(TEXT_ALIGN_CENTER)
            :fontSize(8)
    end
    
    if (i18n.isEnable()) then
        Game():onEvent(EVENT.Game.Start, "I18N_DIALOG", function()
            stage.menu_i18nDialog = Dialog("LIK_TEC", i18n._langList, function(evtData)
                async.call(evtData.triggerPlayer, function()
                    i18n.lang(evtData.value)
                end)
            end)
            stage.menu_i18n = FrameButton(stage.menu:kit() .. "->i18n", stage.menu)
                :relation(FRAME_ALIGN_TOP, stage.menu, FRAME_ALIGN_TOP, 0.256, -0.004)
                :size(0.012, 0.014)
                :texture("i18n")
                :onEvent(EVENT.Frame.LeftClick, function(evtData) stage.menu_i18nDialog:show(evtData.triggerPlayer) end)
        end)
    end
    
    stage.updateSkin = function()
        stage.menu:texture(PlayerLocal():skin())
    end
    stage.updateWelcome = function()
        stage.menu_mapName:text(colour.hex(colour.gold, Game():name()))
    end
    stage.updateName = function()
        stage.menu_player:text(PlayerLocal():name())
    end
    stage.updateFn = function()
        for i, t in ipairs(stage.menu_fns) do
            stage.menu_fn[i].txt:text(t[2])
            if (i == 3 and Game():playingQuantity() == 1) then
                stage.menu_fn[i].txt:text(colour.darkgray(t[2]))
            end
        end
    end
    stage.updateInfo = function()
        stage.menu_info:text(table.concat(Game():infoCenter(), "|n"))
    end
    
    --- 默认种族、欢迎语、等级
    if (PlayerLocal():isPlaying()) then
        async.call(PlayerLocal(), function()
            stage.updateSkin()
            stage.updateFn()
            stage.updateWelcome()
            stage.updateName()
        end)
    end
    
    ---@param evtData noteOnPropChange
    event.reactRegister(EVENT.Prop.Change, "lik_menu", function(evtData)
        if (evtData.triggerGame) then
            async.call(PlayerLocal(), function()
                if (i18n.isEnable() and evtData.key == "i18nLang") then
                    stage.updateWelcome()
                    stage.updateFn()
                    stage.updateName()
                    stage.updateInfo()
                elseif (evtData.key == "playingQuantity") then
                    stage.updateFn()
                elseif (evtData.key == "infoCenter") then
                    stage.updateInfo()
                end
            end)
        elseif (evtData.triggerPlayer) then
            async.call(evtData.triggerPlayer, function()
                if (evtData.key == "skin") then
                    stage.updateSkin()
                elseif (evtData.key == "name") then
                    stage.updateWelcome()
                end
            end)
        end
    end)

end)