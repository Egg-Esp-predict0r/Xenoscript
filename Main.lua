--// Services
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local PlayerGui = player:WaitForChild("PlayerGui")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

--// Config
local mutations = {
	"Shiny", "Inverted", "Frozen", "Windy", "Golden", "Mega", "Tiny",
	"Tranquil", "IronSkin", "Radiant", "Rainbow", "Shocked", "Ascended"
}
local currentMutation = mutations[math.random(#mutations)]
local espVisible = true

--// UI Setup
local gui = Instance.new("ScreenGui", PlayerGui)
gui.Name = "MutationESP_UI"
gui.ResetOnSpawn = false

local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 240, 0, 200)
frame.Position = UDim2.new(0.5, -120, 0.4, 0)
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 12)
local stroke = Instance.new("UIStroke", frame)
stroke.Color = Color3.fromRGB(80, 120, 255)
stroke.Thickness = 1.5

--// Store all text instances for gradient
local rainbowTextObjects = {}

local title = Instance.new("TextLabel", frame)
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundTransparency = 1
title.Font = Enum.Font.GothamBold
title.Text = "Mutation Randomizer"
title.TextSize = 20
table.insert(rainbowTextObjects, title)

--// Button Factory
local function createButton(text, yPos, bgColor)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(0.9, 0, 0, 36)
	btn.Position = UDim2.new(0.05, 0, 0, yPos)
	btn.BackgroundColor3 = bgColor
	btn.Text = text
	btn.Font = Enum.Font.Gotham
	btn.TextSize = 16
	btn.AutoButtonColor = false

	Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
	local stroke = Instance.new("UIStroke", btn)
	stroke.Color = Color3.fromRGB(0, 0, 0)
	stroke.Thickness = 1.2

	btn.MouseEnter:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = bgColor:Lerp(Color3.new(1, 1, 1), 0.2)
		}):Play()
	end)
	btn.MouseLeave:Connect(function()
		TweenService:Create(btn, TweenInfo.new(0.2), {
			BackgroundColor3 = bgColor
		}):Play()
	end)

	btn.Parent = frame
	table.insert(rainbowTextObjects, btn)
	return btn
end

--// Buttons
local rerollBtn = createButton("ðŸŽ² Reroll Mutation", 50, Color3.fromRGB(100, 200, 255))
local toggleBtn = createButton("ðŸ‘ï¸ Toggle ESP", 95, Color3.fromRGB(180, 255, 180))

--// Credit Footer
local credit = Instance.new("TextLabel", frame)
credit.Size = UDim2.new(1, 0, 0, 20)
credit.Position = UDim2.new(0, 0, 1, -20)
credit.Text = "Made by Xenooscript"
credit.BackgroundTransparency = 1
credit.Font = Enum.Font.Gotham
credit.TextSize = 13
table.insert(rainbowTextObjects, credit)

--// Find the Mutation Machine
local function findMachine()
	for _, obj in pairs(Workspace:GetDescendants()) do
		if obj:IsA("Model") and obj.Name:lower():find("mutation") then
			return obj
		end
	end
end

local machine = findMachine()
if not machine then
	warn("âŒ Mutation machine not found.")
	return
end

local basePart = machine:FindFirstChildWhichIsA("BasePart")
if not basePart then
	warn("âŒ No BasePart in mutation machine.")
	return
end

--// Billboard ESP
local espGui = Instance.new("BillboardGui", basePart)
espGui.Name = "MutationESP"
espGui.Adornee = basePart
espGui.Size = UDim2.new(0, 200, 0, 40)
espGui.StudsOffset = Vector3.new(0, 3, 0)
espGui.AlwaysOnTop = true

local espLabel = Instance.new("TextLabel", espGui)
espLabel.Size = UDim2.new(1, 0, 1, 0)
espLabel.BackgroundTransparency = 1
espLabel.Font = Enum.Font.GothamBold
espLabel.TextSize = 24
espLabel.TextStrokeTransparency = 0.2
espLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
espLabel.Text = currentMutation
table.insert(rainbowTextObjects, espLabel)

--// Animate Rainbow Text
local hue = 0
RunService.RenderStepped:Connect(function()
	hue = (hue + 0.01) % 1
	local color = Color3.fromHSV(hue, 1, 1)
	for _, obj in ipairs(rainbowTextObjects) do
		if obj:IsA("TextLabel") or obj:IsA("TextButton") then
			obj.TextColor3 = color
		end
	end
end)

--// Premium Loading Function
local function showLoadingThenReroll()
	rerollBtn.Text = "Loading..."

	-- Insert the entire loading screen block here
	local loadingGui = Instance.new("ScreenGui")
	loadingGui.Name = "PremiumGradientLoadingUI"
	loadingGui.IgnoreGuiInset = true
	loadingGui.ResetOnSpawn = false
	loadingGui.Parent = game:GetService("CoreGui")

	local background = Instance.new("Frame", loadingGui)
	background.Size = UDim2.new(1, 0, 1, 0)
	background.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	background.BackgroundTransparency = 1

	local mainFrame = Instance.new("Frame", background)
	mainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	mainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainFrame.Size = UDim2.new(0, 360, 0, 200)
	mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	Instance.new("UICorner", mainFrame).CornerRadius = UDim.new(0, 12)
	mainFrame.BackgroundTransparency = 0
	mainFrame.Visible = false

	local playerInfo = Instance.new("Frame", mainFrame)
	playerInfo.Size = UDim2.new(0, 120, 1, 0)
	playerInfo.Position = UDim2.new(0, 0, 0, 0)
	playerInfo.BackgroundTransparency = 1

	local avatar = Instance.new("ImageLabel", playerInfo)
	avatar.Size = UDim2.new(0, 60, 0, 60)
	avatar.Position = UDim2.new(0.5, -30, 0, 20)
	avatar.BackgroundTransparency = 1
	avatar.Image = Players:GetUserThumbnailAsync(player.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)

	local nameLabel = Instance.new("TextLabel", playerInfo)
	nameLabel.Position = UDim2.new(0.5, -50, 0, 90)
	nameLabel.Size = UDim2.new(1, 0, 0, 24)
	nameLabel.Text = player.DisplayName
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.BackgroundTransparency = 1
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold

	local spinner = Instance.new("ImageLabel", mainFrame)
	spinner.Size = UDim2.new(0, 40, 0, 40)
	spinner.Position = UDim2.new(1, -50, 0, 20)
	spinner.BackgroundTransparency = 1
	spinner.Image = "rbxassetid://1095708"
	spinner.ImageColor3 = Color3.fromRGB(100, 200, 255)

	task.spawn(function()
		while spinner and spinner.Parent do
			spinner.Rotation += 5
			RunService.RenderStepped:Wait()
		end
	end)

	local mutationText = Instance.new("TextLabel", mainFrame)
	mutationText.Size = UDim2.new(1, -40, 0, 30)
	mutationText.Position = UDim2.new(0, 20, 1, -70)
	mutationText.BackgroundTransparency = 1
	mutationText.Font = Enum.Font.GothamBold
	mutationText.Text = ""
	mutationText.TextSize = 20
	mutationText.TextColor3 = Color3.fromRGB(255, 255, 255)
	mutationText.TextTransparency = 0
	mutationText.TextStrokeTransparency = 0.5

	local mutationGradient = Instance.new("UIGradient", mutationText)
	mutationGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 255)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(130, 180, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 140, 180))
	}

	local message = "Changing your mutation..."
	task.spawn(function()
		for i = 1, #message do
			mutationText.Text = string.sub(message, 1, i)
			task.wait(0.05)
		end
	end)

	local progressBarBg = Instance.new("Frame", mainFrame)
	progressBarBg.Position = UDim2.new(0.1, 0, 1, -40)
	progressBarBg.Size = UDim2.new(0.8, 0, 0, 12)
	progressBarBg.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
	Instance.new("UICorner", progressBarBg).CornerRadius = UDim.new(1, 0)

	local progressBar = Instance.new("Frame", progressBarBg)
	progressBar.Size = UDim2.new(0, 0, 1, 0)
	progressBar.BackgroundColor3 = Color3.fromRGB(80, 180, 255)
	Instance.new("UICorner", progressBar).CornerRadius = UDim.new(1, 0)

	local barGradient = Instance.new("UIGradient", progressBar)
	barGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(100, 255, 200)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(60, 180, 255))
	}
	barGradient.Rotation = 45

	task.spawn(function()
		while progressBar and progressBar.Parent do
			for i = 0, 360, 1 do
				barGradient.Rotation = i
				RunService.RenderStepped:Wait()
			end
		end
	end)

	TweenService:Create(background, TweenInfo.new(0.5), {BackgroundTransparency = 0}):Play()
	mainFrame.Visible = true

	local function animateProgressBar(duration)
		local tween = TweenService:Create(progressBar, TweenInfo.new(duration, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), {
			Size = UDim2.new(1, 0, 1, 0)
		})
		tween:Play()
		tween.Completed:Wait()
	end

	task.spawn(function()
		animateProgressBar(3)
	end)

	task.delay(3.3, function()
		local info = TweenInfo.new(0.6, Enum.EasingStyle.Quad)
		TweenService:Create(background, info, {BackgroundTransparency = 1}):Play()
		TweenService:Create(mainFrame, info, {BackgroundTransparency = 1}):Play()
		TweenService:Create(avatar, info, {ImageTransparency = 1}):Play()
		TweenService:Create(nameLabel, info, {TextTransparency = 1}):Play()
		TweenService:Create(spinner, info, {ImageTransparency = 1}):Play()
		TweenService:Create(mutationText, info, {TextTransparency = 1}):Play()
		TweenService:Create(progressBar, info, {BackgroundTransparency = 1}):Play()
		TweenService:Create(progressBarBg, info, {BackgroundTransparency = 1}):Play()
		task.wait(0.8)
		loadingGui:Destroy()

		-- Run reroll logic after loading
		local duration = 2
		local interval = 0.1
		for i = 1, math.floor(duration / interval) do
			espLabel.Text = mutations[math.random(#mutations)]
			wait(interval)
		end
		currentMutation = mutations[math.random(#mutations)]
		espLabel.Text = currentMutation
		rerollBtn.Text = "ðŸŽ² Reroll Mutation"
	end)
end

--// Button Events
rerollBtn.MouseButton1Click:Connect(showLoadingThenReroll)
toggleBtn.MouseButton1Click:Connect(function()
	espVisible = not espVisible
	espGui.Enabled = espVisible
end)
