
To load the library directly into your script:
```lua
local FedoraLibrary = loadstring(game:HttpGet("YOUR_RAW_SCRIPT_URL_HERE"))()

local Window = FedoraLibrary.CreateWindow("Fedora Hub")

```
## Window Options
### Popups
Creates a centered modal on the screen.
```lua
-- Simple popup
Window:CreatePopup("System loaded successfully!", 14, true)

-- Popup with language support
Window:CreatePopup({
    en = "Welcome to Fedora Hub!",
    es = "¡Bienvenido a Fedora Hub!"
}, 12, false)

```
**Parameters:**
 * text *(string or table)* - Message string or a table containing translations.
 * textSize *(number)* - Font size (defaults to 12).
 * isBold *(boolean)* - Set to true for bold text, false for medium text.
### Notifications
Displays a toast notification at the bottom right corner of the screen. Auto-closes after 3.5 seconds.
```lua
Window:SendNotification("Settings saved!")

```
## Creating Tabs
You can add up to 5 tabs per window.
```lua
local MainTab = Window:CreateTab("Main")
local SettingsTab = Window:CreateTab("Settings")

```
## Tab Elements
### Buttons
Adds a basic clickable button to the tab.
```lua
MainTab:CreateButton("Teleport to Spawn", function()
    print("Teleporting player...")
end)

```
### Toggles
Adds an ON/OFF switch.
```lua
MainTab:CreateToggle("Auto Farm", false, function(state)
    if state then
        print("Farm enabled")
    else
        print("Farm disabled")
    end
end)

```
**Parameters:**
 * text *(string)* - Toggle label.
 * defaultState *(boolean)* - Initial toggle state (true for ON, false for OFF).
 * callback *(function)* - Function called when toggled, returns the current state.
### Dropdowns
Adds a collapsible selection menu.
```lua
MainTab:CreateDropdown("Speed Multiplier", {"16", "32", "64", "100"}, function(selected)
    game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = tonumber(selected)
end)

```
## Translations
You can pass a dictionary of translations to any text element. Set Window.CurrentLanguage to match the active key.
```lua
Window.CurrentLanguage = "es"

MainTab:CreateButton({
    en = "Click Me",
    es = "Haz Clic"
}, function()
    print("Clicked!")
end)

```
