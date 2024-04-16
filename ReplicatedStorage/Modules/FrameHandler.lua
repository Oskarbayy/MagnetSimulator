local FrameHandler = {}

-- Services
local TweenService = game:GetService("TweenService")

-- Assuming 'BlurEffect' is your blur effect instance applied to the camera
local blurEffect = game.Workspace.Camera:FindFirstChild("BlurEffect") 

-- 
local currentlyOpenFrame = nil


function FrameHandler.OpenFrame(frame)
    if currentlyOpenFrame == frame then return end -- Prevent reopening the same frame

    FrameHandler.CloseFrame(currentlyOpenFrame, false) -- Close the currently open frame

    -- Apply blur effect
    blurEffect.Size = 24 -- Adjust the blur intensity
    frame.Visible = true

    currentlyOpenFrame = frame
end


function FrameHandler.CloseFrame(frame, resetBlur)
    if resetBlur == nil then
        resetBlur = true
    end

    if frame then

        frame.Visible = false
        -- Consider adding a check to reset the blur only when no other frame is set to be visible immediately
        if resetBlur then
            if blurEffect then blurEffect.Size = 0 end
        end
    end
end

return FrameHandler