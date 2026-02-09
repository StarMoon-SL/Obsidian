local cloneref = (cloneref or clonereference or function(instance: any)
    return instance
end)
local clonefunction = (clonefunction or copyfunction or function(func) 
    return func 
end)

local HttpService: HttpService = cloneref(game:GetService("HttpService"))
local TweenService: TweenService = cloneref(game:GetService("TweenService"))
local RunService: RunService = cloneref(game:GetService("RunService"))
local Players: Players = cloneref(game:GetService("Players"))
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

local SaveManager = {} do
    SaveManager.Folder = "ObsidianLibSettings"
    SaveManager.SubFolder = ""
    SaveManager.Ignore = {}
    SaveManager.Library = nil
    SaveManager.SnowEnabled = true
    SaveManager.SnowContainer = nil
    SaveManager.SnowConnection = nil

    SaveManager.Parser = {
        Toggle = {
            Save = function(idx, object)
                return { type = "Toggle", idx = idx, value = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Toggles[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Slider = {
            Save = function(idx, object)
                return { type = "Slider", idx = idx, value = tostring(object.Value) }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        Dropdown = {
            Save = function(idx, object)
                return { type = "Dropdown", idx = idx, value = object.Value, multi = object.Multi }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.value then
                    object:SetValue(data.value)
                end
            end,
        },
        ColorPicker = {
            Save = function(idx, object)
                return { type = "ColorPicker", idx = idx, value = object.Value:ToHex(), transparency = object.Transparency }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValueRGB(Color3.fromHex(data.value), data.transparency)
                end
            end,
        },
        KeyPicker = {
            Save = function(idx, object)
                return { type = "KeyPicker", idx = idx, mode = object.Mode, key = object.Value, modifiers = object.Modifiers }
            end,
            Load = function(idx, data)
                if SaveManager.Library.Options[idx] then
                    SaveManager.Library.Options[idx]:SetValue({ data.key, data.mode, data.modifiers })
                end
            end,
        },
        Input = {
            Save = function(idx, object)
                return { type = "Input", idx = idx, text = object.Value }
            end,
            Load = function(idx, data)
                local object = SaveManager.Library.Options[idx]
                if object and object.Value ~= data.text and type(data.text) == "string" then
                    SaveManager.Library.Options[idx]:SetValue(data.text)
                end
            end,
        },
    }

    function SaveManager:SetLibrary(library)
        self.Library = library
    end

    function SaveManager:IgnoreThemeSettings()
        self:SetIgnoreIndexes({
            "BackgroundColor", "MainColor", "AccentColor", "OutlineColor", "FontColor", "FontFace",
            "ThemeManager_ThemeList", "ThemeManager_CustomThemeList", "ThemeManager_CustomThemeName",
        })
    end

    function SaveManager:CreateSnowEffect()
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

    function SaveManager:DestroySnowEffect()
        if self.SnowConnection then
            self.SnowConnection:Disconnect()
            self.SnowConnection = nil
        end
        if self.SnowContainer then
            self.SnowContainer:Destroy()
            self.SnowContainer = nil
        end
    end

    function SaveManager:ToggleSnow(enabled)
        self.SnowEnabled = enabled
        if enabled then
            self:CreateSnowEffect()
        else
            self:DestroySnowEffect()
        end
    end

    function SaveManager:CheckSubFolder(createFolder)
        if typeof(self.SubFolder) ~= "string" or self.SubFolder == "" then return false end

        if createFolder == true then
            if not isfolder(self.Folder .. "/settings/" .. self.SubFolder) then
                makefolder(self.Folder .. "/settings/" .. self.SubFolder)
            end
        end

        return true
    end

    function SaveManager:GetPaths()
        local paths = {}

        local parts = self.Folder:split("/")
        for idx = 1, #parts do
            local path = table.concat(parts, "/", 1, idx)
            if not table.find(paths, path) then paths[#paths + 1] = path end
        end

        paths[#paths + 1] = self.Folder .. "/themes"
        paths[#paths + 1] = self.Folder .. "/settings"

        if self:CheckSubFolder(false) then
            local subFolder = self.Folder .. "/settings/" .. self.SubFolder
         <response clipped><NOTE>Result is longer than **10000 characters**, will be **truncated**.</NOTE>
