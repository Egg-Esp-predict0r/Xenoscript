-- ðŸ¥š EGG RANDOMIZER GUI - Made by Kuni

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local LocalPlayer = Players.LocalPlayer

-- Config
local DETECTION_RANGE = 30
local COOLDOWN = 8
local ESP_ENABLED = true
local canRandomize = true
local running = true

local EGG_LIST = {
    "Bug Egg", "Night Egg", "Mythical Egg", "Paradise Egg",
    "Oasis Egg", "Primal Egg", "Dinosaur Egg"
}

local PET_POOL = {
    ["Bug Egg"] = {"Snail", "Giant Ant", "Praying Mantis", "Dragonfly"},
    ["Night Egg"] = {"Echo Frog", "Raccoon", "Night Owl", "Hedgehog", "Caterpillar"},
    ["Mythical Egg"] = {"Squirrel", "Red Giant Ant", "Grey Mouse", "Brown Mouse"},
    ["Paradise Egg"] = {"Ostrich", "Peacock", "Capybara", "Mimic Octopus"},
    ["Oasis Egg"] = {"Meerkat", "Sandsnake", "Oxolotl", "Fennec Fox"},
    ["Primal Egg"] = {"Parasaurolophus", "Iguanodon", "Dilophosaurus", "Ankylosaurus", "Spinosaurus", "Triceratops"},
    ["Dinosaur Egg"] = {"T-Rex", "Raptor", "Triceratops", "Pterodactyl", "Brontosaurus"}
}

local TARGET_PETS = {
    ["Bug Egg"] = {"Dragonfly"},
    ["Night Egg"] = {"Raccoon"},
    ["Mythical Egg"] = {"Squirrel"},
    ["Paradise Egg"] = {"Mimic Octopus"},
    ["Oasis Egg"] = {"Fennec Fox"},
    ["Primal Egg"] = {"Spinosaurus", "Ankylosaurus"},
    ["Dinosaur Egg"] = {"T-Rex"}
}

local activeEggs = {}

local function getRandomPet(eggName)
    local pool = PET_POOL[eggName]
    return pool and pool[math.random(1, #pool)] or "Unknown"
end

local function isTargetPet(eggName, pet)
    local targets = TARGET_PETS[eggName]
    if not targets then return false end
    for _, target in ipairs(targets) do
        if pet == target then
            return true
        end
    end
    return false
end

-- Attach ESP and prediction text
local function attachUI(egg, predicted, isDivine)
    local part = egg:FindFirstChildWhichIsA("BasePart")
    if not part then return end

    local gui = egg:FindFirstChild("PredictionUI")
    if not gui then
        gui = Instance.new("BillboardGui")
        gui.Name = "PredictionUI"
        gui.Adornee = part
        gui.Size = UDim2.new(0, 140, 0, 60)
        gui.StudsOffset = Vector3.new(0, 3, 0)
        gui.AlwaysOnTop = true
        gui.Parent = egg

        local label = Instance.new("TextLabel", gui)
        label.Name = "Label"
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.new(1, 1, 0)
        label.TextScaled = true
        label.Font = Enum.Font.GothamBold
        label.Text = ""
    end

    local label = gui:FindFirstChild("Label")
    if label then
        if isDivine then
            label.Text = string.format("ðŸ¥š DIVINE EGG WAS FOUND!\n%s", predicted)
            label.TextColor3 = Color3.fromRGB(255, 215, 0)
        else
            label.Text = ESP_ENABLED and string.format("%s â†’\n%s", egg.Name, predicted) or ""
            label.TextColor3 = Color3.new(1, 1, 0)
        end
    end

    gui.Enabled = ESP_ENABLED
end

-- GUI
local function createControlPanel()
    local playerGui = LocalPlayer:WaitForChild("PlayerGui")
    local gui = Instance.new("ScreenGui")
    gui.Name = "EggRandomizerGui"
    gui.ResetOnSpawn = false
    gui.Parent = playerGui

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 250, 0, 250)
    frame.Position = UDim2.new(0.02, 0, 0.25, 0)
    frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    frame.BorderSizePixel = 0
    frame.Active = true
    frame.Draggable = true

    local title = Instance.new("TextLabel", frame)
    title.Size = UDim2.new(1, 0, 0, 30)
    title.Text = "ðŸ¥š EGG RANDOMIZER"
    title.Font = Enum.Font.GothamBold
    title.TextColor3 = Color3.new(1, 1, 1)
    title.BackgroundTransparency = 1
    title.TextScaled = true

    local espBtn = Instance.new("TextButton", frame)
    espBtn.Size = UDim2.new(1, -20, 0, 40)
    espBtn.Position = UDim2.new(0, 10, 0, 40)
    espBtn.Font = Enum.Font.GothamBold
    espBtn.TextScaled = true
    espBtn.TextColor3 = Color3.new(1, 1, 1)
    espBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    espBtn.Text = "ðŸ” ESP: ON"
    espBtn.MouseButton1Click:Connect(function()
        ESP_ENABLED = not ESP_ENABLED
        espBtn.Text = ESP_ENABLED and "ðŸ” ESP: ON" or "ðŸ”’ ESP: OFF"
        espBtn.BackgroundColor3 = ESP_ENABLED and Color3.fromRGB(0,170,0) or Color3.fromRGB(170,0,0)
    end)

    local randBtn = Instance.new("TextButton", frame)
    randBtn.Size = UDim2.new(1, -20, 0, 40)
    randBtn.Position = UDim2.new(0, 10, 0, 90)
    randBtn.Font = Enum.Font.GothamBold
    randBtn.TextScaled = true
    randBtn.TextColor3 = Color3.new(1, 1, 1)
    randBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
    randBtn.Text = "ðŸŽ² RANDOMIZE ONCE"
    randBtn.MouseButton1Click:Connect(function()
        if not canRandomize then return end
        canRandomize = false

        for egg, data in pairs(activeEggs) do
            if egg and egg.Parent then
                local result = getRandomPet(egg.Name)
                data.predicted = result
                data.divine = isTargetPet(egg.Name, result)
            end
        end

        randBtn.Text = "â± WAIT (8s)"
        randBtn.BackgroundColor3 = Color3.fromRGB(170, 170, 0)
        task.delay(COOLDOWN, function()
            canRandomize = true
            randBtn.Text = "ðŸŽ² RANDOMIZE ONCE"
            randBtn.BackgroundColor3 = Color3.fromRGB(0, 170, 0)
        end)
    end)

    local stopBtn = Instance.new("TextButton", frame)
    stopBtn.Size = UDim2.new(1, -20, 0, 40)
    stopBtn.Position = UDim2.new(0, 10, 0, 140)
    stopBtn.Font = Enum.Font.GothamBold
    stopBtn.TextScaled = true
    stopBtn.TextColor3 = Color3.new(1, 1, 1)
    stopBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 0)
    stopBtn.Text = "âŒ STOP GUI"
    stopBtn.MouseButton1Click:Connect(function()
        running = false
        gui:Destroy()
    end)

    local footer = Instance.new("TextLabel", frame)
    footer.Size = UDim2.new(1, 0, 0, 20)
    footer.Position = UDim2.new(0, 0, 1, -20)
    footer.Text = "Made by GROW A GARDEN SCRIPTERS"
    footer.Font = Enum.Font.Gotham
    footer.TextColor3 = Color3.fromRGB(200, 200, 200)
    footer.BackgroundTransparency = 1
    footer.TextScaled = true
end

createControlPanel()

-- Egg Scanner
task.spawn(function()
    while running do
        local char = LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if not root then task.wait(1) continue end

        -- Detect eggs nearby
        for _, obj in ipairs(Workspace:GetDescendants()) do
            if table.find(EGG_LIST, obj.Name) and obj:IsA("Model") and not activeEggs[obj] then
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part and (part.Position - root.Position).Magnitude <= DETECTION_RANGE then
                    activeEggs[obj] = {
                        predicted = getRandomPet(obj.Name),
                        divine = false
                    }
                end
            end
        end

        -- Update ESP text on eggs
        for egg, data in pairs(activeEggs) do
            if egg and egg.Parent then
                attachUI(egg, data.predicted, data.divine)
            else
                activeEggs[egg] = nil
            end
        end

        task.wait(1)
    end
end)
