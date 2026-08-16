-- JMO HUB v2 - Cleaned, upgraded, and executor-friendly
-- Created for Roblox with a simple multi-page UI and extra utility items.

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()

local existing = CoreGui:FindFirstChild("JMOHubV2")
if existing then
	existing:Destroy()
end

local function getRootCharacter(target)
	if not target then
		return nil
	end
	local character = target.Character
	if not character then
		return nil
	end
	return character:FindFirstChild("HumanoidRootPart") or character:FindFirstChild("Torso") or character:FindFirstChild("UpperTorso")
end

local function makeRoundedCorner(instance, radius)
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, radius)
	corner.Parent = instance
	return corner
end

local function makeButton(parent, text, callback, sizeX, sizeY)
	local button = Instance.new("TextButton")
	button.Size = UDim2.new(sizeX or 1, 0, sizeY or 0, 36)
	button.AutoButtonColor = false
	button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	button.BorderSizePixel = 0
	button.Text = text
	button.TextColor3 = Color3.fromRGB(240, 240, 240)
	button.Font = Enum.Font.Gotham
	button.TextSize = 14
	button.Parent = parent
	makeRoundedCorner(button, 8)
	button.MouseEnter:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
	end)
	button.MouseLeave:Connect(function()
		button.BackgroundColor3 = Color3.fromRGB(28, 28, 28)
	end)
	if callback then
		button.MouseButton1Click:Connect(callback)
	end
	return button
end

local function makeLabel(parent, text, sizeX, sizeY)
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(sizeX or 1, 0, sizeY or 0, 22)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = Color3.fromRGB(0, 255, 110)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 13
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = parent
	return label
end

local function addPadding(parent, left, top, right, bottom)
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, left or 12)
	pad.PaddingTop = UDim.new(0, top or 12)
	pad.PaddingRight = UDim.new(0, right or 12)
	pad.PaddingBottom = UDim.new(0, bottom or 12)
	pad.Parent = parent
	return pad
end

local function createTool(name, color, onActivated)
	local tool = Instance.new("Tool")
	tool.Name = name
	tool.RequiresHandle = true
	tool.CanBeDropped = false
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1, 1)
	handle.Color = color or Color3.fromRGB(255, 255, 255)
	handle.Material = Enum.Material.SmoothPlastic
	handle.Shape = Enum.PartType.Ball
	handle.CanCollide = false
	handle.Massless = true
	handle.Parent = tool
	local weld = Instance.new("WeldConstraint")
	weld.Part0 = handle
	weld.Part1 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("RightHand") or nil
	if weld.Part1 then
		weld.Parent = handle
	end
	if onActivated then
		tool.Activated:Connect(onActivated)
	end
	return tool
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JMOHubV2"
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 860, 0, 500)
MainFrame.Position = UDim2.new(0.5, -430, 0.5, -250)
MainFrame.BackgroundColor3 = Color3.fromRGB(11, 11, 14)
MainFrame.BorderSizePixel = 0
MainFrame.Parent = ScreenGui
makeRoundedCorner(MainFrame, 16)

local Header = Instance.new("Frame")
Header.Name = "Header"
Header.Size = UDim2.new(1, 0, 0, 42)
Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
Header.BorderSizePixel = 0
Header.Parent = MainFrame
makeRoundedCorner(Header, 16)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(0.5, 0, 1, 0)
Title.Position = UDim2.new(0, 16, 0, 0)
Title.BackgroundTransparency = 1
Title.Text = "JMO HUB v2"
Title.TextColor3 = Color3.fromRGB(0, 255, 110)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = Header

local CloseButton = Instance.new("TextButton")
CloseButton.Size = UDim2.new(0, 32, 0, 32)
CloseButton.Position = UDim2.new(1, -40, 0.5, -16)
CloseButton.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseButton.BorderSizePixel = 0
CloseButton.Text = "X"
CloseButton.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseButton.Font = Enum.Font.GothamBold
CloseButton.TextSize = 15
CloseButton.Parent = Header
makeRoundedCorner(CloseButton, 8)
CloseButton.MouseButton1Click:Connect(function()
	ScreenGui:Destroy()
end)

local MinimizeButton = Instance.new("TextButton")
MinimizeButton.Size = UDim2.new(0, 32, 0, 32)
MinimizeButton.Position = UDim2.new(1, -80, 0.5, -16)
MinimizeButton.BackgroundColor3 = Color3.fromRGB(50, 50, 58)
MinimizeButton.BorderSizePixel = 0
MinimizeButton.Text = "_"
MinimizeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
MinimizeButton.Font = Enum.Font.GothamBold
MinimizeButton.TextSize = 15
MinimizeButton.Parent = Header
makeRoundedCorner(MinimizeButton, 8)
local Minimized = false
MinimizeButton.MouseButton1Click:Connect(function()
	Minimized = not Minimized
	local targetSize = Minimized and UDim2.new(0, 860, 0, 72) or UDim2.new(0, 860, 0, 500)
	TweenService:Create(MainFrame, TweenInfo.new(0.18), { Size = targetSize }):Play()
	Sidebar.Visible = not Minimized
	Content.Visible = not Minimized
end)

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 170, 1, -42)
Sidebar.Position = UDim2.new(0, 0, 0, 42)
Sidebar.BackgroundColor3 = Color3.fromRGB(15, 15, 18)
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

local SideList = Instance.new("UIListLayout")
SideList.Padding = UDim.new(0, 8)
SideList.SortOrder = Enum.SortOrder.LayoutOrder
SideList.Parent = Sidebar
addPadding(Sidebar, 10, 12, 10, 12)

local Content = Instance.new("Frame")
Content.Name = "Content"
Content.Size = UDim2.new(1, -170, 1, -42)
Content.Position = UDim2.new(0, 170, 0, 42)
Content.BackgroundTransparency = 1
Content.Parent = MainFrame

local Pages = {}
local CurrentPage = nil

local function createPage(name)
	local page = Instance.new("ScrollingFrame")
	page.Name = name .. "Page"
	page.Size = UDim2.new(1, 0, 1, 0)
	page.CanvasSize = UDim2.new(0, 0, 0, 900)
	page.ScrollBarThickness = 5
	page.ScrollBarImageColor3 = Color3.fromRGB(0, 255, 120)
	page.BackgroundTransparency = 1
	page.Visible = false
	page.Parent = Content
	page.AutomaticCanvasSize = Enum.AutomaticSize.Y
	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 10)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = page
	addPadding(page, 18, 12, 18, 18)
	Pages[name] = page
	return page
end

local function setPage(pageName)
	for name, page in pairs(Pages) do
		page.Visible = (name == pageName)
	end
	CurrentPage = pageName
end

local function createPageTab(name)
	local tab = Instance.new("TextButton")
	tab.Size = UDim2.new(1, 0, 0, 40)
	tab.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
	tab.BorderSizePixel = 0
	tab.Text = name
	tab.TextColor3 = Color3.fromRGB(200, 200, 200)
	tab.Font = Enum.Font.GothamBold
	tab.TextSize = 14
	tab.Parent = Sidebar
	makeRoundedCorner(tab, 8)
	tab.MouseButton1Click:Connect(function()
		for _, child in ipairs(Sidebar:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(23, 23, 28)
				child.TextColor3 = Color3.fromRGB(200, 200, 200)
			end
		end
		tab.BackgroundColor3 = Color3.fromRGB(0, 255, 110)
		tab.TextColor3 = Color3.fromRGB(12, 12, 12)
		setPage(name)
	end)
	return tab
end

local HomePage = createPage("Home")
local PlayersPage = createPage("Players")
local ItemsPage = createPage("Items")
local TeleportPage = createPage("Teleport")
local UtilityPage = createPage("Utility")
local SettingsPage = createPage("Settings")

local function addSection(page, title)
	local section = Instance.new("Frame")
	section.Size = UDim2.new(1, 0, 0, 36)
	section.BackgroundTransparency = 1
	section.Parent = page
	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = title
	label.TextColor3 = Color3.fromRGB(0, 255, 110)
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = section
	return section
end

local function makeGrid(panel, columns)
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(1 / columns, -8, 0, 36)
	grid.CellPadding = UDim2.new(0, 8, 0, 8)
	grid.SortOrder = Enum.SortOrder.LayoutOrder
	grid.Parent = panel
	return grid
end

local function addAction(page, sectionTitle, buttonText, callback)
	if sectionTitle then
		addSection(page, sectionTitle)
	end
	local box = Instance.new("Frame")
	box.Size = UDim2.new(1, 0, 0, 40)
	box.BackgroundTransparency = 1
	box.Parent = page
	local button = makeButton(box, buttonText, callback, 1, 1)
	button.Position = UDim2.new(0, 0, 0, 0)
	return button
end

local function addSimpleButton(page, title, callback)
	return addAction(page, nil, title, callback)
end

local function createSlider(parent, labelText, minValue, maxValue, defaultValue, callback)
	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, 0, 0, 50)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 0, 18)
	label.BackgroundTransparency = 1
	label.Text = labelText .. ": " .. tostring(defaultValue)
	label.TextColor3 = Color3.fromRGB(240, 240, 240)
	label.Font = Enum.Font.Gotham
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = container

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 10)
	track.Position = UDim2.new(0, 0, 0, 20)
	track.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
	track.BorderSizePixel = 0
	track.Parent = container
	makeRoundedCorner(track, 5)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.new(0, 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(0, 255, 110)
	fill.BorderSizePixel = 0
	fill.Parent = track
	makeRoundedCorner(fill, 5)

	local knob = Instance.new("TextButton")
	knob.Size = UDim2.new(0, 14, 0, 14)
	knob.Position = UDim2.new(0, 0, 0.5, -7)
	knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	knob.BorderSizePixel = 0
	knob.Text = ""
	knob.Parent = track
	makeRoundedCorner(knob, 7)

	local currentValue = defaultValue

	local function updateSlider(rawValue)
		currentValue = math.clamp(rawValue, minValue, maxValue)
		local percent = (currentValue - minValue) / (maxValue - minValue)
		fill.Size = UDim2.new(percent, 0, 1, 0)
		knob.Position = UDim2.new(percent, -7, 0.5, -7)
		label.Text = labelText .. ": " .. tostring(math.floor(currentValue))
		if callback then
			callback(currentValue)
		end
	end

	knob.InputBegan:Connect(function(input)
		if input.UserInputType ~= Enum.UserInputType.MouseButton1 then
			return
		end

		local connection
		connection = UserInputService.InputChanged:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseMovement then
				local mouseX = inputObject.Position.X
				local startX = track.AbsolutePosition.X
				local totalWidth = track.AbsoluteSize.X
				local percent = math.clamp((mouseX - startX) / totalWidth, 0, 1)
				updateSlider(minValue + (maxValue - minValue) * percent)
			end
		end)

		UserInputService.InputEnded:Connect(function(inputObject)
			if inputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				connection:Disconnect()
			end
		end)
	end)

	updateSlider(defaultValue)
	return {
		GetValue = function()
			return currentValue
		end,
		SetValue = updateSlider,
	}
end

local HomeSection = addSection(HomePage, "Quick Actions")
local homeGrid = Instance.new("Frame")
homeGrid.Size = UDim2.new(1, 0, 0, 180)
homeGrid.BackgroundTransparency = 1
homeGrid.Parent = HomePage
makeGrid(homeGrid, 2)

makeButton(homeGrid, "Fling Nearby", function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			local root = getRootCharacter(player)
			if root then
				local velocity = (root.Position - (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position or root.Position)).Unit * 120
				local bodyVelocity = Instance.new("BodyVelocity")
				bodyVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bodyVelocity.Velocity = Vector3.new(velocity.X, 85, velocity.Z)
				bodyVelocity.Parent = root
				task.delay(1.25, function()
					if bodyVelocity and bodyVelocity.Parent then
						bodyVelocity:Destroy()
					end
				end)
			end
		end
	end
end, 1, 1)

makeButton(homeGrid, "Give Green Balloon", function()
	local balloonTool = createTool("Green Balloon", Color3.fromRGB(40, 255, 110), function()
		local hrp = getRootCharacter(LocalPlayer)
		if not hrp then return end
		local balloon = Instance.new("Part")
		balloon.Name = "GreenBalloon"
		balloon.Shape = Enum.PartType.Ball
		balloon.Size = Vector3.new(2.5, 2.5, 2.5)
		balloon.Color = Color3.fromRGB(35, 255, 120)
		balloon.Material = Enum.Material.Neon
		balloon.CanCollide = false
		balloon.Velocity = Vector3.new(0, 45, 0)
		balloon.Parent = Workspace
		balloon.CFrame = CFrame.new(hrp.Position + Vector3.new(0, 3, 0))
		task.delay(2.5, function()
			if balloon and balloon.Parent then
				balloon:Destroy()
			end
		end)
	end)
	balloonTool.Parent = LocalPlayer.Backpack
end, 1, 1)

makeButton(homeGrid, "Give OneShot Gun", function()
	local gun = Instance.new("Tool")
	gun.Name = "OneShot Gun"
	gun.RequiresHandle = true
	local handle = Instance.new("Part")
	handle.Name = "Handle"
	handle.Size = Vector3.new(1, 1, 3)
	handle.Color = Color3.fromRGB(25, 25, 25)
	handle.Material = Enum.Material.Metal
	handle.CanCollide = false
	handle.Parent = gun
	local barrel = Instance.new("Part")
	barrel.Size = Vector3.new(0.5, 0.5, 1.1)
	barrel.Color = Color3.fromRGB(0, 255, 110)
	barrel.Material = Enum.Material.Neon
	barrel.CanCollide = false
	barrel.Parent = gun
	local weld1 = Instance.new("WeldConstraint")
	weld1.Part0 = handle
	weld1.Part1 = barrel
	weld1.Parent = handle
	gun.Parent = LocalPlayer.Backpack
	gun.Activated:Connect(function()
		local char = LocalPlayer.Character
		if not char then return end
		local hrp = char:FindFirstChild("HumanoidRootPart")
		if not hrp then return end
		local targetPos = Mouse.Hit.Position
		local dir = (targetPos - hrp.Position).Unit
		local ray = Ray.new(hrp.Position + Vector3.new(0, 2, 0), dir * 400)
		local part, pos = Workspace:FindPartOnRayWithIgnoreList(ray, { char }, false, true)
		if part and part.Parent and part.Parent:FindFirstChildOfClass("Humanoid") then
			part.Parent.Humanoid.Health = 0
		end
		local tracer = Instance.new("Part")
		tracer.Name = "Tracer"
		tracer.Anchored = true
		tracer.CanCollide = false
		tracer.Material = Enum.Material.Neon
		tracer.Color = Color3.fromRGB(0, 255, 110)
		tracer.Size = Vector3.new(0.2, 0.2, (hrp.Position - targetPos).Magnitude)
		tracer.CFrame = CFrame.new((hrp.Position + targetPos) / 2, targetPos)
		tracer.Parent = Workspace
		task.delay(0.12, function()
			if tracer and tracer.Parent then
				tracer:Destroy()
			end
		end)
	end)
end, 1, 1)

makeButton(homeGrid, "Teleport Tool", function()
	local tool = createTool("Teleport Tool", Color3.fromRGB(0, 200, 255), function()
		local root = getRootCharacter(LocalPlayer)
		if root then
			root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
		end
	end)
	tool.Parent = LocalPlayer.Backpack
end, 1, 1)

makeButton(homeGrid, "Delete Tool", function()
	local tool = createTool("Delete Tool", Color3.fromRGB(255, 90, 90), function()
		if Mouse.Target then
			Mouse.Target:Destroy()
		end
	end)
	tool.Parent = LocalPlayer.Backpack
end, 1, 1)

local playersSection = addSection(PlayersPage, "Player Control")
local playerGrid = Instance.new("Frame")
playerGrid.Size = UDim2.new(1, 0, 0, 180)
playerGrid.BackgroundTransparency = 1
playerGrid.Parent = PlayersPage
makeGrid(playerGrid, 2)

makeButton(playerGrid, "Fling All", function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local root = getRootCharacter(player)
			if root then
				local bv = Instance.new("BodyVelocity")
				bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				bv.Velocity = Vector3.new(0, 110, 0)
				bv.Parent = root
				task.delay(1.5, function()
					if bv and bv.Parent then
						bv:Destroy()
					end
				end)
			end
		end
	end
end, 1, 1)

makeButton(playerGrid, "Kill Nearby", function()
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local hum = player.Character:FindFirstChildOfClass("Humanoid")
			if hum then
				hum.Health = 0
			end
		end
	end
end, 1, 1)

makeButton(playerGrid, "Speed x2", function()
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 80
			hum.JumpPower = 120
		end
	end
end, 1, 1)

makeButton(playerGrid, "Reset Speed", function()
	local char = LocalPlayer.Character
	if char then
		local hum = char:FindFirstChildOfClass("Humanoid")
		if hum then
			hum.WalkSpeed = 16
			hum.JumpPower = 50
		end
	end
end, 1, 1)

local itemsSection = addSection(ItemsPage, "Item Spawner")
local itemGrid = Instance.new("Frame")
itemGrid.Size = UDim2.new(1, 0, 0, 190)
itemGrid.BackgroundTransparency = 1
itemGrid.Parent = ItemsPage
makeGrid(itemGrid, 2)

makeButton(itemGrid, "Give Grab Tool", function()
	local grab = createTool("Grab Tool", Color3.fromRGB(120, 150, 255), function()
		if Mouse.Target and Mouse.Target:IsA("BasePart") then
			Mouse.Target.CFrame = CFrame.new(Mouse.Hit.Position)
		end
	end)
	grab.Parent = LocalPlayer.Backpack
end, 1, 1)

makeButton(itemGrid, "Give Clone Tool", function()
	local cloneTool = createTool("Clone Tool", Color3.fromRGB(255, 215, 80), function()
		if Mouse.Target and Mouse.Target:IsA("BasePart") then
			local clone = Mouse.Target:Clone()
			clone.Parent = Workspace
			clone.CFrame = Mouse.Target.CFrame + Vector3.new(0, 3, 0)
		end
	end)
	cloneTool.Parent = LocalPlayer.Backpack
end, 1, 1)

makeButton(itemGrid, "Give BTools", function()
	local grab = createTool("Grab", Color3.fromRGB(160, 255, 255), function()
		if Mouse.Target and Mouse.Target:IsA("BasePart") then
			Mouse.Target.CFrame = CFrame.new(Mouse.Hit.Position)
		end
	end)
	grab.Parent = LocalPlayer.Backpack
	local clone = createTool("Clone", Color3.fromRGB(255, 200, 90), function()
		if Mouse.Target and Mouse.Target:IsA("BasePart") then
			local c = Mouse.Target:Clone()
			c.Parent = Workspace
			c.CFrame = Mouse.Target.CFrame + Vector3.new(0, 3, 0)
		end
	end)
	clone.Parent = LocalPlayer.Backpack
	local del = createTool("Delete", Color3.fromRGB(255, 80, 80), function()
		if Mouse.Target then
			Mouse.Target:Destroy()
		end
	end)
	del.Parent = LocalPlayer.Backpack
end, 1, 1)

makeButton(itemGrid, "Give Launch Pad", function()
	local pad = Instance.new("Part")
	pad.Name = "LaunchPad"
	pad.Size = Vector3.new(8, 1, 8)
	pad.Color = Color3.fromRGB(0, 255, 110)
	pad.Material = Enum.Material.Neon
	pad.Position = (LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") and LocalPlayer.Character.HumanoidRootPart.Position + Vector3.new(0, -4, 0)) or Vector3.new(0, 4, 0)
	pad.Anchored = true
	pad.Parent = Workspace
	local touched = false
	pad.Touched:Connect(function(hit)
		if touched then return end
		local hum = hit.Parent and hit.Parent:FindFirstChildOfClass("Humanoid")
		if hum then
			touched = true
			if hum.Parent and hum.Parent:FindFirstChild("HumanoidRootPart") then
				hum.Parent.HumanoidRootPart.Velocity = Vector3.new(0, 120, 0)
			end
			task.delay(0.5, function()
				touched = false
			end)
		end
	end)
end, 1, 1)

local teleportSection = addSection(TeleportPage, "Teleport")
local tpGrid = Instance.new("Frame")
tpGrid.Size = UDim2.new(1, 0, 0, 180)
tpGrid.BackgroundTransparency = 1
tpGrid.Parent = TeleportPage
makeGrid(tpGrid, 2)

makeButton(tpGrid, "Spawn", function()
	local root = getRootCharacter(LocalPlayer)
	if root then
		root.CFrame = CFrame.new(0, 10, 0)
	end
end, 1, 1)

makeButton(tpGrid, "To Mouse", function()
	local root = getRootCharacter(LocalPlayer)
	if root then
		root.CFrame = CFrame.new(Mouse.Hit.Position + Vector3.new(0, 3, 0))
	end
end, 1, 1)

makeButton(tpGrid, "To Random Player", function()
	local players = Players:GetPlayers()
	local target = players[math.random(1, #players)]
	if target ~= LocalPlayer and target.Character then
		local root = getRootCharacter(target)
		if root then
			LocalPlayer.Character:PivotTo(root.CFrame + Vector3.new(0, 2, 0))
		end
	end
end, 1, 1)

makeButton(tpGrid, "Bring All", function()
	local root = getRootCharacter(LocalPlayer)
	if not root then return end
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character then
			local targetRoot = getRootCharacter(player)
			if targetRoot then
				targetRoot.CFrame = root.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end
end, 1, 1)

local utilitySection = addSection(UtilityPage, "Utility")
local utilGrid = Instance.new("Frame")
utilGrid.Size = UDim2.new(1, 0, 0, 260)
utilGrid.BackgroundTransparency = 1
utilGrid.Parent = UtilityPage
makeGrid(utilGrid, 2)

local flightEnabled = false
local flightSpeed = 55
local flightVelocity = nil
local flightGyro = nil
local flightLoop = nil
local flightButton = nil

local function updateFlightButton()
	if flightButton then
		flightButton.Text = flightEnabled and "Flight: ON" or "Flight: OFF"
		flightButton.BackgroundColor3 = flightEnabled and Color3.fromRGB(0, 255, 110) or Color3.fromRGB(28, 28, 28)
		flightButton.TextColor3 = flightEnabled and Color3.fromRGB(12, 12, 12) or Color3.fromRGB(240, 240, 240)
	end
end

local function setFlightState(enabled)
	flightEnabled = enabled
	local char = LocalPlayer.Character
	if char then
		local humanoid = char:FindFirstChildOfClass("Humanoid")
		if humanoid then
			humanoid.PlatformStand = enabled
		end
	end

	if not flightEnabled then
		if flightVelocity then
			flightVelocity:Destroy()
			flightVelocity = nil
		end
		if flightGyro then
			flightGyro:Destroy()
			flightGyro = nil
		end
		if flightLoop then
			flightLoop:Disconnect()
			flightLoop = nil
		end
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				root.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
			end
		end
	end

	if flightEnabled then
		char = LocalPlayer.Character
		if char then
			local root = char:FindFirstChild("HumanoidRootPart")
			if root then
				flightVelocity = Instance.new("BodyVelocity")
				flightVelocity.MaxForce = Vector3.new(1e9, 1e9, 1e9)
				flightVelocity.Velocity = Vector3.new(0, 0, 0)
				flightVelocity.Parent = root

				flightGyro = Instance.new("BodyGyro")
				flightGyro.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
				flightGyro.CFrame = root.CFrame
				flightGyro.Parent = root
			end
		end

		if flightLoop then
			flightLoop:Disconnect()
		end

		flightLoop = RunService.RenderStepped:Connect(function()
			if not flightEnabled then
				return
			end
			local activeChar = LocalPlayer.Character
			if not activeChar then
				return
			end
			local root = activeChar:FindFirstChild("HumanoidRootPart")
			if not root or not flightVelocity or not flightGyro then
				return
			end
			local moveVector = Vector3.new(0, 0, 0)
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVector += Vector3.new(0, 0, -1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVector += Vector3.new(0, 0, 1) end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVector += Vector3.new(-1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVector += Vector3.new(1, 0, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVector += Vector3.new(0, 1, 0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then moveVector += Vector3.new(0, -1, 0) end

			local camera = Workspace.CurrentCamera
			if camera then
				local forward = camera.CFrame.LookVector
				local right = camera.CFrame.RightVector
				local flatForward = Vector3.new(forward.X, 0, forward.Z)
				local flatRight = Vector3.new(right.X, 0, right.Z)
				if flatForward.Magnitude > 0 then
					flatForward = flatForward.Unit
				end
				if flatRight.Magnitude > 0 then
					flatRight = flatRight.Unit
				end
				local direction = (flatForward * moveVector.Z + flatRight * moveVector.X + Vector3.new(0, moveVector.Y, 0))
				if direction.Magnitude > 0 then
					direction = direction.Unit * flightSpeed
					flightVelocity.Velocity = direction
				else
					flightVelocity.Velocity = Vector3.new(0, 0, 0)
				end
				flightGyro.CFrame = CFrame.new(root.Position, root.Position + camera.CFrame.LookVector)
			end
		end)
	end

	updateFlightButton()
end

LocalPlayer.CharacterAdded:Connect(function()
	if flightEnabled then
		setFlightState(false)
	end
end)

flightButton = makeButton(utilGrid, "Flight: OFF", function()
	setFlightState(not flightEnabled)
end, 1, 1)

local flightSlider = createSlider(utilGrid, "Flight Speed", 10, 200, 55, function(value)
	flightSpeed = value
end)

local noclipEnabled = false
makeButton(utilGrid, "Noclip", function()
	noclipEnabled = not noclipEnabled
	if noclipEnabled then
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = false
				end
			end
		end
	else
		local char = LocalPlayer.Character
		if char then
			for _, part in ipairs(char:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end
end, 1, 1)

local jumpConnection = nil
makeButton(utilGrid, "Infinite Jump", function()
	if jumpConnection then
		jumpConnection:Disconnect()
		jumpConnection = nil
		return
	end
	jumpConnection = UserInputService.JumpRequest:Connect(function()
		local char = LocalPlayer.Character
		if char then
			local hum = char:FindFirstChildOfClass("Humanoid")
			if hum then
				hum:ChangeState(Enum.HumanoidStateType.Jumping)
			end
		end
	end)
end, 1, 1)

makeButton(utilGrid, "Remove Fog", function()
	Lighting.FogEnd = 100000
	Lighting.FogStart = 100000
	Lighting.Brightness = 2
end, 1, 1)

makeButton(utilGrid, "Reset Camera", function()
	LocalPlayer:Kick("Reset camera is not needed in this environment.")
end, 1, 1)

local settingsSection = addSection(SettingsPage, "Settings")
local settingsGrid = Instance.new("Frame")
settingsGrid.Size = UDim2.new(1, 0, 0, 120)
settingsGrid.BackgroundTransparency = 1
settingsGrid.Parent = SettingsPage
makeGrid(settingsGrid, 2)

makeButton(settingsGrid, "Theme Green", function()
	MainFrame.BackgroundColor3 = Color3.fromRGB(10, 12, 13)
	Header.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	Title.TextColor3 = Color3.fromRGB(0, 255, 110)
end, 1, 1)

makeButton(settingsGrid, "Theme Purple", function()
	MainFrame.BackgroundColor3 = Color3.fromRGB(20, 12, 25)
	Header.BackgroundColor3 = Color3.fromRGB(35, 20, 45)
	Title.TextColor3 = Color3.fromRGB(220, 120, 255)
end, 1, 1)

makeButton(settingsGrid, "Theme Red", function()
	MainFrame.BackgroundColor3 = Color3.fromRGB(22, 10, 12)
	Header.BackgroundColor3 = Color3.fromRGB(35, 15, 15)
	Title.TextColor3 = Color3.fromRGB(255, 80, 80)
end, 1, 1)

makeButton(settingsGrid, "Close Hub", function()
	ScreenGui:Destroy()
end, 1, 1)

local tabs = {
	createPageTab("Home"),
	createPageTab("Players"),
	createPageTab("Items"),
	createPageTab("Teleport"),
	createPageTab("Utility"),
	createPageTab("Settings")
}

for i, tab in ipairs(tabs) do
	tab.LayoutOrder = i
end

setPage("Home")
if tabs[1] then
	tabs[1].BackgroundColor3 = Color3.fromRGB(0, 255, 110)
	tabs[1].TextColor3 = Color3.fromRGB(12, 12, 12)
end

print("JMO HUB v2 loaded successfully.")
