local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local FedoraLibrary = {}

local Theme = {
	Background = Color3.fromRGB(0, 0, 0),
	Surface = Color3.fromRGB(12, 12, 12),
	SurfaceAlt = Color3.fromRGB(18, 18, 18),
	Stroke = Color3.fromRGB(255, 255, 255),
	TextPrimary = Color3.fromRGB(240, 240, 240),
	TextSecondary = Color3.fromRGB(130, 130, 130),
	Active = Color3.fromRGB(25, 25, 25),
}

local function resolveText(input, language)
	if type(input) == "table" then
		return input[language] or input.en or select(2, next(input)) or ""
	end
	return tostring(input)
end

local function makeDraggable(guiObject)
	local dragging, dragInput, dragStart, startPos
	local connections = {}

	table.insert(connections, guiObject.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = guiObject.Position

			local changedConn
			changedConn = input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
					if changedConn then changedConn:Disconnect() end
				end
			end)
		end
	end))

	table.insert(connections, guiObject.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
			dragInput = input
		end
	end))

	table.insert(connections, UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			local delta = input.Position - dragStart
			local newPos = UDim2.new(
				startPos.X.Scale, startPos.X.Offset + delta.X,
				startPos.Y.Scale, startPos.Y.Offset + delta.Y
			)
			TweenService:Create(guiObject, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
				Position = newPos
			}):Play()
		end
	end))

	return connections
end

function FedoraLibrary.CreateWindow(config)
	config = config or {}
	local hubTitle = config.Title or "Fedora hub."
	local defaultLanguage = config.Language or "en"

	local parentGui = game:GetService("CoreGui")

	if parentGui:FindFirstChild("FedoraHubGui") then
		parentGui.FedoraHubGui:Destroy()
	end

	local ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "FedoraHubGui"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	ScreenGui.Parent = parentGui

	local NotificationContainer = Instance.new("Frame")
	NotificationContainer.Name = "NotificationContainer"
	NotificationContainer.Size = UDim2.new(0, 260, 1, -20)
	NotificationContainer.Position = UDim2.new(1, -270, 0, 10)
	NotificationContainer.BackgroundTransparency = 1
	NotificationContainer.Parent = ScreenGui

	local NotifListLayout = Instance.new("UIListLayout")
	NotifListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	NotifListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	NotifListLayout.Padding = UDim.new(0, 8)
	NotifListLayout.Parent = NotificationContainer

	local Window = {}
	Window.ScreenGui = ScreenGui
	Window.Tabs = {}
	Window.Language = defaultLanguage
	Window._connections = {}
	Window._localizedElements = {}

	local function track(conn)
		table.insert(Window._connections, conn)
		return conn
	end

	local function registerLocalized(entry)
		table.insert(Window._localizedElements, entry)
	end

	function Window:SetLanguage(language)
		Window.Language = language
		for _, entry in ipairs(Window._localizedElements) do
			entry.apply(Window.Language)
		end
	end

	function Window:SendNotification(text)
		local notifFrame = Instance.new("Frame")
		notifFrame.Size = UDim2.new(1, 0, 0, 0)
		notifFrame.BackgroundColor3 = Theme.Background
		notifFrame.ClipsDescendants = true
		notifFrame.Parent = NotificationContainer

		local notifCorner = Instance.new("UICorner")
		notifCorner.CornerRadius = UDim.new(0, 10)
		notifCorner.Parent = notifFrame

		local notifStroke = Instance.new("UIStroke")
		notifStroke.Color = Theme.Stroke
		notifStroke.Transparency = 0.85
		notifStroke.Thickness = 1
		notifStroke.Parent = notifFrame

		local notifText = Instance.new("TextLabel")
		notifText.Size = UDim2.new(1, -20, 1, 0)
		notifText.Position = UDim2.new(0, 10, 0, 0)
		notifText.BackgroundTransparency = 1
		notifText.TextColor3 = Theme.TextPrimary
		notifText.Font = Enum.Font.GothamMedium
		notifText.TextSize = 12
		notifText.TextXAlignment = Enum.TextXAlignment.Left
		notifText.TextWrapped = true
		notifText.Parent = notifFrame

		local function applyText(language)
			notifText.Text = resolveText(text, language)
		end
		applyText(Window.Language)
		registerLocalized({ apply = applyText })

		TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 0, 48)
		}):Play()

		task.delay(3.5, function()
			local closeTween = TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
				Size = UDim2.new(1, 0, 0, 0)
			})
			closeTween:Play()
			closeTween.Completed:Connect(function()
				notifFrame:Destroy()
			end)
		end)
	end

	local ToggleButton = Instance.new("TextButton")
	ToggleButton.Name = "SquareToggle"
	ToggleButton.Size = UDim2.new(0, 48, 0, 48)
	ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
	ToggleButton.BackgroundColor3 = Theme.Background
	ToggleButton.Text = "★"
	ToggleButton.TextColor3 = Theme.TextPrimary
	ToggleButton.TextSize = 20
	ToggleButton.Font = Enum.Font.GothamBold
	ToggleButton.AutoButtonColor = false
	ToggleButton.Parent = ScreenGui

	local ToggleCorner = Instance.new("UICorner")
	ToggleCorner.CornerRadius = UDim.new(0, 12)
	ToggleCorner.Parent = ToggleButton

	local ToggleStroke = Instance.new("UIStroke")
	ToggleStroke.Color = Theme.Stroke
	ToggleStroke.Transparency = 0.8
	ToggleStroke.Thickness = 1.5
	ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	ToggleStroke.Parent = ToggleButton

	for _, conn in ipairs(makeDraggable(ToggleButton)) do
		track(conn)
	end

	local MainFrame = Instance.new("Frame")
	MainFrame.Name = "MainFrame"
	MainFrame.Size = UDim2.new(0, 340, 0, 300)
	MainFrame.Position = UDim2.new(0.5, -170, 0.5, -150)
	MainFrame.BackgroundColor3 = Theme.Background
	MainFrame.ClipsDescendants = true
	MainFrame.Active = true
	MainFrame.Parent = ScreenGui

	local MainCorner = Instance.new("UICorner")
	MainCorner.CornerRadius = UDim.new(0, 16)
	MainCorner.Parent = MainFrame

	local MainStroke = Instance.new("UIStroke")
	MainStroke.Color = Theme.Stroke
	MainStroke.Transparency = 0.85
	MainStroke.Thickness = 1.5
	MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	MainStroke.Parent = MainFrame

	for _, conn in ipairs(makeDraggable(MainFrame)) do
		track(conn)
	end

	local Header = Instance.new("Frame")
	Header.Size = UDim2.new(1, 0, 0, 45)
	Header.BackgroundTransparency = 1
	Header.Parent = MainFrame

	local TitleLabel = Instance.new("TextLabel")
	TitleLabel.Size = UDim2.new(1, -24, 1, 0)
	TitleLabel.Position = UDim2.new(0, 16, 0, 0)
	TitleLabel.BackgroundTransparency = 1
	TitleLabel.TextColor3 = Theme.TextPrimary
	TitleLabel.TextSize = 14
	TitleLabel.Font = Enum.Font.GothamBold
	TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	TitleLabel.Parent = Header

	local function applyTitle(language)
		TitleLabel.Text = resolveText(hubTitle, language)
	end
	applyTitle(Window.Language)
	registerLocalized({ apply = applyTitle })

	local TabBar = Instance.new("Frame")
	TabBar.Size = UDim2.new(1, -32, 0, 32)
	TabBar.Position = UDim2.new(0, 16, 0, 48)
	TabBar.BackgroundColor3 = Theme.Surface
	TabBar.Parent = MainFrame

	local TabCorner = Instance.new("UICorner")
	TabCorner.CornerRadius = UDim.new(0, 8)
	TabCorner.Parent = TabBar

	local TabStroke = Instance.new("UIStroke")
	TabStroke.Color = Theme.Stroke
	TabStroke.Transparency = 0.92
	TabStroke.Thickness = 1
	TabStroke.Parent = TabBar

	local ContentContainer = Instance.new("Frame")
	ContentContainer.Size = UDim2.new(1, -32, 1, -95)
	ContentContainer.Position = UDim2.new(0, 16, 0, 88)
	ContentContainer.BackgroundTransparency = 1
	ContentContainer.Parent = MainFrame

	local isGuiVisible = true
	local originalSize = MainFrame.Size

	track(ToggleButton.MouseButton1Click:Connect(function()
		isGuiVisible = not isGuiVisible
		TweenService:Create(ToggleButton, TweenInfo.new(0.1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 42, 0, 42)
		}):Play()
		task.wait(0.1)
		TweenService:Create(ToggleButton, TweenInfo.new(0.15, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 48, 0, 48)
		}):Play()

		if isGuiVisible then
			MainFrame.Visible = true
			MainFrame.Size = UDim2.new(0, 0, 0, 0)
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
				Size = originalSize
			}):Play()
		else
			local closeTween = TweenService:Create(MainFrame, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
				Size = UDim2.new(0, 0, 0, 0)
			})
			closeTween:Play()
			closeTween.Completed:Connect(function()
				if not isGuiVisible then
					MainFrame.Visible = false
					MainFrame.Size = originalSize
				end
			end)
		end
	end))

	local function updateTabSizes()
		local count = #Window.Tabs
		if count == 0 then return end

		local widthScale = 1 / count
		for i, tabData in ipairs(Window.Tabs) do
			tabData.Button.Size = UDim2.new(widthScale, -2, 1, -6)
			tabData.Button.Position = UDim2.new(widthScale * (i - 1), (i == 1 and 3 or 1), 0, 3)
		end
	end

	function Window:CreateTab(name)
		if #Window.Tabs >= 5 then
			warn("[Fedora Hub]: Reached maximum limit of 5 tabs!")
			return nil
		end

		local TabView = Instance.new("ScrollingFrame")
		TabView.Size = UDim2.new(1, 0, 1, 0)
		TabView.BackgroundTransparency = 1
		TabView.Visible = false
		TabView.ScrollBarThickness = 2
		TabView.ScrollBarImageColor3 = Theme.Stroke
		TabView.CanvasSize = UDim2.new(0, 0, 0, 0)
		TabView.Parent = ContentContainer

		local TabListLayout = Instance.new("UIListLayout")
		TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
		TabListLayout.Padding = UDim.new(0, 8)
		TabListLayout.Parent = TabView

		track(TabListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabView.CanvasSize = UDim2.new(0, 0, 0, TabListLayout.AbsoluteContentSize.Y)
		end))

		local TabBtn = Instance.new("TextButton")
		TabBtn.BackgroundTransparency = 1
		TabBtn.TextColor3 = Theme.TextSecondary
		TabBtn.Font = Enum.Font.GothamBold
		TabBtn.TextSize = 10
		TabBtn.AutoButtonColor = false
		TabBtn.Parent = TabBar

		local TabBtnCorner = Instance.new("UICorner")
		TabBtnCorner.CornerRadius = UDim.new(0, 6)
		TabBtnCorner.Parent = TabBtn

		local function applyTabName(language)
			TabBtn.Text = resolveText(name, language)
		end
		applyTabName(Window.Language)
		registerLocalized({ apply = applyTabName })

		local tabData = {
			View = TabView,
			Button = TabBtn
		}

		table.insert(Window.Tabs, tabData)
		updateTabSizes()

		local function switchTab()
			for _, tData in ipairs(Window.Tabs) do
				if tData == tabData then
					tData.View.Visible = true
					TweenService:Create(tData.Button, TweenInfo.new(0.15), { BackgroundColor3 = Theme.Active }):Play()
					tData.Button.BackgroundTransparency = 0
					tData.Button.TextColor3 = Theme.TextPrimary
				else
					tData.View.Visible = false
					tData.Button.BackgroundTransparency = 1
					tData.Button.TextColor3 = Theme.TextSecondary
				end
			end
		end

		track(TabBtn.MouseButton1Click:Connect(switchTab))

		if #Window.Tabs == 1 then
			switchTab()
		end

		local TabElements = {}

		function TabElements:CreateButton(text, callback)
			local btn = Instance.new("TextButton")
			btn.Size = UDim2.new(1, 0, 0, 38)
			btn.BackgroundColor3 = Theme.Surface
			btn.TextColor3 = Theme.TextPrimary
			btn.Font = Enum.Font.GothamMedium
			btn.TextSize = 12
			btn.AutoButtonColor = false
			btn.Parent = TabView

			local btnCorner = Instance.new("UICorner")
			btnCorner.CornerRadius = UDim.new(0, 8)
			btnCorner.Parent = btn

			local btnStroke = Instance.new("UIStroke")
			btnStroke.Color = Theme.Stroke
			btnStroke.Transparency = 0.9
			btnStroke.Thickness = 1
			btnStroke.Parent = btn

			local function applyBtnText(language)
				btn.Text = resolveText(text, language)
			end
			applyBtnText(Window.Language)
			registerLocalized({ apply = applyBtnText })

			track(btn.MouseButton1Click:Connect(function()
				if callback then callback() end
			end))

			return btn
		end

		function TabElements:CreateToggle(text, defaultState, callback)
			local enabled = defaultState or false

			local ToggleContainer = Instance.new("Frame")
			ToggleContainer.Size = UDim2.new(1, 0, 0, 42)
			ToggleContainer.BackgroundColor3 = Theme.Surface
			ToggleContainer.Parent = TabView

			local TogCorner = Instance.new("UICorner")
			TogCorner.CornerRadius = UDim.new(0, 8)
			TogCorner.Parent = ToggleContainer

			local TogStroke = Instance.new("UIStroke")
			TogStroke.Color = Theme.Stroke
			TogStroke.Transparency = 0.9
			TogStroke.Thickness = 1
			TogStroke.Parent = ToggleContainer

			local ToggleLabel = Instance.new("TextLabel")
			ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
			ToggleLabel.Position = UDim2.new(0, 14, 0, 0)
			ToggleLabel.BackgroundTransparency = 1
			ToggleLabel.TextColor3 = Theme.TextPrimary
			ToggleLabel.Font = Enum.Font.GothamMedium
			ToggleLabel.TextSize = 12
			ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
			ToggleLabel.Parent = ToggleContainer

			local function applyToggleText(language)
				ToggleLabel.Text = resolveText(text, language)
			end
			applyToggleText(Window.Language)
			registerLocalized({ apply = applyToggleText })

			local SwitchTrack = Instance.new("TextButton")
			SwitchTrack.Size = UDim2.new(0, 40, 0, 20)
			SwitchTrack.Position = UDim2.new(1, -50, 0.5, -10)
			SwitchTrack.BackgroundColor3 = enabled and Theme.Stroke or Color3.fromRGB(35, 35, 35)
			SwitchTrack.Text = ""
			SwitchTrack.AutoButtonColor = false
			SwitchTrack.Parent = ToggleContainer

			local TrackCorner = Instance.new("UICorner")
			TrackCorner.CornerRadius = UDim.new(1, 0)
			TrackCorner.Parent = SwitchTrack

			local SwitchKnob = Instance.new("Frame")
			SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
			SwitchKnob.Position = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
			SwitchKnob.BackgroundColor3 = enabled and Theme.Background or Color3.fromRGB(120, 120, 120)
			SwitchKnob.Parent = SwitchTrack

			local KnobCorner = Instance.new("UICorner")
			KnobCorner.CornerRadius = UDim.new(1, 0)
			KnobCorner.Parent = SwitchKnob

			local function setToggleState(state)
				enabled = state
				local knobPos = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
				local trackColor = enabled and Theme.Stroke or Color3.fromRGB(35, 35, 35)
				local knobColor = enabled and Theme.Background or Color3.fromRGB(120, 120, 120)

				TweenService:Create(SwitchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Position = knobPos,
					BackgroundColor3 = knobColor
				}):Play()

				TweenService:Create(SwitchTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					BackgroundColor3 = trackColor
				}):Play()

				if callback then callback(enabled) end
			end

			track(SwitchTrack.MouseButton1Click:Connect(function()
				setToggleState(not enabled)
			end))

			return {
				Set = setToggleState,
				Get = function() return enabled end
			}
		end

		function TabElements:CreateDropdown(title, options, callback)
			local DropdownContainer = Instance.new("Frame")
			DropdownContainer.Size = UDim2.new(1, 0, 0, 38)
			DropdownContainer.BackgroundColor3 = Theme.Surface
			DropdownContainer.ClipsDescendants = true
			DropdownContainer.Parent = TabView

			local DropCorner = Instance.new("UICorner")
			DropCorner.CornerRadius = UDim.new(0, 8)
			DropCorner.Parent = DropdownContainer

			local DropStroke = Instance.new("UIStroke")
			DropStroke.Color = Theme.Stroke
			DropStroke.Transparency = 0.9
			DropStroke.Thickness = 1
			DropStroke.Parent = DropdownContainer

			local DropdownBtn = Instance.new("TextButton")
			DropdownBtn.Size = UDim2.new(1, 0, 0, 38)
			DropdownBtn.BackgroundTransparency = 1
			DropdownBtn.TextColor3 = Theme.TextPrimary
			DropdownBtn.Font = Enum.Font.GothamMedium
			DropdownBtn.TextSize = 12
			DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
			DropdownBtn.Parent = DropdownContainer

			local function applyDropdownTitle(language)
				DropdownBtn.Text = "  " .. resolveText(title, language)
			end
			applyDropdownTitle(Window.Language)
			registerLocalized({ apply = applyDropdownTitle })

			local DropArrow = Instance.new("TextLabel")
			DropArrow.Size = UDim2.new(0, 38, 0, 38)
			DropArrow.Position = UDim2.new(1, -38, 0, 0)
			DropArrow.BackgroundTransparency = 1
			DropArrow.Text = "▼"
			DropArrow.TextColor3 = Theme.TextSecondary
			DropArrow.Font = Enum.Font.GothamMedium
			DropArrow.TextSize = 10
			DropArrow.Parent = DropdownContainer

			local DropScroll = Instance.new("ScrollingFrame")
			DropScroll.Size = UDim2.new(1, -12, 0, 80)
			DropScroll.Position = UDim2.new(0, 6, 0, 40)
			DropScroll.BackgroundTransparency = 1
			DropScroll.ScrollBarThickness = 2
			DropScroll.ScrollBarImageColor3 = Theme.Stroke
			DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
			DropScroll.Parent = DropdownContainer

			local DropListLayout = Instance.new("UIListLayout")
			DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
			DropListLayout.Padding = UDim.new(0, 3)
			DropListLayout.Parent = DropScroll

			track(DropListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropListLayout.AbsoluteContentSize.Y)
			end))

			local isOpen = false
			local function setDropdownState(open)
				isOpen = open
				local optionCount = #options
				local expandedHeight = math.clamp(38 + 6 + (optionCount * 29), 38, 168)
				local targetHeight = open and expandedHeight or 38
				DropScroll.Size = UDim2.new(1, -12, 0, expandedHeight - 44)
				TweenService:Create(DropdownContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
					Size = UDim2.new(1, 0, 0, targetHeight)
				}):Play()
				DropArrow.Text = open and "▲" or "▼"
			end

			track(DropdownBtn.MouseButton1Click:Connect(function()
				setDropdownState(not isOpen)
			end))

			for _, opt in ipairs(options) do
				local optBtn = Instance.new("TextButton")
				optBtn.Size = UDim2.new(1, 0, 0, 26)
				optBtn.BackgroundColor3 = Theme.SurfaceAlt
				optBtn.TextColor3 = Theme.TextPrimary
				optBtn.Font = Enum.Font.GothamMedium
				optBtn.TextSize = 11
				optBtn.TextXAlignment = Enum.TextXAlignment.Left
				optBtn.AutoButtonColor = false
				optBtn.Parent = DropScroll

				local optCorner = Instance.new("UICorner")
				optCorner.CornerRadius = UDim.new(0, 6)
				optCorner.Parent = optBtn

				local function applyOptText(language)
					optBtn.Text = " " .. resolveText(opt, language)
				end
				applyOptText(Window.Language)
				registerLocalized({ apply = applyOptText })

				track(optBtn.MouseButton1Click:Connect(function()
					setDropdownState(false)
					if callback then callback(opt) end
				end))
			end

			return {
				SetOpen = setDropdownState
			}
		end

		return TabElements
	end

	function Window:Destroy()
		for _, conn in ipairs(Window._connections) do
			conn:Disconnect()
		end
		Window._connections = {}
		Window._localizedElements = {}
		ScreenGui:Destroy()
	end

	return Window
end

return FedoraLibrary
