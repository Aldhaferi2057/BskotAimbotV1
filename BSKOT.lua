local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

local Settings = {
    Aimbot = false,
    AutoClick = false,
    ESP = false,
    ESPNames = false,
    Strength = 0.5,
    Visible = true,
    ProtectedPlayers = {}
}

local CurrentTarget = nil
local FileName = "BskotLogo.png"
local DiscordURL = "https://cdn.discordapp.com/attachments/1499476447352586430/1499486685661233162/22ba513f57dff8c9a7ffd95cae6e0f95.png?ex=69f4f94c&is=69f3a7cc&hm=592398660c6a377950800a0004c50fc672ae6665d526484a2277a02735096f23&"

if setclipboard then setclipboard("https://guns.lol/0x0x0x") end

local function GetBskotImage()
    if writefile and readfile then
        if not isfile(FileName) then
            pcall(function() writefile(FileName, game:HttpGet(DiscordURL)) end)
        end
        return getcustomasset(FileName)
    end
    return ""
end

local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 360, 0, 520)
MainFrame.Position = UDim2.new(0.5, -180, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.Text = "Bskot Aimbot كرمال عنزه و عضيدي نو ون"
Title.TextColor3 = Color3.fromRGB(0, 0, 0)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18

local NamesBtn = Instance.new("TextButton", MainFrame)
NamesBtn.Size = UDim2.new(0.9, 0, 0, 35)
NamesBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
NamesBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
NamesBtn.Text = "ESP NAMES: OFF"
NamesBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NamesBtn.BorderSizePixel = 1
NamesBtn.BorderColor3 = Color3.fromRGB(255, 255, 255)
NamesBtn.MouseButton1Click:Connect(function()
    Settings.ESPNames = not Settings.ESPNames
    NamesBtn.Text = "ESP NAMES: " .. (Settings.ESPNames and "ON" or "OFF")
end)

local PowerText = Instance.new("TextLabel", MainFrame)
PowerText.Text = "LOCK SPEED: 50%"
PowerText.Position = UDim2.new(0, 0, 0.22, 0)
PowerText.Size = UDim2.new(1, 0, 0, 20)
PowerText.TextColor3 = Color3.fromRGB(255, 255, 255)
PowerText.BackgroundTransparency = 1

local SliderBack = Instance.new("Frame", MainFrame)
SliderBack.Size = UDim2.new(0.8, 0, 0, 4)
SliderBack.Position = UDim2.new(0.1, 0, 0.28, 0)
SliderBack.BackgroundColor3 = Color3.fromRGB(60, 60, 60)

local SliderKnob = Instance.new("TextButton", SliderBack)
SliderKnob.Size = UDim2.new(0, 14, 0, 14)
SliderKnob.Position = UDim2.new(0.5, -7, -1.2, 0)
SliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
SliderKnob.Text = ""

local dragging = false
SliderKnob.MouseButton1Down:Connect(function() dragging = true end)
UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local r = math.clamp((input.Position.X - SliderBack.AbsolutePosition.X) / SliderBack.AbsoluteSize.X, 0, 1)
        SliderKnob.Position = UDim2.new(r, -7, -1.2, 0)
        Settings.Strength = math.max(r, 0.05)
        PowerText.Text = "LOCK SPEED: " .. math.floor(r * 100) .. "%"
    end
end)
UserInputService.InputEnded:Connect(function(i) if i.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end end)

local BskotLogo = Instance.new("ImageLabel", MainFrame)
BskotLogo.Size = UDim2.new(0, 100, 0, 100)
BskotLogo.Position = UDim2.new(0.68, 0, 0.75, 0)
BskotLogo.BackgroundTransparency = 1
BskotLogo.Image = GetBskotImage()

local Credits = Instance.new("TextLabel", MainFrame)
Credits.Size = UDim2.new(0.4, 0, 0, 20)
Credits.Position = UDim2.new(0.58, 0, 0.94, 0)
Credits.Text = "Coded By Bskot"
Credits.TextColor3 = Color3.fromRGB(255, 255, 255)
Credits.BackgroundTransparency = 1
Credits.Font = Enum.Font.Code
Credits.TextSize = 13
Credits.TextXAlignment = Enum.TextXAlignment.Right

local function IsVisible(part)
    if not part then return false end
    local char = LocalPlayer.Character
    if not char then return false end
    local params = RaycastParams.new()
    params.FilterDescendantsInstances = {char, ScreenGui}
    params.FilterType = Enum.RaycastFilterType.Exclude
    local ray = workspace:Raycast(Camera.CFrame.Position, (part.Position - Camera.CFrame.Position).Unit * 1000, params)
    return ray and ray.Instance:IsDescendantOf(part.Parent)
end

RunService.RenderStepped:Connect(function()
    if Settings.Aimbot then
        if not CurrentTarget or not CurrentTarget.Character or not CurrentTarget.Character:FindFirstChild("Humanoid") or CurrentTarget.Character.Humanoid.Health <= 0 or not IsVisible(CurrentTarget.Character:FindFirstChild("Head")) then
            local nearest = nil
            local minDistance = math.huge
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and not table.find(Settings.ProtectedPlayers, p.UserId) then
                    if p.Character and p.Character:FindFirstChild("Head") and p.Character.Humanoid.Health > 0 then
                        if IsVisible(p.Character.Head) then
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
            local lookCF = CFrame.lookAt(Camera.CFrame.Position, head.Position)
            Camera.CFrame = Camera.CFrame:Lerp(lookCF, Settings.Strength)
            if Settings.AutoClick then
                local angleMatch = Camera.CFrame.LookVector:Dot((head.Position - Camera.CFrame.Position).Unit)
                if angleMatch > 0.999 then
                    if mouse1click then mouse1click() end
                end
            end
        end
    end
    if Settings.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local hl = p.Character:FindFirstChild("BskotHL") or Instance.new("Highlight", p.Character)
                hl.Name = "BskotHL"; hl.FillColor = Color3.fromRGB(255, 255, 255); hl.OutlineColor = Color3.fromRGB(0,0,0); hl.Enabled = true
                if Settings.ESPNames and p.Character:FindFirstChild("Head") then
                    local tag = p.Character.Head:FindFirstChild("BskotTag") or Instance.new("BillboardGui", p.Character.Head)
                    tag.Name = "BskotTag"; tag.AlwaysOnTop = true; tag.Size = UDim2.new(0,100,0,50); tag.ExtentsOffset = Vector3.new(0,2,0)
                    local tl = tag:FindFirstChild("TextLabel") or Instance.new("TextLabel", tag)
                    tl.Size = UDim2.new(1,0,1,0); tl.BackgroundTransparency = 1; tl.Text = p.DisplayName; tl.TextColor3 = Color3.fromRGB(255, 255, 255); tl.TextSize = 14
                end
            end
        end
    end
end)

UserInputService.InputBegan:Connect(function(input, proc)
    if proc then return end
    if input.KeyCode == Enum.KeyCode.LeftControl then
        Settings.Visible = not Settings.Visible
        MainFrame.Visible = Settings.Visible
    elseif input.KeyCode == Enum.KeyCode.F1 then
        Settings.Aimbot = not Settings.Aimbot; Settings.AutoClick = false
    elseif input.KeyCode == Enum.KeyCode.F2 then
        Settings.Aimbot = not Settings.Aimbot; Settings.AutoClick = Settings.Aimbot
    elseif input.KeyCode == Enum.KeyCode.F3 then
        Settings.ESP = true
    elseif input.KeyCode == Enum.KeyCode.F4 then
        Settings.ESP = false
        for _, p in pairs(Players:GetPlayers()) do
            if p.Character then
                if p.Character:FindFirstChild("BskotHL") then p.Character.BskotHL:Destroy() end
                if p.Character.Head:FindFirstChild("BskotTag") then p.Character.Head.BskotTag:Destroy() end
            end
        end
    elseif input.KeyCode == Enum.KeyCode.X then
        ScreenGui:Destroy()
    end
end)
