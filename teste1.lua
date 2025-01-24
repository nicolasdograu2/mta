-- Script para MTA com funcionalidades de teste com painel
-- Compatível com Executor Xeno

local isEnabled = {
    aimbot = false,
    esp = false,
    noclip = false,
    hitbox = false,
    fly = false
}

local screenW, screenH = guiGetScreenSize()
local isPanelVisible = false

-- Funções auxiliares
local function toggleFeature(feature)
    isEnabled[feature] = not isEnabled[feature]
    outputChatBox(feature .. (isEnabled[feature] and " ativado" or " desativado"), 255, 255, 0)
end

local function closeScript()
    outputChatBox("Script encerrado.", 255, 0, 0)
    removeEventHandler("onClientRender", root, handleESP)
    removeEventHandler("onClientPreRender", root, handleAimbot)
    removeEventHandler("onClientRender", root, handleFly)
    removeCommandHandler("toggle_noclip")
    removeCommandHandler("toggle_hitbox")
    removeCommandHandler("toggle_esp")
    removeCommandHandler("toggle_aimbot")
    removeCommandHandler("toggle_fly")
    removeEventHandler("onClientRender", root, renderPanel)
end

-- Aimbot
local function handleAimbot()
    if not isEnabled.aimbot then return end
    
    local player = getLocalPlayer()
    local target = nil
    local minDistance = math.huge

    for _, v in ipairs(getElementsByType("player")) do
        if v ~= player and not isPedDead(v) and isLineOfSightClear(getElementPosition(player), getElementPosition(v), true, false, false, true, false, false, false) then
            local dist = getDistanceBetweenPoints3D(getElementPosition(player), getElementPosition(v))
            if dist < minDistance then
                minDistance = dist
                target = v
            end
        end
    end

    if target then
        setCameraTarget(target)
    end
end

-- ESP
local function handleESP()
    if not isEnabled.esp then return end

    for _, player in ipairs(getElementsByType("player")) do
        if player ~= getLocalPlayer() then
            local x, y, z = getElementPosition(player)
            local screenX, screenY = getScreenFromWorldPosition(x, y, z + 1, 0.06)
            if screenX and screenY then
                dxDrawText(getPlayerName(player), screenX, screenY, screenX, screenY, tocolor(255, 0, 0), 1, "default", "center", "center")
            end
        end
    end
end

-- No Clip
local function toggleNoClip()
    toggleFeature("noclip")
end

-- Hitbox
local function toggleHitbox()
    toggleFeature("hitbox")
    if isEnabled.hitbox then
        setPedTargetingMarker("circle")
    else
        setPedTargetingMarker("arrow")
    end
end

-- Fly
local function handleFly()
    if not isEnabled.fly then return end

    local x, y, z = getElementPosition(getLocalPlayer())
    setElementPosition(getLocalPlayer(), x, y, z + 0.5)
end

-- Painel
local function renderPanel()
    if not isPanelVisible then return end

    local panelW, panelH = 300, 200
    local panelX, panelY = (screenW - panelW) / 2, (screenH - panelH) / 2

    dxDrawRectangle(panelX, panelY, panelW, panelH, tocolor(0, 0, 0, 200))
    dxDrawText("Painel de Controle", panelX, panelY + 10, panelX + panelW, panelY + 30, tocolor(255, 255, 255), 1, "default", "center", "top")

    local features = {"aimbot", "esp", "noclip", "hitbox", "fly"}
    for i, feature in ipairs(features) do
        local y = panelY + 30 + (i - 1) * 30
        local state = isEnabled[feature] and "[Ativado]" or "[Desativado]"
        dxDrawText(feature .. " " .. state, panelX + 10, y, panelX + panelW, y + 20, tocolor(255, 255, 255), 1, "default")
    end

    dxDrawText("Pressione F9 para fechar o painel", panelX, panelY + panelH - 30, panelX + panelW, panelY + panelH, tocolor(255, 255, 255), 1, "default", "center", "bottom")
end

local function togglePanel()
    isPanelVisible = not isPanelVisible
    if isPanelVisible then
        addEventHandler("onClientRender", root, renderPanel)
    else
        removeEventHandler("onClientRender", root, renderPanel)
    end
end

-- Bindings
bindKey("F1", "down", function() toggleFeature("aimbot") end)
bindKey("F2", "down", function() toggleFeature("esp") end)
bindKey("F3", "down", toggleNoClip)
bindKey("F4", "down", toggleHitbox)
bindKey("F5", "down", function() toggleFeature("fly") end)
bindKey("F9", "down", togglePanel)
bindKey("9", "down", closeScript)

-- Event Handlers
addEventHandler("onClientRender", root, handleESP)
addEventHandler("onClientPreRender", root, handleAimbot)
addEventHandler("onClientRender", root, handleFly)

outputChatBox("Script iniciado. Use F1-F5 para ativar/desativar funcionalidades. Pressione F9 para abrir o painel. Tecla 9 para fechar.", 0, 255, 0)
