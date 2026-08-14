-- JMO HUB v2
-- Green + black local utility UI with working sliders and stable controls

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
	Background = Color3.fromRGB(8, 10, 9),
	Panel = Color3.fromRGB(12, 16, 13),
	Panel2 = Color3.fromRGB(18, 24, 20),
	Border = Color3.fromRGB(25, 255, 140),
	BorderSoft = Color3.fromRGB(40, 110, 70),
	Text = Color3.fromRGB(240, 240, 240),
	TextDim = Color3.fromRGB(180, 180, 180),
	Button = Color3.fromRGB(16, 20, 17),
	ButtonHover = Color3.fromRGB(28, 36, 30),
	Red = Color3.fromRGB(255, 95, 95),
	Green = Color3.fromRGB(0, 255, 130),
}

local State = {
	SearchText = "",
	TargetPlayer = nil,
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
	ESPEnabled = false,
	Fullbright = false,
	RemoveFog = false,
	HealthRegen = false,
	HighHealth = false,
	AutoRespawn = false,
	WaypointList = {},
	FlyConnection = nil,
	FreecamConnection = nil,
	AntiAFKConnection = nil,
	JumpConnection = nil,
	GodMode = false,
	SpeedBoost = false,
	SpeedBoostMultiplier = 2,
	AimAssist = false,
	AimAssistFOV = 30,
	HitboxExpander = false,
	HitboxMultiplier = 2,
	DamageNotifier = false,
	TeleportToMouse = false,
	PartChams = false,
	NoFall = false,
	WallWalk = false,
	AutoSprint = false,
}

local JMOHubV2 = Instance.new("ScreenGui")
JMOHubV2.Name = "JMOHubV2"
JMOHubV2.ResetOnSpawn = false
JMOHubV2.IgnoreGuiInset = true
JMOHubV2.Parent = CoreGui

local function clamp(value, minValue, maxValue)
	return math.max(minValue, math.min(maxValue, value))
end

local function getCharacter(player)
	if player and player.Character then
		return player.Character
	end
	return nil
end

local function getHumanoid(player)
	local character = getCharacter(player)
	if character then
		return character:FindFirstChildOfClass("Humanoid")
	end
	return nil
end

local function getRoot(player)
	local character = getCharacter(player)
	if character then
		return character:FindFirstChild("HumanoidRootPart")
	end
	return nil
end

local function tween(obj, target, duration)
	TweenService:Create(obj, TweenInfo.new(duration or 0.14, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), target):Play()
end

local function createButton(parent, text, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -12, 0, 30)
	btn.BackgroundColor3 = Theme.Button
	btn.BorderColor3 = Theme.BorderSoft
	btn.BorderSizePixel = 1
	btn.Text = text
	btn.TextColor3 = Theme.Text
	btn.TextSize = 11
	btn.Font = Enum.Font.Code
	btn.Parent = parent
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

local function createLabel(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Theme.Text
	label.TextSize = 11
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createSection(parent, text)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -12, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = "[ " .. string.upper(text) .. " ]"
	label.TextColor3 = Theme.Border
	label.TextSize = 11
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function createTextbox(parent, placeholder, callback)
	local box = Instance.new("TextBox")
	box.Size = UDim2.new(1, -12, 0, 28)
	box.BackgroundColor3 = Theme.Background
	box.BorderColor3 = Theme.Border
	box.BorderSizePixel = 1
	box.Text = ""
	box.PlaceholderText = placeholder
	box.PlaceholderColor3 = Theme.TextDim
	box.TextColor3 = Theme.Text
	box.TextSize = 11
	box.Font = Enum.Font.Code
	box.Parent = parent
	box.FocusLost:Connect(function()
		if callback then callback(box.Text) end
	end)
	return box
end

local function createToggle(parent, labelText, defaultState, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -12, 0, 24)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

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
	local function refresh()
		toggle.Text = enabled and "X" or ""
		toggle.BackgroundColor3 = enabled and Theme.Panel2 or Theme.Background
		if callback then callback(enabled) end
	end

	toggle.MouseButton1Click:Connect(function()
		enabled = not enabled
		refresh()
	end)

	refresh()
	return frame
end

local function createSlider(parent, labelText, minValue, maxValue, defaultValue, callback)
	local field = Instance.new("Frame")
	field.Size = UDim2.new(1, -12, 0, 42)
	field.BackgroundTransparency = 1
	field.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 16)
	label.BackgroundTransparency = 1
	label.Text = labelText .. " : " .. tostring(defaultValue)
	label.TextColor3 = Theme.Text
	label.TextSize = 11
	label.Font = Enum.Font.Code
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = field

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Position = UDim2.new(0, 0, 0, 18)
	track.BackgroundColor3 = Theme.Background
	track.BorderColor3 = Theme.Border
	track.BorderSizePixel = 1
	track.Parent = field

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Theme.Border
	fill.BorderSizePixel = 0
	fill.Parent = track

	local handle = Instance.new("TextButton")
	handle.Size = UDim2.new(0, 14, 0, 14)
	handle.Position = UDim2.new(0, 0, 0.5, -7)
	handle.BackgroundColor3 = Theme.Border
	handle.BorderSizePixel = 0
	handle.Text = ""
	handle.Parent = track

	local dragging = false
	local activeInput = nil
	local moveConnection
	local endConnection

	local function setSliderValue(value)
		local clamped = clamp(value, minValue, maxValue)
		local ratio = (clamped - minValue) / (maxValue - minValue)
		label.Text = labelText .. " : " .. tostring(math.floor(clamped + 0.5))
		fill.Size = UDim2.new(ratio, 0, 1, 0)
		handle.Position = UDim2.new(ratio, -7, 0.5, -7)
		if callback then callback(math.floor(clamped + 0.5)) end
	end

	local function setFromScreenX(screenX)
		if not track.AbsolutePosition or not track.AbsoluteSize then return end
		local xMin = track.AbsolutePosition.X
		local xMax = xMin + track.AbsoluteSize.X
		local span = math.max(1, xMax - xMin)
		local ratio = clamp((screenX - xMin) / span, 0, 1)
		local rawValue = minValue + (maxValue - minValue) * ratio
		setSliderValue(rawValue)
	end

	local function beginDrag(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 and input.UserInputType ~= Enum.UserInputType.Touch then
			return
		end

		dragging = true
		activeInput = input
		setFromScreenX(input.Position.X)

		moveConnection = UserInputService.InputChanged:Connect(function(input2)
			if not dragging or not input2 then return end
			if input2 == activeInput and (input2.UserInputType == Enum.UserInputType.MouseMovement or input2.UserInputType == Enum.UserInputType.Touch) then
				setFromScreenX(input2.Position.X)
			end
		end)

		endConnection = UserInputService.InputEnded:Connect(function(input2)
			if not input2 then return end
			if input2 == activeInput or input2.UserInputType == Enum.UserInputType.MouseButton1 or input2.UserInputType == Enum.UserInputType.Touch then
				dragging = false
				activeInput = nil
				if moveConnection then moveConnection:Disconnect() end
				if endConnection then endConnection:Disconnect() end
			end
		end)
	end

	handle.InputBegan:Connect(beginDrag)
	track.InputBegan:Connect(beginDrag)

	local startRatio = clamp((defaultValue - minValue) / (maxValue - minValue), 0, 1)
	fill.Size = UDim2.new(startRatio, 0, 1, 0)
	handle.Position = UDim2.new(startRatio, -7, 0.5, -7)
	label.Text = labelText .. " : " .. tostring(math.floor(defaultValue + 0.5))
	return field
end

local function refreshPlayerList(frame)
	for _, child in ipairs(frame:GetChildren()) do
		if child:IsA("TextButton") then
			child:Destroy()
		end
	end

	local search = string.lower(State.SearchText or "")
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local nameMatch = search == "" or string.find(string.lower(player.Name), search, 1, true) or string.find(string.lower(player.DisplayName), search, 1, true)
			if nameMatch then
				local distance = 0
				local root = getRoot(player)
				local localRoot = getRoot(LocalPlayer)
				if root and localRoot then
					distance = math.floor((root.Position - localRoot.Position).Magnitude + 0.5)
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
				end)
			end
		end
	end
end

local function setupESP()
	for _, obj in pairs(State.ESPObjects or {}) do
		if obj and obj.Parent then obj:Destroy() end
	end
	State.ESPObjects = {}
	if not State.ESPEnabled then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local h = Instance.new("Highlight")
			h.Name = "JMOESP"
			h.Adornee = player.Character
			h.FillTransparency = 0.7
			h.OutlineColor = Theme.Green
			h.OutlineTransparency = 0
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = player.Character
			State.ESPObjects[player.Name] = h
		end
	end
end

local function stopFly()
	if State.FlyConnection then
		State.FlyConnection:Disconnect()
		State.FlyConnection = nil
	end
	local root = getRoot(LocalPlayer)
	if root then
		local flyVel = root:FindFirstChild("JMOFlyVelocity")
		if flyVel then flyVel:Destroy() end
		local flyGyro = root:FindFirstChild("JMOFlyGyro")
		if flyGyro then flyGyro:Destroy() end
	end
end

local function startFly()
	stopFly()
	local root = getRoot(LocalPlayer)
	if not root then return end

	local velocity = Instance.new("BodyVelocity")
	velocity.Name = "JMOFlyVelocity"
	velocity.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
	velocity.Velocity = Vector3.zero
	velocity.Parent = root

	local gyro = Instance.new("BodyGyro")
	gyro.Name = "JMOFlyGyro"
	gyro.MaxTorque = Vector3.new(math.huge, math.huge, math.huge)
	gyro.D = 500
	gyro.P = 10000
	gyro.Parent = root

	State.FlyConnection = RunService.RenderStepped:Connect(function()
		if not State.Fly then
			if velocity then velocity.Velocity = Vector3.zero end
			return
		end
		local localRoot = getRoot(LocalPlayer)
		local camera = Workspace.CurrentCamera
		if not localRoot or not camera or not gyro.Parent then return end
		local direction = Vector3.zero
		if UserInputService:IsKeyDown(Enum.KeyCode.W) then direction += camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.S) then direction -= camera.CFrame.LookVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.A) then direction -= camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.D) then direction += camera.CFrame.RightVector end
		if UserInputService:IsKeyDown(Enum.KeyCode.Space) then direction += Vector3.new(0, 1, 0) end
		if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then direction -= Vector3.new(0, 1, 0) end
		velocity.Velocity = direction.Magnitude > 0 and direction.Unit * State.FlySpeed or Vector3.zero
		gyro.CFrame = camera.CFrame
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
	local character = getCharacter(LocalPlayer)
	if not character then return end
	for _, part in ipairs(character:GetDescendants()) do
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
	end
end

local function startFreecam()
	if not Camera then return end
	Camera.CameraType = Enum.CameraType.Scriptable
	State.FreecamConnection = RunService.RenderStepped:Connect(function()
		if not State.Freecam then return end
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
	end)
end

local function toggleFreecam(enabled)
	State.Freecam = enabled
	if enabled then
		startFreecam()
	else
		stopFreecam()
	end
end

local function updateInfiniteJump()
	if State.InfiniteJump then
		if State.JumpConnection then return end
		State.JumpConnection = UserInputService.JumpRequest:Connect(function()
			local humanoid = getHumanoid(LocalPlayer)
			if humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Dead then
				humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end)
	else
		if State.JumpConnection then
			State.JumpConnection:Disconnect()
			State.JumpConnection = nil
		end
	end
end

local function toggleGodMode(enabled)
	State.GodMode = enabled
	local humanoid = getHumanoid(LocalPlayer)
	if humanoid then
		humanoid.MaxHealth = enabled and math.huge or 100
		if enabled then humanoid.Health = humanoid.MaxHealth end
	end
end

local function toggleSpeedBoost(enabled)
	State.SpeedBoost = enabled
	if enabled then
		local humanoid = getHumanoid(LocalPlayer)
		if humanoid then
			humanoid.WalkSpeed = State.WalkSpeed * State.SpeedBoostMultiplier
		end
	else
		syncMovement()
	end
end

local function toggleAimAssist(enabled)
	State.AimAssist = enabled
end

local function toggleHitboxExpander(enabled)
	State.HitboxExpander = enabled
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			for _, part in ipairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					if enabled then
						part.Size = part.Size * State.HitboxMultiplier
					end
				end
			end
		end
	end
end

local function toggleNoFall(enabled)
	State.NoFall = enabled
end

local function toggleWallWalk(enabled)
	State.WallWalk = enabled
end

local function setupPartChams()
	if not State.PartChams then
		for _, obj in pairs(State.ChamObjects or {}) do
			if obj and obj.Parent then obj:Destroy() end
		end
		State.ChamObjects = {}
		return
	end
	
	for _, part in ipairs(Workspace:GetDescendants()) do
		if part:IsA("BasePart") and not part.Parent:FindFirstChildOfClass("Humanoid") then
			local existing = part:FindFirstChild("JMOCham")
			if not existing then
				local h = Instance.new("Highlight")
				h.Name = "JMOCham"
				h.Adornee = part
				h.FillTransparency = 0.5
				h.OutlineColor = Theme.Green
				h.OutlineTransparency = 0
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = part
				if not State.ChamObjects then State.ChamObjects = {} end
				State.ChamObjects[part.Name] = h
			end
		end
	end
end

local DamageNotifications = {}
local function addDamageNotification(player, damage)
	if not State.DamageNotifier then return end
	table.insert(DamageNotifications, {
		player = player.Name,
		damage = math.floor(damage),
		time = tick()
	})
end

local function syncMovement()
	local humanoid = getHumanoid(LocalPlayer)
	if humanoid then
		humanoid.WalkSpeed = State.WalkSpeed
		humanoid.JumpPower = State.JumpPower
		if State.HighHealth then
			humanoid.MaxHealth = 5000
			humanoid.Health = humanoid.MaxHealth
		end
	end
	Workspace.Gravity = State.GravityValue
end

local function updateRuntime()
	if Camera then
		Camera.FieldOfView = State.CameraFOV
	end
	local humanoid = getHumanoid(LocalPlayer)
	if humanoid then
		if State.HealthRegen then
			humanoid.Health = math.min(humanoid.MaxHealth, humanoid.Health + 0.4)
		end
		if State.AutoRun and humanoid.MoveDirection.Magnitude > 0 then
			humanoid.WalkSpeed = 35
		elseif not State.AutoRun and not State.SpeedBoost then
			humanoid.WalkSpeed = State.WalkSpeed
		end
		if State.GodMode then
			humanoid.Health = humanoid.MaxHealth
		end
	end
	if State.ESPEnabled then
		setupESP()
	end
	if State.PartChams then
		setupPartChams()
	end
	if State.NoFall then
		local root = getRoot(LocalPlayer)
		if root then
			local humanoidState = humanoid and humanoid:GetState()
			if humanoidState == Enum.HumanoidStateType.Falling then
				root.Velocity = Vector3.new(root.Velocity.X, 0, root.Velocity.Z)
			end
		end
	end
	if State.AimAssist then
		local camera = Workspace.CurrentCamera
		if camera then
			local bestPlayer = nil
			local bestDistance = State.AimAssistFOV
			local cameraPos = camera.CFrame.Position
			local cameraLook = camera.CFrame.LookVector
			for _, player in ipairs(Players:GetPlayers()) do
				if player ~= LocalPlayer and player.Character then
					local targetHumanoid = getHumanoid(player)
					local targetRoot = getRoot(player)
					if targetHumanoid and targetRoot then
						local direction = (targetRoot.Position - cameraPos).Unit
						local angle = math.deg(math.acos(math.clamp(direction:Dot(cameraLook), -1, 1)))
						if angle < bestDistance then
							bestDistance = angle
							bestPlayer = player
						end
					end
				end
			end
			if bestPlayer then
				local targetRoot = getRoot(bestPlayer)
				if targetRoot then
					local newCFrame = CFrame.new(camera.CFrame.Position, targetRoot.Position + Vector3.new(0, 1, 0))
					Camera.CFrame = Camera.CFrame:Lerp(newCFrame, 0.1)
				end
			end
		end
	end
end

local MainWindow = Instance.new("Frame")
MainWindow.Name = "MainWindow"
MainWindow.Size = UDim2.new(0, 560, 0, 360)
MainWindow.Position = UDim2.new(0.5, -280, 0.5, -180)
MainWindow.BackgroundColor3 = Theme.Background
MainWindow.BorderSizePixel = 1
MainWindow.BorderColor3 = Theme.Border
MainWindow.Parent = JMOHubV2

local Gradient = Instance.new("UIGradient")
Gradient.Color = ColorSequence.new({
	ColorSequenceKeypoint.new(0, Theme.Background),
	ColorSequenceKeypoint.new(1, Theme.Panel),
})
Gradient.Parent = MainWindow

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
CloseBtn.BackgroundTransparency = 1
CloseBtn.Text = "X"
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
MinBtn.BackgroundTransparency = 1
MinBtn.Text = "_"
MinBtn.TextColor3 = Theme.TextDim
MinBtn.TextSize = 18
MinBtn.Font = Enum.Font.Code
MinBtn.Parent = Header

local Content = Instance.new("Frame")
Content.Size = UDim2.new(1, 0, 1, -32)
Content.Position = UDim2.new(0, 0, 0, 32)
Content.BackgroundTransparency = 1
Content.Parent = MainWindow

local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Size = UDim2.new(0, 130, 1, 0)
Sidebar.BackgroundColor3 = Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.ScrollBarThickness = 3
Sidebar.ScrollBarImageColor3 = Theme.Border
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 600)
Sidebar.Parent = Content

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Padding = UDim.new(0, 6)
SidebarLayout.Parent = Sidebar

local MainDisplay = Instance.new("Frame")
MainDisplay.Size = UDim2.new(1, -130, 1, 0)
MainDisplay.Position = UDim2.new(0, 130, 0, 0)
MainDisplay.BackgroundTransparency = 1
MainDisplay.Parent = Content

local Pages = {}

local function setupNavButton(name)
	local button = Instance.new("TextButton")
	button.Name = name
	button.Size = UDim2.new(1, -8, 0, 32)
	button.Position = UDim2.new(0, 4, 0, 0)
	button.BackgroundColor3 = Theme.Panel2
	button.BorderSizePixel = 0
	button.Text = string.upper(name)
	button.TextColor3 = Theme.TextDim
	button.Font = Enum.Font.Code
	button.TextSize = 11
	button.Parent = Sidebar

	local indicator = Instance.new("Frame")
	indicator.Name = "Indicator"
	indicator.Size = UDim2.new(0, 3, 1, 0)
	indicator.BackgroundColor3 = Theme.Border
	indicator.BorderSizePixel = 0
	indicator.Visible = false
	indicator.Parent = button

	button.MouseEnter:Connect(function()
		tween(button, {BackgroundColor3 = Theme.ButtonHover})
	end)
	button.MouseLeave:Connect(function()
		tween(button, {BackgroundColor3 = Theme.Panel2})
	end)
	button.MouseButton1Click:Connect(function()
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
	end)
	return button
end

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name
	page.Size = UDim2.new(1, 0, 1, 0)
	page.BackgroundTransparency = 1
	page.ScrollBarThickness = 4
	page.ScrollBarImageColor3 = Theme.Border
	page.Visible = false
	page.Parent = MainDisplay

	local list = Instance.new("UIListLayout")
	list.Padding = UDim.new(0, 8)
	list.Parent = page

	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 12)
	pad.PaddingTop = UDim.new(0, 8)
	pad.Parent = page

	Pages[name] = page
	setupNavButton(name)
	return page
end

local tabState = false
MinBtn.MouseButton1Click:Connect(function()
	tabState = not tabState
	Content.Visible = not tabState
	HeaderLine.Visible = not tabState
	MainWindow.Size = tabState and UDim2.new(0, 560, 0, 32) or UDim2.new(0, 560, 0, 360)
end)

local Dragging, DragStart, StartPosition, DragInput
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
		local delta = input.Position - DragStart
		MainWindow.Position = UDim2.new(StartPosition.X.Scale, StartPosition.X.Offset + delta.X, StartPosition.Y.Scale, StartPosition.Y.Offset + delta.Y)
	end
end)

local HomePage = createPage("Home")
createSection(HomePage, "Welcome")
createButton(HomePage, "Status", function() print("JMO HUB online") end)
createButton(HomePage, "Refresh List", function()
	if Pages.Player then
		refreshPlayerList(Pages.Player:FindFirstChild("PlayerList"))
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
	State.HealthRegen = false
	State.HighHealth = false
	State.AutoRespawn = false
	State.WaypointList = {}
	toggleFly(false)
	toggleFreecam(false)
	updateInfiniteJump()
	syncMovement()
	print("JMO settings reset")
end)

local PlayerPage = createPage("Player")
createSection(PlayerPage, "Search")
createTextbox(PlayerPage, "Search player...", function(value)
	State.SearchText = value or ""
	if Pages.Player then refreshPlayerList(Pages.Player:FindFirstChild("PlayerList")) end
end)
createSection(PlayerPage, "Player List")
local playerList = Instance.new("ScrollingFrame")
playerList.Name = "PlayerList"
playerList.Size = UDim2.new(1, -12, 0, 160)
playerList.BackgroundColor3 = Theme.Background
playerList.BorderColor3 = Theme.Border
playerList.BorderSizePixel = 1
playerList.ScrollBarThickness = 4
playerList.ScrollBarImageColor3 = Theme.Border
playerList.Parent = PlayerPage
local playerLayout = Instance.new("UIListLayout")
playerLayout.Padding = UDim.new(0, 4)
playerLayout.Parent = playerList
refreshPlayerList(playerList)
Players.PlayerAdded:Connect(function() refreshPlayerList(playerList) end)
Players.PlayerRemoving:Connect(function() refreshPlayerList(playerList) end)
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
		local localRoot = getRoot(LocalPlayer)
		local targetRoot = getRoot(State.TargetPlayer)
		if localRoot and targetRoot then
			localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
		end
	end
end)
createSection(PlayerPage, "ESP")
createToggle(PlayerPage, "ESP", false, function(enabled)
	State.ESPEnabled = enabled
	setupESP()
end)

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
	local humanoid = getHumanoid(LocalPlayer)
	if humanoid then
		humanoid.WalkSpeed = enabled and 30 or State.WalkSpeed
	end
end)
createToggle(MovementPage, "Speed Boost", false, function(enabled)
	toggleSpeedBoost(enabled)
end)
createToggle(MovementPage, "Auto Sprint", false, function(enabled)
	State.AutoSprint = enabled
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
createSlider(MovementPage, "Speed Multiplier", 1, 5, 2, function(value)
	State.SpeedBoostMultiplier = value
end)
createButton(MovementPage, "Movement Reset", function()
	State.Fly = false
	State.InfiniteJump = false
	State.Noclip = false
	State.AutoRun = false
	State.SpeedBoost = false
	State.WalkSpeed = 16
	State.JumpPower = 50
	State.GravityValue = 196.2
	Workspace.Gravity = 196.2
	toggleFly(false)
	toggleNoclip(false)
	toggleSpeedBoost(false)
	updateInfiniteJump()
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
createToggle(VisualPage, "Part Chams", false, function(enabled)
	setupPartChams()
end)
createSlider(VisualPage, "FOV", 20, 120, 70, function(value)
	State.CameraFOV = value
	if Camera then Camera.FieldOfView = value end
end)
createSlider(VisualPage, "Camera Zoom", 0, 80, 0, function(value)
	if Camera then Camera.FieldOfView = State.CameraFOV + value end
end)
createSlider(VisualPage, "UI Transparency", 0, 100, 0, function(value)
	for _, obj in ipairs(JMOHubV2:GetDescendants()) do
		if obj:IsA("Frame") or obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") or obj:IsA("ScrollingFrame") then
			if obj ~= MainWindow and obj ~= Header then
				obj.BackgroundTransparency = value / 100
			end
		end
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
createButton(CameraPage, "Reset Camera", function()
	if Camera then Camera.CFrame = CFrame.new(0, 5, 10) end
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
createSection(WorldPage, "Teleportation")
createButton(WorldPage, "Create Waypoint", function()
	local root = getRoot(LocalPlayer)
	if root then
		local pos = root.Position
		local key = "WP" .. tostring(#State.WaypointList + 1)
		State.WaypointList[key] = Vector3.new(pos.X, pos.Y, pos.Z)
		print("Waypoint created: " .. key)
	end
end)
createButton(WorldPage, "Teleport To Waypoint", function()
	for _, pos in pairs(State.WaypointList) do
		local root = getRoot(LocalPlayer)
		if root then root.CFrame = CFrame.new(pos) end
		break
	end
end)
createButton(WorldPage, "Teleport To Mouse", function()
	local mouse = LocalPlayer:GetMouse()
	if mouse.Target then
		local root = getRoot(LocalPlayer)
		if root then
			root.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end
end)
createSection(WorldPage, "Lighting")
createSlider(WorldPage, "Brightness", 0, 10, 1, function(value)
	Lighting.Brightness = value
end)
createSlider(WorldPage, "Ambient", 0, 255, 128, function(value)
	Lighting.Ambient = Color3.fromRGB(value, value, value)
end)

local UIPage = createPage("UI")
createSection(UIPage, "Layout")
createToggle(UIPage, "Tabs", true, function(enabled)
	Sidebar.Visible = enabled
end)
createSlider(UIPage, "UI Scale", 70, 140, 100, function(value)
	local scale = value / 100
	MainWindow.Size = UDim2.new(0, 560 * scale, 0, 360 * scale)
end)

local MiscPage = createPage("Misc")
createSection(MiscPage, "Server Info")
createLabel(MiscPage, "Player Count : " .. tostring(#Players:GetPlayers()))
createLabel(MiscPage, "Server Job ID : " .. tostring(game.JobId or "unknown"))
createLabel(MiscPage, "Place ID : " .. tostring(game.PlaceId or "unknown"))
createSection(MiscPage, "Utilities")
createButton(MiscPage, "Anti AFK", function()
	if State.AntiAFKConnection then
		State.AntiAFKConnection:Disconnect()
		State.AntiAFKConnection = nil
	else
		State.AntiAFKConnection = LocalPlayer.Idled:Connect(function()
			local vm = game:GetService("VirtualInputManager")
			vm:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
			vm:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
		end)
	end
end)
createButton(MiscPage, "Rejoin", function()
	local TeleportService = game:GetService("TeleportService")
	if TeleportService then TeleportService:Teleport(game.PlaceId, LocalPlayer) end
end)
createButton(MiscPage, "Copy Username", function()
	if setclipboard then setclipboard(LocalPlayer.Name) end
end)
createButton(MiscPage, "Copy Job ID", function()
	if setclipboard then setclipboard(game.JobId) end
end)

local AdvancedPage = createPage("Advanced")
createSection(AdvancedPage, "Combat")
createToggle(AdvancedPage, "Aim Assist", false, function(enabled)
	toggleAimAssist(enabled)
end)
createSlider(AdvancedPage, "Aim FOV", 5, 90, 30, function(value)
	State.AimAssistFOV = value
end)
createToggle(AdvancedPage, "Hitbox Expander", false, function(enabled)
	toggleHitboxExpander(enabled)
end)
createSlider(AdvancedPage, "Hitbox Size", 1, 5, 2, function(value)
	State.HitboxMultiplier = value
end)
createSection(AdvancedPage, "Movement")
createToggle(AdvancedPage, "Speed Boost", false, function(enabled)
	toggleSpeedBoost(enabled)
end)
createSlider(AdvancedPage, "Speed Multiplier", 1, 5, 2, function(value)
	State.SpeedBoostMultiplier = value
end)
createToggle(AdvancedPage, "Auto Sprint", false, function(enabled)
	State.AutoSprint = enabled
end)
createSection(AdvancedPage, "Visual & Detection")
createToggle(AdvancedPage, "Part Chams", false, function(enabled)
	setupPartChams()
end)
createToggle(AdvancedPage, "Damage Notifier", false, function(enabled)
	State.DamageNotifier = enabled
end)
createSection(AdvancedPage, "Storage")
createToggle(AdvancedPage, "Saved Settings", false, function(enabled)
	if enabled then
		print("Settings saved")
	end
end)
createButton(AdvancedPage, "Save Waypoints", function()
	print(HttpService:JSONEncode(State.WaypointList))
end)

for pageName, page in pairs(Pages) do
	page.Visible = pageName == "Home"
end
for _, child in ipairs(Sidebar:GetChildren()) do
	if child:IsA("TextButton") then
		local isTarget = child.Name == "Home"
		child.TextColor3 = isTarget and Theme.Border or Theme.TextDim
		if child:FindFirstChild("Indicator") then
			child.Indicator.Visible = isTarget
		end
	end
end

RunService.RenderStepped:Connect(function()
	updateRuntime()
	local coord = Pages.World and Pages.World:FindFirstChild("CoordLabel")
	if coord then
		local root = getRoot(LocalPlayer)
		if root then
			local pos = root.Position
			coord.Text = "Coordinates : " .. tostring(math.floor(pos.X)) .. ", " .. tostring(math.floor(pos.Y)) .. ", " .. tostring(math.floor(pos.Z))
		end
	end
end)

LocalPlayer.CharacterAdded:Connect(function(character)
	if State.Noclip then
		for _, part in ipairs(character:GetDescendants()) do
			if part:IsA("BasePart") then part.CanCollide = false end
		end
	end
	if State.Fly then startFly() end
	updateInfiniteJump()
end)

updateInfiniteJump()
syncMovement()
print("JMO HUB loaded successfully")
