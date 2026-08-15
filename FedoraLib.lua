local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

if PlayerGui:FindFirstChild("FedoraLibrary") then
    PlayerGui.FedoraLibrary:Destroy()
end

local Library = {}
Library.Flags = {}
Library.CurrentLang = "EN"

local function resolveText(input)
    if type(input) == "table" then
        return input[Library.CurrentLang] or input.EN or ""
    elseif type(input) == "string" then
        return input
    else
        return ""
    end
end

local function fontSizeFor(base)
    if Library.CurrentLang == "AR" then
        return (base * 1.5) - 1.5
    end
    return base
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "FedoraLibrary"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = PlayerGui

local registeredTextElements = {}

local function registerText(instanceObj, prop, textInput, baseSize)
    table.insert(registeredTextElements, {
        obj = instanceObj,
        prop = prop,
        source = textInput,
        baseSize = baseSize
    })
    instanceObj[prop] = resolveText(textInput)
    if baseSize then
        pcall(function()
            instanceObj.TextSize = fontSizeFor(baseSize)
        end)
    end
end

local function registerCustomText(refreshFn)
    table.insert(registeredTextElements, { custom = true, refreshFn = refreshFn })
    refreshFn()
end

local function refreshAllText()
    for _, entry in ipairs(registeredTextElements) do
        if entry.custom then
            entry.refreshFn()
        elseif entry.obj and entry.obj.Parent then
            entry.obj[entry.prop] = resolveText(entry.source)
            if entry.baseSize then
                pcall(function()
                    entry.obj.TextSize = fontSizeFor(entry.baseSize)
                end)
            end
        end
    end
end

local function makeDraggable(guiObject)
    local dragging = false
    local dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        local newPos = UDim2.new(
            startPos.X.Scale, startPos.X.Offset + delta.X,
            startPos.Y.Scale, startPos.Y.Offset + delta.Y
        )
        TweenService:Create(guiObject, TweenInfo.new(0.08, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
            Position = newPos
        }):Play()
    end

    guiObject.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = guiObject.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    guiObject.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

function Library:ShowPopup(titleInput, bodyInput)
    local PopupFrame = Instance.new("Frame")
    PopupFrame.Name = "AmoledPopup"
    PopupFrame.Size = UDim2.new(0, 280, 0, 150)
    PopupFrame.Position = UDim2.new(0.5, -140, 0.5, -75)
    PopupFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    PopupFrame.ClipsDescendants = true
    PopupFrame.ZIndex = 100
    PopupFrame.Parent = ScreenGui

    local PopupCorner = Instance.new("UICorner")
    PopupCorner.CornerRadius = UDim.new(0, 10)
    PopupCorner.Parent = PopupFrame

    local PopupStroke = Instance.new("UIStroke")
    PopupStroke.Color = Color3.fromRGB(255, 255, 255)
    PopupStroke.Transparency = 0.85
    PopupStroke.Thickness = 1.5
    PopupStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    PopupStroke.Parent = PopupFrame

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 28, 0, 28)
    CloseBtn.Position = UDim2.new(1, -32, 0, 6)
    CloseBtn.BackgroundTransparency = 1
    CloseBtn.Text = "X"
    CloseBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 14
    CloseBtn.ZIndex = 101
    CloseBtn.Parent = PopupFrame

    CloseBtn.MouseButton1Click:Connect(function()
        PopupFrame:Destroy()
    end)

    local PopupTitle = Instance.new("TextLabel")
    PopupTitle.Size = UDim2.new(1, -64, 0, 28)
    PopupTitle.Position = UDim2.new(0, 32, 0, 8)
    PopupTitle.BackgroundTransparency = 1
    PopupTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    PopupTitle.Font = Enum.Font.GothamBold
    PopupTitle.TextXAlignment = Enum.TextXAlignment.Center
    PopupTitle.TextYAlignment = Enum.TextYAlignment.Center
    PopupTitle.ZIndex = 101
    PopupTitle.Parent = PopupFrame
    registerText(PopupTitle, "Text", titleInput, 14)

local PopupBody = Instance.new("TextLabel")
    PopupBody.Position = UDim2.new(0, 16, 0, 38)
    PopupBody.BackgroundTransparency = 1
    PopupBody.TextColor3 = Color3.fromRGB(230, 230, 230)
    PopupBody.Font = Enum.Font.GothamBold
    PopupBody.TextWrapped = true
    PopupBody.TextXAlignment = Enum.TextXAlignment.Center
    PopupBody.TextYAlignment = Enum.TextYAlignment.Center
    PopupBody.ZIndex = 101
    PopupBody.Parent = PopupFrame
    registerText(PopupBody, "Text", bodyInput, 13)

    local bodyWidth = 280 - 32
    PopupBody.Size = UDim2.new(0, bodyWidth, 0, 1000)

    local textHeight = PopupBody.TextBounds.Y
    local minPopupHeight = 150
    local maxPopupHeight = 420
    local targetPopupHeight = math.clamp(38 + 16 + textHeight, minPopupHeight, maxPopupHeight)

    PopupBody.Size = UDim2.new(1, -32, 1, -48)

    PopupFrame.Size = UDim2.new(0, 0, 0, 0)
    PopupFrame.Position = UDim2.new(0.5, -140, 0.5, 0)
    TweenService:Create(PopupFrame, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 280, 0, targetPopupHeight),
        Position = UDim2.new(0.5, -140, 0.5, -(targetPopupHeight / 2))
    }):Play()

    return PopupFrame
end
local NotificationContainer = Instance.new("Frame")
NotificationContainer.Name = "NotificationContainer"
NotificationContainer.Size = UDim2.new(0, 260, 1, -60)
NotificationContainer.Position = UDim2.new(1, -270, 0, 10)
NotificationContainer.BackgroundTransparency = 1
NotificationContainer.Parent = ScreenGui

local NotifListLayout = Instance.new("UIListLayout")
NotifListLayout.Parent = NotificationContainer
NotifListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
NotifListLayout.SortOrder = Enum.SortOrder.LayoutOrder
NotifListLayout.Padding = UDim.new(0, 8)

function Library:SendNotification(titleInput, textInput)
    local notifFrame = Instance.new("Frame")
    notifFrame.Size = UDim2.new(1, 0, 0, 0)
    notifFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    notifFrame.ClipsDescendants = true
    notifFrame.Parent = NotificationContainer

    local notifCorner = Instance.new("UICorner")
    notifCorner.CornerRadius = UDim.new(0, 10)
    notifCorner.Parent = notifFrame

    local notifStroke = Instance.new("UIStroke")
    notifStroke.Color = Color3.fromRGB(255, 255, 255)
    notifStroke.Transparency = 0.85
    notifStroke.Thickness = 1
    notifStroke.Parent = notifFrame

    local notifTitle = Instance.new("TextLabel")
    notifTitle.Size = UDim2.new(1, -20, 0, 20)
    notifTitle.Position = UDim2.new(0, 10, 0, 6)
    notifTitle.BackgroundTransparency = 1
    notifTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifTitle.Font = Enum.Font.GothamBold
    notifTitle.TextWrapped = true
    notifTitle.Parent = notifFrame

    local notifText = Instance.new("TextLabel")
    notifText.Size = UDim2.new(1, -20, 0, 32)
    notifText.Position = UDim2.new(0, 10, 0, 26)
    notifText.BackgroundTransparency = 1
    notifText.TextColor3 = Color3.fromRGB(255, 255, 255)
    notifText.Font = Enum.Font.GothamMedium
    notifText.TextWrapped = true
    notifText.Parent = notifFrame

    registerText(notifTitle, "Text", titleInput, 13)
    registerText(notifText, "Text", textInput, 12)

    local function applyLangStyle()
        if Library.CurrentLang == "AR" then
            notifTitle.TextSize = 15
            notifTitle.TextXAlignment = Enum.TextXAlignment.Left
            notifText.TextSize = 18
            notifText.TextXAlignment = Enum.TextXAlignment.Right
        else
            notifTitle.TextSize = 13
            notifTitle.TextXAlignment = Enum.TextXAlignment.Left
            notifText.TextSize = 12
            notifText.TextXAlignment = Enum.TextXAlignment.Left
        end
    end

    applyLangStyle()
    registerCustomText(applyLangStyle)

    TweenService:Create(notifFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
        Size = UDim2.new(1, 0, 0, 68)
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

    return notifFrame
end

function Library:SetLanguage(langKey)
    Library.CurrentLang = langKey
    refreshAllText()
end

function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or {EN = "Window", AR = "نافذة"}

    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Name = "SquareToggle"
    ToggleButton.Size = UDim2.new(0, 48, 0, 48)
    ToggleButton.Position = UDim2.new(0.05, 0, 0.4, 0)
    ToggleButton.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    ToggleButton.Text = "★"
    ToggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    ToggleButton.TextSize = 20
    ToggleButton.Font = Enum.Font.GothamBold
    ToggleButton.AutoButtonColor = false
    ToggleButton.Parent = ScreenGui

    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 12)
    ToggleCorner.Parent = ToggleButton

    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Color = Color3.fromRGB(255, 255, 255)
    ToggleStroke.Transparency = 0.8
    ToggleStroke.Thickness = 1.5
    ToggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    ToggleStroke.Parent = ToggleButton

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 340, 0, 300)
    MainFrame.Position = UDim2.new(0.5, -170, 0.5, -150)
    MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    MainFrame.ClipsDescendants = true
    MainFrame.Active = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 16)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Color3.fromRGB(255, 255, 255)
    MainStroke.Transparency = 0.85
    MainStroke.Thickness = 1.5
    MainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    MainStroke.Parent = MainFrame
        
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 45)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(1, -24, 1, 0)
    TitleLabel.Position = UDim2.new(0, 16, 0, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.Parent = Header
    registerText(TitleLabel, "Text", windowTitle, 14)

local TabBar = Instance.new("ScrollingFrame")
    TabBar.Size = UDim2.new(1, -32, 0, 32)
    TabBar.Position = UDim2.new(0, 16, 0, 48)
    TabBar.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.ScrollingDirection = Enum.ScrollingDirection.X
    TabBar.ElasticBehavior = Enum.ElasticBehavior.Never
    TabBar.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabBar.AutomaticCanvasSize = Enum.AutomaticSize.None
    TabBar.Parent = MainFrame

    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabBar

    local TabStroke = Instance.new("UIStroke")
    TabStroke.Color = Color3.fromRGB(255, 255, 255)
    TabStroke.Transparency = 0.92
    TabStroke.Thickness = 1
    TabStroke.Parent = TabBar

    local ContentContainer = Instance.new("Frame")
    ContentContainer.Size = UDim2.new(1, -32, 1, -95)
    ContentContainer.Position = UDim2.new(0, 16, 0, 88)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = MainFrame

    makeDraggable(ToggleButton)
    makeDraggable(MainFrame)

    local isGuiVisible = true
    local originalSize = MainFrame.Size

    ToggleButton.MouseButton1Click:Connect(function()
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
    end)

    local Window = {}
    Window.MainFrame = MainFrame
    Window.Tabs = {}

local tabButtons = {}
    local tabViews = {}
    local maxTabs = 10
local tabsBeforeScroll = 5
    local GAP = 10

    function Window:CreateTab(tabNameInput)
        local index = #tabViews + 1
        if index > maxTabs then
            warn("FedoraLib: max of " .. maxTabs .. " tabs supported")
            return nil
        end

        local view = Instance.new("ScrollingFrame")
        view.Size = UDim2.new(1, 0, 1, 0)
        view.BackgroundTransparency = 1
        view.Visible = (index == 1)
        view.BorderSizePixel = 0
        view.ScrollBarThickness = 0
        view.ElasticBehavior = Enum.ElasticBehavior.Never
        view.CanvasSize = UDim2.new(0, 0, 0, 0)
        view.AutomaticCanvasSize = Enum.AutomaticSize.None
        view.Parent = ContentContainer
        table.insert(tabViews, view)

local scrollBasis = tabsBeforeScroll
        local scaleWidth = 1 / scrollBasis
        local fixedPixelWidth = 308 / scrollBasis
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(scaleWidth, -2, 1, -10)
        btn.Position = UDim2.new((index - 1) * scaleWidth, 1, 0, 5)
        btn.BackgroundColor3 = (index == 1) and Color3.fromRGB(25, 25, 25) or Color3.fromRGB(0, 0, 0)
        btn.BackgroundTransparency = (index == 1) and 0 or 1
        btn.TextColor3 = (index == 1) and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(130, 130, 130)
        btn.Font = Enum.Font.GothamBold
        btn.AutoButtonColor = false
        btn.Parent = TabBar
        registerText(btn, "Text", tabNameInput, 9)

        local btnCorner = Instance.new("UICorner")
        btnCorner.CornerRadius = UDim.new(0, 6)
        btnCorner.Parent = btn

        table.insert(tabButtons, btn)

        TabBar.CanvasSize = UDim2.new(0, math.max(index * fixedPixelWidth, TabBar.AbsoluteSize.X), 0, 0)

        btn.MouseButton1Click:Connect(function()
            for idx, v in ipairs(tabViews) do
                v.Visible = (idx == index)
                if idx == index then
                    TweenService:Create(tabButtons[idx], TweenInfo.new(0.15), { BackgroundColor3 = Color3.fromRGB(25, 25, 25) }):Play()
                    tabButtons[idx].BackgroundTransparency = 0
                    tabButtons[idx].TextColor3 = Color3.fromRGB(255, 255, 255)
                else
                    tabButtons[idx].BackgroundTransparency = 1
                    tabButtons[idx].TextColor3 = Color3.fromRGB(130, 130, 130)
                end
            end
        end)

        local Tab = {}
        Tab.View = view
        Tab.Elements = {}

        local function updateCanvas()
            local totalHeight = 0
            for i, e in ipairs(Tab.Elements) do
                totalHeight = totalHeight + e.height
                if i < #Tab.Elements then
                    totalHeight = totalHeight + GAP
                end
            end
            view.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
        end

        local function addElement(frame, height)
            local y = 0
            for _, e in ipairs(Tab.Elements) do
                y = y + e.height + GAP
            end
            frame.Position = UDim2.new(0, 0, 0, y)
            local entry = { frame = frame, height = height }
            table.insert(Tab.Elements, entry)
            updateCanvas()
            return entry
        end

        local function repositionAfter(entry)
            local idx = nil
            for i, e in ipairs(Tab.Elements) do
                if e == entry then
                    idx = i
                    break
                end
            end
            if not idx then
                return
            end

            local y = 0
            for i = 1, idx do
                y = y + Tab.Elements[i].height + GAP
            end

            for i = idx + 1, #Tab.Elements do
                local e = Tab.Elements[i]
                TweenService:Create(e.frame, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = UDim2.new(0, 0, 0, y)
                }):Play()
                y = y + e.height + GAP
            end

            updateCanvas()
        end

        function Tab:CreateToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            local flagName = toggleConfig.Flag or toggleConfig.Name or ("Toggle" .. tostring(math.random(100000, 999999)))
            local nameInput = toggleConfig.Name or {EN = "Toggle", AR = "مفتاح"}
            local onLabel = toggleConfig.OnText or {EN = "ON", AR = "مفعل"}
            local offLabel = toggleConfig.OffText or {EN = "OFF", AR = "غير مفعل"}
            local defaultVal = toggleConfig.Default or false
            local callback = toggleConfig.Callback or function() end

            Library.Flags[flagName] = defaultVal

            local ToggleContainer = Instance.new("Frame")
            ToggleContainer.Size = UDim2.new(1, 0, 0, 42)
            ToggleContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            ToggleContainer.Parent = view

            addElement(ToggleContainer, 42)

            local TogCorner = Instance.new("UICorner")
            TogCorner.CornerRadius = UDim.new(0, 8)
            TogCorner.Parent = ToggleContainer

            local TogStroke = Instance.new("UIStroke")
            TogStroke.Color = Color3.fromRGB(255, 255, 255)
            TogStroke.Transparency = 0.9
            TogStroke.Thickness = 1
            TogStroke.Parent = ToggleContainer

            local ToggleLabel = Instance.new("TextLabel")
            ToggleLabel.Size = UDim2.new(1, -60, 1, 0)
            ToggleLabel.Position = UDim2.new(0, 14, 0, 0)
            ToggleLabel.BackgroundTransparency = 1
            ToggleLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            ToggleLabel.Font = Enum.Font.GothamMedium
            ToggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            ToggleLabel.Parent = ToggleContainer

            local function labelSource()
                local base = resolveText(nameInput)
                local status = defaultVal and resolveText(onLabel) or resolveText(offLabel)
                return base .. ": " .. status
            end

            registerCustomText(function()
                ToggleLabel.Text = labelSource()
                ToggleLabel.TextSize = fontSizeFor(12)
            end)
                        
            local SwitchTrack = Instance.new("TextButton")
            SwitchTrack.Size = UDim2.new(0, 40, 0, 20)
            SwitchTrack.Position = UDim2.new(1, -50, 0.5, -10)
            SwitchTrack.BackgroundColor3 = defaultVal and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(35, 35, 35)
            SwitchTrack.Text = ""
            SwitchTrack.AutoButtonColor = false
            SwitchTrack.Parent = ToggleContainer

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = SwitchTrack

            local SwitchKnob = Instance.new("Frame")
            SwitchKnob.Size = UDim2.new(0, 16, 0, 16)
            SwitchKnob.Position = defaultVal and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
            SwitchKnob.BackgroundColor3 = defaultVal and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(120, 120, 120)
            SwitchKnob.Parent = SwitchTrack

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = SwitchKnob

            local function updateToggleSwitch(enabled)
                defaultVal = enabled
                Library.Flags[flagName] = enabled
                local knobPos = enabled and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8)
                local trackColor = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(35, 35, 35)
                local knobColor = enabled and Color3.fromRGB(0, 0, 0) or Color3.fromRGB(120, 120, 120)

                ToggleLabel.Text = labelSource()

                TweenService:Create(SwitchKnob, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Position = knobPos,
                    BackgroundColor3 = knobColor
                }):Play()

                TweenService:Create(SwitchTrack, TweenInfo.new(0.2, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundColor3 = trackColor
                }):Play()

                callback(enabled)
            end

            SwitchTrack.MouseButton1Click:Connect(function()
                updateToggleSwitch(not defaultVal)
            end)

            return {
                Set = function(_, value)
                    updateToggleSwitch(value)
                end
            }
        end

        function Tab:CreateDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            local flagName = dropdownConfig.Flag or dropdownConfig.Name or ("Dropdown" .. tostring(math.random(100000, 999999)))
            local nameInput = dropdownConfig.Name or {EN = "Dropdown", AR = "قائمة"}
            local defaultLabel = dropdownConfig.DefaultText or {EN = "[Select]", AR = "[اختر]"}
            local selectPrefix = dropdownConfig.SelectPrefix or {EN = "Selected: ", AR = "المحدد: "}
            local options = dropdownConfig.Options or {}
            local callback = dropdownConfig.Callback or function() end
            local isLanguageSwitcher = dropdownConfig.IsLanguageSwitch == true

            local selectedOption = dropdownConfig.Default or nil
            Library.Flags[flagName] = selectedOption

            local DropdownContainer = Instance.new("Frame")
            DropdownContainer.Size = UDim2.new(1, 0, 0, 38)
            DropdownContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            DropdownContainer.ClipsDescendants = true
            DropdownContainer.Parent = view

            local elementEntry = addElement(DropdownContainer, 38)

            local DropCorner = Instance.new("UICorner")
            DropCorner.CornerRadius = UDim.new(0, 8)
            DropCorner.Parent = DropdownContainer

            local DropStroke = Instance.new("UIStroke")
            DropStroke.Color = Color3.fromRGB(255, 255, 255)
            DropStroke.Transparency = 0.9
            DropStroke.Thickness = 1
            DropStroke.Parent = DropdownContainer

            local DropdownBtn = Instance.new("TextButton")
            DropdownBtn.Size = UDim2.new(1, 0, 0, 38)
            DropdownBtn.BackgroundTransparency = 1
            DropdownBtn.TextColor3 = Color3.fromRGB(240, 240, 240)
            DropdownBtn.Font = Enum.Font.GothamMedium
            DropdownBtn.TextXAlignment = Enum.TextXAlignment.Left
            DropdownBtn.Parent = DropdownContainer

            local function dropdownLabelText()
                if selectedOption then
                    return "  " .. resolveText(selectPrefix) .. resolveText(selectedOption)
                else
                    return "  " .. resolveText(defaultLabel)
                end
            end

            DropdownBtn.Text = dropdownLabelText()
            DropdownBtn.TextSize = fontSizeFor(12)

            local DropArrow = Instance.new("TextLabel")
            DropArrow.Size = UDim2.new(0, 38, 0, 38)
            DropArrow.Position = UDim2.new(1, -38, 0, 0)
            DropArrow.BackgroundTransparency = 1
            DropArrow.Text = "▼"
            DropArrow.TextColor3 = Color3.fromRGB(150, 150, 150)
            DropArrow.Font = Enum.Font.GothamMedium
            DropArrow.TextSize = 10
            DropArrow.Parent = DropdownContainer

            local DropScroll = Instance.new("ScrollingFrame")
            DropScroll.Size = UDim2.new(1, -12, 0, 90)
            DropScroll.Position = UDim2.new(0, 6, 0, 40)
            DropScroll.BackgroundTransparency = 1
DropScroll.ScrollBarThickness = 0
            DropScroll.ScrollBarImageColor3 = Color3.fromRGB(255, 255, 255)
            DropScroll.ElasticBehavior = Enum.ElasticBehavior.Never
            DropScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropScroll.Parent = DropdownContainer

            local DropListLayout = Instance.new("UIListLayout")
            DropListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            DropListLayout.Padding = UDim.new(0, 3)
            DropListLayout.Parent = DropScroll

            DropListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropScroll.CanvasSize = UDim2.new(0, 0, 0, DropListLayout.AbsoluteContentSize.Y)
            end)

local isDropdownOpen = false
            local maxVisibleOptions = 4

            local function setDropdownState(open)
                isDropdownOpen = open
                local optionCount = #options
                local visibleCount = math.min(optionCount, maxVisibleOptions)
                local scrollHeight = math.max(visibleCount * 29 - 3, 0)
                local expandedHeight = 38 + 12 + scrollHeight
                local targetHeight = open and expandedHeight or 38

                DropScroll.Size = UDim2.new(1, -12, 0, scrollHeight)

                TweenService:Create(DropdownContainer, TweenInfo.new(0.25, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    Size = UDim2.new(1, 0, 0, targetHeight)
                }):Play()

                DropArrow.Text = open and "▲" or "▼"

                elementEntry.height = targetHeight
                repositionAfter(elementEntry)

                if open then
                    for i, optInput in ipairs(options) do
                        if optInput == selectedOption then
                            local targetY = (i - 1) * 29
                            local maxScroll = math.max(DropListLayout.AbsoluteContentSize.Y - scrollHeight, 0)
                            DropScroll.CanvasPosition = Vector2.new(0, math.min(targetY, maxScroll))
                            break
                        end
                    end
                end
            end

            local function selectOption(optInput)
                selectedOption = optInput
                Library.Flags[flagName] = optInput
                DropdownBtn.Text = dropdownLabelText()
                setDropdownState(false)
                if isLanguageSwitcher then
                    local langCode = dropdownConfig.OptionLangCodes and dropdownConfig.OptionLangCodes[optInput] or nil
                    if langCode then
                        Library:SetLanguage(langCode)
                    end
                end
                callback(optInput)
            end

            local function buildOptions()
                for _, child in ipairs(DropScroll:GetChildren()) do
                    if child:IsA("TextButton") then
                        child:Destroy()
                    end
                end

                for _, optInput in ipairs(options) do
                    local optBtn = Instance.new("TextButton")
                    optBtn.Size = UDim2.new(1, 0, 0, 26)
                    optBtn.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
                    optBtn.TextColor3 = Color3.fromRGB(220, 220, 220)
                    optBtn.Font = Enum.Font.GothamMedium
                    optBtn.TextXAlignment = Enum.TextXAlignment.Left
                    optBtn.AutoButtonColor = false
                    optBtn.Parent = DropScroll
                    optBtn.Text = " " .. resolveText(optInput)
                    optBtn.TextSize = fontSizeFor(11)

                    local optCorner = Instance.new("UICorner")
                    optCorner.CornerRadius = UDim.new(0, 6)
                    optCorner.Parent = optBtn

                    optBtn.MouseButton1Click:Connect(function()
                        selectOption(optInput)
                    end)

                    registerCustomText(function()
                        optBtn.Text = " " .. resolveText(optInput)
                        optBtn.TextSize = fontSizeFor(11)
                    end)
                end
            end

            buildOptions()

            DropdownBtn.MouseButton1Click:Connect(function()
                setDropdownState(not isDropdownOpen)
            end)

            registerCustomText(function()
                DropdownBtn.Text = dropdownLabelText()
                DropdownBtn.TextSize = fontSizeFor(12)
            end)

            return {
                Refresh = function(_, newOptions)
                    options = newOptions or options
                    buildOptions()
                end,
                Set = function(_, optInput)
                    selectOption(optInput)
                end
            }
        end
function Tab:CreateSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            local flagName = sliderConfig.Flag or sliderConfig.Name or ("Slider" .. tostring(math.random(100000, 999999)))
            local nameInput = sliderConfig.Name or {EN = "Slider", AR = "منزلق"}
            local minVal = sliderConfig.Min or 0
            local maxVal = sliderConfig.Max or 100
            local defaultVal = sliderConfig.Default or minVal
            local callback = sliderConfig.Callback or function() end

            Library.Flags[flagName] = defaultVal

            local SliderContainer = Instance.new("Frame")
            SliderContainer.Size = UDim2.new(1, 0, 0, 54)
            SliderContainer.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            SliderContainer.Active = true
            SliderContainer.Parent = view

            addElement(SliderContainer, 54)

            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 8)
            SliderCorner.Parent = SliderContainer

            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Color3.fromRGB(255, 255, 255)
            SliderStroke.Transparency = 0.9
            SliderStroke.Thickness = 1
            SliderStroke.Parent = SliderContainer

            local SliderLabel = Instance.new("TextLabel")
            SliderLabel.Size = UDim2.new(1, -70, 0, 20)
            SliderLabel.Position = UDim2.new(0, 12, 0, 6)
            SliderLabel.BackgroundTransparency = 1
            SliderLabel.TextColor3 = Color3.fromRGB(240, 240, 240)
            SliderLabel.Font = Enum.Font.GothamMedium
            SliderLabel.TextXAlignment = Enum.TextXAlignment.Left
            SliderLabel.Parent = SliderContainer

            registerCustomText(function()
                SliderLabel.Text = resolveText(nameInput)
                SliderLabel.TextSize = fontSizeFor(12)
            end)

            local ValueBubble = Instance.new("Frame")
            ValueBubble.Size = UDim2.new(0, 44, 0, 20)
            ValueBubble.Position = UDim2.new(1, -56, 0, 6)
            ValueBubble.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
            ValueBubble.Parent = SliderContainer

            local BubbleCorner = Instance.new("UICorner")
            BubbleCorner.CornerRadius = UDim.new(0, 6)
            BubbleCorner.Parent = ValueBubble

            local BubbleStroke = Instance.new("UIStroke")
            BubbleStroke.Color = Color3.fromRGB(255, 255, 255)
            BubbleStroke.Transparency = 0.88
            BubbleStroke.Thickness = 1
            BubbleStroke.Parent = ValueBubble

            local ValueLabel = Instance.new("TextLabel")
            ValueLabel.Size = UDim2.new(1, 0, 1, 0)
            ValueLabel.BackgroundTransparency = 1
            ValueLabel.Text = tostring(defaultVal)
            ValueLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            ValueLabel.Font = Enum.Font.GothamBold
            ValueLabel.TextSize = 11
            ValueLabel.Parent = ValueBubble

            local HitArea = Instance.new("TextButton")
            HitArea.Size = UDim2.new(1, -24, 0, 24)
            HitArea.Position = UDim2.new(0, 12, 0, 26)
            HitArea.BackgroundTransparency = 1
            HitArea.Text = ""
            HitArea.AutoButtonColor = false
            HitArea.Active = true
            HitArea.Parent = SliderContainer

            local Track = Instance.new("Frame")
            Track.Size = UDim2.new(1, 0, 0, 4)
            Track.Position = UDim2.new(0, 0, 0.5, -2)
            Track.BackgroundColor3 = Color3.fromRGB(32, 32, 32)
            Track.Parent = HitArea

            local TrackCorner = Instance.new("UICorner")
            TrackCorner.CornerRadius = UDim.new(1, 0)
            TrackCorner.Parent = Track

            local Fill = Instance.new("Frame")
            local startPercent = (defaultVal - minVal) / (maxVal - minVal)
            Fill.Size = UDim2.new(startPercent, 0, 1, 0)
            Fill.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Fill.Parent = Track

            local FillCorner = Instance.new("UICorner")
            FillCorner.CornerRadius = UDim.new(1, 0)
            FillCorner.Parent = Fill

            local FillGradient = Instance.new("UIGradient")
            FillGradient.Color = ColorSequence.new(
                Color3.fromRGB(210, 210, 210),
                Color3.fromRGB(255, 255, 255)
            )
            FillGradient.Rotation = 0
            FillGradient.Parent = Fill

            local Knob = Instance.new("Frame")
            Knob.Size = UDim2.new(0, 16, 0, 16)
            Knob.AnchorPoint = Vector2.new(0.5, 0.5)
            Knob.Position = UDim2.new(startPercent, 0, 0.5, 0)
            Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Knob.ZIndex = 2
            Knob.Parent = Track

            local KnobCorner = Instance.new("UICorner")
            KnobCorner.CornerRadius = UDim.new(1, 0)
            KnobCorner.Parent = Knob

            local KnobStroke = Instance.new("UIStroke")
            KnobStroke.Color = Color3.fromRGB(0, 0, 0)
            KnobStroke.Transparency = 0.7
            KnobStroke.Thickness = 1
            KnobStroke.Parent = Knob

            local dragging = false
            local currentValue = defaultVal

            local function updateFromInput(inputPos)
                local trackAbsPos = Track.AbsolutePosition.X
                local trackAbsSize = Track.AbsoluteSize.X
                local relative = math.clamp((inputPos - trackAbsPos) / trackAbsSize, 0, 1)
                local value = math.floor(minVal + (relative * (maxVal - minVal)))

                currentValue = value
                Library.Flags[flagName] = value

                Fill.Size = UDim2.new(relative, 0, 1, 0)
                Knob.Position = UDim2.new(relative, 0, 0.5, 0)
                ValueLabel.Text = tostring(value)

                callback(value)
            end

            HitArea.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    TweenService:Create(Knob, TweenInfo.new(0.12), { Size = UDim2.new(0, 20, 0, 20) }):Play()
                    updateFromInput(input.Position.X)
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    updateFromInput(input.Position.X)
                end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    if dragging then
                        TweenService:Create(Knob, TweenInfo.new(0.12), { Size = UDim2.new(0, 16, 0, 16) }):Play()
                    end
                    dragging = false
                end
            end)

            return {
                Set = function(_, value)
                    local relative = math.clamp((value - minVal) / (maxVal - minVal), 0, 1)
                    updateFromInput(Track.AbsolutePosition.X + (relative * Track.AbsoluteSize.X))
                end,
                Get = function(_)
                    return currentValue
                end
            }
                end
        function Tab:CreateButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            local nameInput = buttonConfig.Name or {EN = "Button", AR = "زر"}
            local callback = buttonConfig.Callback or function() end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 0, 38)
            Btn.BackgroundColor3 = Color3.fromRGB(12, 12, 12)
            Btn.TextColor3 = Color3.fromRGB(240, 240, 240)
            Btn.Font = Enum.Font.GothamMedium
            Btn.Parent = view
            registerText(Btn, "Text", nameInput, 12)

            addElement(Btn, 38)

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 8)
            BtnCorner.Parent = Btn

            local BtnStroke = Instance.new("UIStroke")
            BtnStroke.Color = Color3.fromRGB(255, 255, 255)
            BtnStroke.Transparency = 0.9
            BtnStroke.Thickness = 1
            BtnStroke.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                callback()
            end)

            return Btn
        end

        function Tab:CreateLabel(labelConfig)
            labelConfig = labelConfig or {}
            local textInput = labelConfig.Text or {EN = "Label", AR = "نص"}

            local Lbl = Instance.new("TextLabel")
            Lbl.Size = UDim2.new(1, 0, 0, 38)
            Lbl.BackgroundTransparency = 1
            Lbl.TextColor3 = Color3.fromRGB(255, 255, 255)
            Lbl.Font = Enum.Font.GothamBold
            Lbl.TextWrapped = true
            Lbl.TextXAlignment = Enum.TextXAlignment.Center
            Lbl.TextYAlignment = Enum.TextYAlignment.Center
            Lbl.Parent = view
            registerText(Lbl, "Text", textInput, 14)

            addElement(Lbl, 38)

            return Lbl
        end

        Window.Tabs[tabNameInput] = Tab
        return Tab
    end

    return Window
end

return Library
