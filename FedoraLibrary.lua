local FedoraLibrary = {}
FedoraLibrary.__index = FedoraLibrary

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")

local function ApplyCorner(parent, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius or 8)
	corner.Parent = parent
	return corner
end

local function ApplyStroke(parent, color, thickness)
	local stroke = Instance.new("UIStroke")
	stroke.Color = color or Color3.fromRGB(35, 35, 35)
	stroke.Thickness = thickness or 1
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = parent
	return stroke
end

function FedoraLibrary.CreateWindow(titleText)
	local Window = {}
	Window.CurrentLanguage = "en"
	Window.TextObjects = {}
	Window.Tabs = {}
	
	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "FedoraHub_" .. math.random(1000, 9999)
	ScreenGui.ResetOnSpawn = false
	
	pcall(function()
		ScreenGui.Parent = CoreGui
	end)
	if not ScreenGui.Parent then
		ScreenGui.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
	end
	
	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 520, 0, 360)
	MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
	MainFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
	MainFrame.BorderSizePixel = 0
	MainFrame.ClipsDescendants = true
	MainFrame.Parent = ScreenGui
	ApplyCorner(MainFrame, 10)
	ApplyStroke(MainFrame, Color3.fromRGB(30, 30, 30), 1)

	local TopBar = Instance.new("Frame")
	TopBar.Name = "TopBar"
	TopBar.Size = UDim2.new(1, 0, 0, 40)
	TopBar.BackgroundColor3 = Color3.fromRGB(16, 16, 16)
	TopBar.BorderSizePixel = 0
	TopBar.Parent = MainFrame
	
	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Name = "TitleLabel"
	TitleLabel.Size = UDim2.new(1, -20, 1, 0)
	TitleLabel.Position = UDim2.new(0, 15, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.Text = titleText or "Fedora Hub"
	TitleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
	TitleLabel.TextSize = 15
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = TopBar

	local dragging, dragInput, dragStart, startPos
	TopBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = MainFrame.Position
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)
	
	TopBar.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end)
	
	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)

	local TabBar = Instance.new("Frame")
	TabBar.Name = "TabBar"
	TabBar.Size = UDim2.new(1, -20, 0, 32)
	TabBar.Position = UDim2.new(0, 10, 0, 48)
	TabBar.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	TabBar.Parent = MainFrame
	ApplyCorner(TabBar, 6)

	local TabListLayout = Instance.new("UIListLayout")
	TabListLayout.FillDirection = Enum.FillDirection.Horizontal
	TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	TabListLayout.Padding = UDim.new(0, 4)
	TabListLayout.Parent = TabBar

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Name = "ContentContainer"
	ContentContainer.Size = UDim2.new(1, -20, 1, -95)
	ContentContainer.Position = UDim2.new(0, 10, 0, 85)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	local NotificationContainer = Instance.new("Frame")
	NotificationContainer.Name = "NotificationContainer"
	NotificationContainer.Size = UDim2.new(0, 200, 1, -20)
	NotificationContainer.Position = UDim2.new(1, -210, 0, 10)
	NotificationContainer.BackgroundTransparency = 1
	NotificationContainer.Parent = ScreenGui

	local NotifLayout = Instance.new("UIListLayout")
	NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifLayout.Padding = UDim.new(0, 6)
	NotifLayout.Parent = NotificationContainer

	local function ResolveText(textData, targetLang)
		targetLang = targetLang or Window.CurrentLanguage
		if type(textData) == "table" then
			return textData[targetLang] or textData["en"] or ""
		end
		return tostring(textData)
	end

	local function RegisterTextLabel(label, textData)
		if type(textData) == "table" then
			table.insert(Window.TextObjects, { Label = label, TextData = textData })
		end
		label.Text = ResolveText(textData, Window.CurrentLanguage)
		if Window.CurrentLanguage == "ar" then
			label.TextXAlignment = Enum.TextXAlignment.Right
		end
	end

	function Window:SetLanguage(lang)
		if lang ~= "en" and lang ~= "ar" then return end
		Window.CurrentLanguage = lang
		for _, item in ipairs(Window.TextObjects) do
			if item.Label and item.Label.Parent then
				item.Label.Text = ResolveText(item.TextData, lang)
				if lang == "ar" then
					item.Label.TextXAlignment = Enum.TextXAlignment.Right
				else
					item.Label.TextXAlignment = Enum.TextXAlignment.Left
				end
			end
		end
	end

	function Window:SendNotification(textData)
		local NotifFrame = Instance.new("Frame")
		NotifFrame.Size = UDim2.new(1, 0, 0, 36)
		NotifFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
		NotifFrame.BackgroundTransparency = 1
		NotifFrame.Parent = NotificationContainer
		ApplyCorner(NotifFrame, 6)
		ApplyStroke(NotifFrame, Color3.fromRGB(40, 40, 40), 1)

		local NotifLabel = Instance.new("TextLabel")
		NotifLabel.Size = UDim2.new(1, -20, 1, 0)
		NotifLabel.Position = UDim2.new(0, 10, 0, 0)
		NotifLabel.BackgroundTransparency = 1
		NotifLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
		NotifLabel.TextSize = 12
		NotifLabel.Font = Enum.Font.GothamMedium
		NotifLabel.Parent = NotifFrame

		RegisterTextLabel(NotifLabel, textData)

		TweenService:Create(NotifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 0}):Play()
		
		task.delay(3.5, function()
			local fade = TweenService:Create(NotifFrame, TweenInfo.new(0.3), {BackgroundTransparency = 1})
			fade:Play()
			fade.Completed:Connect(function()
				NotifFrame:Destroy()
			end)
		end)
	end

	function Window:CreatePopup(textData, textSize, isBold)
		local PopupOverlay = Instance.new("Frame")
		PopupOverlay.Size = UDim2.new(1, 0, 1, 0)
		PopupOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
		PopupOverlay.BackgroundTransparency = 1
		PopupOverlay.Parent = MainFrame

		local PopupFrame = Instance.new("Frame")
		PopupFrame.Size = UDim2.new(0, 280, 0, 140)
		PopupFrame.Position = UDim2.new(0.5, -140, 0.5, -70)
		PopupFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
		PopupFrame.Parent = PopupOverlay
		ApplyCorner(PopupFrame, 8)
		ApplyStroke(PopupFrame, Color3.fromRGB(45, 45, 45), 1)

		local PopupLabel = Instance.new("TextLabel")
		PopupLabel.Size = UDim2.new(1, -20, 1, -50)
		PopupLabel.Position = UDim2.new(0, 10, 0, 10)
		PopupLabel.BackgroundTransparency = 1
		PopupLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
		PopupLabel.TextSize = textSize or 12
		PopupLabel.Font = isBold and Enum.Font.GothamBold or Enum.Font.GothamMedium
		PopupLabel.TextWrapped = true
		PopupLabel.Parent = PopupFrame

		RegisterTextLabel(PopupLabel, textData)

		local CloseBtn = Instance.new("TextButton")
		CloseBtn.Size = UDim2.new(0, 80, 0, 26)
		CloseBtn.Position = UDim2.new(0.5, -40, 1, -34)
		CloseBtn.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
		CloseBtn.Text = "OK"
		CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
		CloseBtn.Font = Enum.Font.GothamBold
		CloseBtn.TextSize = 11
		CloseBtn.Parent = PopupFrame
		ApplyCorner(CloseBtn, 4)

		TweenService:Create(PopupOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 0.5}):Play()

		CloseBtn.MouseButton1Click:Connect(function()
			local fade = TweenService:Create(PopupOverlay, TweenInfo.new(0.2), {BackgroundTransparency = 1})
			fade:Play()
			fade.Completed:Connect(function()
				PopupOverlay:Destroy()
			end)
		end)
	end

	function Window:CreateTab(tabNameData)
		if #Window.Tabs >= 5 then return end

		local Tab = {}
		local TabIndex = #Window.Tabs + 1

		local TabButton = Instance.new("TextButton")
		TabButton.Name = "TabButton_" .. TabIndex
		TabButton.Size = UDim2.new(0.2, -3, 1, 0)
		TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
		TabButton.BackgroundTransparency = TabIndex == 1 and 0 or 1
		TabButton.TextColor3 = TabIndex == 1 and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(140, 140, 140)
		TabButton.Font = Enum.Font.GothamBold
		TabButton.TextSize = 12
		TabButton.Parent = TabBar
		ApplyCorner(TabButton, 4)

		RegisterTextLabel(TabButton, tabNameData)

		local TabPage = Instance.new("ScrollingFrame")
		TabPage.Name = "TabPage_" .. TabIndex
		TabPage.Size = UDim2.new(1, 0, 1, 0)
		TabPage.BackgroundTransparency = 1
		TabPage.BorderSizePixel = 0
		TabPage.ScrollBarThickness = 2
		TabPage.ScrollBarImageColor3 = Color3.fromRGB(50, 50, 50)
		TabPage.Visible = TabIndex == 1
		TabPage.Parent = ContentContainer

		local PageLayout = Instance.new("UIListLayout")
		PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
		PageLayout.Padding = UDim.new(0, 6)
		PageLayout.Parent = TabPage

		PageLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabPage.CanvasSize = UDim2.new(0, 0, 0, PageLayout.AbsoluteContentSize.Y + 10)
		end)

		TabButton.MouseButton1Click:Connect(function()
			for _, t in ipairs(Window.Tabs) do
				t.Button.BackgroundTransparency = 1
				t.Button.TextColor3 = Color3.fromRGB(140, 140, 140)
				t.Page.Visible = false
			end
			TabButton.BackgroundTransparency = 0
			TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
			TabPage.Visible = true
		end)

		function Tab:CreateButton(textData, callback)
			local Btn = Instance.new("TextButton")
			Btn.Size = UDim2.new(1, -6, 0, 32)
			Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			Btn.AutoButtonColor = false
			Btn.Text = ""
			Btn.Parent = TabPage
			ApplyCorner(Btn, 6)
			ApplyStroke(Btn, Color3.fromRGB(32, 32, 32), 1)

			local BtnLabel = Instance.new("TextLabel")
			BtnLabel.Size = UDim2.new(1, -20, 1, 0)
			BtnLabel.Position = UDim2.new(0, 10, 0, 0)
			BtnLabel.BackgroundTransparency = 1
			BtnLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
			BtnLabel.TextSize = 12
			BtnLabel.Font = Enum.Font.GothamMedium
			BtnLabel.Parent = Btn

			RegisterTextLabel(BtnLabel, textData)

			Btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end)
		end

		function Tab:CreateToggle(textData, defaultState, callback)
			local Tgl = Instance.new("Frame")
			Tgl.Size = UDim2.new(1, -6, 0, 32)
			Tgl.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			Tgl.Parent = TabPage
			ApplyCorner(Tgl, 6)
			ApplyStroke(Tgl, Color3.fromRGB(32, 32, 32), 1)

			local TglLabel = Instance.new("TextLabel")
			TglLabel.Size = UDim2.new(1, -50, 1, 0)
			TglLabel.Position = UDim2.new(0, 10, 0, 0)
			TglLabel.BackgroundTransparency = 1
			TglLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
			TglLabel.TextSize = 12
			TglLabel.Font = Enum.Font.GothamMedium
			TglLabel.Parent = Tgl

			RegisterTextLabel(TglLabel, textData)

			local Switch = Instance.new("Frame")
			Switch.Size = UDim2.new(0, 32, 0, 16)
			Switch.Position = UDim2.new(1, -42, 0.5, -8)
			Switch.BackgroundColor3 = defaultState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
			Switch.Parent = Tgl
			ApplyCorner(Switch, 8)

			local State = defaultState or false

			local ClickArea = Instance.new("TextButton")
			ClickArea.Size = UDim2.new(1, 0, 1, 0)
			ClickArea.BackgroundTransparency = 1
			ClickArea.Text = ""
			ClickArea.Parent = Tgl

			ClickArea.MouseButton1Click:Connect(function()
				State = not State
				TweenService:Create(Switch, TweenInfo.new(0.15), {
					BackgroundColor3 = State and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(40, 40, 40)
				}):Play()
				if callback then callback(State) end
			end)
		end

		function Tab:CreateDropdown(textData, options, callback)
			local DropFrame = Instance.new("Frame")
			DropFrame.Size = UDim2.new(1, -6, 0, 32)
			DropFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
			DropFrame.ClipsDescendants = true
			DropFrame.Parent = TabPage
			ApplyCorner(DropFrame, 6)
			ApplyStroke(DropFrame, Color3.fromRGB(32, 32, 32), 1)

			local DropLabel = Instance.new("TextLabel")
			DropLabel.Size = UDim2.new(1, -30, 0, 32)
			DropLabel.Position = UDim2.new(0, 10, 0, 0)
			DropLabel.BackgroundTransparency = 1
			DropLabel.TextColor3 = Color3.fromRGB(220, 220, 220)
			DropLabel.TextSize = 12
			DropLabel.Font = Enum.Font.GothamMedium
			DropLabel.Parent = DropFrame

			RegisterTextLabel(DropLabel, textData)

			local ToggleBtn = Instance.new("TextButton")
			ToggleBtn.Size = UDim2.new(1, 0, 0, 32)
			ToggleBtn.BackgroundTransparency = 1
			ToggleBtn.Text = ""
			ToggleBtn.Parent = DropFrame

			local IsOpen = false
			local ItemHeight = 24
			local TotalHeight = 32 + (#options * ItemHeight) + 6

			ToggleBtn.MouseButton1Click:Connect(function()
				IsOpen = not IsOpen
				TweenService:Create(DropFrame, TweenInfo.new(0.2), {
					Size = UDim2.new(1, -6, 0, IsOpen and TotalHeight or 32)
				}):Play()
			end)

			for i, option in ipairs(options) do
				local OptBtn = Instance.new("TextButton")
				OptBtn.Size = UDim2.new(1, -12, 0, ItemHeight)
				OptBtn.Position = UDim2.new(0, 6, 0, 32 + ((i - 1) * ItemHeight))
				OptBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
				OptBtn.Text = tostring(option)
				OptBtn.TextColor3 = Color3.fromRGB(180, 180, 180)
				OptBtn.TextSize = 11
				OptBtn.Font = Enum.Font.Gotham
				OptBtn.Parent = DropFrame
				ApplyCorner(OptBtn, 4)

				OptBtn.MouseButton1Click:Connect(function()
					IsOpen = false
					TweenService:Create(DropFrame, TweenInfo.new(0.2), {
						Size = UDim2.new(1, -6, 0, 32)
					}):Play()
					if callback then callback(option) end
				end)
			end
		end

		Tab.Button = TabButton
		Tab.Page = TabPage
		table.insert(Window.Tabs, Tab)

		return Tab
	end

	return Window
end

return FedoraLibrary
