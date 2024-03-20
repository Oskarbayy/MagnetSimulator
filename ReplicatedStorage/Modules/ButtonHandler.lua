--[[ DOCUMENTATION
    Every button clicked on checks for a 'ModuleScript' StringValue and then calls that modulescript
    but if there is a 'Function' StringValue too then it calls that function inside that
    modulescript.
]]

local ButtonHandler = {} 
-- Check
-- Services
local RStorage = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")

-- Modules
local Modules = RStorage:WaitForChild("Modules")
local MouseOverModule = require(Modules.MouseOverModule)


local plr = game.Players.LocalPlayer


function ButtonHandler:Init()
	-- setup all buttons and hover animations and such
	for _, button in pairs(plr.PlayerGui:WaitForChild("ScreenGui"):GetDescendants()) do
		if button:IsA("GuiButton") then
			print(button, "added to 'ButtonHandler'!")
			
			local defaultSize = Instance.new("Vector3Value", button)
			defaultSize.Value = Vector3.new(button.Size.X.Scale, button.Size.Y.Scale, 0)
			defaultSize.Name = "defaultSize"
			
			local tables = {button.Name, "TextLabel", "Icon"}
			for i,v in pairs(tables) do
				if button:FindFirstChild(v) then
					local defaultSize = Instance.new("Vector3Value", button[v])
					defaultSize.Value = Vector3.new(button[v].Size.X.Scale, button[v].Size.Y.Scale, 0)
					defaultSize.Name = "defaultSize"
					
				end
			end
			
			local MouseEnter, MouseLeave = MouseOverModule.MouseEnterLeaveEvent(button)

			MouseEnter:Connect(function()
				
				local buttonTween = TS:Create(button, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(button.defaultSize.Value.X * 1.1, 0, button.defaultSize.Value.Y * 1.1, 0)})
				buttonTween:Play()
				
				if button:FindFirstChild("UIStroke") then
					local colorTween = TS:Create(button.UIStroke, TweenInfo.new(.25), {Color = Color3.new(1,1,1)})
					colorTween:Play()
				end
				
				if button:FindFirstChild("Icon") then
					local icon = button.Icon
					local iconTween = TS:Create(icon, TweenInfo.new(.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(icon.defaultSize.Value.X * 1.15, 0, icon.defaultSize.Value.Y * 1.15, 0)})
					iconTween:Play()
				end
				
				if button:FindFirstChild("TextLabel") then
					local text = button.TextLabel
					local textTween = TS:Create(text, TweenInfo.new(.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(text.defaultSize.Value.X * 4, 0, text.defaultSize.Value.Y * 4, 0)})
					textTween:Play()
					text.Visible = true
				end
			end)

			MouseLeave:Connect(function()
				print("Mouseleft from button:", button)				
				local buttonTween = TS:Create(button, TweenInfo.new(.25, Enum.EasingStyle.Linear, Enum.EasingDirection.In), {Size = UDim2.new(button.defaultSize.Value.X, 0, button.defaultSize.Value.Y, 0)})
				buttonTween:Play()				
				
				if button:FindFirstChild("UIStroke") then
					local colorTween = TS:Create(button.UIStroke, TweenInfo.new(.25), {Color = Color3.new(0,0,0)})
					colorTween:Play()
				end
				
				if button:FindFirstChild("Icon") then
					local icon = button.Icon
					local iconTween = TS:Create(icon, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(icon.defaultSize.Value.X, 0, icon.defaultSize.Value.Y, 0)})
					iconTween:Play()
				end
				
				if button:FindFirstChild("TextLabel") then
					local text = button.TextLabel
					text.Visible = false
					-- tween fast since that will overrite
					local textTween = TS:Create(text, TweenInfo.new(0, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = UDim2.new(text.defaultSize.Value.X, 0, text.defaultSize.Value.Y, 0)})
					textTween:Play()
				end
			end) 
			
			button.MouseButton1Down:Connect(function()
				local buttonTween = TS:Create(button, TweenInfo.new(.1, Enum.EasingStyle.Linear, Enum.EasingDirection.Out), {Size = UDim2.new(button.defaultSize.Value.X * .9, 0, button.defaultSize.Value.Y * .9, 0)})
				buttonTween:Play()
			end)
			
			button.MouseButton1Up:Connect(function()
				local buttonTween = TS:Create(button, TweenInfo.new(1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(button.defaultSize.Value.X * 1.1, 0, button.defaultSize.Value.Y * 1.1, 0)})
				buttonTween:Play()
			end)
			
			-- Button Clicked
			
			button.MouseButton1Click:Connect(function()
				if button:FindFirstChild("ModuleScript") then
					local ModuleScript = button.ModuleScript.Value
					if Modules:FindFirstChild(ModuleScript) then
						if button:FindFirstChild("Function") then
							require(Modules[ModuleScript])[button.Function.Value](button.Name)
						else
							require(Modules[ModuleScript])(button.Name)
						end
					else
						print(ModuleScript, "Doesnt exist in Client Modules Folder")
					end
					
				else
					print(button, "Doesnt have a 'ModuleScript' connected")
				end
				
			end)
		end
	end
	
end

return ButtonHandler