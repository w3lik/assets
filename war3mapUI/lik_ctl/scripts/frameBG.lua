---@param stage UI_LikCtlStage
function likCtl_frameBG(kit, stage)
    
    stage.main = FrameBackdrop(kit, FrameGameUI)
        :adaptive(true)
        :relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, 0, 0)
    
    stage.bgShadow = FrameBackdrop(kit .. "->shadow", stage.main)
        :texture("bg\\shadow_i")
        :alpha(160)
        :size(0.03, stage.bgShadowH)
    stage.bgShadowL = FrameBackdrop(kit .. "->shadowl", stage.bgShadow)
        :relation(FRAME_ALIGN_RIGHT, stage.bgShadow, FRAME_ALIGN_LEFT, 0, 0)
        :texture("bg\\shadow_l")
        :alpha(160)
        :size(0.006, stage.bgShadowH)
    stage.bgShadowR = FrameBackdrop(kit .. "->shadowr", stage.bgShadow)
        :relation(FRAME_ALIGN_LEFT, stage.bgShadow, FRAME_ALIGN_RIGHT, 0, 0)
        :texture("bg\\shadow_r")
        :alpha(160)
        :size(0.006, stage.bgShadowH)
    
    stage.bg = FrameBackdrop(kit .. "->bg", stage.main)
        :adaptive(true)
        :block(true)
        :relation(FRAME_ALIGN_BOTTOM, FrameGameUI, FRAME_ALIGN_BOTTOM, -0.05, 0)
        :size(stage.bgW, stage.bgH)
    stage.bgEtc = FrameBackdrop(kit .. "->bgEtc", stage.bg)
        :block(true)
        :relation(FRAME_ALIGN_LEFT_BOTTOM, stage.bg, FRAME_ALIGN_RIGHT_BOTTOM, 0, 0)
        :size(0.01, stage.bgH)
    stage.bgTail = FrameBackdrop(kit .. "->bgTail", stage.bg)
        :block(true)
        :relation(FRAME_ALIGN_LEFT_BOTTOM, stage.bgEtc, FRAME_ALIGN_RIGHT_BOTTOM, -0.011, 0)
        :size(stage.bgTailW, stage.bgH)
    
    stage.bgShadow:relation(FRAME_ALIGN_RIGHT_BOTTOM, stage.bgTail, FRAME_ALIGN_RIGHT_TOP, -0.034, -0.031)

end