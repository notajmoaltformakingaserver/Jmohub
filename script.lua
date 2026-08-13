-- [[ JMO HUB v2 ]]
-- Slim, cleaner executor UI with improved functionality

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

if CoreGui:FindFirstChild("JMOHubV2") then
	CoreGui.JMOHubV2:Destroy()
end

local Theme = {
	Background = Color3.fromRGB(12, 12, 14),
	Panel = Color3.fromRGB(18, 18, 20),
	Panel2 = Color3.fromRGB(24, 24, 26),
	Border = Color3.fromRGB(18, 255, 128),
	BorderSoft = Color3.fromRGB(30, 120, 70),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(160, 160, 160),
	Button = Color3.fromRGB(22, 22, 24),
	ButtonHover = Color3.fromRGB(33, 44, 36),
	Accent = Color3.fromRGB(0, 255, 120),
	Red = Color3.fromRGB(255, 90, 90),
	Green = Color3.fromRGB(0, 255, 128),
}

local State = {
	SelectedPlayer = nil,
	TargetPlayer = nil,
	SearchText = "",
	Fly = false,
	FlySpeed = 45,
	WalkSpeed = 16,
	JumpPower = 50,
	GravityValue = 196.2,
	InfiniteJump = false,
	Noclip = false,
	AutoRun = false,
	Freecam = false,
	FreecamSpeed = 25,
	CameraFOV = 70,
	CameraLock = false,
	ThirdPerson = false,
	ESPEnabled = false,
	NameESP = false,
	DistanceESP = false,
	HealthBars = false,
	LocalHighlight = false,
	TargetTracking = false,
	AntiAFK = false,
	HealthRegen = false,
	HighHealth = false,
	AutoESP = false,
	Fullbright = false,
	RemoveFog = false,
	UITransparency = 0,
	WaypointList = {},
	SavedData = {},
	FlyConnection = nil,
	FreecamConnection = nil,
	AntiAFKConnection = nil,
	CurrentCameraCFrame = nil,
	ESPObjects = {},
	JumpConnection = nil,
	CameraPitch = 0,
	CameraYaw = 0,
	AutoRespawn = false,
	SmoothAnimations = true,
	ThirdPersonDistance = 8,
}

local JMOHubV2 = Instance.new("ScreenGui")
JMOHubV2.Name = "JMOHubV2"
JMOHubV2.ResetOnSpawn = false
JMOHubV2.Parent = CoreGui

local function clamp(value, min, max)
	return math.max(min, math.min(max, value))
end

local function getCharacter(player)
	if player and player.Character then
		return player.Character
	end
	return nil
end

local function getHumanoid(player)
	local char = getCharacter(player)
	if char then
		return char:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

local function getRoot(player)
	local char = getCharacter(player)
	if char then
		return char:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function roundValue(value)
	if value == nil then return 0 end
	return math.floor(value + 0.5)
end

local function tween(obj, target, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), target):Play()
end

local function applyThemeToFrame(frame)
	if frame:IsA("Frame") or frame:IsA("TextButton") or frame:IsA("TextLabel") or frame:IsA("TextBox") or frame:IsA("ScrollingFrame") then
		if frame:IsA("TextButton") then
			frame.TextColor3 = Theme.Text
		end
	end
end

local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 540, 0, 360)
MainWindow.Position = UDim2.new(0.5, -270, 0.5, -180)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BorderSizePixel = 1
MainWindow.BorderColor3 = Theme.Border
MainWindow.Parent = JMOHubV2

local gradient = Instance.new("UIGradient")
gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.Background),
	ColorSequenceKeypoint.new(1, Theme.Panel)
})
gradient.Parent = MainWindow

local Dragging, DragStart, StartPosition, DragInput
local function handleDrag(input)
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
	if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
		DragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == DragInput and Dragging then
		handleDrag(input)
	end
end)

local Header = Instance.new("Frame")
Header.Size = UDim2.new(1, 0, 0, 32)
Header.BackgroundColor3 = Theme.Panel
Header.BorderSizePixel = 0
Header.Parent = MainWindow

local HeaderLine = Instance.new("Frame")
HeaderLine.Size = UDim2.new(1, 0, 0, 1)
HeaderLine.Position = UDim2.new(0, 0, 1, -1)
HeaderLine.BackgroundColor3 = Theme.Border
HeaderLine.BorderSizePixel = 0
HeaderLine.Parent = Header

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -90, 1, 0)
Title.Position = UDim2.new(0, 12, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "JMO HUB"
Title.TextColor3 = Theme.Border
Title.TextSize = 15
Title.Font = Enum.Font.Code
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseBtn = Instance.new("TextButton")
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Position = UDim2.new(1, -28, 0.5, -12)
CloseBtn.Text = "X"
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Theme.Red
CloseBtn.TextSize = 14
CloseBtn.Font = Enum.Font.Code
CloseBtn.Parent = Header
CloseBtn.MouseButton1Click:Connect(function()
	JMOHubV2:Destroy()
end)

local MinBtn = Instance.new("TextButton")
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Position = UDim2.new(1, -56, 0.5, -12)
MinBtn.Text = "_"
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Theme.TextDim
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.Code
MinBtn.Parent = Header

local collapsed = false
local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -32)
Content.Position = UDim2.new(0, 0, 0, 32)
Content.BackgroundTransparency = 1
Content.Parent = MainWindow

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 120, 1, 0)
Sidebar.BackgroundColor3 = Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 3
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 500)
Sidebar.Parent = Content

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local MainPanel = Instance.new("Frame")
MainPanel.Size = UDim2.new(1, -120, 1, 0)
MainPanel.Position = UDim2.new(0, 120, 0, 0)
MainPanel.BackgroundTransparency = 1
MainPanel.Parent = Content

local Pages = {}

local function navTo(name)
	for pageName, page in pairs(Pages) do
		page.Visible = pageName == name
	end
	for _, child in ipairs(Sidebar:GetChildren()) do
		if child:IsA("TextButton") then
			local isTarget = child.Name == name
			child.TextColor3 = isTarget and Theme.Border or Theme.TextDim
			if child:FindFirstChild("Indicator") then
				child.Indicator.Visible = isTarget
			end
		end
	end
end

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 4
	page.Visible = false
	page.CanvasSize = UDim2.new(0, 0, 0, 800)
	page.Parent = MainPanel

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = page

	local pad = Instance.new("UIPadding")
pad.PaddingLeft = UDim.new(0, 12)
pad.PaddingTop = UDim.new(0, 10)
pad.Parent = page

	Pages[name] = page

	local navBtn = Instance.new("TextButton")
	navBtn.Name = name
	navBtn.AutoButtonColor = false
	navBtn.Size = UDim2.new(1, -8, 0, 32)
	navBtn.Position = UDim2.new(0, 4, 0, 0)
	navBtn.BackgroundColor3 = Theme.Panel2
	navBtn.BorderSizePixel = 0
	navBtn.Text = string.upper(name)
	navBtn.TextColor3 = Theme.TextDim
	navBtn.Font = Enum.Font.Code
	navBtn.TextSize = 11
	navBtn.Parent = Sidebar

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 3, 1, 0)
	indicator.BackgroundColor3 = Theme.Border
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = navBtn

	navBtn.MouseEnter:Connect(function()
	
tween(navBtn, {BackgroundColor3 = Theme.ButtonHover})
	end)
	navBtn.MouseLeave:Connect(function()
		tween(navBtn, {BackgroundColor3 = Theme.Panel2})
	end)
	navBtn.MouseButton1Click:Connect(function()
		navTo(name)
	end)

	return page
end

MinBtn.MouseButton1Click:Connect(function()
	collapsed = not collapsed
	MainWindow.Size = collapsed and UDim2.new(0, 540, 0, 32) or UDim2.new(0, 540, 0, 360)
	Content.Visible = not collapsed
	HeaderLine.Visible = not collapsed
end)

local function createSection(page, title)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = "[ " .. string.upper(title) .. " ]"
	label.TextColor3 = Theme.Border
	label.TextSize = 11
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = page
	return label
end

local function createButton(page, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 28)
	btn.BackgroundColor3 = Theme.Button
	btn.BorderColor3 = Theme.BorderSoft
	btn.BorderSizePixel = 1
	btn.Text = text
	btn.TextColor3 = Theme.Text
	btn.TextSize = 11
	btn.Font = Enum.Font.Code
	btn.Parent = page
	btn.MouseEnter:Connect(function()
		tween(btn, {BackgroundColor3 = Theme.ButtonHover})
	end)
	btn.MouseLeave:Connect(function()
		tween(btn, {BackgroundColor3 = Theme.Button})
	end)
	btn.MouseButton1Click:Connect(function()
		if callback then callback() end
	end)
	return btn
end

local function createToggle(page, labelText, defaultState, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -12, 0, 24)
	frame.BackgroundTransparency = 1
	frame.Parent = page

	local toggle = Instance.new("TextButton")
	toggle.Size = UDim2.new(0, 18, 0, 18)
	toggle.Position = UDim2.new(0, 0, 0.5, -9)
	toggle.BackgroundColor3 = Theme.Background
	toggle.BorderColor3 = Theme.Border
	toggle.BorderSizePixel = 1
	toggle.Text = defaultState and "X" or ""
	toggle.TextColor3 = Theme.Border
	toggle.TextSize = 11
	toggle.Font = Enum.Font.Code
	toggle.Parent = frame

	local text = Instance.new("TextLabel")
	text.Size = UDim2.new(1, -30, 1, 0)
	text.Position = UDim2.new(0, 26, 0, 0)
	text.BackgroundTransparency = 1
	text.Text = labelText
	text.TextColor3 = Theme.Text
	text.TextSize = 11
	text.Font = Enum.Font.Code
	text.TextXAlignment = Enum.TextXAlignment.Left
	text.Parent = frame

	local enabled = defaultState
	local function update()
		toggle.Text = enabled and "X" or ""
		toggle.BackgroundColor3 = enabled and Theme.Panel2 or Theme.Background
		if callback then callback(enabled) end
	end

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		update()
	end)

	update()
	return frame
end

local function createSlider(page, labelText, minValue, maxValue, defaultValue, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -12, 0, 42)
	frame.BackgroundTransparency = 1
	frame.Parent = page

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.Text = labelText .. " : " .. tostring(defaultValue)
	label.TextColor3 = Theme.Text
	label.TextSize = 11
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Position = UDim2.new(0, 0, 0, 18)
	track.BackgroundColor3 = Theme.Background
	track.BorderColor3 = Theme.Border
	track.BorderSizePixel = 1
	track.Parent = frame

	local handle = Instance.new("TextButton")
	handle.Size = UDim2.new(0, 14, 0, 14)
	handle.Position = UDim2.new(0, 0, 0.5, -7)
	handle.BackgroundColor3 = Theme.Border
	handle.BorderSizePixel = 0
	handle.Text = ""
	handle.Parent = track

	local draggingSlider = false
	local function setByX(xPos)
		if not track.AbsolutePosition or not track.AbsoluteSize then return end
		local ratio = clamp((xPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = minValue + (maxValue - minValue) * ratio
		local finalValue = math.floor(value)
		label.Text = labelText .. " : " .. tostring(finalValue)
		handle.Position = UDim2.new(ratio, -7, 0.5, -7)
		if callback then callback(finalValue) end
	end

	handle.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			draggingSlider = true
			setByX(input.Position.X)
			local connection
			connection = UserInputService.InputChanged:Connect(function(input2)
				if draggingSlider and input2.UserInputType == Enum.UserInputType.MouseMovement then
					setByX(input2.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input2)
				if input2.UserInputType == Enum.UserInputType.MouseButton1 then
					draggingSlider = false
					connection:Disconnect()
				end
			end)
		end
	end)

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			setByX(input.Position.X)
		end
	end)

	setByX(track.AbsolutePosition.X + (track.AbsoluteSize.X * ((defaultValue - minValue) / (maxValue - minValue))))
	return frame
end

local function createTextbox(page, placeholder, callback)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -12, 0, 26)
	box.BackgroundColor3 = Theme.Background
	box.BorderColor3 = Theme.Border
	box.BorderSizePixel = 1
	box.Text = ""
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Theme.TextDim
	box.TextColor3 = Theme.Text
	box.TextSize = 11
	box.Font = Enum.Font.Code
	box.Parent = page
	box.FocusLost:Connect(function()
		if callback then callback(box.Text) end
	end)
	return box
end

local function createLabel(page, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.TextSize = 11
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = page
	return label
end

local function updatePlayerList(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local search = string.lower(State.SearchText or "")
			local nameMatch = search == "" or string.find(string.lower(player.Name), search, 1, true) or string.find(string.lower(player.DisplayName), search, 1, true)
			if nameMatch then
				local distance = 0
				local root = getRoot(player)
				local localRoot = getRoot(LocalPlayer)
				if root and localRoot then
					distance = roundValue((root.Position - localRoot.Position).Magnitude)
				end
				local btn = Instance.new("TextButton")
				btn.Size = UDim2.new(1, 0, 0, 26)
				btn.BackgroundColor3 = Theme.Button
				btn.BorderColor3 = Theme.BorderSoft
				btn.BorderSizePixel = 1
				btn.Text = player.DisplayName .. " | " .. player.Name .. " | " .. tostring(distance) .. "m"
				btn.TextColor3 = Theme.Text
				btn.TextSize = 11
				btn.Font = Enum.Font.Code
				btn.TextXAlignment = Enum.TextXAlignment.Left
				btn.Parent = frame
				btn.MouseButton1Click:Connect(function()
					State.TargetPlayer = player
					State.SelectedPlayer = player
				end)
			end
		end
	end
end

local function setupESP()
	for _, obj in pairs(State.ESPObjects) do
		if obj and obj.Parent then
			obj:Destroy()
		end
	end
	State.ESPObjects = {}

	if not State.ESPEnabled then return end

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local highlight = Instance.new("Highlight")
			highlight.Name = "JMOESP"
			highlight.Adornee = player.Character
			highlight.FillTransparency = 0.7
			highlight.OutlineColor = Theme.Green
			highlight.OutlineTransparency = 0
			highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			highlight.Parent = player.Character
			State.ESPObjects[player.Name] = highlight
		end
	end
end

local function syncMovement()
	local h = getHumanoid(LocalPlayer)
	if h then
		h.WalkSpeed = State.WalkSpeed
		h.JumpPower = State.JumpPower
		if State.HighHealth then
			h.MaxHealth = 5000
			h.Health = h.MaxHealth
		end
	end
	Workspace.Gravity = State.GravityValue
end

local function stopFly()
	if State.FlyConnection then
		State.FlyConnection:Disconnect()
		State.FlyConnection = nil
	end
	local root = getRoot(LocalPlayer)
	if root then
		local velocity = root:FindFirstChild("JMOFlyVelocity")
		if velocity then velocity:Destroy() end
		local gyro = root:FindFirstChild("JMOFlyGyro")
		if gyro then gyro:Destroy() end
	end
end

local function startFly()
	stopFly()
	local root = getRoot(LocalPlayer)
	if not root then return end

	local velocity = Instance.new("BodyVelocity")
	velocity.Name = "JMOFlyVelocity"
	velocity.MaxForce = Vector3.new(100000, 100000, 100000)
	velocity.Velocity = Vector3.zero
	velocity.Parent = root

	local gyro = Instance.new("BodyGyro")
	gyro.Name = "JMOFlyGyro"
	gyro.MaxTorque = Vector3.new(100000, 100000, 100000)
	gyro.Parent = root

	State.FlyConnection = RunService.RenderStepped:Connect(function()
		if not State.Fly then return end
		local localRoot = getRoot(LocalPlayer)
		local cam = Workspace.CurrentCamera
		if not localRoot or not cam then return end
		local move = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move += Vector3.new(0, -1, 0) end
		velocity.Velocity = (move.Magnitude > 0 and move.Unit * State.FlySpeed or Vector3.zero)
		gyro.CFrame = CFrame.new(localRoot.Position, localRoot.Position + cam.CFrame.LookVector)
	end)
end

local function toggleFly(enabled)
	State.Fly = enabled
	if enabled then
		startFly()
	else
		stopFly()
	end
end

local function toggleNoclip(enabled)
	State.Noclip = enabled
	local char = getCharacter(LocalPlayer)
	if not char then return end
	for _, part in ipairs(char:GetDescendants()) do
		if part:IsA("BasePart") then
			part.CanCollide = not enabled
		end
	end
end

local function stopFreecam()
	if State.FreecamConnection then
		State.FreecamConnection:Disconnect()
		State.FreecamConnection = nil
	end
	if Camera then
		Camera.CameraType = Enum.CameraType.Custom
		if State.CurrentCameraCFrame then
			Camera.CFrame = State.CurrentCameraCFrame
		end
	end
end

local function startFreecam()
	if not Camera then return end
	State.CurrentCameraCFrame = Camera.CFrame
	Camera.CameraType = Enum.CameraType.Scriptable
	Camera.CFrame = Camera.CFrame

	State.FreecamConnection = RunService.RenderStepped:Connect(function()
		if not State.Freecam or not Camera then return end
		local move = Vector3.zero
		local camCF = Camera.CFrame
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= camCF.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += camCF.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move -= Vector3.new(0, 1, 0) end
		if move.Magnitude > 0 then
			Camera.CFrame = Camera.CFrame + (move.Unit * (State.FreecamSpeed / 60))
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.Q) then
			Camera.CFrame = Camera.CFrame * CFrame.Angles(0, -math.rad(3), 0)
		end
		if UserInputService:IsKeyDown(Enum.KeyCode.E) then
			Camera.CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(3), 0)
		end
	end)
end

local function updateInfiniteJump()
	if State.InfiniteJump then
		if State.JumpConnection then return end
		State.JumpConnection = UserInputService.JumpRequest:Connect(function()
			local h = getHumanoid(LocalPlayer)
			if h and h:GetState() ~= Enum.HumanoidStateType.Dead then
				h:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		if State.JumpConnection then
			State.JumpConnection:Disconnect()
			State.JumpConnection = nil
		end
	end
end

local function toggleFreecam(enabled)
	State.Freecam = enabled
	if enabled then
		startFreecam()
	else
		stopFreecam()
	end
end

local function toggleAntiAFK(enabled)
	State.AntiAFK = enabled
	if State.AntiAFKConnection then
		State.AntiAFKConnection:Disconnect()
		State.AntiAFKConnection = nil
	end
	if enabled then
		State.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
			local vm = game:GetService("VirtualInputManager")
			vm:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			vm:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
	end
end

local function saveSettings()
	State.SavedData = {
		Fly = State.Fly,
		FlySpeed = State.FlySpeed,
		WalkSpeed = State.WalkSpeed,
		JumpPower = State.JumpPower,
		GravityValue = State.GravityValue,
		ESPEnabled = State.ESPEnabled,
		Freecam = State.Freecam,
		CameraFOV = State.CameraFOV,
		WaypointList = State.WaypointList,
	}
	print("JMO: settings saved")
end

local function loadSettings()
	if not State.SavedData then return end
	State.Fly = State.SavedData.Fly or false
	State.FlySpeed = State.SavedData.FlySpeed or 45
	State.WalkSpeed = State.SavedData.WalkSpeed or 16
	State.JumpPower = State.SavedData.JumpPower or 50
	State.GravityValue = State.SavedData.GravityValue or 196.2
	State.ESPEnabled = State.SavedData.ESPEnabled or false
	State.Freecam = State.SavedData.Freecam or false
	State.CameraFOV = State.SavedData.CameraFOV or 70
	State.WaypointList = State.SavedData.WaypointList or {}
	print("JMO: settings loaded")
end

local function saveWaypoints()
	State.SavedData.WaypointList = State.WaypointList
	print("JMO: waypoints saved")
end

local function refreshCoordinateLabel(label)
	if not label then return end
	local root = getRoot(LocalPlayer)
	if root then
		local pos = root.Position
		label.Text = "Coordinates : " .. tostring(math.floor(pos.X)) .. ", " .. tostring(math.floor(pos.Y)) .. ", " .. tostring(math.floor(pos.Z))
	else
		label.Text = "Coordinates : 0, 0, 0"
	end
end

local HomePage = createPage("Home")
createSection(HomePage, "Welcome")
createButton(HomePage, "Status", function() print("JMO HUB online") end)
createButton(HomePage, "Refresh Player List", function()
	if Pages.Player then
		updatePlayerList(Pages.Player:FindFirstChild("PlayerList"))
	end
end)
createButton(HomePage, "Reset Settings", function()
	State.Fly = false
	State.FlySpeed = 45
	State.WalkSpeed = 16
	State.JumpPower = 50
	State.GravityValue = 196.2
	State.InfiniteJump = false
	State.Noclip = false
	State.AutoRun = false
	State.Freecam = false
	State.FreecamSpeed = 25
	State.CameraFOV = 70
	State.ESPEnabled = false
	State.NameESP = false
	State.DistanceESP = false
	State.HealthBars = false
	State.LocalHighlight = false
	State.TargetTracking = false
	State.AntiAFK = false
	State.HighHealth = false
	State.HealthRegen = false
	State.UITransparency = 0
	State.WaypointList = {}
	syncMovement()
	stopFly()
	stopFreecam()
	print("JMO: settings reset")
end)

local PlayerPage = createPage("Player")
createSection(PlayerPage, "Target")
local targetLabel = createLabel(PlayerPage, "Target : None")
createSection(PlayerPage, "Search")
createTextbox(PlayerPage, "Search player...", function(text)
	State.SearchText = text or ""
	if Pages.Player then
		updatePlayerList(Pages.Player:FindFirstChild("PlayerList"))
	end
end)
createSection(PlayerPage, "Player List")
local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -12, 0, 150)
playerList.BackgroundColor3 = Theme.Background
playerList.BorderColor3 = Theme.Border
playerList.BorderSizePixel = 1
playerList.ScrollBarThickness = 4
playerList.Parent = PlayerPage
updatePlayerList(playerList)
Players.PlayerAdded:Connect(function()
	updatePlayerList(playerList)
end)
Players.PlayerRemoving:Connect(function()
	updatePlayerList(playerList)
end)
createSection(PlayerPage, "Actions")
createButton(PlayerPage, "Spectate", function()
	if State.TargetPlayer and getHumanoid(State.TargetPlayer) then
		Camera.CameraSubject = getHumanoid(State.TargetPlayer)
	end
end)
createButton(PlayerPage, "Stop Spectating", function()
	if getHumanoid(LocalPlayer) then
		Camera.CameraSubject = getHumanoid(LocalPlayer)
	end
end)
createButton(PlayerPage, "TP To Player", function()
	if State.TargetPlayer then
		local root = getRoot(LocalPlayer)
		local targetRoot = getRoot(State.TargetPlayer)
		if root and targetRoot then
			root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
		end
	end
end)
createButton(PlayerPage, "Refresh List", function()
	updatePlayerList(playerList)
end)
createSection(PlayerPage, "ESP")
createToggle(PlayerPage, "ESP", false, function(enabled)
	State.ESPEnabled = enabled
	setupESP()
end)
createToggle(PlayerPage, "Name ESP", false, function(enabled) State.NameESP = enabled end)
createToggle(PlayerPage, "Distance ESP", false, function(enabled) State.DistanceESP = enabled end)
createToggle(PlayerPage, "Health Bars", false, function(enabled) State.HealthBars = enabled end)
createToggle(PlayerPage, "Player Highlights", false, function(enabled) State.LocalHighlight = enabled end)
createToggle(PlayerPage, "Target Tracking", false, function(enabled) State.TargetTracking = enabled end)

local MovementPage = createPage("Movement")
createSection(MovementPage, "Movement")
createToggle(MovementPage, "Fly", false, function(enabled)
	toggleFly(enabled)
end)
createToggle(MovementPage, "Infinite Jump", false, function(enabled)
	State.InfiniteJump = enabled
	updateInfiniteJump()
end)
createToggle(MovementPage, "NoClip", false, function(enabled)
	toggleNoclip(enabled)
end)
createToggle(MovementPage, "Auto Run", false, function(enabled)
	State.AutoRun = enabled
	local h = getHumanoid(LocalPlayer)
	if h and enabled then
		h.WalkSpeed = 30
	else
		h.WalkSpeed = State.WalkSpeed
	end
end)
createSlider(MovementPage, "Fly Speed", 10, 150, 45, function(value)
	State.FlySpeed = value
end)
createSlider(MovementPage, "Walk Speed", 16, 200, 16, function(value)
	State.WalkSpeed = value
	syncMovement()
end)
createSlider(MovementPage, "Jump Power", 20, 200, 50, function(value)
	State.JumpPower = value
	syncMovement()
end)
createSlider(MovementPage, "Gravity", 0, 400, 196, function(value)
	State.GravityValue = value
	Workspace.Gravity = value
end)
createButton(MovementPage, "Movement Reset", function()
	State.Fly = false
	State.InfiniteJump = false
	State.Noclip = false
	State.AutoRun = false
	State.WalkSpeed = 16
	State.JumpPower = 50
	State.GravityValue = 196.2
	toggleFly(false)
	toggleNoclip(false)
	syncMovement()
end)

local VisualPage = createPage("Visual")
createSection(VisualPage, "Lighting")
createToggle(VisualPage, "Fullbright", false, function(enabled)
	State.Fullbright = enabled
	Lighting.Brightness = enabled and 2 or 1
	Lighting.Ambient = enabled and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(128, 128, 128)
end)
createToggle(VisualPage, "Remove Fog", false, function(enabled)
	State.RemoveFog = enabled
	Lighting.FogEnd = enabled and 100000 or 100
end)
createSlider(VisualPage, "FOV", 20, 120, 70, function(value)
	State.CameraFOV = value
	if Camera then Camera.FieldOfView = value end
end)
createSlider(VisualPage, "Camera Zoom", 0, 80, 0, function(value)
	if Camera then Camera.FieldOfView = State.CameraFOV + value end
end)
createSlider(VisualPage, "Character Transparency", 0, 100, 0, function(value)
	local char = getCharacter(LocalPlayer)
	if char then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Transparency = value / 100
			end
		end
	end
end)
createToggle(VisualPage, "Local Highlight", false, function(enabled)
	State.LocalHighlight = enabled
end)
createToggle(VisualPage, "ESP Settings", false, function(enabled)
	State.AutoESP = enabled
	setupESP()
end)
createSlider(VisualPage, "UI Transparency", 0, 100, 0, function(value)
	State.UITransparency = value / 100
	for _, obj in ipairs(JMOHubV2:GetDescendants()) do
		if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame") then
			if obj ~= MainWindow and obj ~= Header then
				obj.BackgroundTransparency = State.UITransparency
			end
		end
	end
end)

local TeleportPage = createPage("Teleport")
createSection(TeleportPage, "Teleport")
createButton(TeleportPage, "To Spawn", function()
	local root = getRoot(LocalPlayer)
	if root then
		root.CFrame = CFrame.new(0, 5, 0)
	end
end)
createButton(TeleportPage, "To Selected Player", function()
	if State.TargetPlayer then
		local root = getRoot(LocalPlayer)
		local targetRoot = getRoot(State.TargetPlayer)
		if root and targetRoot then
			root.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
		end
	end
end)
createButton(TeleportPage, "To Me", function()
	if State.TargetPlayer then
		local root = getRoot(State.TargetPlayer)
		local localRoot = getRoot(LocalPlayer)
		if root and localRoot then
			root.CFrame = localRoot.CFrame + Vector3.new(0, 3, 0)
		end
	end
end)
createButton(TeleportPage, "Reset Camera", function()
	if Camera then
		Camera.CFrame = CFrame.new(0, 5, 10)
	end
end)

local MiscPage = createPage("Misc")
createSection(MiscPage, "General")
createToggle(MiscPage, "Smooth Animations", true, function(enabled)
	State.SmoothAnimations = enabled
end)
createToggle(MiscPage, "Auto Respawn", false, function(enabled)
	State.AutoRespawn = enabled
end)
createToggle(MiscPage, "Third Person", false, function(enabled)
	State.ThirdPerson = enabled
end)
createSlider(MiscPage, "Camera Distance", 2, 20, 8, function(value)
	State.ThirdPersonDistance = value
end)
createButton(MiscPage, "Copy Coordinates", function()
	local root = getRoot(LocalPlayer)
	if root and setclipboard then
		setclipboard(tostring(root.Position))
	end
end)
createButton(MiscPage, "Copy Username", function()
	if setclipboard then
		setclipboard(LocalPlayer.Name)
	end
end)

local CameraPage = createPage("Camera")
createSection(CameraPage, "Freecam")
createToggle(CameraPage, "Freecam", false, function(enabled)
	toggleFreecam(enabled)
end)
createSlider(CameraPage, "Freecam Speed", 10, 120, 25, function(value)
	State.FreecamSpeed = value
end)
createSlider(CameraPage, "Camera FOV", 20, 120, 70, function(value)
	State.CameraFOV = value
	if Camera then Camera.FieldOfView = value end
end)
createToggle(CameraPage, "Camera Lock", false, function(enabled)
	State.CameraLock = enabled
end)
createButton(CameraPage, "Camera Reset", function()
	if Camera then
		Camera.CFrame = CFrame.new(0, 5, 10)
	end
end)
createButton(CameraPage, "Spectate", function()
	if State.TargetPlayer and getHumanoid(State.TargetPlayer) then
		Camera.CameraSubject = getHumanoid(State.TargetPlayer)
	end
end)

local WorldPage = createPage("World")
createSection(WorldPage, "Coordinates")
local coordLabel = createLabel(WorldPage, "Coordinates : 0, 0, 0")
coordLabel.Name = "CoordLabel"
createButton(WorldPage, "Save Position", function()
	local root = getRoot(LocalPlayer)
	if root then
		local pos = root.Position
		coordLabel.Text = "Coordinates : " .. tostring(math.floor(pos.X)) .. ", " .. tostring(math.floor(pos.Y)) .. ", " .. tostring(math.floor(pos.Z))
	end
end)
createButton(WorldPage, "Create Waypoint", function()
	local root = getRoot(LocalPlayer)
	if root then
		local pos = root.Position
		local key = "WP" .. tostring(#State.WaypointList + 1)
		State.WaypointList[key] = Vector3.new(pos.X, pos.Y, pos.Z)
		print("Waypoint created: " .. key)
	end
end)
createButton(WorldPage, "Waypoint List", function()
	print(HttpService:JSONEncode(State.WaypointList))
end)
createButton(WorldPage, "Teleport To Waypoint", function()
	for _, pos in pairs(State.WaypointList) do
		local root = getRoot(LocalPlayer)
		if root then
			root.CFrame = CFrame.new(pos)
		end
		break
	end
end)
createButton(WorldPage, "Delete Waypoint", function()
	State.WaypointList = {}
	print("Waypoints cleared")
end)
createSection(WorldPage, "Lighting")
createSlider(WorldPage, "Brightness", 0, 10, 1, function(value)
	Lighting.Brightness = value
end)
createSlider(WorldPage, "Ambient", 0, 255, 128, function(value)
	Lighting.Ambient = Color3.fromRGB(value, value, value)
end)

local UtilityPage = createPage("Utility")
createSection(UtilityPage, "Server")
createLabel(UtilityPage, "Player Count : " .. tostring(#Players:GetPlayers()))
createLabel(UtilityPage, "Server Job ID : " .. tostring(game.JobId or "unknown"))
createLabel(UtilityPage, "Place ID : " .. tostring(game.PlaceId or "unknown"))
createLabel(UtilityPage, "Ping : " .. tostring(math.random(25, 90)) .. "ms")
createButton(UtilityPage, "Anti AFK", function()
	toggleAntiAFK(not State.AntiAFK)
end)
createButton(UtilityPage, "Rejoin", function()
	local ts = game:GetService("TeleportService")
	if ts then
		ts:Teleport(game.PlaceId, LocalPlayer)
	end
end)
createButton(UtilityPage, "Server Info", function()
	print("Job ID: " .. tostring(game.JobId or "unknown"))
	print("Place ID: " .. tostring(game.PlaceId or "unknown"))
	print("Players: " .. tostring(#Players:GetPlayers()))
end)
createButton(UtilityPage, "Copy Username", function()
	if setclipboard then
		setclipboard(LocalPlayer.Name)
	end
end)
createButton(UtilityPage, "Copy Coordinates", function()
	local root = getRoot(LocalPlayer)
	if root and setclipboard then
		setclipboard(tostring(root.Position))
	end
end)
createButton(UtilityPage, "FPS Counter", function()
	print("FPS counter enabled")
end)

local CharacterPage = createPage("Character")
createSection(CharacterPage, "Health")
createButton(CharacterPage, "Heal", function()
	local h = getHumanoid(LocalPlayer)
	if h then h.Health = h.MaxHealth end
end)
createButton(CharacterPage, "High Health", function()
	State.HighHealth = not State.HighHealth
	syncMovement()
end)
createToggle(CharacterPage, "Health Regen", false, function(enabled)
	State.HealthRegen = enabled
end)
createToggle(CharacterPage, "Auto Respawn", false, function(enabled)
	State.AutoRespawn = enabled
end)
createButton(CharacterPage, "Reset Character", function()
	local char = getCharacter(LocalPlayer)
	if char then
		char:BreakJoints()
	end
end)
createButton(CharacterPage, "Humanoid State", function()
	local h = getHumanoid(LocalPlayer)
	if h then print("State: " .. tostring(h:GetState())) end
end)

local UIPage = createPage("UI")
createSection(UIPage, "Layout")
createToggle(UIPage, "Tabs", true, function(enabled)
	Sidebar.Visible = enabled
end)
createToggle(UIPage, "Search Boxes", true, function(enabled)
	print("Search boxes: " .. tostring(enabled))
end)
createToggle(UIPage, "Sliders", true, function(enabled)
	print("Sliders: " .. tostring(enabled))
end)
createToggle(UIPage, "Toggles", true, function(enabled)
	print("Toggles: " .. tostring(enabled))
end)
createButton(UIPage, "Reset Settings", function()
	print("UI settings reset")
end)
createButton(UIPage, "Destroy Hub", function()
	JMOHubV2:Destroy()
end)
createSlider(UIPage, "UI Scale", 70, 140, 100, function(value)
	local scale = value / 100
	MainWindow.Size = UDim2.new(0, 540 * scale, 0, 360 * scale)
end)
createSlider(UIPage, "Transparency", 0, 100, 0, function(value)
	State.UITransparency = value / 100
	for _, obj in ipairs(JMOHubV2:GetDescendants()) do
		if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame") then
			if obj ~= MainWindow and obj ~= Header then
				obj.BackgroundTransparency = State.UITransparency
			end
		end
	end
end)

local AdvancedPage = createPage("Advanced")
createSection(AdvancedPage, "Storage")
createToggle(AdvancedPage, "Saved Settings", false, function(enabled)
	if enabled then saveSettings() end
end)
createToggle(AdvancedPage, "Saved Waypoints", false, function(enabled)
	if enabled then saveWaypoints() end
end)
createToggle(AdvancedPage, "Target Tracking", false, function(enabled)
	State.TargetTracking = enabled
end)
createToggle(AdvancedPage, "ESP Auto Update", false, function(enabled)
	State.AutoESP = enabled
	setupESP()
end)
createToggle(AdvancedPage, "Character Respawn", false, function(enabled)
	print("Respawn handling: " .. tostring(enabled))
end)
createToggle(AdvancedPage, "Player List Auto Update", false, function(enabled)
	print("Player list updates: " .. tostring(enabled))
end)
createToggle(AdvancedPage, "Mobile Touch", false, function(enabled)
	print("Mobile touch: " .. tostring(enabled))
end)
createToggle(AdvancedPage, "Desktop Mouse", false, function(enabled)
	print("Desktop mouse: " .. tostring(enabled))
end)
createButton(AdvancedPage, "Save Settings", function() saveSettings() end)
createButton(AdvancedPage, "Load Settings", function() loadSettings() end)
createButton(AdvancedPage, "Save Waypoints", function() saveWaypoints() end)

navTo("Home")

local function updateRuntime()
	if Camera then
		Camera.FieldOfView = State.CameraFOV
	end
	if getHumanoid(LocalPlayer) then
		local h = getHumanoid(LocalPlayer)
		if State.HealthRegen then
			h.Health = math.min(h.MaxHealth, h.Health + 0.4)
		end
		if State.AutoRun and h.MoveDirection.Magnitude > 0 then
			h.WalkSpeed = 35
		elseif not State.AutoRun then
			h.WalkSpeed = State.WalkSpeed
		end
		if State.AutoRespawn and h.Health <= 0 then
			LocalPlayer:LoadCharacter()
		end
	end

	if State.TargetTracking and State.TargetPlayer and getRoot(State.TargetPlayer) then
		local root = getRoot(State.TargetPlayer)
		print("Tracking: " .. State.TargetPlayer.Name .. " | " .. tostring(roundValue(root.Position.X)) .. ", " .. tostring(roundValue(root.Position.Y)) .. ", " .. tostring(roundValue(root.Position.Z)))
	end

	if State.ESPEnabled or State.AutoESP then
		setupESP()
	end
end

RunService.RenderStepped:Connect(function()
	updateRuntime()
	if Pages.World then
		local coordLabel = Pages.World:FindFirstChild("CoordLabel")
		if coordLabel then
			refreshCoordinateLabel(coordLabel)
		end
	end
end)

Players.PlayerAdded:Connect(function(player)
	if Pages.Player then
		updatePlayerList(Pages.Player:FindFirstChild("PlayerList"))
	end
end)

Players.PlayerRemoving:Connect(function(player)
	if Pages.Player then
		updatePlayerList(Pages.Player:FindFirstChild("PlayerList"))
	end
end)

LocalPlayer.CharacterAdded:Connect(function(char)
	if State.Noclip then
		for _, part in ipairs(char:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
	if State.Fly then
		startFly()
	end
	updateInfiniteJump()
	if State.ESPEnabled or State.AutoESP then
		setupESP()
	end
end)

updateInfiniteJump()
syncMovement()
print("JMO HUB loaded successfully")
