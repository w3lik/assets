--[[
    消息类
    Author: hunzsig
]]

local kit = "lik_msg"

---@class UI_LikMsg:UIKit
local ui = UIKit(kit)

ui:onSetup(function(this)
    local stage = this:stage()
    
    -- Echo 屏幕信息
    if (false == isStaticClass("lik_echo", UIKitClass)) then
        stage.echo = Frame(kit .. "->echo", japi.DZ_FrameGetUnitMessage(), nil)
            :absolut(FRAME_ALIGN_LEFT_BOTTOM, 0.1, 0.25)
            :size(0, 0.36)
    end
    
    -- Chat 居中聊天信息
    stage.chat = Frame(kit .. "->chat", japi.DZ_FrameGetChatMessage(), nil)
        :absolut(FRAME_ALIGN_BOTTOM, 0, 0.22)
        :size(0.22, 0.16)
    
    -- alerter message
    stage.alerter = FrameText(kit .. "->alerter", FrameGameUI)
        :relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0, 0.13)
        :fontSize(12)
        :textAlign(TEXT_ALIGN_CENTER)
        :text('')

end)

function ui:alerterMessage(content)
    local stage = self:stage()
    stage.alerter:text(content)
end