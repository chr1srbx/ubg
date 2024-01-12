-- FIXAUTOFARM!!!!!!!!!!!!!!! stamina break and predictable hits? (ghost would be a simple fix)
-- Game Variables
local formattedResult
local Target
local hitHand
local shouldDash
local heavyHit = false 
local takamuraHit = false
local outOfStamina = false
local staminaLimit
local distanceLimit
local playerStyle
local wolfBlock 

--Human-Like Mimic
local backOffDirection -- direction its going to back off from you to recover stamina, like holding S and A or S and D
local moveForwardDirection -- direction its going to come at you from, like holding W and A or W and D
local dashForward -- supposed to dash forward if further than 4.6 studs
local fakeHit -- supposed to get close to the player and wait for 2 seconds before blowing a hit

-- Autofarm Variables
local autofarm = false
local auto1 = true local auto2 = false local auto3 = false local auto4 = false auto5 = false auto6 = false auto7 = false auto8 = false
local targetPosition

-- General Variables
local Enabled = true
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = Instance.new("VirtualInputManager")
local GuiService = game:GetService("GuiService")
local VirtualInput = {}
local Client = game.Players.LocalPlayer
local States = workspace:WaitForChild("States")
local Effect = require(game:GetService("ReplicatedStorage").Modules.EffectHelper)

-- Settings
local actionLogger = true
local dashing = true
local attacking = true
local movement = true
local blocking = true

-- Action Logger

local gui = Instance.new("ScreenGui")
gui.Parent = game.Players.LocalPlayer.PlayerGui

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0.3, 0, 0.5, 0)
frame.Position = UDim2.new(0.7, 0, 0.25, 0)
frame.BackgroundColor3 = Color3.fromRGB(44, 44, 44) 
frame.BorderSizePixel = 5
frame.BorderColor3 = Color3.fromRGB(0, 0, 0)
frame.Parent = gui

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1, 0, 1, 0)
scrollFrame.Parent = frame
scrollFrame.ScrollBarThickness = 12 

local listLayout = Instance.new("UIListLayout")
listLayout.Parent = scrollFrame
listLayout.SortOrder = Enum.SortOrder.LayoutOrder

function addLog(message)
    if actionLogger then
        local logLabel = Instance.new("TextLabel")
        logLabel.Text = message
        logLabel.Size = UDim2.new(1, 0, 0, 30)
        logLabel.TextWrapped = true
        logLabel.TextColor3 = Color3.new(1, 1, 1)  
        logLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        logLabel.BorderSizePixel = 2
        logLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)  
        logLabel.Parent = scrollFrame

        scrollFrame.CanvasPosition = Vector2.new(0, scrollFrame.CanvasSize.Y.Offset)
        
        local totalSize = 0
        for _, child in pairs(scrollFrame:GetChildren()) do
            if child:IsA("TextLabel") then
                totalSize = totalSize + child.AbsoluteSize.Y
            end
        end
        scrollFrame.CanvasSize = UDim2.new(0, 0, 0, totalSize)
    end
end

function toggleVisibility()
    frame.Visible = not frame.Visible
end

--Init
setthreadidentity(8)

--Mouse Input FIX

local function handleGuiInset(x, y)
        local guiOffset, _ = GuiService:GetGuiInset()
        return x + guiOffset.X, y + guiOffset.Y
end
function VirtualInput.click(vec2)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 0, true)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 0, false)
end
function VirtualInput.rightClick(vec2)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 1, true)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 1, false)
end
function VirtualInput.mouseLeftDown(vec2)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 0, true)
end
function VirtualInput.mouseLeftUp(vec2)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 0, false)
end
function VirtualInput.mouseRightDown(vec2)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 1, true)
end
function VirtualInput.mouseRightUp(vec2)
    VirtualInput.sendMouseButtonEvent(vec2.x, vec2.y, 1, false)
end
function VirtualInput.sendMouseButtonEvent(x, y, button, isDown)
    x, y = handleGuiInset(x, y)
    VirtualInputManager:SendMouseButtonEvent(x, y, button, isDown, currentWindow, 0)
end
function VirtualInput.SendMouseMoveEvent(x, y)
    x, y = handleGuiInset(x, y)
    VirtualInputManager:SendMouseMoveEvent(x, y, currentWindow)
end
function nametoenum(name)
    return Enum.KeyCode[name] 
end
getgenv().mouse1click = newcclosure(function()
    VirtualInput.click(Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y))
end)
getgenv().mouse1press = newcclosure(function()
    VirtualInput.sendMouseButtonEvent(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y, 0, true)
end)
getgenv().mouse1release = newcclosure(function()
    VirtualInput.sendMouseButtonEvent(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y, 0, false)
end)
getgenv().mouse2press = newcclosure(function()
    VirtualInput.sendMouseButtonEvent(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y, 1, true)
end)
getgenv().mouse2release = newcclosure(function()
    VirtualInput.sendMouseButtonEvent(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y, 1, false)
end)
getgenv().mouse2click = newcclosure(function()
    VirtualInput.rightClick(Vector2.new(game.Players.LocalPlayer:GetMouse().X, game.Players.LocalPlayer:GetMouse().Y))
end)

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.X and not gameProcessedEvent then
        Enabled = false
        print("Enabled:", Enabled)
        frame.Visible = false
    end
end)

--Dash to avoid a hit
function Dash(hand)

    keyrelease(Enum.KeyCode.A)
    keyrelease(Enum.KeyCode.D)
    keyrelease(Enum.KeyCode.S)
    keyrelease(Enum.KeyCode.Space)

    if dashForward == 2 then
        dashForward = 0
        addLog("Ignoring Randomizer")
    else
        dashForward = math.random(0,3)
        moveForwardDirection = math.random(0,2)
        fakeHit = math.random(0,6)
        backOffDirection = math.random(0,2)
        addLog("backOffDirection:" .. backOffDirection)
        addLog("dashForward:" .. dashForward)
        addLog("moveForwardDirection:" .. moveForwardDirection)
        addLog("fakeHit:" .. fakeHit)
    end
    setthreadidentity(8)
    if hand == "RightHand" then
        keypress(Enum.KeyCode.A)
    elseif hand == "LeftHand" then
        keypress(Enum.KeyCode.D)
    elseif hand == "Takamura" then
        keypress(Enum.KeyCode.S)
    end

    if hand == nil then
        addLog("Dashed from trickster")
    else
        addLog("Dashed from : " .. hand)
    end

    keypress(Enum.KeyCode.Space)

    task.wait(0.01)
    keyrelease(Enum.KeyCode.A)
    keyrelease(Enum.KeyCode.D)
    keyrelease(Enum.KeyCode.S)
    keyrelease(Enum.KeyCode.Space)
end

function getRoot(chr)
    return chr.HumanoidRootPart
end

--Function Hook
shared.BaseEffectFunction = shared.BaseEffectFunction or {}

for i, v in pairs(Effect) do
    shared.BaseEffectFunction[i] = shared.BaseEffectFunction[i] or v
    
    Effect[i] = function(d, ...)
        task.spawn(function()
            if not Enabled then
                return
            end
            -- Clear Variables
            local delay 
            local Target = nil

            if type(d) == "table" and typeof(d[2]) == "Instance" then
                -- Finding target
                Target = States[Client.Name]:FindFirstChild("LockedOn", true).Value
                if not States[Client.Name]:FindFirstChild("Equipped", true).Value or Target == nil then
                    print("Ignore")
                    return
                end

                Distance = Client:DistanceFromCharacter(getRoot(Target).Position)

                -- Distance Check
                if Distance > 7.8 then
                    return
                end

                if d[1] == "StaminaBreak" or d[1] == "BlockBreak" and d[2] == Target then
                    addLog("Stamina Break or Block Break Occured!")
                    outOfStamina = true
                else
                    outOfStamina = false
                end

                if d[1] == "SlowMo" and d[3] == Target then
                    addLog("SlowMo Occured!")
                    outOfStamina = true
                else
                    outOfStamina = false
                end

                -- Other checks (heavy or non-heavy, slugger hit)
                if d[1] == "AttackTrail" and type(d[4]) == "string" then
                    hitHand = d[4]
                end

                if type(d[3]) == "boolean" and type(d[4]) == "boolean" then
                    if d[4] then
                        hitHand = "Takamura"
                        keyrelease(Enum.KeyCode.W)
                    end
                    heavyHit = d[3]
                    takamuraHit = d[4]
                    addLog("Heavy Hit : " .. heavyHit)
                    addLog("Takamura Hit : " .. takamuraHit)
                end

                -- Determine the delay
                if type(d[5]) == 'number' then
                    addLog("PlayerStyle : " .. playerStyle)
                    task.wait(0.01)
                    delay = d[5] - 0.1
                    if d[3] == "UltimateTrail" then
                        delay = d[5] - 0.10
                    elseif not heavyHit then
                        delay = d[5] - 0.5
                    elseif playerStyle == "Volk" and heavyHit then
                        delay = d[5] - 0.31
                        addLog("Wolf Dash")
                    end

                    formattedResult = string.format("%.2f", delay)
                    addLog("Formatted delay" .. formattedResult)
                    --addLog("Properties" .. "heavyHit :" .. heavyHit .. "takamuraHit : " .. takamuraHit)
                end

                -- Dash execution
                if (d[1] == "AttackTrail" or d[1] == "StartupHighlight" ) and d[2] ~= Client.Character and d[2] == Target and dashing then
                    shouldDash = true
                end
            end
        end)
        return shared.BaseEffectFunction[i](d, ...)
    end 
end 

local function mainLoop()
    local TargetInstance = States[Client.Name]:FindFirstChild("LockedOn", true) -- Find the target
    if TargetInstance.Value ~= "LockedOn" and TargetInstance.Value ~= nil then
        local TargetName = TargetInstance.Value.Name  -- Get the name of the instance as a string
        local Target = workspace.States:FindFirstChild(TargetName)
        local TargetValue = TargetInstance.Value  -- Assuming it's the player's name
        local TargetPlayer = game.Players:GetPlayerFromCharacter(TargetValue)  -- Get the player instance based on the name\
    
        if TargetPlayer and TargetPlayer.Character and Target:IsA("Folder") and TargetName ~= nil then
            local TargetHumanoidRootPart = getRoot(TargetPlayer.Character)
            local characterData = Target:FindFirstChild("CharacterData")
            local Occupied = Target:FindFirstChild("Occupied")
            local playerData = Target:FindFirstChild("PlayerData")
    
            if TargetHumanoidRootPart then
                local LocalPlayerCharacter = game.Players.LocalPlayer.Character
                local LocalPlayerHumanoidRootPart = getRoot(LocalPlayerCharacter)
                if LocalPlayerHumanoidRootPart and characterData then
                    --local == us, if no local then target, for ex: localHealth is our health, Health is our targets health.
                    local Distance = (TargetHumanoidRootPart.Position - LocalPlayerHumanoidRootPart.Position).Magnitude
                    local blocking = characterData.Blocking.Value
                    local pvpOff = characterData.PvPOff.Value
                    local inSafezone = characterData.InSafezone.Value
                    local canPunch = Occupied.CanPunch.Value
                    local punching = Occupied.Punching.Value
                    local dashing = characterData.Dashing.Value
                    local stunned = characterData.Stunned.Value
                    local ultEnergy = characterData.UltimateEnergy.Value
                    local blockEnergy = characterData.BlockEnergy.Value
                    local stamina = characterData.Stamina.Value
                    local Health = characterData.Health.Value
                    local RecoverHealth = characterData.RecoverHealth.Value
                    playerStyle = playerData.Style.Value
                    local localUlt = States[Client.Name]:FindFirstChild("UltimateEnergy", true).Value
                    local cutscene = States[Client.Name]:FindFirstChild("Cutscene", true).Value
                    local localStamina= States[Client.Name]:FindFirstChild("Stamina", true).Value
                    local localstunned = States[Client.Name]:FindFirstChild("Stunned", true).Value
                    local localblockEnergy = States[Client.Name]:FindFirstChild("BlockEnergy", true).Value
                    local localPlaystyle = States[Client.Name]:FindFirstChild("Style", true).Value
                    local localHealth = States[Client.Name]:FindFirstChild("Health", true).Value
                    local RecoveringHealth  = RecoverHealth - Health

                    if not cutscene then
                        if pvpOff or inSafezone then
                            return 
                        end

                        if wolfBlock then
                            Dash("RightHand")
                            wolfBlock = false
                        end

                        if outOfStamina and attacking then
                            if localUlt == 100 and localHealth > 25 and Health < 50 then
                                addLog("Doing Ultimate!")
                                keypress(Enum.KeyCode.Q)
                                task.wait(0.01)
                                keyrelease(Enum.KeyCode.Q)
                                return
                            else
                                addLog("M2")
                                mouse2click()
                                return
                            end
                        end

                        if localstunned and localblockEnergy > 6 and not outOfStamina then
                            --addLog("Blocking!")
                            keypress(Enum.KeyCode.F)
                        else
                            keyrelease(Enum.KeyCode.F)
                        end

                        if shouldDash then
                            task.wait(0.04)
                            task.wait(formattedResult)
                            Dash(hitHand)
                            shouldDash = false
                        end


                        if localStamina <= 20 and not shouldDash and movement then
                            if not outOfStamina then
                                --addLog("Out Of Stamina, Back off")
                                if backOffDirection == 0 then
                                    keypress(Enum.KeyCode.S)
                                elseif backOffDirection == 1 then
                                    keypress(Enum.KeyCode.S)
                                    keypress(Enum.KeyCode.A)
                                elseif backOffDirection == 2 then
                                    keypress(Enum.KeyCode.S)    
                                    keypress(Enum.KeyCode.D) 
                                end
                                staminaLimit = true
                            end
                        elseif localStamina >= 80 then
                            keyrelease(Enum.KeyCode.S)
                            keyrelease(Enum.KeyCode.D) 
                            keyrelease(Enum.KeyCode.A)
                            staminaLimit = false
                        end

                        if Distance > 4.8 and localStamina >= 80 and movement then
                            --addLog("Getting Closer..")

                            if dashForward == 2 then
                                moveForwardDirection = 0
                                keypress(Enum.KeyCode.Space)
                            end

                            if moveForwardDirection == 0 then
                                keypress(Enum.KeyCode.W)
                            elseif moveForwardDirection == 1 then
                                keypress(Enum.KeyCode.W)
                                keypress(Enum.KeyCode.A)
                            elseif moveForwardDirection == 2 then
                                keypress(Enum.KeyCode.W)    
                                keypress(Enum.KeyCode.D)  
                            end
                            distanceLimit = true
                        else
                        -- addLog("In Range")
                            keyrelease(Enum.KeyCode.W)
                            keyrelease(Enum.KeyCode.D)  
                            keyrelease(Enum.KeyCode.Space)
                            keyrelease(Enum.KeyCode.A)
                            distanceLimit = false
                        end

                        if RecoveringHealth > 10 and Distance < 4.8 and localStamina > 25 and attacking then 
                            mouse2click()
                        end

                        if not staminaLimit and Distance < 4.8 and attacking then
                            if fakeHit == 5 then
                                task.wait(math.random(0.4, 2))
                                fakeHit = 0
                            end 
                            mouse1click()
                        end
                    end

                else
                    addLog("Local player's HumanoidRootPart not found")
                end
            else
                addLog("Target's HumanoidRootPart not found")
            end
        else
            addLog("Target player not found")
            keyrelease(Enum.KeyCode.W)
            keyrelease(Enum.KeyCode.S)
            keyrelease(Enum.KeyCode.Space)
        end
    end
end

local function Autofarm()
    local localEquipped = States[Client.Name]:FindFirstChild("Equipped", true).Value == true
    if not localEquipped then
        local humanoid = game.Players.LocalPlayer.Character:WaitForChild("Humanoid")
        if auto1 then
            targetPosition = Vector3.new(-9.06866646, 2, -16.7717419)
        elseif auto2 then
            targetPosition = Vector3.new(-9.0687294, 2, 7.36345148)
        elseif auto3 then
            targetPosition = Vector3.new(21.21317481994629, 2, 7.55935668945312)
        elseif auto4 then
            targetPosition = Vector3.new(18.48920440673828, 3, -16.75988006591797)
        elseif auto5 then
            targetPosition = Vector3.new(-6.330819, 3, 108.24155)
        elseif auto6 then
            targetPosition = Vector3.new(-7.6166, 3, 84.427)
        elseif auto7 then
            targetPosition = Vector3.new(16.198, 3, 107.305)
        elseif auto8 then
            targetPosition = Vector3.new(16.798, 3, 84.2217)
        end
        local tolerance = 4 -- Adjust this value to control how close the character needs to get to the target

    -- Function to teleport the character to the target position
        function teleportCharacterTo(targetPosition)
            local character = humanoid.Parent
            local primaryPart = character.PrimaryPart

            primaryPart.CFrame = CFrame.new(targetPosition) -- Teleport the character to the target position
        end
    end
    -- Teleport the character to the target position
    teleportCharacterTo(targetPosition)
end


-- Other initializations...
addLog("!Loaded!")
Dash("LeftHand")

-- Main loop
while Enabled do
    mainLoop()
    task.wait()
end

while autofarm do
    Autofarm()
    task.wait()
end
    
