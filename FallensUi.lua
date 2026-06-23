
local Fallens = {}
Fallens.__index = Fallens

-- Services
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local TextService = game:GetService("TextService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- ═══════════════════════════════════════════════════════════════
-- Fallens THEME CONFIGURATION
-- ═══════════════════════════════════════════════════════════════
local Theme = {
    -- Backgrounds
    Background = Color3.fromRGB(13, 13, 13),        -- Main frame bg
    SidebarBg = Color3.fromRGB(10, 10, 10),         -- Left sidebar
    GroupBg = Color3.fromRGB(18, 18, 18),           -- Group panels
    Surface = Color3.fromRGB(28, 28, 28),            -- Elevated surfaces
    InputBg = Color3.fromRGB(30, 30, 30),            -- Input fields

    -- Accent (Purple)
    Accent = Color3.fromRGB(147, 51, 234),           -- Primary purple
    AccentLight = Color3.fromRGB(168, 85, 247),       -- Lighter purple
    AccentDark = Color3.fromRGB(126, 34, 206),      -- Darker purple

    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),     -- White text
    TextSecondary = Color3.fromRGB(156, 156, 156),  -- Gray text
    TextMuted = Color3.fromRGB(100, 100, 100),       -- Muted text

    -- Interactive
    ToggleOn = Color3.fromRGB(147, 51, 234),        -- Purple toggle
    ToggleOff = Color3.fromRGB(45, 45, 45),          -- Dark toggle
    SliderTrack = Color3.fromRGB(45, 45, 45),        -- Slider bg
    SliderFill = Color3.fromRGB(147, 51, 234),      -- Purple fill
    Button = Color3.fromRGB(35, 35, 35),             -- Button bg
    ButtonHover = Color3.fromRGB(45, 45, 45),       -- Button hover
    Locked = Color3.fromRGB(60, 60, 60),             -- Locked items

    -- Borders
    Border = Color3.fromRGB(40, 40, 40),              -- Default border
    BorderLight = Color3.fromRGB(55, 55, 55),       -- Light border
}

-- ═══════════════════════════════════════════════════════════════
-- UTILITY FUNCTIONS
-- ═══════════════════════════════════════════════════════════════
local function Create(class, props)
    local obj = Instance.new(class)
    for k, v in pairs(props) do
        if k ~= "Parent" then
            pcall(function() obj[k] = v end)
        end
    end
    if props.Parent then obj.Parent = props.Parent end
    return obj
end

local function Tween(obj, props, duration, easing, direction)
    TweenService:Create(obj, TweenInfo.new(
        duration or 0.2, 
        easing or Enum.EasingStyle.Quint, 
        direction or Enum.EasingDirection.Out
    ), props):Play()
end

local function makeDraggable(frame, handle)
    handle = handle or frame
    local dragging, dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- MAIN CONSTRUCTOR
-- ═══════════════════════════════════════════════════════════════
function Fallens.new(config)
    config = config or {}
    local self = setmetatable({}, Fallens)

    self.Name = config.Name or "Fallens"
    self.AccentColor = config.AccentColor or Theme.Accent
    self.Toggles = {}
    self.Options = {}
    self.Sections = {}
    self.ActiveTab = nil
    self.IsVisible = true
    self.Connections = {}

    -- ScreenGui
    self.ScreenGui = Create("ScreenGui", {
        Name = "FallensUI",
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        ResetOnSpawn = false,
        Parent = CoreGui
    })

    -- Main Frame (830x530 matching reference)
    local mainW, mainH = 830, 530
    self.MainFrame = Create("Frame", {
        Name = "MainFrame",
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        Size = UDim2.new(0, mainW, 0, mainH),
        Position = UDim2.new(0.5, -mainW/2, 0.5, -mainH/2),
        Parent = self.ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.MainFrame})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = self.MainFrame})

    -- Top accent line (purple glow)
    Create("Frame", {
        Name = "AccentLine",
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0.64, 0, 0, 2),
        Position = UDim2.new(0.18, 0, 0, 0),
        ZIndex = 3,
        Parent = self.MainFrame
    })

    -- ═══════════════════════════════════════════════════════════════
    -- SIDEBAR (Left Panel)
    -- ═══════════════════════════════════════════════════════════════
    self.Sidebar = Create("Frame", {
        Name = "Sidebar",
        BackgroundColor3 = Theme.SidebarBg,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 180, 1, 0),
        Position = UDim2.new(0, 0, 0, 0),
        Parent = self.MainFrame
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 12), Parent = self.Sidebar})

    -- Sidebar divider line
    Create("Frame", {
        Name = "Divider",
        BackgroundColor3 = Theme.Border,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 1, 1, -20),
        Position = UDim2.new(1, 0, 0, 10),
        Parent = self.Sidebar
    })

    -- Logo area with "N" icon
    local logoFrame = Create("Frame", {
        Name = "LogoFrame",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 0, 10),
        Parent = self.Sidebar
    })

    -- N Logo
    Create("TextLabel", {
        Name = "LogoIcon",
        Text = "N",
        Font = Enum.Font.GothamBold,
        TextSize = 28,
        TextColor3 = self.AccentColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 35, 0, 35),
        Position = UDim2.new(0, 15, 0, 5),
        Parent = logoFrame
    })

    -- Fallens text
    Create("TextLabel", {
        Name = "LogoText",
        Text = "Fallens",
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextColor3 = Theme.TextPrimary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 100, 0, 20),
        Position = UDim2.new(0, 50, 0, 12),
        Parent = logoFrame
    })

    -- Section scroll
    self.SectionScroll = Create("ScrollingFrame", {
        Name = "SectionScroll",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -140),
        Position = UDim2.new(0, 5, 0, 75),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.Sidebar
    })

    self.SectionLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 5),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = self.SectionScroll
    })

    -- UI Settings button at bottom
    self.SettingsBtn = Create("TextButton", {
        Name = "SettingsBtn",
        Text = "  UI Settings",
        Font = Enum.Font.GothamSemibold,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -20, 0, 32),
        Position = UDim2.new(0, 10, 1, -45),
        Parent = self.Sidebar
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = self.SettingsBtn})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = self.SettingsBtn})

    -- ═══════════════════════════════════════════════════════════════
    -- CONTENT AREA (Right Panel)
    -- ═══════════════════════════════════════════════════════════════
    self.ContentArea = Create("Frame", {
        Name = "ContentArea",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -200, 1, -10),
        Position = UDim2.new(0, 190, 0, 5),
        Parent = self.MainFrame
    })

    -- Header with title and search
    self.Header = Create("Frame", {
        Name = "Header",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 50),
        Position = UDim2.new(0, 10, 0, 5),
        Parent = self.ContentArea
    })

    -- Tab title (purple)
    self.TabTitle = Create("TextLabel", {
        Name = "TabTitle",
        Text = "All Elements",
        Font = Enum.Font.GothamBold,
        TextSize = 18,
        TextColor3 = self.AccentColor,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 200, 0, 25),
        Position = UDim2.new(0, 0, 0, 0),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header
    })

    -- Tab description
    self.TabDesc = Create("TextLabel", {
        Name = "TabDesc",
        Text = "Showcasing every UI element",
        Font = Enum.Font.Gotham,
        TextSize = 12,
        TextColor3 = Theme.TextSecondary,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 250, 0, 18),
        Position = UDim2.new(0, 0, 0, 26),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.Header
    })

    -- Search box
    self.SearchFrame = Create("Frame", {
        Name = "SearchFrame",
        BackgroundColor3 = Theme.Surface,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 220, 0, 30),
        Position = UDim2.new(1, -230, 0, 5),
        Parent = self.Header
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = self.SearchFrame})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = self.SearchFrame})

    Create("ImageLabel", {
        Image = "rbxassetid://10734943674",
        ImageColor3 = Theme.TextMuted,
        BackgroundTransparency = 1,
        Size = UDim2.new(0, 14, 0, 14),
        Position = UDim2.new(0, 10, 0.5, -7),
        Parent = self.SearchFrame
    })

    self.SearchBox = Create("TextBox", {
        PlaceholderText = "Search tabs/groups...",
        PlaceholderColor3 = Theme.TextMuted,
        Text = "",
        TextColor3 = Theme.TextPrimary,
        Font = Enum.Font.Gotham,
        TextSize = 12,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -35, 1, 0),
        Position = UDim2.new(0, 28, 0, 0),
        Parent = self.SearchFrame
    })

    -- Content scroll area
    self.ContentScroll = Create("ScrollingFrame", {
        Name = "ContentScroll",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 1, -60),
        Position = UDim2.new(0, 0, 0, 55),
        ScrollBarThickness = 0,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        Parent = self.ContentArea
    })

    -- Make draggable
    makeDraggable(self.MainFrame, self.MainFrame)

    -- Toggle with RightControl
    self.ToggleKey = Enum.KeyCode.RightControl
    table.insert(self.Connections, UserInputService.InputBegan:Connect(function(input, gp)
        if not gp and input.KeyCode == self.ToggleKey then
            self:Toggle()
        end
    end))

    return self
end

-- ═══════════════════════════════════════════════════════════════
-- TOGGLE VISIBILITY
-- ═══════════════════════════════════════════════════════════════
function Fallens:Toggle()
    self.IsVisible = not self.IsVisible
    self.MainFrame.Visible = self.IsVisible
end

-- ═══════════════════════════════════════════════════════════════
-- ADD SECTION (Sidebar category)
-- ═══════════════════════════════════════════════════════════════
function Fallens:AddSection(config)
    config = config or {}
    local section = {}
    section.Name = config.Name or "Section"
    section.Tabs = {}
    section.IsExpanded = true

    -- Section button (purple when active)
    section.Button = Create("TextButton", {
        Name = section.Name,
        Text = "  " .. section.Name,
        Font = Enum.Font.GothamSemibold,
        TextSize = 13,
        TextColor3 = Theme.TextPrimary,
        TextXAlignment = Enum.TextXAlignment.Left,
        BackgroundColor3 = self.AccentColor,
        BackgroundTransparency = 0,
        BorderSizePixel = 0,
        Size = UDim2.new(1, -10, 0, 32),
        Parent = self.SectionScroll
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = section.Button})

    -- Optional icon
    if config.Icon then
        Create("ImageLabel", {
            Image = config.Icon,
            ImageColor3 = Color3.new(1, 1, 1),
            BackgroundTransparency = 1,
            Size = UDim2.new(0, 16, 0, 16),
            Position = UDim2.new(0, 10, 0.5, -8),
            Parent = section.Button
        })
        section.Button.Text = "      " .. section.Name
    end

    -- Tab container
    section.TabContainer = Create("Frame", {
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -10, 0, 0),
        Parent = self.SectionScroll
    })

    section.TabLayout = Create("UIListLayout", {
        Padding = UDim.new(0, 3),
        SortOrder = Enum.SortOrder.LayoutOrder,
        Parent = section.TabContainer
    })

    section.TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        section.TabContainer.Size = UDim2.new(1, -10, 0, section.TabLayout.AbsoluteContentSize.Y)
    end)

    -- ═══════════════════════════════════════════════════════════════
    -- ADD TAB
    -- ═══════════════════════════════════════════════════════════════
    function section:AddTab(tabConfig)
        tabConfig = tabConfig or {}
        local tab = {}
        tab.Name = tabConfig.Name or "Tab"
        tab.Description = tabConfig.Description or ""
        tab.Groups = {}

        -- Tab button in sidebar
        tab.Button = Create("TextButton", {
            Name = tab.Name,
            Text = "  " .. tab.Name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 12,
            TextColor3 = Theme.TextSecondary,
            TextXAlignment = Enum.TextXAlignment.Left,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 0, 28),
            Parent = section.TabContainer
        })

        -- Content frame
        tab.Content = Create("Frame", {
            Name = tab.Name .. "Content",
            BackgroundTransparency = 1,
            Size = UDim2.new(1, 0, 1, 0),
            Visible = false,
            Parent = self.ContentScroll
        })

        -- Two column layout
        tab.LeftColumn = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.48, 0, 1, 0),
            Parent = tab.Content
        })

        tab.RightColumn = Create("Frame", {
            BackgroundTransparency = 1,
            Size = UDim2.new(0.48, 0, 1, 0),
            Position = UDim2.new(0.52, 0, 0, 0),
            Parent = tab.Content
        })

        -- Tab click handler
        tab.Button.MouseButton1Click:Connect(function()
            if self.ActiveTab then
                self.ActiveTab.Content.Visible = false
                self.ActiveTab.Button.TextColor3 = Theme.TextSecondary
                self.ActiveTab.Button.BackgroundTransparency = 1
            end
            self.ActiveTab = tab
            tab.Content.Visible = true
            tab.Button.TextColor3 = Theme.TextPrimary
            tab.Button.BackgroundColor3 = Theme.Surface
            tab.Button.BackgroundTransparency = 0

            self.TabTitle.Text = tab.Name
            self.TabDesc.Text = tab.Description
        end)

        -- ═══════════════════════════════════════════════════════════════
        -- ADD GROUP (Content panel)
        -- ═══════════════════════════════════════════════════════════════
        function tab:AddGroup(groupConfig)
            groupConfig = groupConfig or {}
            local group = {}
            group.Name = groupConfig.Name or "Group"
            group.Side = groupConfig.Side or "Left"
            group.Elements = {}

            local parent = group.Side == "Left" and tab.LeftColumn or tab.RightColumn

            -- Group frame with rounded corners
            group.Frame = Create("Frame", {
                Name = group.Name,
                BackgroundColor3 = Theme.GroupBg,
                BorderSizePixel = 0,
                Size = UDim2.new(1, 0, 0, 50),
                Parent = parent
            })
            Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = group.Frame})
            Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = group.Frame})

            -- Group header with icon
            local header = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 30),
                Position = UDim2.new(0, 10, 0, 8),
                Parent = group.Frame
            })

            Create("ImageLabel", {
                Image = groupConfig.Icon or "rbxassetid://10723427199",
                ImageColor3 = Theme.TextSecondary,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 16, 0, 16),
                Position = UDim2.new(0, 0, 0, 2),
                Parent = header
            })

            Create("TextLabel", {
                Text = group.Name,
                Font = Enum.Font.GothamBold,
                TextSize = 14,
                TextColor3 = Theme.TextPrimary,
                BackgroundTransparency = 1,
                Size = UDim2.new(0, 200, 0, 20),
                Position = UDim2.new(0, 22, 0, 0),
                TextXAlignment = Enum.TextXAlignment.Left,
                Parent = header
            })

            -- Elements container
            group.ElementsContainer = Create("Frame", {
                BackgroundTransparency = 1,
                Size = UDim2.new(1, -20, 0, 0),
                Position = UDim2.new(0, 10, 0, 35),
                Parent = group.Frame
            })

            group.ElementLayout = Create("UIListLayout", {
                Padding = UDim.new(0, 8),
                SortOrder = Enum.SortOrder.LayoutOrder,
                Parent = group.ElementsContainer
            })

            group.ElementLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                group.ElementsContainer.Size = UDim2.new(1, -20, 0, group.ElementLayout.AbsoluteContentSize.Y)
                group.Frame.Size = UDim2.new(1, 0, 0, 45 + group.ElementLayout.AbsoluteContentSize.Y)
            end)

            -- ═══════════════════════════════════════════════════════════════
            -- UI ELEMENTS
            -- ═══════════════════════════════════════════════════════════════

            function group:AddLabel(config)
                config = config or {}
                return Create("TextLabel", {
                    Text = config.Text or "Label",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextSecondary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, config.Wrap and 40 or 20),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    TextWrapped = config.Wrap or false,
                    Parent = group.ElementsContainer
                })
            end

            function group:AddButton(config)
                config = config or {}
                local isLocked = config.Locked or false

                local btn = Create("TextButton", {
                    Text = (config.Name or "Button") .. (isLocked and " (locked)" or ""),
                    Font = Enum.Font.GothamSemibold,
                    TextSize = 13,
                    TextColor3 = isLocked and Theme.Locked or Theme.TextSecondary,
                    BackgroundColor3 = isLocked and Theme.Surface or Theme.Button,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 32),
                    Parent = group.ElementsContainer
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 8), Parent = btn})

                if not isLocked then
                    btn.MouseEnter:Connect(function() Tween(btn, {BackgroundColor3 = Theme.ButtonHover}, 0.15) end)
                    btn.MouseLeave:Connect(function() Tween(btn, {BackgroundColor3 = Theme.Button}, 0.15) end)
                    btn.MouseButton1Click:Connect(function() if config.Callback then config.Callback() end end)
                end
                return btn
            end

            function group:AddToggle(config)
                config = config or {}
                local toggle = {Value = config.Default or false, Callback = config.Callback or function() end}

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Toggle",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local switch = Create("Frame", {
                    BackgroundColor3 = toggle.Value and Theme.ToggleOn or Theme.ToggleOff,
                    Size = UDim2.new(0, 40, 0, 22),
                    Position = UDim2.new(1, -40, 0.5, -11),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = switch})

                local knob = Create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    Size = UDim2.new(0, 18, 0, 18),
                    Position = toggle.Value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9),
                    Parent = switch
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

                local click = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Parent = frame})

                function toggle:Set(value)
                    toggle.Value = value
                    Tween(switch, {BackgroundColor3 = value and Theme.ToggleOn or Theme.ToggleOff}, 0.2)
                    Tween(knob, {Position = value and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)}, 0.2)
                    toggle.Callback(value)
                end
                click.MouseButton1Click:Connect(function() toggle:Set(not toggle.Value) end)
                return toggle
            end

            function group:AddSlider(config)
                config = config or {}
                local slider = {
                    Value = config.Default or config.Min or 0,
                    Min = config.Min or 0,
                    Max = config.Max or 100,
                    Increment = config.Increment or 1,
                    Callback = config.Callback or function() end
                }

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 40), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Slider",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local valueLabel = Create("TextLabel", {
                    Text = slider.Value .. " / " .. slider.Max,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.TextSecondary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.4, 0, 0, 18),
                    Position = UDim2.new(0.6, 0, 0, 0),
                    TextXAlignment = Enum.TextXAlignment.Right,
                    Parent = frame
                })

                local track = Create("Frame", {
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 6),
                    Position = UDim2.new(0, 0, 0, 26),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = track})

                local fill = Create("Frame", {
                    BackgroundColor3 = Theme.SliderFill,
                    BorderSizePixel = 0,
                    Size = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), 0, 1, 0),
                    Parent = track
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = fill})

                local knob = Create("Frame", {
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 12, 0, 12),
                    Position = UDim2.new((slider.Value - slider.Min) / (slider.Max - slider.Min), -6, 0.5, -6),
                    Parent = track
                })
                Create("UICorner", {CornerRadius = UDim.new(1, 0), Parent = knob})

                local dragging = false
                local function update(input)
                    local pos = math.clamp((input.Position.X - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
                    local val = math.floor((pos * (slider.Max - slider.Min) + slider.Min) / slider.Increment) * slider.Increment
                    val = math.clamp(val, slider.Min, slider.Max)
                    slider.Value = val
                    valueLabel.Text = val .. " / " .. slider.Max
                    fill.Size = UDim2.new(pos, 0, 1, 0)
                    knob.Position = UDim2.new(pos, -6, 0.5, -6)
                    slider.Callback(val)
                end

                track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = true; update(input) end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then update(input) end
                end)
                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                end)
                return slider
            end

            function group:AddDropdown(config)
                config = config or {}
                local dropdown = {Options = config.Options or {}, Value = config.Default or "", Callback = config.Callback or function() end}

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Dropdown",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local btn = Create("TextButton", {
                    Text = tostring(dropdown.Value),
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.TextSecondary,
                    BackgroundColor3 = Theme.InputBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 22),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = btn})

                local idx = table.find(dropdown.Options, dropdown.Value) or 1
                btn.MouseButton1Click:Connect(function()
                    idx = idx % #dropdown.Options + 1
                    dropdown.Value = dropdown.Options[idx]
                    btn.Text = tostring(dropdown.Value)
                    dropdown.Callback(dropdown.Value)
                end)
                return dropdown
            end

            function group:AddMultiDropdown(config)
                config = config or {}
                local dropdown = {Options = config.Options or {}, Values = config.Default or {}, Callback = config.Callback or function() end}

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Multi Dropdown",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local display = #dropdown.Values > 0 and table.concat(dropdown.Values, ", ") or "None"
                local btn = Create("TextButton", {
                    Text = display,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.TextSecondary,
                    BackgroundColor3 = Theme.InputBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 22),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = btn})
                return dropdown
            end

            function group:AddKeybind(config)
                config = config or {}
                local keybind = {Value = config.Default or Enum.KeyCode.Unknown, Callback = config.Callback or function() end}

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Keybind",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.6, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local btn = Create("TextButton", {
                    Text = keybind.Value.Name,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.TextSecondary,
                    BackgroundColor3 = Theme.InputBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(0, 60, 0, 24),
                    Position = UDim2.new(1, -60, 0.5, -12),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = btn})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = btn})

                local listening = false
                btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "..." end)
                UserInputService.InputBegan:Connect(function(input, gp)
                    if listening and not gp and input.UserInputType == Enum.UserInputType.Keyboard then
                        listening = false
                        keybind.Value = input.KeyCode
                        btn.Text = input.KeyCode.Name
                        keybind.Callback(input.KeyCode)
                    elseif not gp and input.KeyCode == keybind.Value then
                        keybind.Callback()
                    end
                end)
                return keybind
            end

            function group:AddColorPicker(config)
                config = config or {}
                local picker = {Value = config.Default or Color3.fromRGB(255, 255, 255), Callback = config.Callback or function() end}

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 26), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Color",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(0.7, 0, 1, 0),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local preview = Create("Frame", {
                    BackgroundColor3 = picker.Value,
                    Size = UDim2.new(0, 30, 0, 20),
                    Position = UDim2.new(1, -30, 0.5, -10),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = preview})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = preview})

                local colors = {Color3.fromRGB(255,255,255), Color3.fromRGB(255,0,0), Color3.fromRGB(0,255,0), Color3.fromRGB(0,0,255), Color3.fromRGB(255,255,0), Color3.fromRGB(255,0,255), Color3.fromRGB(0,255,255), Color3.fromRGB(147,51,234)}
                local cIndex = 1

                local clickBtn = Create("TextButton", {Text = "", BackgroundTransparency = 1, Size = UDim2.new(0, 30, 0, 20), Position = UDim2.new(1, -30, 0.5, -10), Parent = frame})
                clickBtn.MouseButton1Click:Connect(function()
                    cIndex = cIndex % #colors + 1
                    picker.Value = colors[cIndex]
                    preview.BackgroundColor3 = picker.Value
                    picker.Callback(picker.Value)
                end)
                return picker
            end

            function group:AddInput(config)
                config = config or {}
                local input = {Value = config.Default or "", Callback = config.Callback or function() end}

                local frame = Create("Frame", {BackgroundTransparency = 1, Size = UDim2.new(1, 0, 0, 50), Parent = group.ElementsContainer})

                Create("TextLabel", {
                    Text = config.Name or "Input",
                    Font = Enum.Font.Gotham,
                    TextSize = 13,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundTransparency = 1,
                    Size = UDim2.new(1, 0, 0, 18),
                    TextXAlignment = Enum.TextXAlignment.Left,
                    Parent = frame
                })

                local box = Create("TextBox", {
                    Text = input.Value,
                    PlaceholderText = config.Placeholder or "Enter text...",
                    PlaceholderColor3 = Theme.TextMuted,
                    Font = Enum.Font.Gotham,
                    TextSize = 12,
                    TextColor3 = Theme.TextPrimary,
                    BackgroundColor3 = Theme.InputBg,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Position = UDim2.new(0, 0, 0, 22),
                    Parent = frame
                })
                Create("UICorner", {CornerRadius = UDim.new(0, 6), Parent = box})
                Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = box})

                box.FocusLost:Connect(function()
                    input.Value = box.Text
                    input.Callback(box.Text)
                end)
                return input
            end

            table.insert(tab.Groups, group)
            return group
        end

        table.insert(section.Tabs, tab)
        return tab
    end

    table.insert(self.Sections, section)
    return section
end

-- ═══════════════════════════════════════════════════════════════
-- NOTIFICATION SYSTEM
-- ═══════════════════════════════════════════════════════════════
function Fallens:Notify(config)
    config = config or {}
    local title = config.Title or "Notification"
    local desc = config.Description or ""
    local duration = config.Duration or 3

    local notif = Create("Frame", {
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 280, 0, desc ~= "" and 70 or 50),
        Position = UDim2.new(1, 20, 0, 20),
        Parent = self.ScreenGui
    })
    Create("UICorner", {CornerRadius = UDim.new(0, 10), Parent = notif})
    Create("UIStroke", {Color = Theme.Border, Thickness = 1, Parent = notif})

    -- Purple accent bar
    Create("Frame", {
        BackgroundColor3 = self.AccentColor,
        BorderSizePixel = 0,
        Size = UDim2.new(0, 3, 1, 0),
        Parent = notif
    })

    Create("TextLabel", {
        Text = title,
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        TextColor3 = Theme.TextPrimary,
        BackgroundTransparency = 1,
        Size = UDim2.new(1, -20, 0, 20),
        Position = UDim2.new(0, 12, 0, 8),
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = notif
    })

    if desc ~= "" then
        Create("TextLabel", {
            Text = desc,
            Font = Enum.Font.Gotham,
            TextSize = 12,
            TextColor3 = Theme.TextSecondary,
            BackgroundTransparency = 1,
            Size = UDim2.new(1, -20, 0, 16),
            Position = UDim2.new(0, 12, 0, 30),
            TextXAlignment = Enum.TextXAlignment.Left,
            Parent = notif
        })
    end

    -- Animate in
    Tween(notif, {Position = UDim2.new(1, -300, 0, 20)}, 0.4, Enum.EasingStyle.Back)

    task.delay(duration, function()
        Tween(notif, {Position = UDim2.new(1, 20, 0, 20)}, 0.3, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
        task.wait(0.3)
        notif:Destroy()
    end)
end

-- ═══════════════════════════════════════════════════════════════
-- DEMO / EXAMPLE USAGE (matching reference image)
-- ═══════════════════════════════════════════════════════════════
function Fallens.Demo()
    local UI = Fallens.new({Name = "Fallens", AccentColor = Color3.fromRGB(147, 51, 234)})

    -- General Section
    local general = UI:AddSection({Name = "General", Icon = "rbxassetid://98092584632154"})

    -- All Elements Tab
    local allTab = general:AddTab({Name = "All Elements", Description = "Showcasing every UI element"})

    -- Basic Elements Group (Left)
    local basicGroup = allTab:AddGroup({Name = "Basic Elements", Side = "Left", Icon = "rbxassetid://10723427199"})
    basicGroup:AddLabel({Text = "This is a standard label. It can wrap"})
    basicGroup:AddButton({Name = "Standard Button", Callback = function() print("Clicked!") end})
    basicGroup:AddButton({Name = "Locked Button (Premium)", Locked = true})

    local toggle1 = basicGroup:AddToggle({Name = "Example Toggle", Default = true})
    local slider1 = basicGroup:AddSlider({Name = "Example Slider", Min = 0, Max = 200, Default = 100})

    -- Advanced Elements Group (Right)
    local advancedGroup = allTab:AddGroup({Name = "Advanced Elements", Side = "Right", Icon = "rbxassetid://10723427199"})
    advancedGroup:AddInput({Name = "Example Text Input", Default = "Auto-filled text!"})
    advancedGroup:AddColorPicker({Name = "Example Color Picker", Default = Color3.fromRGB(255, 255, 255)})
    advancedGroup:AddDropdown({Name = "Example Dropdown", Options = {"Option A", "Option B", "Option C"}, Default = "Option B"})
    advancedGroup:AddMultiDropdown({Name = "Example Multi-Dropdown", Options = {"Apple", "Banana", "Cherry", "Date"}, Default = {"Banana", "Date"}})
    advancedGroup:AddKeybind({Name = "Example Keybind", Default = Enum.KeyCode.E})

    -- Master Switch
    local masterToggle = advancedGroup:AddToggle({Name = "Master Switch...", Default = false})

    -- Premium Elements Group (Left, bottom)
    local premiumGroup = allTab:AddGroup({Name = "Premium Elements", Side = "Left", Icon = "rbxassetid://10723427199"})
    premiumGroup:AddLabel({Text = "This group showcases the new locked features. These toggles cannot be"})
    premiumGroup:AddButton({Name = "Aimbot (VIP)", Locked = true})
    premiumGroup:AddButton({Name = "ESP Player (VIP)", Locked = true})

    -- Misc Elements Group (Right, bottom)
    local miscGroup = allTab:AddGroup({Name = "Misc Elements", Side = "Right", Icon = "rbxassetid://10723427199"})
    miscGroup:AddLabel({Text = "Just some extra elements to balance"})
    miscGroup:AddButton({Name = "Misc Locked Button", Locked = true})
    miscGroup:AddSlider({Name = "Misc Slider", Min = 0, Max = 100, Default = 50})

    -- Automation Tab
    local autoTab = general:AddTab({Name = "Automation", Description = "Automation features"})

    -- Configs Tab
    local configTab = general:AddTab({Name = "Configs", Description = "Configuration settings"})

    -- Activate first tab
    allTab.Button.MouseButton1Click:Fire()

    UI:Notify({
        Title = "Fallens UI Loaded",
        Description = "Press RightControl to toggle",
        Duration = 5
    })

    return UI
end

return Fallens
