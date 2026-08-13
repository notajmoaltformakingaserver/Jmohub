-- [[ JMO HUB v2 ]]
-- Universal Client-Side Interface Framework

local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

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

-- Draggable UI Scripting
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

-- Close Button
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

-- Minimize Button
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

-- Dividers
local Divider = Instance.new("Frame")
Divider.Size = UDim2.new(1, 0, 0, 1)
Divider.Position = UDim2.new(0, 0, 0, 35)
Divider.BackgroundColor3 = Theme.Border
Divider.BorderSizePixel = 0
Divider.Parent = MainWindow

-- Sidebar Navigation Layout
local Sidebar = Instance.new("ScrollingFrame")
Sidebar.Name = "Sidebar"
Sidebar.Size = UDim2.new(0, 140, 1, 0)
Sidebar.BackgroundColor3 = Theme.Panel
Sidebar.BorderSizePixel = 0
Sidebar.CanvasSize = UDim2.new(0, 0, 0, 450)
Sidebar.ScrollBarThickness = 2
Sidebar.ScrollBarImageColor3 = Theme.Border
Sidebar.Parent = ContentContainer

local SidebarLayout = Instance.new("UIListLayout")
SidebarLayout.Parent = Sidebar
SidebarLayout.SortOrder = Enum.SortOrder.LayoutOrder

-- Section View Container
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
	Page.CanvasSize = UDim2.new(0, 0, 0, 600)
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
	
	-- Sidebar Nav Button
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

-- UI Component Utility Functions
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
		callback(Enabled)
	end)
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
		local relX = math.max(0, math.min(x - SliderBar.AbsolutePosition.X, SliderBar.AbsoluteSize.X))
		local percentage = relX / SliderBar.AbsoluteSize.X
		local value = min + (max - min) * percentage
		SliderButton.Position = UDim2.new(percentage, -8, 0.5, -8)
		Label.Text = text .. " : " .. tostring(math.floor(value))
		callback(math.floor(value))
	end
	
	SliderButton.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			local connection
			connection = UserInputService.InputChanged:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseMovement then
					UpdateSlider(input.Position.X)
				end
			end)
			UserInputService.InputEnded:Connect(function(input)
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					connection:Disconnect()
				end
			end)
		end
	end)
end

-- Create pages and populate with UI elements
local HomePage = CreatePage("Home")
UI:CreateSectionHeader(HomePage, "Welcome")
UI:CreateButton(HomePage, "Test Button", function()
	print("Button clicked!")
end)
UI:CreateToggle(HomePage, "Test Toggle", false, function(enabled)
	print("Toggle:", enabled)
end)
UI:CreateSlider(HomePage, "Test Slider", 0, 100, 50, function(value)
	print("Slider value:", value)
end)

-- Make home page visible by default
HomePage.Visible = true
if Pages["Home"] then
	for _, b in pairs(Sidebar:GetChildren()) do
		if b:IsA("TextButton") and b.Text:find("HOME") then
			b.TextColor3 = Theme.Border
			if b:FindFirstChild("Frame") then
				b.Frame.Visible = true
			end
		end
	end
end


print("JMO HUB v2 loaded successfully!")