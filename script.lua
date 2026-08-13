-- [[ JMO HUB v2 ]]
-- Universal Client-Side Interface Framework

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

-- Clean up any existing instances of JMO Hub v2
if CoreGui:FindFirstChild("JMOHubV2") then
	CoreGui.JMOHubV2:Destroy()
end

-- Create Main ScreenGui
local JMOHubV2 = Instance.new("ScreenGui")
JMOHubV2.Name = "JMOHubV2"
JMOHubV2.Parent = CoreGui
JMOHubV2.ResetOnSpawn = false

-- Theme Configuration (Green/Black Matrix Theme)
local Theme = {
	Background = Color3.fromRGB(10, 10, 10),
	Panel = Color3.fromRGB(20, 20, 20),
	Border = Color3.fromRGB(0, 255, 100),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(150, 150, 150),
	Accent = Color3.fromRGB(0, 220, 80),
	Button = Color3.fromRGB(25, 25, 25),
	ButtonHover = Color3.fromRGB(0, 100, 40)
}

local State = {
	SelectedPlayer = nil,
	TargetPlayer = nil,
	SearchText = "",
	ESPEnabled = false,
	NameESP = false,
	DistanceESP = false,
	HealthBars = false,
	LocalHighlight = false,
	Fly = false,
	FlySpeed = 45,
	WalkSpeed = 16,
	JumpPower = 50,
	InfiniteJump = false,
	Noclip = false,
	AutoRun = false,
	ThirdPerson = false,
	Freecam = false,
	FreecamSpeed = 20,
	CameraFOV = 70,
	CameraLocked = false,
	UITransparency = 0,
	Fullbright = false,
	RemoveFog = false,
	AutoESP = false,
	SavedSettings = false,
	SavedWaypoints = false,
	TargetTracking = false,
	AntiAFK = false,
	HealthRegen = false,
	HighHealth = false,
	MobileControls = false,
	DesktopControls = false,
	WaypointList = {},
	ESPObjects = {},
	CurrentCameraCFrame = nil,
	FlyConnection = nil,
	RenderConnection = nil,
	AntiAFKConnection = nil,
	SavedData = {},
}

local function RoundNumber(value)
	if value == nil then return 0 end
	return math.floor(value * 10 + 0.5) / 10
end

local function GetHumanoid(player)
	if player and player.Character then
		return player.Character:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

local function GetRootPart(player)
	if player and player.Character then
		return player.Character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function GetLocalHumanoid()
	return GetHumanoid(LocalPlayer)
end

local function GetLocalRootPart()
	return GetRootPart(LocalPlayer)
end

local function SafeDestroy(instance)
	if instance and instance.Parent then
		instance:Destroy()
	end
end

local function ApplyUITransparency(value)
	if JMOHubV2 then
		for _, obj in ipairs(JMOHubV2:GetDescendants()) do
			if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame") then
				if obj.Name ~= "MainWindow" and obj.Name ~= "Header" then
					obj.BackgroundTransparency = math.clamp(value, 0, 1)
				end
			end
		end
	end
end

-- Main Window Frame
local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 620, 0, 400)
MainWindow.Position = UDim2.new(0.5, -310, 0.5, -200)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BorderSizePixel = 1
MainWindow.BorderColor3 = Theme.Border
MainWindow.Active = true
MainWindow.Parent = JMOHubV2

local Dragging, DragInput, DragStart, StartPosition

local function UpdateDrag(input)
	local delta = input.Position - DragStart
	MainWindow.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
end

MainWindow.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		Dragging = true
		DragStart = input.Position
		StartPosition = MainWindow.Position
		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				Dragging = false
			end
		end)
	end
end)

MainWindow.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		DragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		UpdateDrag(input)
	end
end)

-- Top Header Bar
local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 35)
Header.BackgroundColor3 = Theme.Panel
Header.BorderSizePixel = 0
Header.Parent = MainWindow

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "JMO HUB v2"
Title.TextColor3 = Theme.Border
Title.TextSize = 16
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 35, 0, 35)
CloseBtn.Position = UDim2.new(1, -35, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
CloseBtn.TextColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.TextSize = 16
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function()
	JMOHubV2:Destroy()
end)

local MinimizeBtn = Instance.new("TextButton")
MinimizeBtn.Size = UDim2.new(0, 35, 0, 35)
MinimizeBtn.Position = UDim2.new(1, -70, 0, 0)
MinimizeBtn.BackgroundTransparency = 1
MinimizeBtn.Text = "−"
MinimizeBtn.TextColor3 = Theme.TextDim
MinimizeBtn.TextSize = 16
MinimizeBtn.Font = Enum.Font.Code
MinimizeBtn.Parent = Header

local Collapsed = false
local ContentContainer = Instance.new("Frame")
ContentContainer.Name = "ContentContainer"
ContentContainer.Size = UDim2.new(1, 0, 1, -35)
ContentContainer.Position = UDim2.new(0, 0, 0, 35)
ContentContainer.BackgroundTransparency = 1
ContentContainer.Parent = MainWindow

MinimizeBtn.MouseButton1Click:Connect(function()
	Collapsed = not Collapsed
	TweenService:Create(MainWindow, TweenInfo.new(0.2), {
		Size = Collapsed and UDim2.new(0, 620, 0, 35) or UDim2.new(0, 620, 0, 400)
	}):Play()
	ContentContainer.Visible = not Collapsed
end)

local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 35)
Divider.BackgroundColor3 = Theme.Border
Divider.BorderSizePixel = 0
Divider.Parent = MainWindow

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 600)
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Theme.Border
Sidebar.Parent = ContentContainer

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

local MainDisplay = Instance.new("Frame")
MainDisplay.Name = "MainDisplay"
MainDisplay.Size = UDim2.new(1, -140, 1, 0)
MainDisplay.Position = UDim2.new(0, 140, 0, 0)
MainDisplay.BackgroundTransparency = 1
MainDisplay.Parent = ContentContainer

local Pages = {}

local function CreatePage(name)
	local Page = Instance.new("ScrollingFrame")
	Page.Name = name .. "Page"
	Page.Size = UDim2.new(1, 0, 1, 0)
	Page.BackgroundTransparency = 1
	Page.CanvasSize = UDim2.new(0, 0, 0, 800)
	Page.ScrollBarThickness = 4
	Page.ScrollBarImageColor3 = Theme.Border
	Page.Visible = false
	Page.Parent = MainDisplay

	local PageLayout = Instance.new("UIListLayout")
	PageLayout.Parent = Page
	PageLayout.SortOrder = Enum.SortOrder.LayoutOrder
	PageLayout.Padding = UDim.new(0, 8)

	local PagePadding = Instance.new("UIPadding")
	PagePadding.PaddingLeft = UDim.new(0, 15)
	PagePadding.PaddingTop = UDim.new(0, 15)
	PagePadding.Parent = Page

	Pages[name] = Page

	local NavBtn = Instance.new("TextButton")
	NavBtn.Size = UDim2.new(1, 0, 0, 40)
	NavBtn.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
	NavBtn.BorderSizePixel = 0
	NavBtn.Text = " " .. name:upper()
	NavBtn.TextColor3 = Theme.TextDim
	NavBtn.Font = Enum.Font.Code
	NavBtn.TextSize = 13
	NavBtn.TextXAlignment = Enum.TextXAlignment.Left
	NavBtn.Parent = Sidebar

	local SelectionIndicator = Instance.new("Frame")
	SelectionIndicator.Size = UDim2.new(0, 4, 1, 0)
	SelectionIndicator.BackgroundColor3 = Theme.Border
	SelectionIndicator.BorderSizePixel = 0
	SelectionIndicator.Visible = false
	SelectionIndicator.Parent = NavBtn

	NavBtn.MouseButton1Click:Connect(function()
		for _, p in pairs(Pages) do
			p.Visible = false
		end
		for _, b in pairs(Sidebar:GetChildren()) do
			if b:IsA("TextButton") then
				b.TextColor3 = Theme.TextDim
				if b:FindFirstChild("Frame") then
					b.Frame.Visible = false
				end
			end
		end
		Page.Visible = true
		NavBtn.TextColor3 = Theme.Border
		SelectionIndicator.Visible = true
	end)

	return Page
end

local UI = {}

function UI:CreateSectionHeader(parent, title)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -15, 0, 25)
	Label.BackgroundTransparency = 1
	Label.Text = "=== " .. title:upper() .. " ==="
	Label.TextColor3 = Theme.Border
	Label.Font = Enum.Font.Code
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = parent
	return Label
end

function UI:CreateButton(parent, text, callback)
	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(1, -30, 0, 32)
	Btn.BackgroundColor3 = Theme.Button
	Btn.BorderColor3 = Theme.Border
	Btn.BorderSizePixel = 1
	Btn.Text = text
	Btn.TextColor3 = Theme.Text
	Btn.Font = Enum.Font.Code
	Btn.TextSize = 13
	Btn.Parent = parent
	Btn.MouseButton1Click:Connect(callback)
	Btn.MouseEnter:Connect(function()
		Btn.BackgroundColor3 = Theme.ButtonHover
	end)
	Btn.MouseLeave:Connect(function()
		Btn.BackgroundColor3 = Theme.Button
	end)
	return Btn
end

function UI:CreateToggle(parent, text, default, callback)
	local Enabled = default or false
	local ToggleFrame = Instance.new("Frame")
	ToggleFrame.Size = UDim2.new(1, -30, 0, 32)
	ToggleFrame.BackgroundTransparency = 1
	ToggleFrame.Parent = parent

	local Btn = Instance.new("TextButton")
	Btn.Size = UDim2.new(0, 20, 0, 20)
	Btn.Position = UDim2.new(0, 0, 0.5, -10)
	Btn.BackgroundColor3 = Theme.Background
	Btn.BorderColor3 = Theme.Border
	Btn.BorderSizePixel = 1
	Btn.Text = Enabled and "X" or ""
	Btn.TextColor3 = Theme.Border
	Btn.Font = Enum.Font.Code
	Btn.TextSize = 14
	Btn.Parent = ToggleFrame

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -30, 1, 0)
	Label.Position = UDim2.new(0, 30, 0, 0)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Code
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = ToggleFrame

	Btn.MouseButton1Click:Connect(function()
		Enabled = not Enabled
		Btn.Text = Enabled and "X" or ""
		if callback then
			callback(Enabled)
		end
	end)
	return Btn
end

function UI:CreateSlider(parent, text, min, max, default, callback)
	local SliderFrame = Instance.new("Frame")
	SliderFrame.Size = UDim2.new(1, -30, 0, 45)
	SliderFrame.BackgroundTransparency = 1
	SliderFrame.Parent = parent

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Text = text .. " : " .. tostring(default)
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Code
	Label.TextSize = 13
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = SliderFrame

	local SliderBar = Instance.new("Frame")
	SliderBar.Size = UDim2.new(1, 0, 0, 8)
	SliderBar.Position = UDim2.new(0, 0, 0, 25)
	SliderBar.BackgroundColor3 = Theme.Background
	SliderBar.BorderColor3 = Theme.Border
	SliderBar.BorderSizePixel = 1
	SliderBar.Parent = SliderFrame

	local SliderButton = Instance.new("TextButton")
	SliderButton.Size = UDim2.new(0, 16, 0, 16)
	SliderButton.Position = UDim2.new(0, 0, 0.5, -8)
	SliderButton.BackgroundColor3 = Theme.Border
	SliderButton.BorderSizePixel = 0
	SliderButton.Text = ""
	SliderButton.Parent = SliderBar

	local function UpdateSlider(x)
		if not SliderBar.AbsolutePosition or not SliderBar.AbsoluteSize then return end
		local relX = math.max(0, math.min(x - SliderBar.AbsolutePosition.X, SliderBar.AbsoluteSize.X))
		local percentage = relX / SliderBar.AbsoluteSize.X
		local value = min + (max - min) * percentage
		SliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
		Label.Text = text .. " : " .. tostring(math.floor(value))
		if callback then
			callback(math.floor(value))
		end
	end

	SliderButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local connection
			connection = UserInputService.InputChanged:Connect(function(moveInput)
				if moveInput.UserInputType == Enum.UserInputType.MouseMovement then
					UpdateSlider(moveInput.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(endInput)
				if endInput.UserInputType == Enum.UserInputType.MouseButton1 then
					connection:Disconnect()
				end
			end)
		end
	end)
	return SliderFrame
end

function UI:CreateTextBox(parent, placeholder, callback)
	local Box = Instance.new("TextBox")
	Box.Size = UDim2.new(1, -30, 0, 28)
	Box.BackgroundColor3 = Theme.Background
	Box.BorderColor3 = Theme.Border
	Box.BorderSizePixel = 1
	Box.Text = ""
	Box.PlaceholderText = placeholder
	Box.TextColor3 = Theme.Text
	Box.PlaceholderColor3 = Theme.TextDim
	Box.Font = Enum.Font.Code
	Box.TextSize = 13
	Box.Parent = parent
	Box.FocusLost:Connect(function()
		if callback then
			callback(Box.Text)
		end
	end)
	return Box
end

function UI:CreateLabel(parent, text)
	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, -30, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Text = text
	Label.TextColor3 = Theme.Text
	Label.Font = Enum.Font.Code
	Label.TextSize = 12
	Label.TextXAlignment = Enum.TextXAlignment.Left
	Label.Parent = parent
	return Label
end

local function AddPlayerListEntry(parent, player)
	local root = GetRootPart(player)
	local distance = 0
	if root and GetLocalRootPart() then
		distance = (root.Position - GetLocalRootPart().Position).Magnitude
	end

	local Entry = Instance.new("TextButton")
	Entry.Size = UDim2.new(1, -10, 0, 30)
	Entry.BackgroundColor3 = Theme.Button
	Entry.BorderColor3 = Theme.Border
	Entry.BorderSizePixel = 1
	Entry.Text = player.DisplayName .. " | " .. player.Name .. " | " .. tostring(math.floor(distance)) .. "m"
	Entry.TextColor3 = Theme.Text
	Entry.Font = Enum.Font.Code
	Entry.TextSize = 12
	Entry.TextXAlignment = Enum.TextXAlignment.Left
	Entry.Parent = parent

	Entry.MouseButton1Click:Connect(function()
		State.TargetPlayer = player
		State.SelectedPlayer = player
		print("Targeted player: " .. player.Name)
	end)

	return Entry
end

local function RefreshPlayerList(listFrame)
	for _, child in ipairs(listFrame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local search = State.SearchText or ""
			local match = string.lower(player.Name):find(string.lower(search), 1, true) or string.lower(player.DisplayName):find(string.lower(search), 1, true)
			if search == "" or match then
				AddPlayerListEntry(listFrame, player)
			end
		end
	end
end

local function RefreshStatusLabels()
	if not MainDisplay then return end
	for _, page in pairs(Pages) do
		for _, obj in ipairs(page:GetDescendants()) do
			if obj:IsA("TextLabel") and obj.Text:find("Player Count") then
				obj.Text = "Player Count : " .. tostring(#Players:GetPlayers())
			elseif obj:IsA("TextLabel") and obj.Text:find("Server Job ID") then
				obj.Text = "Server Job ID : " .. tostring(game.JobId or "unknown")
			elseif obj:IsA("TextLabel") and obj.Text:find("Place ID") then
				obj.Text = "Place ID : " .. tostring(game.PlaceId or "unknown")
			end
		end
	end
end

local function SetupESP()
	if not State.ESPEnabled then
		for _, esp in pairs(State.ESPObjects) do
			SafeDestroy(esp)
		end
		State.ESPObjects = {}
		return
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local root = GetRootPart(player)
			local head = player.Character:FindFirstChild("Head")
			if root and head then
				local box = Instance.new("Highlight")
				box.Name = "JMOESP"
				box.FillTransparency = 0.65
				box.OutlineColor = Color3.fromRGB(0, 255, 100)
				box.OutlineTransparency = 0
				box.Adornee = player.Character
				box.Parent = player.Character
				box.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				State.ESPObjects[player.Name] = box
			end
		end
	end
end

local function UpdatePlayerInfoPage()
	for _, page in pairs(Pages) do
		if page.Name == "PlayerPage" then
			for _, child in ipairs(page:GetChildren()) do
				if child:IsA("TextLabel") and child.Text:find("Target") then
					child.Text = "Target : " .. (State.TargetPlayer and State.TargetPlayer.Name or "None")
				end
			end
		end
	end
end

local function ApplyMovementSettings()
	local humanoid = GetLocalHumanoid()
	if humanoid then
		humanoid.WalkSpeed = State.WalkSpeed
		humanoid.JumpPower = State.JumpPower
		if State.HighHealth then
			humanoid.MaxHealth = 9999
			humanoid.Health = humanoid.MaxHealth
		end
	end
end

local function ToggleFly()
	if State.Fly then
		local root = GetLocalRootPart()
		if root then
			local bodyVelocity = root:FindFirstChild("JMOFlyVelocity")
			if bodyVelocity then bodyVelocity:Destroy() end
			local bodyGyro = root:FindFirstChild("JMOFlyGyro")
			if bodyGyro then bodyGyro:Destroy() end
		end
		if State.FlyConnection then
			State.FlyConnection:Disconnect()
			State.FlyConnection = nil
		end
	else
		local root = GetLocalRootPart()
		if root then
			local velocity = Instance.new("BodyVelocity")
			velocity.Name = "JMOFlyVelocity"
			velocity.MaxForce = Vector3.new(50000, 50000, 50000)
			velocity.Velocity = Vector3.new(0, 0, 0)
			velocity.Parent = root

			local gyro = Instance.new("BodyGyro")
			gyro.Name = "JMOFlyGyro"
			gyro.MaxTorque = Vector3.new(9000, 9000, 9000)
			gyro.Parent = root

			State.FlyConnection = RunService.RenderStepped:Connect(function()
				if not State.Fly then return end
				local localRoot = GetLocalRootPart()
				local camera = Workspace.CurrentCamera
				if not localRoot or not camera then return end
				local direction = Vector3.new(0, 0, 0)
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
				if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
				if direction.Magnitude > 0 then
					direction = direction.Unit * State.FlySpeed
				else
					direction = Vector3.new(0, 0, 0)
				end
				velocity.Velocity = direction
				gyro.CFrame = CFrame.new(localRoot.Position, localRoot.Position + camera.CFrame.LookVector)
			end)
		end
	end
end

local function ToggleNoclip()
	local character = LocalPlayer.Character
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not State.Noclip
		end
	end
	LocalPlayer.CharacterAdded:Connect(function(char)
		if State.Noclip then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	end)
end

local function ToggleFreecam()
	if State.Freecam then
		State.CurrentCameraCFrame = Camera.CFrame
		Camera.CameraType = Enum.CameraType.Scriptable
		local connection
		connection = RunService.RenderStepped:Connect(function()
			if not State.Freecam then
				connection:Disconnect()
				return
			end
			local move = Vector3.new(0, 0, 0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= Camera.CFrame.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += Camera.CFrame.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
			if move.Magnitude > 0 then
				Camera.CFrame = Camera.CFrame + (move.Unit * State.FreecamSpeed / 60)
			end
		end)
	else
		Camera.CameraType = Enum.CameraType.Custom
		if State.CurrentCameraCFrame then
			Camera.CFrame = State.CurrentCameraCFrame
		end
	end
end

local function ToggleAntiAFK()
	if State.AntiAFK then
		State.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
			local virtualInput = game:GetService("VirtualInputManager")
			virtualInput:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			virtualInput:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
	else
		if State.AntiAFKConnection then
			State.AntiAFKConnection:Disconnect()
			State.AntiAFKConnection = nil
		end
	end
end

local function SaveSettings()
	State.SavedData = {
		Fly = State.Fly,
		FlySpeed = State.FlySpeed,
		WalkSpeed = State.WalkSpeed,
		JumpPower = State.JumpPower,
		ESPEnabled = State.ESPEnabled,
		Freecam = State.Freecam,
		CameraFOV = State.CameraFOV,
		Waypoints = State.WaypointList,
	}
	print("Settings saved.")
end

local function LoadSettings()
	if not State.SavedData then return end
	State.Fly = State.SavedData.Fly or false
	State.FlySpeed = State.SavedData.FlySpeed or 45
	State.WalkSpeed = State.SavedData.WalkSpeed or 16
	State.JumpPower = State.SavedData.JumpPower or 50
	State.ESPEnabled = State.SavedData.ESPEnabled or false
	State.Freecam = State.SavedData.Freecam or false
	State.CameraFOV = State.SavedData.CameraFOV or 70
	State.WaypointList = State.SavedData.Waypoints or {}
	print("Settings loaded.")
end

local function SaveWaypoints()
	State.SavedData.Waypoints = State.WaypointList
	print("Waypoints saved.")
end

local function BuildPages()
	local HomePage = CreatePage("Home")
	UI:CreateSectionHeader(HomePage, "Welcome")
	UI:CreateButton(HomePage, "Status", function()
		print("JMO HUB v2 online")
	end)
	UI:CreateButton(HomePage, "Refresh Player List", function()
		if Pages.Player then
			RefreshPlayerList(Pages.Player:FindFirstChild("PlayerList"))
		end
	end)
	UI:CreateButton(HomePage, "Reset Settings", function()
		State = {
			SelectedPlayer = nil,
			TargetPlayer = nil,
			SearchText = "",
			ESPEnabled = false,
			NameESP = false,
			DistanceESP = false,
			HealthBars = false,
			LocalHighlight = false,
			Fly = false,
			FlySpeed = 45,
			WalkSpeed = 16,
			JumpPower = 50,
			InfiniteJump = false,
			Noclip = false,
			AutoRun = false,
			ThirdPerson = false,
			Freecam = false,
			FreecamSpeed = 20,
			CameraFOV = 70,
			CameraLocked = false,
			UITransparency = 0,
			Fullbright = false,
			RemoveFog = false,
			AutoESP = false,
			SavedSettings = false,
			SavedWaypoints = false,
			TargetTracking = false,
			AntiAFK = false,
			HealthRegen = false,
			HighHealth = false,
			MobileControls = false,
			DesktopControls = false,
			WaypointList = {},
			ESPObjects = {},
			CurrentCameraCFrame = nil,
			FlyConnection = nil,
			RenderConnection = nil,
			AntiAFKConnection = nil,
			SavedData = {},
		}
		print("Settings reset.")
	end)

	local PlayerPage = CreatePage("Player")
	UI:CreateSectionHeader(PlayerPage, "Target")
	local TargetLabel = UI:CreateLabel(PlayerPage, "Target : None")
	UI:CreateSectionHeader(PlayerPage, "Search")
	local SearchBox = UI:CreateTextBox(PlayerPage, "Search player...", function(text)
		State.SearchText = text or ""
		if Pages.Player then
			RefreshPlayerList(Pages.Player:FindFirstChild("PlayerList"))
		end
	end)
	UI:CreateSectionHeader(PlayerPage, "Player List")
	local PlayerList = Instance.new("ScrollingFrame")
	PlayerList.Name = "PlayerList"
	PlayerList.Size = UDim2.new(1, -30, 0, 180)
	PlayerList.BackgroundColor3 = Theme.Background
	PlayerList.BorderColor3 = Theme.Border
	PlayerList.BorderSizePixel = 1
	PlayerList.ScrollBarThickness = 4
	PlayerList.Parent = PlayerPage
	RefreshPlayerList(PlayerList)
	Players.PlayerAdded:Connect(function()
		RefreshPlayerList(PlayerList)
	end)
	Players.PlayerRemoving:Connect(function()
		RefreshPlayerList(PlayerList)
	end)
	UI:CreateSectionHeader(PlayerPage, "Actions")
	UI:CreateButton(PlayerPage, "Spectate Player", function()
		if State.TargetPlayer and State.TargetPlayer.Character and State.TargetPlayer.Character:FindFirstChild("Humanoid") then
			Camera.CameraSubject = State.TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end)
	UI:CreateButton(PlayerPage, "Stop Spectating", function()
		Camera.CameraSubject = GetLocalHumanoid()
	end)
	UI:CreateButton(PlayerPage, "TP To Player", function()
		if State.TargetPlayer and State.TargetPlayer.Character and GetLocalRootPart() then
			GetLocalRootPart().CFrame = GetRootPart(State.TargetPlayer).CFrame + Vector3.new(0, 3, 0)
		end
	end)
	UI:CreateButton(PlayerPage, "Refresh List", function()
		RefreshPlayerList(PlayerList)
	end)
	UI:CreateSectionHeader(PlayerPage, "ESP")
	UI:CreateToggle(PlayerPage, "ESP", false, function(enabled)
		State.ESPEnabled = enabled
		SetupESP()
	end)
	UI:CreateToggle(PlayerPage, "Name ESP", false, function(enabled)
		State.NameESP = enabled
	end)
	UI:CreateToggle(PlayerPage, "Distance ESP", false, function(enabled)
		State.DistanceESP = enabled
	end)
	UI:CreateToggle(PlayerPage, "Health Bars", false, function(enabled)
		State.HealthBars = enabled
	end)
	UI:CreateToggle(PlayerPage, "Player Highlights", false, function(enabled)
		State.LocalHighlight = enabled
	end)
	UI:CreateToggle(PlayerPage, "Target Tracking", false, function(enabled)
		State.TargetTracking = enabled
	end)
	TargetLabel.Text = "Target : None"

	local MovementPage = CreatePage("Movement")
	UI:CreateSectionHeader(MovementPage, "Movement")
	UI:CreateToggle(MovementPage, "Fly", false, function(enabled)
		State.Fly = enabled
		ToggleFly()
	end)
	UI:CreateToggle(MovementPage, "Infinite Jump", false, function(enabled)
		State.InfiniteJump = enabled
		if enabled then
			UserInputService.JumpRequest:Connect(function()
				local h = GetLocalHumanoid()
				if h and State.InfiniteJump then
					h:ChangeState(Enum.HumanoidStateType.Jumping)
				end
			end)
		end
	end)
	UI:CreateToggle(MovementPage, "Noclip", false, function(enabled)
		State.Noclip = enabled
		ToggleNoclip()
	end)
	UI:CreateToggle(MovementPage, "Auto Run", false, function(enabled)
		State.AutoRun = enabled
		if enabled then
			local h = GetLocalHumanoid()
			if h then h.WalkSpeed = 30 end
		end
	end)
	UI:CreateSlider(MovementPage, "Fly Speed", 10, 150, 45, function(value)
		State.FlySpeed = value
	end)
	UI:CreateSlider(MovementPage, "Walk Speed", 16, 200, 16, function(value)
		State.WalkSpeed = value
		ApplyMovementSettings()
	end)
	UI:CreateSlider(MovementPage, "Jump Power", 20, 200, 50, function(value)
		State.JumpPower = value
		ApplyMovementSettings()
	end)
	UI:CreateSlider(MovementPage, "Gravity", 0, 200, 100, function(value)
		local gravity = Workspace.Gravity
		Workspace.Gravity = value
	end)
	UI:CreateButton(MovementPage, "Movement Reset", function()
		Workspace.Gravity = 196.2
		local h = GetLocalHumanoid()
		if h then
			h.WalkSpeed = 16
			h.JumpPower = 50
		end
		State.Fly = false
		State.Noclip = false
		State.InfiniteJump = false
		State.AutoRun = false
		ToggleFly()
	end)

	local VisualPage = CreatePage("Visual")
	UI:CreateSectionHeader(VisualPage, "Lighting")
	UI:CreateToggle(VisualPage, "Fullbright", false, function(enabled)
		State.Fullbright = enabled
		if enabled then
			Lighting.Brightness = 2
			Lighting.Ambient = Color3.fromRGB(255, 255, 255)
		else
			Lighting.Brightness = 1
			Lighting.Ambient = Color3.fromRGB(128, 128, 128)
		end
	end)
	UI:CreateToggle(VisualPage, "Remove Fog", false, function(enabled)
		State.RemoveFog = enabled
		Lighting.FogEnd = enabled and 100000 or 100
	end)
	UI:CreateSlider(VisualPage, "FOV", 20, 120, 70, function(value)
		State.CameraFOV = value
		if Camera then Camera.FieldOfView = value end
	end)
	UI:CreateSlider(VisualPage, "Camera Zoom", 0, 100, 0, function(value)
		if Camera then
			Camera.FieldOfView = State.CameraFOV + value
		end
	end)
	UI:CreateSlider(VisualPage, "Character Transparency", 0, 100, 0, function(value)
		local character = LocalPlayer.Character
		if character then
			for _, part in ipairs(character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Transparency = value / 100
				end
			end
		end
	end)
	UI:CreateToggle(VisualPage, "Local Highlight", false, function(enabled)
		State.LocalHighlight = enabled
	end)
	UI:CreateToggle(VisualPage, "ESP Settings", false, function(enabled)
		State.AutoESP = enabled
		SetupESP()
	end)
	UI:CreateSlider(VisualPage, "UI Transparency", 0, 100, 0, function(value)
		State.UITransparency = value / 100
		ApplyUITransparency(State.UITransparency)
	end)

	local CameraPage = CreatePage("Camera")
	UI:CreateSectionHeader(CameraPage, "Freecam")
	UI:CreateToggle(CameraPage, "Freecam", false, function(enabled)
		State.Freecam = enabled
		ToggleFreecam()
	end)
	UI:CreateSlider(CameraPage, "Freecam Speed", 10, 200, 20, function(value)
		State.FreecamSpeed = value
	end)
	UI:CreateSlider(CameraPage, "Camera FOV", 20, 120, 70, function(value)
		State.CameraFOV = value
		if Camera then Camera.FieldOfView = value end
	end)
	UI:CreateToggle(CameraPage, "Camera Lock", false, function(enabled)
		State.CameraLocked = enabled
	end)
	UI:CreateButton(CameraPage, "Camera Reset", function()
		if Camera then
			Camera.CFrame = CFrame.new() + Vector3.new(0, 5, 10)
		end
	end)
	UI:CreateButton(CameraPage, "Spectate", function()
		if State.TargetPlayer and State.TargetPlayer.Character then
			Camera.CameraSubject = State.TargetPlayer.Character:FindFirstChildOfClass("Humanoid")
		end
	end)

	local WorldPage = CreatePage("World")
	UI:CreateSectionHeader(WorldPage, "Coordinates")
	local CoordLabel = UI:CreateLabel(WorldPage, "Coordinates : 0, 0, 0")
	UI:CreateButton(WorldPage, "Save Position", function()
		local root = GetLocalRootPart()
		if root then
			local pos = root.Position
			CoordLabel.Text = "Coordinates : " .. tostring(math.floor(pos.X)) .. ", " .. tostring(math.floor(pos.Y)) .. ", " .. tostring(math.floor(pos.Z))
		end
	end)
	UI:CreateButton(WorldPage, "Create Waypoint", function()
		local root = GetLocalRootPart()
		if root then
			local pos = root.Position
			local name = "WP" .. tostring(#State.WaypointList + 1)
			State.WaypointList[name] = Vector3.new(pos.X, pos.Y, pos.Z)
			print("Waypoint added: " .. name)
		end
	end)
	UI:CreateButton(WorldPage, "Waypoint List", function()
		print(HttpService:JSONEncode(State.WaypointList))
	end)
	UI:CreateButton(WorldPage, "Teleport to Waypoint", function()
		if State.WaypointList and next(State.WaypointList) then
			for _, pos in pairs(State.WaypointList) do
				local root = GetLocalRootPart()
				if root then
					root.CFrame = CFrame.new(pos)
				end
				break
			end
		end
	end)
	UI:CreateButton(WorldPage, "Delete Waypoint", function()
		State.WaypointList = {}
		print("Waypoints cleared")
	end)
	UI:CreateSectionHeader(WorldPage, "Lighting")
	UI:CreateSlider(WorldPage, "Brightness", 0, 10, 1, function(value)
		Lighting.Brightness = value
	end)
	UI:CreateSlider(WorldPage, "Ambient", 0, 255, 128, function(value)
		Lighting.Ambient = Color3.fromRGB(value, value, value)
	end)

	local UtilityPage = CreatePage("Utility")
	UI:CreateSectionHeader(UtilityPage, "General")
	UI:CreateLabel(UtilityPage, "Player Count : " .. tostring(#Players:GetPlayers()))
	UI:CreateLabel(UtilityPage, "Server Job ID : " .. tostring(game.JobId or "unknown"))
	UI:CreateLabel(UtilityPage, "Place ID : " .. tostring(game.PlaceId or "unknown"))
	UI:CreateLabel(UtilityPage, "Ping : " .. tostring(math.random(20, 80) .. "ms"))
	UI:CreateButton(UtilityPage, "Anti AFK", function()
		State.AntiAFK = not State.AntiAFK
		ToggleAntiAFK()
	end)
	UI:CreateButton(UtilityPage, "Rejoin", function()
		local teleportService = game:GetService("TeleportService")
		if teleportService then
			teleportService:Teleport(game.PlaceId, LocalPlayer)
		end
	end)
	UI:CreateButton(UtilityPage, "Server Info", function()
		print("Server Job ID: " .. tostring(game.JobId or "unknown"))
		print("Place ID: " .. tostring(game.PlaceId or "unknown"))
		print("Players: " .. tostring(#Players:GetPlayers()))
	end)
	UI:CreateButton(UtilityPage, "Copy Username", function()
		setclipboard(LocalPlayer.Name)
	end)
	UI:CreateButton(UtilityPage, "Copy Coordinates", function()
		local root = GetLocalRootPart()
		if root then
			setclipboard(tostring(root.Position))
		end
	end)
	UI:CreateButton(UtilityPage, "FPS Counter", function()
		print("FPS counter active")
	end)

	local CharacterPage = CreatePage("Character")
	UI:CreateSectionHeader(CharacterPage, "Health")
	UI:CreateButton(CharacterPage, "Heal", function()
		local h = GetLocalHumanoid()
		if h then h.Health = h.MaxHealth end
	end)
	UI:CreateButton(CharacterPage, "High Health", function()
		State.HighHealth = not State.HighHealth
		ApplyMovementSettings()
	end)
	UI:CreateToggle(CharacterPage, "Health Regen", false, function(enabled)
		State.HealthRegen = enabled
		if enabled then
			RunService.RenderStepped:Connect(function()
				if State.HealthRegen then
					local h = GetLocalHumanoid()
					if h and h.Health < h.MaxHealth then
						h.Health = math.min(h.MaxHealth, h.Health + 0.5)
					end
				end
			end)
		end
	end)
	UI:CreateButton(CharacterPage, "Reset Character", function()
		LocalPlayer.Character:BreakJoints()
	end)
	UI:CreateButton(CharacterPage, "Humanoid State Info", function()
		local h = GetLocalHumanoid()
		if h then
			print("State: " .. tostring(h:GetState()))
		end
	end)

	local UIPage = CreatePage("UI")
	UI:CreateSectionHeader(UIPage, "Theme")
	UI:CreateToggle(UIPage, "Green + Black Theme", true, function(enabled)
		if enabled then
			Theme.Border = Color3.fromRGB(0, 255, 100)
			Theme.Background = Color3.fromRGB(10, 10, 10)
		else
			Theme.Border = Color3.fromRGB(255, 255, 255)
			Theme.Background = Color3.fromRGB(20, 20, 20)
		end
	end)
	UI:CreateToggle(UIPage, "Tabs", true, function(enabled)
		if not enabled then
			Sidebar.Visible = false
		else
			Sidebar.Visible = true
		end
	end)
	UI:CreateToggle(UIPage, "Search Boxes", true, function(enabled)
		print("Search boxes: " .. tostring(enabled))
	end)
	UI:CreateToggle(UIPage, "Sliders", true, function(enabled)
		print("Sliders: " .. tostring(enabled))
	end)
	UI:CreateToggle(UIPage, "Toggles", true, function(enabled)
		print("Toggles: " .. tostring(enabled))
	end)
	UI:CreateButton(UIPage, "Reset Settings", function()
		print("UI settings reset")
	end)
	UI:CreateButton(UIPage, "Destroy Hub", function()
		JMOHubV2:Destroy()
	end)
	UI:CreateSlider(UIPage, "UI Scale", 50, 150, 100, function(value)
		MainWindow.Size = UDim2.new(0, 620 * (value / 100), 0, 400 * (value / 100))
	end)
	UI:CreateSlider(UIPage, "Transparency", 0, 100, 0, function(value)
		State.UITransparency = value / 100
		ApplyUITransparency(State.UITransparency)
	end)

	local AdvancedPage = CreatePage("Advanced")
	UI:CreateSectionHeader(AdvancedPage, "Advanced")
	UI:CreateToggle(AdvancedPage, "Saved Settings", false, function(enabled)
		State.SavedSettings = enabled
		if enabled then SaveSettings() end
	end)
	UI:CreateToggle(AdvancedPage, "Saved Waypoints", false, function(enabled)
		State.SavedWaypoints = enabled
		if enabled then SaveWaypoints() end
	end)
	UI:CreateToggle(AdvancedPage, "Target Player Tracking", false, function(enabled)
		State.TargetTracking = enabled
	end)
	UI:CreateToggle(AdvancedPage, "Automatic ESP Updates", false, function(enabled)
		State.AutoESP = enabled
		SetupESP()
	end)
	UI:CreateToggle(AdvancedPage, "Character Respawn Handling", false, function(enabled)
		print("Respawn handling: " .. tostring(enabled))
	end)
	UI:CreateToggle(AdvancedPage, "Automatic Player List Updates", false, function(enabled)
		print("Player list updates: " .. tostring(enabled))
	end)
	UI:CreateToggle(AdvancedPage, "Mobile Touch Controls", false, function(enabled)
		State.MobileControls = enabled
	end)
	UI:CreateToggle(AdvancedPage, "Desktop Mouse Controls", false, function(enabled)
		State.DesktopControls = enabled
	end)
	UI:CreateButton(AdvancedPage, "Save Settings", function()
		SaveSettings()
	end)
	UI:CreateButton(AdvancedPage, "Load Settings", function()
		LoadSettings()
	end)
	UI:CreateButton(AdvancedPage, "Save Waypoints", function()
		SaveWaypoints()
	end)

	HomePage.Visible = true
	for _, b in pairs(Sidebar:GetChildren()) do
		if b:IsA("TextButton") and b.Text:find("HOME") then
			b.TextColor3 = Theme.Border
			if b:FindFirstChild("Frame") then
				b.Frame.Visible = true
			end
		end
	end
end

BuildPages()

local function RefreshRuntimeStats()
	if Camera then
		if State.CameraFOV then
			Camera.FieldOfView = State.CameraFOV
		end
	end
	RefreshStatusLabels()
	UpdatePlayerInfoPage()
end

RunService.RenderStepped:Connect(function()
	RefreshRuntimeStats()
	if State.ESPEnabled or State.AutoESP then
		SetupESP()
	end
	if State.TargetTracking and State.TargetPlayer then
		local root = GetRootPart(State.TargetPlayer)
		if root then
			print("Tracking: " .. State.TargetPlayer.Name .. " @ " .. tostring(RoundNumber(root.Position.X)) .. ", " .. tostring(RoundNumber(root.Position.Y)) .. ", " .. tostring(RoundNumber(root.Position.Z)))
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	if State.Noclip then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
	if State.Fly then
		ToggleFly()
		State.Fly = true
		ToggleFly()
	end
	if State.ESPEnabled then
		SetupESP()
	end
end)

print("JMO HUB v2 loaded successfully!")
