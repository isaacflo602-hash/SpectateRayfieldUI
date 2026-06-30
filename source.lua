local Rayfield = loadstring(game:HttpGet("https://sirius.menu/rayfield"))()

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Workspace = game:GetService("Workspace")

local Window = Rayfield:CreateWindow({
    Name = "Spectate",
    LoadingTitle = "Spectate UI",
    LoadingSubtitle = "Loading Rayfield UI",
    ConfigurationSaving = {
        Enabled = false
    },
    Discord = {
        Enabled = false
    },
    KeySystem = false
})

local Tab = Window:CreateTab("Spectate", 4483362458)

local spectateEnabled = false
local spectateIndex = 1
local playerList = {}

local function updatePlayerList()
    playerList = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(playerList, player)
        end
    end
end

local function setSpectateCamera()
    if spectateEnabled and #playerList > 0 then
        local target = playerList[spectateIndex]
        if target.Character and target.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
        end
    else
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
            Workspace.CurrentCamera.CameraSubject = LocalPlayer.Character.Humanoid
        end
    end
end

local function updateSpectate()
    if spectateEnabled then
        updatePlayerList()

        if #playerList == 0 then
            Rayfield:Notify({
                Title = "Spectate",
                Content = "No players found.",
                Duration = 3
            })
            return
        end

        spectateIndex = math.clamp(spectateIndex, 1, #playerList)
        setSpectateCamera()

        Rayfield:Notify({
            Title = "Spectating",
            Content = playerList[spectateIndex].Name,
            Duration = 2
        })
    else
        setSpectateCamera()

        Rayfield:Notify({
            Title = "Spectate",
            Content = "Disabled",
            Duration = 2
        })
    end
end

Tab:CreateToggle({
    Name = "Enable Spectate",
    CurrentValue = false,
    Flag = "SpectateToggle",
    Callback = function(Value)
        spectateEnabled = Value
        updateSpectate()
    end,
})

Tab:CreateButton({
    Name = "Next Player",
    Callback = function()
        if not spectateEnabled then
            return
        end

        updatePlayerList()

        if #playerList == 0 then
            return
        end

        spectateIndex += 1

        if spectateIndex > #playerList then
            spectateIndex = 1
        end

        setSpectateCamera()

        Rayfield:Notify({
            Title = "Spectating",
            Content = playerList[spectateIndex].Name,
            Duration = 2
        })
    end,
})

Tab:CreateButton({
    Name = "Previous Player",
    Callback = function()
        if not spectateEnabled then
            return
        end

        updatePlayerList()

        if #playerList == 0 then
            return
        end

        spectateIndex -= 1

        if spectateIndex < 1 then
            spectateIndex = #playerList
        end

        setSpectateCamera()

        Rayfield:Notify({
            Title = "Spectating",
            Content = playerList[spectateIndex].Name,
            Duration = 2
        })
    end,
})

Players.PlayerAdded:Connect(updatePlayerList)

Players.PlayerRemoving:Connect(function()
    updatePlayerList()

    if spectateEnabled then
        if #playerList == 0 then
            spectateEnabled = false
            setSpectateCamera()
        else
            spectateIndex = math.clamp(spectateIndex, 1, #playerList)
            setSpectateCamera()
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function()
    if not spectateEnabled then
        setSpectateCamera()
    end
end)

updatePlayerList()
