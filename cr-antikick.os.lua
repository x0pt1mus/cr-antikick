getgenv().ProtectionEnabled = getgenv().ProtectionEnabled or true

getgenv().protectCharacter = function()
    local player = game:GetService("Players").LocalPlayer
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoidRootPart = character:WaitForChild("HumanoidRootPart", 10)
    local torso = character:FindFirstChild("Torso")
    local originalPosition = humanoidRootPart and humanoidRootPart.Position

    if not humanoidRootPart or not originalPosition then
        warn("[Protection] Missing HumanoidRootPart or initial position.")
        return
    end

    humanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
        if getgenv().ProtectionEnabled and (humanoidRootPart.Position - originalPosition).Magnitude > 50 then
            humanoidRootPart.CFrame = CFrame.new(originalPosition)
            warn("[Protection] Unauthorized position change detected!")
        end
    end)

    character.ChildAdded:Connect(function(child)
        if getgenv().ProtectionEnabled and child:IsA("SkateboardPlatform") then
            child:Destroy()
            warn("[Protection] Unauthorized object removed.")
        end
    end)

    if torso then
        torso:GetPropertyChangedSignal("Anchored"):Connect(function()
            if getgenv().ProtectionEnabled and torso.Anchored then
                torso.Anchored = false
                warn("[Protection] Prevented torso anchoring.")
            end
        end)
    end

    character.ChildRemoved:Connect(function(child)
        if getgenv().ProtectionEnabled and child.Name == "Humanoid" then
            warn("[Protection] Humanoid removed! Restoring...")
            local newHumanoid = Instance.new("Humanoid", character)
            humanoidRootPart.CFrame = CFrame.new(originalPosition)
        end
    end)
end

getgenv().initializeProtection = function()
    local player = game:GetService("Players").LocalPlayer
    if getgenv().ProtectionEnabled then
        player.CharacterAdded:Connect(getgenv().protectCharacter)
        if player.Character then task.defer(getgenv().protectCharacter) end
        warn("Protection enabled! Powered by x0pt1mus")
    else
        warn("Protection is disabled.")
    end
end

if getgenv().ProtectionEnabled then getgenv().initializeProtection() end
