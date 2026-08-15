
## Loading the Library

```lua
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/gapiwapiw/Fedora-library-/refs/heads/main/FedoraLib.lua"))()

local Window = Library:CreateWindow({
    Title = {EN = "Fedora Hub", AR = "فيدورا هب"}
})
```

## What's Changed

- Tabs now support up to **10 tabs**. The first **5** stay at a fixed, comfortable width; adding a 6th tab or beyond triggers horizontal scrolling on the tab bar instead of shrinking tabs further.
- Removed scrollbar pills everywhere — tab content, dropdown lists, and the tab bar itself all scroll with no visible scrollbar track.
- Removed overscroll bounce-back ("elastic" behavior) on every scrollable element (tab content, dropdowns, tab bar). Scrolling now stops dead at the start/end instead of rubber-banding.
- Dropdowns auto-scroll to reveal the currently selected option when opened, and no longer leave empty dead space below a short options list.
- Popups (`ShowPopup`) now auto-size to fit their text instead of clipping or overflowing long messages, with a sensible min/max height.
- Notifications (`SendNotification`) now take a **title/label** in addition to the body text, instead of a single line of text.

## Popups

Creates a centered modal on screen with a title and body.

```lua
Library:ShowPopup(
    {EN = "System Loaded", AR = "تم تحميل النظام"},
    {EN = "Everything is ready to go.", AR = "كل شيء جاهز."}
)
```

**Parameters:**
- `titleInput` *(string or table)* — Title text, or a table of translations (e.g. `{EN = "...", AR = "..."}`).
- `bodyInput` *(string or table)* — Body text, or a table of translations.

## Notifications

Displays a toast notification with a title and message. Auto-closes after 3.5 seconds.

```lua
Library:SendNotification(
    {EN = "Saved", AR = "تم الحفظ"},
    {EN = "Your settings have been saved.", AR = "تم حفظ إعداداتك."}
)
```

**Parameters:**
- `titleInput` *(string or table)* — Notification title/label.
- `textInput` *(string or table)* — Notification body text.

## Creating a Window

```lua
local Window = Library:CreateWindow({
    Title = {EN = "Fedora Hub", AR = "فيدورا هب"}
})
```

## Creating Tabs

Up to **10 tabs** per window. The first 5 are shown at a fixed width; beyond that, the tab bar scrolls horizontally.

```lua
local MainTab = Window:CreateTab({EN = "Main", AR = "الرئيسية"})
local SettingsTab = Window:CreateTab({EN = "Settings", AR = "الإعدادات"})
```

## Tab Elements

### Buttons

```lua
MainTab:CreateButton({
    Name = {EN = "Teleport to Spawn", AR = "انتقل لنقطة البداية"},
    Callback = function()
        print("Teleporting player...")
    end
})
```

### Toggles

```lua
MainTab:CreateToggle({
    Name = {EN = "Auto Farm", AR = "الزراعة التلقائية"},
    Default = false,
    Callback = function(state)
        print(state and "Farm enabled" or "Farm disabled")
    end
})
```

**Parameters (table):**
- `Name` *(string or table)* — Toggle label.
- `Default` *(boolean)* — Initial state.
- `Flag` *(string, optional)* — Key used to store the value in `Library.Flags`.
- `OnText` / `OffText` *(string or table, optional)* — Custom ON/OFF labels.
- `Callback` *(function)* — Called with the new state on every toggle.

### Dropdowns

```lua
MainTab:CreateDropdown({
    Name = {EN = "Speed Multiplier", AR = "مضاعف السرعة"},
    Options = {
        {EN = "16", AR = "16"},
        {EN = "32", AR = "32"},
        {EN = "64", AR = "64"},
        {EN = "100", AR = "100"}
    },
    Callback = function(selected)
        print("Selected:", selected)
    end
})
```

**Parameters (table):**
- `Name` *(string or table)* — Dropdown label.
- `Options` *(array)* — List of options (strings or translation tables).
- `Default` *(optional)* — Preselected option.
- `DefaultText` *(string or table, optional)* — Placeholder shown when nothing is selected.
- `SelectPrefix` *(string or table, optional)* — Prefix shown before the selected value.
- `Callback` *(function)* — Called with the selected option whenever it changes.

### Labels

```lua
MainTab:CreateLabel({
    Text = {EN = "This is a label", AR = "هذا نص"}
})
```

## Translations

Most text-accepting parameters accept either a plain string or a table keyed by language code (`EN`, `AR`). Switch the active language at any time:

```lua
Library:SetLanguage("AR")
```

All registered text elements refresh automatically when the language changes.
