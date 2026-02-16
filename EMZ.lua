-- EMZ Panel Pro VIP (Interfaz Elegante y Profesional)
-- VERSIÓN COMPLETA - CORREGIDA PARA SAMSUNG A21S + DELTA EXECUTOR
-- TODAS LAS FUNCIONES FUNCIONAN: ESP, AIMBOT, FOV, ETC.

local player = game.Players.LocalPlayer
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local camera = workspace.CurrentCamera
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")

local flySpeed = 20
local walkSpeed = 20
local flying = false
local speedEnabled = false
local noclipEnabled = false
local espBodyEnabled = false
local espEnemyEnabled = false
local espBoxEnabled = false
local espLineEnabled = false
local aimbotEnabled = false
local aimbotVisible = false
local aimbotFOV = 50
local aimbotTarget = "cabeza"
local infiniteJumpEnabled = false

local minValue = 20
local maxValue = 1000
local minFOV = 20
local maxFOV = 100

-- Colores para el cambio automático SUAVE (transición gradual)
local coloresRotativos = {
	Color3.fromRGB(255, 0, 0),    -- Rojo
	Color3.fromRGB(255, 255, 0),  -- Amarillo
	Color3.fromRGB(0, 255, 0),    -- Verde
	Color3.fromRGB(0, 255, 255),  -- Celeste
	Color3.fromRGB(0, 100, 255),  -- Azul
	Color3.fromRGB(255, 0, 255),  -- Magenta
	Color3.fromRGB(255, 165, 0),  -- Naranja
	Color3.fromRGB(255, 105, 180) -- Rosa
}
local colorIndex = 1
local colorActual = coloresRotativos[1]
local colorObjetivo = coloresRotativos[2]
local transicionProgreso = 0
local VELOCIDAD_TRANSICION = 0.02 -- Más lento = transición más suave

-- Cambiar color con transición suave
task.spawn(function()
	while true do
		task.wait(0.05) -- Actualizar cada 0.05 segundos para transición suave
		
		-- Incrementar progreso de transición
		transicionProgreso = transicionProgreso + VELOCIDAD_TRANSICION
		
		if transicionProgreso >= 1 then
			transicionProgreso = 0
			colorIndex = colorIndex % #coloresRotativos + 1
			colorActual = colorObjetivo
			colorObjetivo = coloresRotativos[(colorIndex % #coloresRotativos) + 1]
		end
		
		-- Interpolar entre color actual y objetivo
		local r = colorActual.R + (colorObjetivo.R - colorActual.R) * transicionProgreso
		local g = colorActual.G + (colorObjetivo.G - colorActual.G) * transicionProgreso
		local b = colorActual.B + (colorObjetivo.B - colorActual.B) * transicionProgreso
		
		colorActual = Color3.new(r, g, b)
	end
end)

-- GUI
local gui = Instance.new("ScreenGui")
gui.Parent = player:WaitForChild("PlayerGui")
gui.Name = "DRIP_CLIENT_MOBILE"
gui.ResetOnSpawn = false

local function notifyToggle(optionName, enabled)
	local ok, _ = pcall(function()
		if enabled then
			-- soundOn:Play()
		else
			-- soundOff:Play()
		end
	end)
	pcall(function()
		local verb = enabled and "activada" or "desactivada"
		StarterGui:SetCore("ChatMakeSystemMessage", {
			Text = optionName .. " " .. verb,
			Color = Color3.fromRGB(120, 200, 255),
			Font = Enum.Font.SourceSansBold,
			FontSize = Enum.FontSize.Size14
		})
	end)
end

-- CONTADOR DE ENEMIGOS EN LA PANTALLA
local enemyCountDisplay = Instance.new("TextLabel", gui)
enemyCountDisplay.Name = "EnemyCountDisplay"
enemyCountDisplay.Size = UDim2.new(0, 200, 0, 40)
enemyCountDisplay.Position = UDim2.new(0.5, -100, 0, 20)
enemyCountDisplay.BackgroundTransparency = 1
enemyCountDisplay.Text = "Enemigos: 0"
enemyCountDisplay.TextColor3 = Color3.fromRGB(255, 0, 0)
enemyCountDisplay.Font = Enum.Font.GothamBold
enemyCountDisplay.TextSize = 25
enemyCountDisplay.TextXAlignment = Enum.TextXAlignment.Center
enemyCountDisplay.Visible = false  -- Solo visible cuando ESP Enemigos está ON

-- ================== DISEÑO MOBILE ==================
local PANEL_WIDTH = 280
local PANEL_HEIGHT = 280

-- Barra 40 pixels, negra, alineada con el panel
local topBar = Instance.new("Frame", gui)
topBar.Name = "TopBar"
topBar.Size = UDim2.new(0, PANEL_WIDTH, 0, 40)
topBar.Position = UDim2.new(0, 50, 0, 20)
topBar.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
topBar.BorderSizePixel = 0

-- Título morado (CAMBIADO: ahora dice "DRIP CLIENT || By EMZ")
local titleLabel = Instance.new("TextLabel", topBar)
titleLabel.Name = "Title"
titleLabel.Size = UDim2.new(1, -42, 1, 0)
titleLabel.Position = UDim2.new(0, 10, 0, 0)
titleLabel.BackgroundTransparency = 1
titleLabel.Text = "DRIP CLIENT || By EMZ"
titleLabel.TextColor3 = Color3.fromRGB(170, 100, 255)
titleLabel.Font = Enum.Font.GothamSemibold
titleLabel.TextSize = 13
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.TextYAlignment = Enum.TextYAlignment.Center

-- Línea gruesa morada debajo de la barra
local purpleLine = Instance.new("Frame", topBar)
purpleLine.Name = "PurpleLine"
purpleLine.Size = UDim2.new(1, 0, 0, 4)
purpleLine.Position = UDim2.new(0, 0, 1, 0)
purpleLine.BackgroundColor3 = Color3.fromRGB(170, 100, 255)
purpleLine.BorderSizePixel = 0

-- Botón Toggle (▶/◀) morado
local toggleButton = Instance.new("TextButton", topBar)
toggleButton.Name = "ToggleButton"
toggleButton.Size = UDim2.new(0, 40, 0, 40)
toggleButton.Position = UDim2.new(1, -40, 0, 0)
toggleButton.BackgroundTransparency = 1
toggleButton.Text = "▶"
toggleButton.TextColor3 = Color3.fromRGB(170, 100, 255)
toggleButton.Font = Enum.Font.GothamBold
toggleButton.TextSize = 18
toggleButton.BorderSizePixel = 0
toggleButton.AutoButtonColor = false

local isOpen = false

-- Panel principal
local panel = Instance.new("Frame", gui)
panel.Name = "EMZ_Panel_VIP"
panel.Size = UDim2.new(0, PANEL_WIDTH, 0, PANEL_HEIGHT)
panel.Position = UDim2.new(0, 50, 0, 60)
panel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
panel.BorderSizePixel = 0
panel.Visible = false
panel.Active = true

-- CONTENEDOR DE PESTAÑAS (arriba horizontal)
local tabContainer = Instance.new("Frame", panel)
tabContainer.Name = "TabContainer"
tabContainer.Size = UDim2.new(1, 0, 0, 50)
tabContainer.Position = UDim2.new(0, 0, 0, 0)
tabContainer.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
tabContainer.BorderSizePixel = 0

local tabLayout = Instance.new("UIListLayout", tabContainer)
tabLayout.Padding = UDim.new(0, 8)
tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
tabLayout.VerticalAlignment = Enum.VerticalAlignment.Center
tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
tabLayout.FillDirection = Enum.FillDirection.Horizontal

-- CONTENEDOR DE CONTENIDO (debajo)
local contentContainer = Instance.new("Frame", panel)
contentContainer.Name = "ContentContainer"
contentContainer.Size = UDim2.new(1, 0, 1, -50)
contentContainer.Position = UDim2.new(0, 0, 0, 50)
contentContainer.BackgroundTransparency = 1
contentContainer.BorderSizePixel = 0

-- Scroll principal del panel
local scroll = Instance.new("ScrollingFrame", contentContainer)
scroll.Name = "Scroll"
scroll.Size = UDim2.new(1, 0, 1, 0)
scroll.Position = UDim2.new(0, 0, 0, 0)
scroll.BackgroundTransparency = 1
scroll.ScrollBarThickness = 5
scroll.BorderSizePixel = 0
scroll.CanvasSize = UDim2.new(0, 0, 0, 0)
scroll.ScrollingDirection = Enum.ScrollingDirection.Y

local padding = Instance.new("UIPadding", scroll)
padding.PaddingLeft = UDim.new(0, 12)
padding.PaddingRight = UDim.new(0, 12)
padding.PaddingTop = UDim.new(0, 12)
padding.PaddingBottom = UDim.new(0, 12)

local layout = Instance.new("UIListLayout", scroll)
layout.Padding = UDim.new(0, 10)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.SortOrder = Enum.SortOrder.LayoutOrder

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
	scroll.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
end)

-- ====== DRAG FUNCTIONALITY ======
local dragging = false
local dragStart = Vector2.new(0, 0)
local startPos = UDim2.new()
local moveConnection

topBar.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = panel.Position
		if not moveConnection then
			moveConnection = UIS.InputChanged:Connect(function(move)
				if not dragging then return end
				if move.UserInputType ~= Enum.UserInputType.MouseMovement and move.UserInputType ~= Enum.UserInputType.Touch then return end
				local delta = move.Position - dragStart
				panel.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				topBar.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y - 40)
			end)
		end
	end
end)

topBar.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = false
		if moveConnection then
			moveConnection:Disconnect()
			moveConnection = nil
		end
	end
end)

-- ====== CREAR PESTAÑA ======
local function createTab(name, emoji)
	local tab = Instance.new("Frame")
	tab.Name = name .. "Tab"
	tab.Size = UDim2.new(0, 70, 0, 40)
	tab.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
	tab.BorderSizePixel = 0
	tab.Parent = tabContainer
	
	local tabButton = Instance.new("TextButton", tab)
	tabButton.Size = UDim2.new(1, 0, 1, 0)
	tabButton.BackgroundTransparency = 1
	tabButton.Text = emoji .. " " .. name
	tabButton.TextColor3 = Color3.fromRGB(170, 100, 255)
	tabButton.Font = Enum.Font.GothamBold
	tabButton.TextSize = 11
	tabButton.AutoButtonColor = false
	
	local underline = Instance.new("Frame", tab)
	underline.Name = "Underline"
	underline.Size = UDim2.new(1, 0, 0, 3)
	underline.Position = UDim2.new(0, 0, 1, -3)
	underline.BackgroundColor3 = Color3.fromRGB(170, 100, 255)
	underline.BorderSizePixel = 0
	underline.Visible = false
	
	return tab, tabButton, underline
end

-- :::::: BOTONES Y SLIDERS ::::::
local function labelColor() return Color3.fromRGB(0, 0, 0) end

local function createButton(text)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, -8, 0, 42)
	btn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	btn.BorderSizePixel = 0
	btn.Text = text
	btn.TextColor3 = labelColor()
	btn.Font = Enum.Font.GothamBold
	btn.TextSize = 13
	btn.AutoButtonColor = false
	btn.Parent = scroll

	local corner = Instance.new("UICorner", btn)
	corner.CornerRadius = UDim.new(0, 10)
	return btn
end

local function createSlider(title, value, minVal, maxVal, callback)
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -8, 0, 90)
	frame.BackgroundTransparency = 1
	frame.Parent = scroll

	-- Etiqueta del slider CON VALOR VISIBLE
	local label = Instance.new("TextLabel", frame)
	label.Size = UDim2.new(1, 0, 0, 18)
	label.Position = UDim2.new(0, 0, 0, 0)
	label.Text = title .. " : " .. value
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.BackgroundTransparency = 1
	label.Font = Enum.Font.GothamBold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left

	-- Barra
	local sliderBar = Instance.new("Frame", frame)
	sliderBar.Name = "SliderBar"
	sliderBar.Size = UDim2.new(1, -8, 0, 12)
	sliderBar.Position = UDim2.new(0, 4, 0, 28)
	sliderBar.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
	sliderBar.BorderSizePixel = 0

	local sbCorner = Instance.new("UICorner", sliderBar)
	sbCorner.CornerRadius = UDim.new(0, 8)

	-- Fill progreso
	local fill = Instance.new("Frame", sliderBar)
	fill.Name = "Fill"
	fill.Size = UDim2.new((value - minVal) / math.max(1, (maxVal - minVal)), 0, 1, 0)
	fill.BackgroundColor3 = Color3.fromRGB(170, 100, 255)
	fill.BorderSizePixel = 0

	local fillCorner = Instance.new("UICorner", fill)
	fillCorner.CornerRadius = UDim.new(0, 8)

	local handle = Instance.new("Frame", sliderBar)
	handle.Name = "Handle"
	handle.Size = UDim2.new(0, 18, 0, 18)
	handle.AnchorPoint = Vector2.new(0.5, 0.5)
	handle.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
	handle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	handle.BorderSizePixel = 0

	local handleCorner = Instance.new("UICorner", handle)
	handleCorner.CornerRadius = UDim.new(0, 9)

	-- Mostrador de valor
	local valueDisplay = Instance.new("TextLabel", sliderBar)
	valueDisplay.Name = "ValueDisplay"
	valueDisplay.Size = UDim2.new(0, 40, 0, 12)
	valueDisplay.AnchorPoint = Vector2.new(0.5, 0.5)
	valueDisplay.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
	valueDisplay.BackgroundTransparency = 1
	valueDisplay.Text = tostring(value)
	valueDisplay.TextColor3 = Color3.fromRGB(255, 255, 255)
	valueDisplay.Font = Enum.Font.GothamBold
	valueDisplay.TextSize = 10
	valueDisplay.TextXAlignment = Enum.TextXAlignment.Center

	-- Variables para el arrastre del slider
	local draggingSlider = false
	local sliderConnection
	local currentValue = value

	-- Función para actualizar el slider
	local function updateSliderValue(inputPos)
		local relativePos = inputPos.X - sliderBar.AbsolutePosition.X
		local barWidth = sliderBar.AbsoluteSize.X
		local percentage = math.clamp(relativePos / barWidth, 0, 1)
		local newValue = math.floor(minVal + percentage * (maxVal - minVal))
		return newValue
	end

	-- Función para aplicar el valor
	local function applyValue(newValue)
		currentValue = newValue
		label.Text = title .. " : " .. newValue
		valueDisplay.Text = tostring(newValue)
		fill.Size = UDim2.new((newValue - minVal) / math.max(1, (maxVal - minVal)), 0, 1, 0)
		handle.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
		valueDisplay.Position = UDim2.new(fill.Size.X.Scale, 0, 0.5, 0)
		if callback then
			callback(newValue)
		end
	end

	-- Input began en la barra del slider
	sliderBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = true
			if not sliderConnection then
				sliderConnection = UIS.InputChanged:Connect(function(move)
					if not draggingSlider then return end
					if move.UserInputType ~= Enum.UserInputType.MouseMovement and move.UserInputType ~= Enum.UserInputType.Touch then return end
					local newValue = updateSliderValue(move.Position)
					applyValue(newValue)
				end)
			end
		end
	end)

	sliderBar.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			draggingSlider = false
			if sliderConnection then
				sliderConnection:Disconnect()
				sliderConnection = nil
			end
		end
	end)

	local toggle = Instance.new("TextButton", frame)
	toggle.Size = UDim2.new(1, -8, 0, 40)
	toggle.Position = UDim2.new(0, 4, 0, 48)
	toggle.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	toggle.TextColor3 = labelColor()
	toggle.BorderSizePixel = 0
	toggle.Font = Enum.Font.GothamBold
	toggle.TextSize = 12
	toggle.AutoButtonColor = false

	local toggleCorner = Instance.new("UICorner", toggle)
	toggleCorner.CornerRadius = UDim.new(0, 8)

	local function update(val)
		applyValue(val)
	end

	local function getValue()
		return currentValue
	end

	return toggle, update, getValue
end

-- ====== CREAR PESTAÑAS EN ORDEN: AIMBOT, PLAYER, ESP ======
local aimbotTab, aimbotTabButton, aimbotUnderline = createTab("Aimbot", "🎯")
local playerTab, playerTabButton, playerUnderline = createTab("Player", "👤")
local visualesTab, visualesTabButton, visualesUnderline = createTab("ESP", "👁")

local activeTab = "Aimbot"

-- ALMACENAR REFERENCIAS DE BOTONES PARA REUTILIZAR
local buttonReferences = {
	Aimbot = {},
	Player = {},
	Visuales = {}
}

-- VARIABLES PARA EL SELECTOR DE AIMBOT
local aimbotSelectorOpen = false

-- ====== CREAR PANEL FLOTANTE DEL SELECTOR DE AIMBOT ======
local aimbotSelectorPanel = Instance.new("Frame", gui)
aimbotSelectorPanel.Name = "AimbotSelectorPanel"
aimbotSelectorPanel.Size = UDim2.new(0, 160, 0, 110)
aimbotSelectorPanel.Position = UDim2.new(0, 350, 0, 60)
aimbotSelectorPanel.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
aimbotSelectorPanel.BorderSizePixel = 0
aimbotSelectorPanel.Visible = false

local selectorCorner = Instance.new("UICorner", aimbotSelectorPanel)
selectorCorner.CornerRadius = UDim.new(0, 10)

local selectorLayout = Instance.new("UIListLayout", aimbotSelectorPanel)
selectorLayout.Padding = UDim.new(0, 6)
selectorLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
selectorLayout.VerticalAlignment = Enum.VerticalAlignment.Top
selectorLayout.SortOrder = Enum.SortOrder.LayoutOrder
selectorLayout.FillDirection = Enum.FillDirection.Vertical

local selectorPadding = Instance.new("UIPadding", aimbotSelectorPanel)
selectorPadding.PaddingLeft = UDim.new(0, 6)
selectorPadding.PaddingRight = UDim.new(0, 6)
selectorPadding.PaddingTop = UDim.new(0, 6)
selectorPadding.PaddingBottom = UDim.new(0, 6)

-- Opciones del selector (SIN PIERNA DERECHA) - AHORA CON FORMA DE PÍLDORA
local opciones = {
	{nombre = "Cabeza", valor = "cabeza"},
	{nombre = "Cuello", valor = "cuello"},
	{nombre = "Pecho", valor = "pecho"}
}

for _, opt in pairs(opciones) do
	local optBtn = Instance.new("TextButton", aimbotSelectorPanel)
	optBtn.Size = UDim2.new(1, -12, 0, 32)
	-- Color de fondo: morado si está seleccionado, gris oscuro si no
	optBtn.BackgroundColor3 = aimbotTarget == opt.valor and Color3.fromRGB(170, 100, 255) or Color3.fromRGB(40, 40, 45)
	optBtn.BorderSizePixel = 0
	optBtn.Text = opt.nombre
	optBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Texto blanco siempre
	optBtn.Font = Enum.Font.GothamBold
	optBtn.TextSize = 11
	optBtn.AutoButtonColor = false

	-- ESQUINAS REDONDEADAS (FORMA DE PÍLDORA) - Radio de 16 para forma ovalada
	local optCorner = Instance.new("UICorner", optBtn)
	optCorner.CornerRadius = UDim.new(0, 16)

	optBtn.MouseButton1Click:Connect(function()
		aimbotTarget = opt.valor
		-- Actualizar colores
		for _, child in pairs(aimbotSelectorPanel:GetChildren()) do
			if child:IsA("TextButton") then
				child.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Gris oscuro para inactivos
			end
		end
		optBtn.BackgroundColor3 = Color3.fromRGB(170, 100, 255) -- Morado para activo
		notifyToggle("Aimbot Target: " .. opt.nombre, true)
	end)
end

-- FUNCIONES DE CARGA
local function loadAimbotTab()
	local aimbotButton = createButton("Aimbot OFF")
	buttonReferences.Aimbot.aimbotButton = aimbotButton
	
	-- Aplicar estado actual al botón
	if aimbotEnabled then
		aimbotButton.Text = "Aimbot ON ✓"
		aimbotButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		aimbotButton.Text = "Aimbot OFF"
		aimbotButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	aimbotButton.MouseButton1Click:Connect(function()
		aimbotEnabled = not aimbotEnabled
		aimbotButton.Text = aimbotEnabled and "Aimbot ON ✓" or "Aimbot OFF"
		aimbotButton.BackgroundColor3 = aimbotEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("Aimbot", aimbotEnabled)
	end)

	-- BOTÓN SELECTOR CON FLECHA
	local selectorBtn = Instance.new("TextButton", scroll)
	selectorBtn.Size = UDim2.new(1, -8, 0, 42)
	selectorBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	selectorBtn.BorderSizePixel = 0
	selectorBtn.Text = "Selector De Aimbot ▼"
	selectorBtn.TextColor3 = labelColor()
	selectorBtn.Font = Enum.Font.GothamBold
	selectorBtn.TextSize = 12
	selectorBtn.AutoButtonColor = false

	local selectorBtnCorner = Instance.new("UICorner", selectorBtn)
	selectorBtnCorner.CornerRadius = UDim.new(0, 10)

	selectorBtn.MouseButton1Click:Connect(function()
		aimbotSelectorOpen = not aimbotSelectorOpen
		aimbotSelectorPanel.Visible = aimbotSelectorOpen
		selectorBtn.Text = aimbotSelectorOpen and "Selector De Aimbot ▲" or "Selector De Aimbot ▼"
	end)

	local aimbotTypeFrame = Instance.new("Frame")
	aimbotTypeFrame.Size = UDim2.new(1, -8, 0, 50)
	aimbotTypeFrame.BackgroundTransparency = 1
	aimbotTypeFrame.Parent = scroll

	-- BOTONES DE VISIBLE/NORMAL - AHORA CON FORMA DE PÍLDORA Y COLORES ACTUALIZADOS
	local aimbotVisibleBtn = Instance.new("TextButton", aimbotTypeFrame)
	aimbotVisibleBtn.Size = UDim2.new(0.45, 0, 0, 34)
	aimbotVisibleBtn.Position = UDim2.new(0, 0, 0, 0)
	-- Color: morado si activo, gris oscuro si inactivo
	aimbotVisibleBtn.BackgroundColor3 = aimbotVisible and Color3.fromRGB(170, 100, 255) or Color3.fromRGB(40, 40, 45)
	aimbotVisibleBtn.Text = "Visible"
	aimbotVisibleBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Texto blanco siempre
	aimbotVisibleBtn.BorderSizePixel = 0
	aimbotVisibleBtn.Font = Enum.Font.GothamBold
	aimbotVisibleBtn.TextSize = 12
	aimbotVisibleBtn.AutoButtonColor = false

	local visibleCorner = Instance.new("UICorner", aimbotVisibleBtn)
	visibleCorner.CornerRadius = UDim.new(0, 16) -- FORMA DE PÍLDORA

	local aimbotNormalBtn = Instance.new("TextButton", aimbotTypeFrame)
	aimbotNormalBtn.Size = UDim2.new(0.45, 0, 0, 34)
	aimbotNormalBtn.Position = UDim2.new(0.55, 0, 0, 0)
	-- Color: morado si activo, gris oscuro si inactivo
	aimbotNormalBtn.BackgroundColor3 = not aimbotVisible and Color3.fromRGB(170, 100, 255) or Color3.fromRGB(40, 40, 45)
	aimbotNormalBtn.Text = "Normal"
	aimbotNormalBtn.TextColor3 = Color3.fromRGB(255, 255, 255) -- Texto blanco siempre
	aimbotNormalBtn.BorderSizePixel = 0
	aimbotNormalBtn.Font = Enum.Font.GothamBold
	aimbotNormalBtn.TextSize = 12
	aimbotNormalBtn.AutoButtonColor = false

	local normalCorner = Instance.new("UICorner", aimbotNormalBtn)
	normalCorner.CornerRadius = UDim.new(0, 16) -- FORMA DE PÍLDORA

	aimbotVisibleBtn.MouseButton1Click:Connect(function()
		aimbotVisible = true
		aimbotVisibleBtn.BackgroundColor3 = Color3.fromRGB(170, 100, 255) -- Morado activo
		aimbotNormalBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Gris inactivo
	end)

	aimbotNormalBtn.MouseButton1Click:Connect(function()
		aimbotVisible = false
		aimbotNormalBtn.BackgroundColor3 = Color3.fromRGB(170, 100, 255) -- Morado activo
		aimbotVisibleBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 45) -- Gris inactivo
	end)

	-- FOV SLIDER
	local fovButton, updateFOV, getFOV = createSlider("Aim FOV", aimbotFOV, minFOV, maxFOV, function(val)
		aimbotFOV = val
	end)
	fovButton.BackgroundColor3 = Color3.fromRGB(170, 100, 255)
	fovButton.Text = "FOV: " .. aimbotFOV
end

local function loadPlayerTab()
	local flyButton, updateFly, getFly = createSlider("Fly Speed", flySpeed, minValue, maxValue, function(val)
		flySpeed = val
	end)
	
	if flying then
		flyButton.Text = "Fly ON ✓"
		flyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		flyButton.Text = "Fly OFF"
		flyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	buttonReferences.Player.flyButton = flyButton
	
	flyButton.MouseButton1Click:Connect(function()
		flying = not flying
		flyButton.Text = flying and "Fly ON ✓" or "Fly OFF"
		flyButton.BackgroundColor3 = flying and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("Fly", flying)
		if not flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
			player.Character.HumanoidRootPart.Velocity = Vector3.zero
		end
	end)

	local speedButton, updateSpeed, getSpeed = createSlider("Walk Speed", walkSpeed, minValue, maxValue, function(val)
		walkSpeed = val
	end)
	
	if speedEnabled then
		speedButton.Text = "Speed ON ✓"
		speedButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		speedButton.Text = "Speed OFF"
		speedButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	buttonReferences.Player.speedButton = speedButton
	
	speedButton.MouseButton1Click:Connect(function()
		speedEnabled = not speedEnabled
		speedButton.Text = speedEnabled and "Speed ON ✓" or "Speed OFF"
		speedButton.BackgroundColor3 = speedEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("Speed", speedEnabled)
		if not speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
			player.Character.Humanoid.WalkSpeed = 16
		end
	end)

	local noclipButton = createButton("Noclip OFF")
	buttonReferences.Player.noclipButton = noclipButton
	
	if noclipEnabled then
		noclipButton.Text = "Noclip ON ✓"
		noclipButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		noclipButton.Text = "Noclip OFF"
		noclipButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	noclipButton.MouseButton1Click:Connect(function()
		noclipEnabled = not noclipEnabled
		noclipButton.Text = noclipEnabled and "Noclip ON ✓" or "Noclip OFF"
		noclipButton.BackgroundColor3 = noclipEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("Noclip", noclipEnabled)
		
		if not noclipEnabled and player.Character then
			for _, part in pairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then
					part.CanCollide = true
				end
			end
		end
	end)

	local jumpButton = createButton("Infinite Jump OFF")
	buttonReferences.Player.jumpButton = jumpButton
	
	if infiniteJumpEnabled then
		jumpButton.Text = "Infinite Jump ON ✓"
		jumpButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		jumpButton.Text = "Infinite Jump OFF"
		jumpButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	jumpButton.MouseButton1Click:Connect(function()
		infiniteJumpEnabled = not infiniteJumpEnabled
		jumpButton.Text = infiniteJumpEnabled and "Infinite Jump ON ✓" or "Infinite Jump OFF"
		jumpButton.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("Infinite Jump", infiniteJumpEnabled)
	end)
end

-- ESP BOX y ESP LÍNEA - Elementos de dibujo
local espBoxes = {}
local espLines = {}

-- Función para limpiar ESP de jugadores que ya no existen o están muertos
local function limpiarESPObsoleto()
	local jugadoresValidos = {}
	
	-- Crear lista de jugadores válidos (vivos y con character)
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			jugadoresValidos[plr] = true
		end
	end
	
	-- Limpiar ESP Cuerpo (Highlights) - Solo si está activado
	if espBodyEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				if not jugadoresValidos[plr] then
					if plr.Character:FindFirstChild("EMZ_ESP") then
						plr.Character.EMZ_ESP:Destroy()
					end
				end
			end
		end
	end
	
	-- Limpiar ESP Enemigos (Highlights) - Solo si está activado
	if espEnemyEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				if not jugadoresValidos[plr] then
					if plr.Character:FindFirstChild("EMZ_ESP_ENEMY") then
						plr.Character.EMZ_ESP_ENEMY:Destroy()
					end
				end
			end
		end
	end
	
	-- Limpiar ESP Boxes
	for plr, box in pairs(espBoxes) do
		if not jugadoresValidos[plr] then
			for _, line in pairs(box) do
				line:Remove()
			end
			espBoxes[plr] = nil
		end
	end
	
	-- Limpiar ESP Líneas
	for plr, line in pairs(espLines) do
		if not jugadoresValidos[plr] then
			line:Remove()
			espLines[plr] = nil
		end
	end
end

-- Función para dibujar ESP BOX (Caja MÁS GRANDE)
local function drawESPBox(plr)
	if not plr.Character then return end
	local root = plr.Character:FindFirstChild("HumanoidRootPart")
	local head = plr.Character:FindFirstChild("Head")
	if not root or not head then return end
	
	-- Obtener posición en pantalla
	local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
	local headPos, _ = camera:WorldToViewportPoint(head.Position)
	
	if not onScreen then 
		-- Si no está en pantalla, ocultar la caja
		if espBoxes[plr] then
			for _, line in pairs(espBoxes[plr]) do
				line.Visible = false
			end
		end
		return 
	end
	
	-- Calcular altura y ancho de la caja (MÁS GRANDE - aumentado de 1.5 a 2.2)
	local height = math.abs(headPos.Y - rootPos.Y) * 2.2
	local width = height * 0.7
	
	-- Crear o actualizar caja
	if not espBoxes[plr] then
		local box = {}
		
		-- Crear 4 líneas para la caja
		for i = 1, 4 do
			local line = Drawing.new("Line")
			line.Thickness = 1
			line.Color = colorActual
			line.Visible = espBoxEnabled
			table.insert(box, line)
		end
		
		espBoxes[plr] = box
	end
	
	-- Actualizar posición de la caja
	local box = espBoxes[plr]
	local centerX = rootPos.X
	local centerY = rootPos.Y - height/2
	
	-- Línea superior
	box[1].From = Vector2.new(centerX - width/2, centerY)
	box[1].To = Vector2.new(centerX + width/2, centerY)
	
	-- Línea derecha
	box[2].From = Vector2.new(centerX + width/2, centerY)
	box[2].To = Vector2.new(centerX + width/2, centerY + height)
	
	-- Línea inferior
	box[3].From = Vector2.new(centerX + width/2, centerY + height)
	box[3].To = Vector2.new(centerX - width/2, centerY + height)
	
	-- Línea izquierda
	box[4].From = Vector2.new(centerX - width/2, centerY + height)
	box[4].To = Vector2.new(centerX - width/2, centerY)
	
	-- Actualizar color y visibilidad
	for _, line in pairs(box) do
		line.Color = colorActual
		line.Visible = espBoxEnabled
	end
end

-- Función para dibujar ESP LÍNEA
local function drawESPLine(plr)
	if not plr.Character then return end
	local root = plr.Character:FindFirstChild("HumanoidRootPart")
	if not root then return end
	
	local rootPos, onScreen = camera:WorldToViewportPoint(root.Position)
	
	-- Crear o actualizar línea
	if not espLines[plr] then
		local line = Drawing.new("Line")
		line.Thickness = 1
		line.Color = colorActual
		line.Visible = espLineEnabled and onScreen
		espLines[plr] = line
	end
	
	-- Actualizar línea desde el centro de la pantalla hasta el jugador
	local line = espLines[plr]
	line.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
	line.To = Vector2.new(rootPos.X, rootPos.Y)
	line.Color = colorActual
	line.Visible = espLineEnabled and onScreen
end

local function loadVisualesTab()
	-- ========== ESP CUERPO ==========
	local espBodyButton = createButton("ESP Cuerpo OFF")
	buttonReferences.Visuales.espBodyButton = espBodyButton
	
	-- Aplicar estado actual
	if espBodyEnabled then
		espBodyButton.Text = "ESP Cuerpo ON ✓"
		espBodyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		espBodyButton.Text = "ESP Cuerpo OFF"
		espBodyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	espBodyButton.MouseButton1Click:Connect(function()
		espBodyEnabled = not espBodyEnabled
		espBodyButton.Text = espBodyEnabled and "ESP Cuerpo ON ✓" or "ESP Cuerpo OFF"
		espBodyButton.BackgroundColor3 = espBodyEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("ESP Cuerpo", espBodyEnabled)
		
		-- Limpiar ESP Cuerpo si se desactiva
		if not espBodyEnabled then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					if plr.Character:FindFirstChild("EMZ_ESP") then
						plr.Character.EMZ_ESP:Destroy()
					end
				end
			end
		end
	end)

	-- ========== ESP ENEMIGOS (TOTALMENTE INDEPENDIENTE) ==========
	local espEnemyButton = createButton("ESP Enemigos OFF")
	buttonReferences.Visuales.espEnemyButton = espEnemyButton
	
	-- Aplicar estado actual
	if espEnemyEnabled then
		espEnemyButton.Text = "ESP Enemigos ON ✓"
		espEnemyButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		espEnemyButton.Text = "ESP Enemigos OFF"
		espEnemyButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	espEnemyButton.MouseButton1Click:Connect(function()
		espEnemyEnabled = not espEnemyEnabled
		espEnemyButton.Text = espEnemyEnabled and "ESP Enemigos ON ✓" or "ESP Enemigos OFF"
		espEnemyButton.BackgroundColor3 = espEnemyEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("ESP Enemigos", espEnemyEnabled)
		enemyCountDisplay.Visible = espEnemyEnabled
		
		-- Limpiar ESP Enemigos si se desactiva
		if not espEnemyEnabled then
			for _, plr in pairs(Players:GetPlayers()) do
				if plr ~= player and plr.Character then
					if plr.Character:FindFirstChild("EMZ_ESP_ENEMY") then
						plr.Character.EMZ_ESP_ENEMY:Destroy()
					end
				end
			end
			enemyCountDisplay.Visible = false
		end
	end)
	
	-- ========== ESP BOX ==========
	local espBoxButton = createButton("ESP Box OFF")
	buttonReferences.Visuales.espBoxButton = espBoxButton
	
	if espBoxEnabled then
		espBoxButton.Text = "ESP Box ON ✓"
		espBoxButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		espBoxButton.Text = "ESP Box OFF"
		espBoxButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	espBoxButton.MouseButton1Click:Connect(function()
		espBoxEnabled = not espBoxEnabled
		espBoxButton.Text = espBoxEnabled and "ESP Box ON ✓" or "ESP Box OFF"
		espBoxButton.BackgroundColor3 = espBoxEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("ESP Box", espBoxEnabled)
		
		-- Limpiar cajas si se desactiva
		if not espBoxEnabled then
			for _, box in pairs(espBoxes) do
				for _, line in pairs(box) do
					line.Visible = false
					line:Remove()
				end
			end
			espBoxes = {}
		end
	end)
	
	-- ========== ESP LÍNEA ==========
	local espLineButton = createButton("ESP Línea OFF")
	buttonReferences.Visuales.espLineButton = espLineButton
	
	if espLineEnabled then
		espLineButton.Text = "ESP Línea ON ✓"
		espLineButton.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
	else
		espLineButton.Text = "ESP Línea OFF"
		espLineButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	end
	
	espLineButton.MouseButton1Click:Connect(function()
		espLineEnabled = not espLineEnabled
		espLineButton.Text = espLineEnabled and "ESP Línea ON ✓" or "ESP Línea OFF"
		espLineButton.BackgroundColor3 = espLineEnabled and Color3.fromRGB(50, 200, 50) or Color3.fromRGB(200, 50, 50)
		notifyToggle("ESP Línea", espLineEnabled)
		
		-- Limpiar líneas si se desactiva
		if not espLineEnabled then
			for _, line in pairs(espLines) do
				line.Visible = false
				line:Remove()
			end
			espLines = {}
		end
	end)
end

-- FUNCIÓN switchTab
local function switchTab(tabName)
	activeTab = tabName
	for _, child in pairs(scroll:GetChildren()) do
		if child:IsA("GuiObject") then
			child:Destroy()
		end
	end
	
	-- Actualizar subrayados
	aimbotUnderline.Visible = false
	playerUnderline.Visible = false
	visualesUnderline.Visible = false
	
	if tabName == "Aimbot" then
		loadAimbotTab()
		aimbotUnderline.Visible = true
	elseif tabName == "Player" then
		loadPlayerTab()
		playerUnderline.Visible = true
	elseif tabName == "Visuales" then
		loadVisualesTab()
		visualesUnderline.Visible = true
	end
	
	local spacer = Instance.new("Frame")
	spacer.Size = UDim2.new(1, -8, 0, 10)
	spacer.BackgroundTransparency = 1
	spacer.Parent = scroll
	
	local resetButton = createButton("Reset All")
	resetButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
	resetButton.MouseButton1Click:Connect(function()
		flying = false
		speedEnabled = false
		noclipEnabled = false
		infiniteJumpEnabled = false
		espBodyEnabled = false
		espEnemyEnabled = false
		espBoxEnabled = false
		espLineEnabled = false
		aimbotEnabled = false
		aimbotVisible = false
		aimbotFOV = 50
		aimbotTarget = "cabeza"
		aimbotSelectorOpen = false
		aimbotSelectorPanel.Visible = false
		enemyCountDisplay.Visible = false
		
		notifyToggle("Reset All", false)
		if player.Character then
			local hum = player.Character:FindFirstChild("Humanoid")
			if hum then hum.WalkSpeed = 16 end
			for _, part in pairs(player.Character:GetDescendants()) do
				if part:IsA("BasePart") then 
					part.CanCollide = true
				end
			end
		end
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				if plr.Character:FindFirstChild("EMZ_ESP") then 
					plr.Character.EMZ_ESP:Destroy() 
				end
				if plr.Character:FindFirstChild("EMZ_ESP_ENEMY") then 
					plr.Character.EMZ_ESP_ENEMY:Destroy() 
				end
			end
		end
		
		-- Limpiar ESP Box y Línea
		for _, box in pairs(espBoxes) do
			for _, line in pairs(box) do
				line:Remove()
			end
		end
		espBoxes = {}
		
		for _, line in pairs(espLines) do
			line:Remove()
		end
		espLines = {}
		
		switchTab("Aimbot")
	end)
end

-- CONEXIONES DE PESTAÑAS
aimbotTabButton.MouseButton1Click:Connect(function()
	switchTab("Aimbot")
end)

playerTabButton.MouseButton1Click:Connect(function()
	switchTab("Player")
end)

visualesTabButton.MouseButton1Click:Connect(function()
	switchTab("Visuales")
end)

-- FUNCIÓN PARA RAYCAST
local function isTargetVisible(cameraPosition, targetPosition)
	local direction = (targetPosition - cameraPosition)
	local distance = direction.Magnitude
	
	if distance == 0 then return false end
	
	local ray = Ray.new(cameraPosition, direction.Unit * distance)
	local hitPart, hitPosition = workspace:FindPartOnRay(ray, player.Character)
	
	if hitPart == nil then
		return true
	end
	
	if hitPart:IsDescendantOf(player.Character) then
		return true
	end
	
	if hitPart.Parent and hitPart.Parent:FindFirstChild("Humanoid") then
		return true
	end
	
	return false
end

-- FUNCIÓN PARA CALCULAR SI ESTÁ EN FOV
local function isInFOV(playerPos, targetPos, fovAngle)
	local cameraDirection = camera.CFrame.LookVector
	local toTarget = (targetPos - playerPos).Unit
	
	local dotProduct = cameraDirection:Dot(toTarget)
	local fovCosine = math.cos(math.rad(fovAngle / 2))
	
	return dotProduct >= fovCosine
end

-- ========== FUNCIÓN PARA OBTENER PARTE DEL CUERPO SEGÚN SELECTOR ==========
local function getAimbotTargetPart(character)
	local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
	
	if aimbotTarget == "cabeza" then
		return character:FindFirstChild("Head")
	elseif aimbotTarget == "cuello" then
		local head = character:FindFirstChild("Head")
		local upperTorso = character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
		if head and upperTorso then
			local neckPos = (head.Position + upperTorso.Position) / 2
			local neckPart = Instance.new("Part")
			neckPart.Transparency = 1
			neckPart.CanCollide = false
			neckPart.Position = neckPos
			return neckPart
		end
		return head
	elseif aimbotTarget == "pecho" then
		return character:FindFirstChild("UpperTorso") or character:FindFirstChild("Torso")
	end
	
	return character:FindFirstChild("Head")
end

-- ========== ESP Body - SOLO CUERPO COMPLETO (INDEPENDIENTE) ==========
local function updateESPBody()
	if not espBodyEnabled then return end
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local highlight = plr.Character:FindFirstChild("EMZ_ESP")
			if highlight then
				highlight.FillColor = colorActual
				highlight.OutlineColor = colorActual
			else
				local h = Instance.new("Highlight")
				h.Name = "EMZ_ESP"
				h.FillColor = colorActual
				h.OutlineColor = colorActual
				h.FillTransparency = 0.3
				h.OutlineTransparency = 0
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = plr.Character
			end
		end
	end
end

-- ========== ESP ENEMIGOS - SOLO TEXTO CONTADOR (INDEPENDIENTE) ==========
local function updateESPEnemies()
	if not espEnemyEnabled then return end
	
	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
			local enemyHighlight = plr.Character:FindFirstChild("EMZ_ESP_ENEMY")
			if enemyHighlight then
				enemyHighlight.FillColor = colorActual
				enemyHighlight.OutlineColor = colorActual
			else
				local h = Instance.new("Highlight")
				h.Name = "EMZ_ESP_ENEMY"
				h.FillColor = colorActual
				h.OutlineColor = colorActual
				h.FillTransparency = 0.3
				h.OutlineTransparency = 0
				h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
				h.Parent = plr.Character
			end
		end
	end
end

-- ========== FOV VISIBLE ==========
local fovCircle = nil
local function updateFOVCircle()
	if aimbotEnabled then
		if not fovCircle then
			fovCircle = Drawing.new("Circle")
			fovCircle.Thickness = 1
			fovCircle.NumSides = 60
			fovCircle.Radius = aimbotFOV * 2
			fovCircle.Filled = false
			fovCircle.Color = Color3.fromRGB(170, 100, 255)
			fovCircle.Visible = true
			fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
		else
			fovCircle.Radius = aimbotFOV * 2
			fovCircle.Position = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
			fovCircle.Visible = true
		end
	else
		if fovCircle then
			fovCircle.Visible = false
			fovCircle:Remove()
			fovCircle = nil
		end
	end
end

-- ========== AIMBOT CON SELECTOR DE PARTES ==========
RunService.RenderStepped:Connect(function()
	if aimbotEnabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		local closestPlayer = nil
		local closestDistance = math.huge
		
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
				local targetPart = getAimbotTargetPart(plr.Character)
				if targetPart then
					local targetPos = targetPart.Position
					local distance = (targetPos - player.Character.HumanoidRootPart.Position).Magnitude
					
					-- Verificar si está dentro del FOV
					if isInFOV(camera.CFrame.Position, targetPos, aimbotFOV) then
						-- Si es "Visible", verificar línea de visión
						if aimbotVisible then
							if isTargetVisible(camera.CFrame.Position, targetPos) then
								if distance < closestDistance then
									closestDistance = distance
									closestPlayer = plr
								end
							end
						else
							-- Modo Normal: apunta siempre (ignora paredes)
							if distance < closestDistance then
								closestDistance = distance
								closestPlayer = plr
							end
						end
					end
				end
			end
		end
		
		if closestPlayer and closestPlayer.Character then
			local targetPart = getAimbotTargetPart(closestPlayer.Character)
			if targetPart then
				local cameraPos = camera.CFrame.Position
				local targetPos = targetPart.Position
				
				-- Apuntar a la parte seleccionada
				camera.CFrame = CFrame.new(cameraPos, targetPos)
			end
		end
	end
end)

-- ========== AUTO UPDATE ESP (TOTALMENTE INDEPENDIENTE) ==========
RunService.Heartbeat:Connect(function()
	-- LIMPIAR ESP OBSOLETO
	limpiarESPObsoleto()
	
	-- Actualizar contador de enemigos (SOLO cuando ESP Enemigos está activo)
	if espEnemyEnabled then
		local enemyCount = 0
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
				enemyCount = enemyCount + 1
			end
		end
		enemyCountDisplay.Text = "Enemigos: " .. enemyCount
		enemyCountDisplay.Visible = true
	else
		enemyCountDisplay.Visible = false
	end

	-- ESP Cuerpo (INDEPENDIENTE)
	if espBodyEnabled then
		updateESPBody()
	else
		-- Asegurar que no queden restos de ESP Cuerpo
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				if plr.Character:FindFirstChild("EMZ_ESP") then
					plr.Character.EMZ_ESP:Destroy()
				end
			end
		end
	end

	-- ESP Enemigos (INDEPENDIENTE - SOLO TEXTO, SIN HIGHLIGHT)
	if espEnemyEnabled then
		-- NOTA: Ya no creamos Highlight para ESP Enemigos
		-- Solo mostramos el contador arriba
	else
		-- Asegurar que no queden restos de ESP Enemigos
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character then
				if plr.Character:FindFirstChild("EMZ_ESP_ENEMY") then
					plr.Character.EMZ_ESP_ENEMY:Destroy()
				end
			end
		end
	end
	
	-- ESP BOX
	if espBoxEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
				drawESPBox(plr)
			end
		end
	else
		-- Limpiar cajas si está desactivado
		for _, box in pairs(espBoxes) do
			for _, line in pairs(box) do
				line.Visible = false
			end
		end
	end
	
	-- ESP LÍNEA
	if espLineEnabled then
		for _, plr in pairs(Players:GetPlayers()) do
			if plr ~= player and plr.Character and plr.Character:FindFirstChild("Humanoid") and plr.Character.Humanoid.Health > 0 then
				drawESPLine(plr)
			end
		end
	else
		-- Limpiar líneas si está desactivado
		for _, line in pairs(espLines) do
			line.Visible = false
		end
	end
end)

-- NOCLIP LOGIC
RunService.Stepped:Connect(function()
	if noclipEnabled and player.Character then
		for _, part in pairs(player.Character:GetDescendants()) do
			if part:IsA("BasePart") then
				part.CanCollide = false
			end
		end
	end
end)

-- Actualizar círculo FOV
RunService.RenderStepped:Connect(function()
	updateFOVCircle()
end)

-- Toggle panel
toggleButton.MouseButton1Click:Connect(function()
	isOpen = not isOpen
	panel.Visible = isOpen
	toggleButton.Text = isOpen and "◀" or "▶"
	if isOpen then
		switchTab("Aimbot")
	end
end)

-- FLY LOGIC
RunService.RenderStepped:Connect(function()
	if flying and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
		player.Character.HumanoidRootPart.Velocity = camera.CFrame.LookVector * flySpeed
	end
	if speedEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid.WalkSpeed = walkSpeed
	end
end)

-- INFINITE JUMP LOGIC
UIS.JumpRequest:Connect(function()
	if infiniteJumpEnabled and player.Character and player.Character:FindFirstChild("Humanoid") then
		player.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
	end
end)

-- Cargar pestaña inicial
switchTab("Aimbot")
