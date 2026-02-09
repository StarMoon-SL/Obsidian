local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local isfolder, isfile, listfiles = isfolder, isfile, listfiles

if typeof(clonefunction) == "function" then
    local
        isfolder_copy,
        isfile_copy,
        listfiles_copy = clonefunction(isfolder), clonefunction(isfile), clonefunction(listfiles)

    local isfolder_success, isfolder_error = pcall(function()
        return isfolder_copy("test" .. tostring(math.random(1000000, 9999999)))
    end)

    if isfolder_success == false or typeof(isfolder_error) ~= "boolean" then
        isfolder = function(folder)
            local success, data = pcall(isfolder_copy, folder)
            return (if success then data else false)
        end

        isfile = function(file)
            local success, data = pcall(isfile_copy, file)
            return (if success then data else false)
        end

        listfiles = function(folder)
            local success, data = pcall(listfiles_copy, folder)
            return (if success then data else {})
        end
    end
end

local ThemeManager = {}
do
    local ThemeFields = { "FontColor", "MainColor", "AccentColor", "BackgroundColor", "OutlineColor" }
    ThemeManager.Folder = "ObsidianLibSettings"
    ThemeManager.Library = nil
    ThemeManager.AppliedToTab = false
    ThemeManager.SnowEnabled = true
    ThemeManager.SnowContainer = nil
    ThemeManager.SnowConnection = nil

    ThemeManager.BuiltInThemes = {
        ["Default"] = {
            1,
            { FontColor = "ffffff", MainColor = "191919", AccentColor = "7d55ff", BackgroundColor = "0f0f0f", OutlineColor = "282828" },
        },
        ["BBot"] = {
            2,
            { FontColor = "ffffff", MainColor = "1e1e1e", AccentColor = "7e48a3", BackgroundColor = "232323", OutlineColor = "141414" },
        },
        ["Fatality"] = {
            3,
            { FontColor = "ffffff", MainColor = "1e1842", AccentColor = "c50754", BackgroundColor = "191335", OutlineColor = "3c355d" },
        },
        ["Jester"] = {
            4,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "db4467", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Mint"] = {
            5,
            { FontColor = "ffffff", MainColor = "242424", AccentColor = "3db488", BackgroundColor = "1c1c1c", OutlineColor = "373737" },
        },
        ["Tokyo Night"] = {
            6,
            { FontColor = "ffffff", MainColor = "191925", AccentColor = "6759b3", BackgroundColor = "16161f", OutlineColor = "323232" },
        },
        ["Ubuntu"] = {
            7,
            { FontColor = "ffffff", MainColor = "3e3e3e", AccentColor = "e2581e", BackgroundColor = "323232", OutlineColor = "191919" },
        },
        ["Quartz"] = {
            8,
            { FontColor = "ffffff", MainColor = "232330", AccentColor = "426e87", BackgroundColor = "1d1b26", OutlineColor = "27232f" },
        },
        ["Nord"] = {
            9,
            { FontColor = "eceff4", MainColor = "3b4252", AccentColor = "88c0d0", BackgroundColor = "2e3440", OutlineColor = "4c566a" },
        },
        ["Dracula"] = {
            10,
            { FontColor = "f8f8f2", MainColor = "44475a", AccentColor = "ff79c6", BackgroundColor = "282a36", OutlineColor = "6272a4" },
        },
        ["Monokai"] = {
            11,
            { FontColor = "f8f8f2", MainColor = "272822", AccentColor = "f92672", BackgroundColor = "1e1f1c", OutlineColor = "49483e" },
        },
        ["Gruvbox"] = {
            12,
            { FontColor = "ebdbb2", MainColor = "3c3836", AccentColor = "fb4934", BackgroundColor = "282828", OutlineColor = "504945" },
        },
        ["Solarized"] = {
            13,
            { FontColor = "839496", MainColor = "073642", AccentColor = "cb4b16", BackgroundColor = "002b36", OutlineColor = "586e75" },
        },
        ["Catppuccin"] = {
            14,
            { FontColor = "d9e0ee", MainColor = "302d41", AccentColor = "f5c2e7", BackgroundColor = "1e1e2e", OutlineColor = "575268" },
        },
        ["One Dark"] = {
            15,
            { FontColor = "abb2bf", MainColor = "282c34", AccentColor = "c678dd", BackgroundColor = "21252b", OutlineColor = "5c6370" },
        },
        ["Cyberpunk"] = {
            16,
            { FontColor = "f9f9f9", MainColor = "262335", AccentColor = "00ff9f", BackgroundColor = "1a1a2e", OutlineColor = "413c5e" },
        },
        ["Oceanic Next"] = {
            17,
            { FontColor = "d8dee9", MainColor = "1b2b34", AccentColor = "6699cc", BackgroundColor = "16232a", OutlineColor = "343d46" },
        },
        ["Material"] = {
            18,
            { FontColor = "eeffff", MainColor = "212121", AccentColor = "82aaff", BackgroundColor = "151515", OutlineColor = "424242" },
        }
    }

    function ThemeManager:SetLibrary(library)
        self.Library = library
    end

    function ThemeManager:CreateSnowEffect()
        if not self.Library or not self.Library.GUI then return end
        if self.SnowContainer then return end

        local gui = self.Library.GUI
        local snowContainer = Instance.new("Frame")
        snowContainer.Name = "SnowContainer"
        snowContainer.BackgroundTransparency = 1
        snowContainer.BorderSizePixel = 0
        snowContainer.Size = UDim2.new(1, 0, 1, 0)
        snowContainer.ZIndex = 1000
        snowContainer.ClipsDescendants = true
        snowContainer.Parent = gui

        self.SnowContainer = snowContainer

        local snowflakes = {}
        local maxSnowflakes = 50
        local spawnRate = 0.1
        local lastSpawn = 0

        self.SnowConnection = RunService.RenderStepped:Connect(function(deltaTime)
            if not self.SnowEnabled or not snowContainer.Parent then
                return
            end

            lastSpawn = lastSpawn + deltaTime

            if lastSpawn >= spawnRate and #snowflakes < maxSnowflakes then
                lastSpawn = 0

                local snowflake = Instance.new("TextLabel")
                snowflake.Name = "Snowflake"
                snowflake.BackgroundTransparency = 1
                snowflake.BorderSizePixel = 0
                snowflake.Text = "❄"
                snowflake.TextColor3 = Color3.fromRGB(255, 255, 255)
                snowflake.TextStrokeTransparency = 0.8
                snowflake.TextStrokeColor3 = Color3.fromRGB(200, 220, 255)
                snowflake.Font = Enum.Font.GothamBold
                snowflake.TextSize = math.random(10, 20)
                snowflake.Size = UDim2.new(0, 20, 0, 20)
                snowflake.Position = UDim2.new(0, math.random(0, snowContainer.AbsoluteSize.X - 20), 0, -30)
                snowflake.ZIndex = 1001
                snowflake.Parent = snowContainer

                local duration = math.random(3, 6)
                local endPos = UDim2.new(0, snowflake.Position.X.Offset + math.random(-50, 50), 1, 30)

                local tweenInfo = TweenInfo.new(
                    duration,
                    Enum.EasingStyle.Linear,
                    Enum.EasingDirection.Out,
                    0,
                    false,
                    0
                )

                local swayTween = TweenInfo.new(
                    duration / 2,
                    Enum.EasingStyle.Sine,
                    Enum.EasingDirection.InOut,
                    -1,
                    true,
                    0
                )

                local tween = TweenService:Create(snowflake, tweenInfo, { Position = endPos, Rotation = math.random(-180, 180) })
                local sway = TweenService:Create(snowflake, swayTween, { Position = UDim2.new(0, endPos.X.Offset + math.random(-30, 30), endPos.Y.Scale, endPos.Y.Offset) })

                table.insert(snowflakes, { Instance = snowflake, Tween = tween, Sway = sway })

                tween:Play()
                sway:Play()

                tween.Completed:Connect(function()
                    if snowflake and snowflake.Parent then
                        snowflake:Destroy()
                    end
                    for i, v in ipairs(snowflakes) do
                        if v.Instance == snowflake then
                            table.remove(snowflakes, i)
                            break
                        end
                    end
                end)
            end

            for i = #snowflakes, 1, -1 do
                local flake = snowflakes[i]
                if not flake.Instance or not flake.Instance.Parent then
                    table.remove(snowflakes, i)
                end
            end
        end)
    end

    function ThemeManager:DestroySnowEffect()
        if self.SnowConnection then
            self.SnowConnection:Disconnect()
            self.SnowConnection = nil
        end
        if self.SnowContainer then
            self.SnowContainer:Destroy()
            self.SnowContainer = nil
        end
    end

    function ThemeManager:ToggleSnow(enabled)
        self.SnowEnabled = enabled
        if enabled then
            self:CreateSnowEffect()
        else
            self:DestroySnowEffect()
        end
    end

    function ThemeManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            paths[#paths + 1] = table.concat(parts, "/", 1, idx)
        end

        paths[#paths + 1] = self.Folder .. "/themes"

        return paths
    end

    function ThemeManager:BuildFolderTree()
        local paths = self:GetPaths()

        for i = 1, #paths do
            local str = paths[i]
            if is<response clipped><NOTE>Result is longer than **10000 characters**, will be **truncated**.</NOTE>
