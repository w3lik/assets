--[[
    小地图
    Author: hunzsig
]]

local kit = "lik_minimap"

---@class UI_LikMinimap:UIKit
local ui = UIKit(kit)

ui:onSetup(function(this)
    
    local stage = this:stage()
    
    -- 小地图边框背景
    stage.main = FrameBackdrop(kit .. '->main', FrameGameUI)
        :adaptive(true)
        :relation(FRAME_ALIGN_LEFT_BOTTOM, FrameGameUI, FRAME_ALIGN_LEFT_BOTTOM, 0, 0)
        :size(0.207, 0.1541666667)
    
    local width = 0.122
    
    -- 小地图
    stage.map = Frame(kit .. '->map', japi.DZ_FrameGetMinimap(), nil)
        :relation(FRAME_ALIGN_LEFT_BOTTOM, FrameGameUI, FRAME_ALIGN_LEFT_BOTTOM, 0.0036, 0.006)
        :size(width * 0.75, width)
    
    --- 小地图按钮
    -----@type table<number,Frame>
    stage.btns = {}
    local offset = {
        { 0.0018, -0.005 },
        { 0.0022, -0.005 - 0.021 },
        { 0.0020, -0.005 - 0.021 - 0.018 },
        { 0.0023, -0.005 - 0.021 - 0.018 - 0.018 },
        { 0.0022, -0.005 - 0.021 - 0.018 - 0.018 - 0.025 },
    }
    for i = 0, 4 do
        stage.btns[i] = Frame(kit .. '->btn->' .. i, japi.DZ_FrameGetMinimapButton(i), nil)
            :relation(FRAME_ALIGN_LEFT_TOP, stage.map, FRAME_ALIGN_RIGHT_TOP, offset[i + 1][1], offset[i + 1][2])
            :size(0.013, 0.013)
    end
    
    --- 默认皮肤
    async.call(PlayerLocal(), function()
        if (PlayerLocal():isPlaying()) then
            stage.main:texture("bg\\" .. PlayerLocal():skin())
        end
    end)

end)