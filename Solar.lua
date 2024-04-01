local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer: Player = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local ScreenResolution = workspace.CurrentCamera.ViewportSize

-- External Libraries
local Signals = {}

-- Signals Types
type func = (any...) -> any...

type Signal = {
	Connections: { Connection },
	Connect: (self: Signal, func: func) -> Connection,
	Wait: (self: Signal, func: func?) -> (),
	Once: (self: Signal, func: func) -> Connection,
	Fire: (self: Signal, ...any) -> (),
	Enabled: boolean,
}

type Connection = {
	func: func,
	Enabled: boolean,
	Disconnect: (self: Connection) -> (),
}

-- Signals Code
do
	function Signals.new(): Signal
		local Signal = setmetatable({}, { __index = Signals }) :: Signal

		Signal.Connections = {}
		Signal.Enabled = true

		Signal.new = nil

		return Signal :: Signal
	end

	function Signals.Connect(Signal: Signal, func: func): Connection
		local Connection = {} :: Connection
		Connection.func = func
		Connection.Enabled = true
		Connection.id = #Signal.Connections + 1

		Signal.Connections[Connection.id] = Connection

		function Connection:Disconnect()
			Signal.Connections[Connection.id] = nil
			table.clear(Connection)
			Connection = nil
		end

		return Connection
	end

	function Signals.Wait(Signal: Signal, func: func?)
		local Thread = coroutine.running()
		local Connection: Connection

		Connection = Signal:Connect(function(...)
			if Connection == nil then
				return
			end

			if func then
				func(...)
			end
			Connection:Disconnect()
			Connection = nil :: any

			task.spawn(Thread, ...)
		end)

		return coroutine.yield()
	end

	function Signals.Once(Signal: Signal, func: func)
		local Connection

		Connection = Signals.Connect(Signal, function(...)
			Connection:Disconnect()
			func(...)
		end)

		return Connection
	end

	function Signals.Fire(Signal: Signal, ...: any)
		if not Signal.Enabled then
			return
		end

		for i, v in next, Signal.Connections do
			if v.Enabled and v.func then
				task.spawn(v.func, ...)
			end
		end
	end
end

-- Library
local Solar = {_VERSION = "0.7.7"}
local Styler = {}
local Utils = {}

-- Utils

-- Types
type BaseGui =
	{ [string]: BaseGui | any }
	& CanvasGroup
	& TextLabel
	& TextButton
	& TextBox
	& Frame
	& ScrollingFrame
	& ImageLabel
	& ImageButton

type CommonType = string | number | boolean

local function toboolean(s: string)
	return s == "true" or s == "false" and false or nil
end

do
	function Utils.propertyExists(Instance: Instance, Property: string): (boolean, any?)
		local Exists, property = pcall(function()
			return Instance[Property]
		end)
		return Exists, property
	end

	function Utils.ApplyProperties(Object: Instance, Properties: { [string]: any } | any)
		for i, v in next, Properties do
			if typeof(v) == "table" and Object:FindFirstChild(i) then
				Utils.ApplyProperties(Object:FindFirstChild(i) :: Instance, v)
			elseif Utils.propertyExists(Object, i) then
				Object[i] = v
			end
		end
	end

	function Utils.newInstanceFromTable(t: any)
		local Success, Inst = pcall(function()
			return Instance.new(t.ClassName)
		end)
		if not Success then
			return
		end

		for i, v in next, t do
			if Utils.propertyExists(Inst, i) then
				pcall(function()
					Inst[i] = v
				end)
			elseif typeof(v) == "table" and Utils.propertyExists(Inst, i) == false then
				local Child = Utils.newInstanceFromTable(v)
				if typeof(i) == "string" then
					Child.Name = i
				end
				Child.Parent = Inst
			end
		end

		return Inst
	end

	function Utils.Vec2ToUD2(Vec2: Vector2): UDim2
		return UDim2.fromOffset(Vec2.X, Vec2.Y)
	end
end

-- Styler

-- Types
type StylerModifier = { ClassName: string }
type StylerWidgetStyle = BaseGui & { [string]: StylerWidgetStyle }

do
	Styler.PropertyBlackList = {
		Parent = true,
		ClassName = true,
		Name = true,
	}

	Styler.Modifiers = {
		Border = {
			ClassName = "UIStroke",
		},
		Rounding = {
			ClassName = "UICorner",
		},
		Gradient = {
			ClassName = "UIGradient",
		},
	}

	local function getModifier(Name: string): StylerModifier?
		if Styler.Modifiers[Name] then
			return Styler.Modifiers[Name]
		end
		return nil
	end

	function Styler.GetStateValue(Widget: SolarBaseWidget, Value: any)
		local newValue = Value
		if typeof(newValue) == "function" then
			newValue = Value(Widget)
			if typeof(newValue) == "function" then
				newValue = Styler.GetStateValue(Widget, newValue)
			end
			return newValue
		else
			return newValue
		end
	end

	function Styler.ApplyStyle(Widget: SolarBaseWidget | any, GuiObject: GuiBase, WidgetStyle: any?)
		local WidgetStyle = Widget.Style
			or WidgetStyle
			or Solar.Style.Widgets and Solar.Style.Widgets[Widget.Class]
			or {}
		for i, v in next, WidgetStyle do
			if GuiObject:FindFirstChild(i) and typeof(v) == "table" then
				Styler.ApplyStyle(Widget, GuiObject:FindFirstChild(i), v)
			elseif typeof(v) == "table" and getModifier(i) then
				local Modifier = GuiObject:FindFirstChild(getModifier(i).ClassName)
				if not Modifier then
					Modifier = Instance.new(getModifier(i).ClassName)
					Modifier.Parent = GuiObject
				end

				for index, value in next, v do
					if Utils.propertyExists(Modifier, index) then
						Modifier[index] = Styler.GetStateValue(Widget, value)
					end
				end
			elseif typeof(i) == "string" and Utils.propertyExists(GuiObject, i) and not Styler.PropertyBlackList[i] then
				GuiObject[i] = Styler.GetStateValue(Widget, v)
			end
		end
	end
end

-- The Library
Solar.Stepped = Signals.new()
Solar.Windows = {}
Solar.Style = {}
Solar.Gui = nil

-- Types
type SolarArgs = { [string]: any }
type SolarWidgetConstructor = (Args: SolarArgs?) -> SolarWidget

type SolarWidget = {
	Name: string,
	Class: string,
	Parent: SolarWidget,
	Window: SolarWindow,
	Gui: BaseGui?,
	State: { [string]: any }?,
	Style: StylerWidgetStyle?,

	Destroy: (self: any) -> (),
}

type SolarSubWidget = {
	Side: "Right" | "Left",
}

type SolarWindow = {
	Moveable: boolean,
	Resizable: boolean,

	Position: Vector2,
	Size: Vector2,

	MaxSize: Vector2,
	MinSize: Vector2,

	Icon: string?,

	ScreenLocked: boolean,
	Closable: boolean,

	State: {
		Open: boolean,
		MouseIn: boolean,
		Moving: boolean,
		Resizing: boolean,
		CurrentPage: number,
	},

	Empty: (self: any, Args: SolarArgs?) -> SolarWidget,
	Text: (self: any, Args: SolarArgs?) -> SolarText,
	Value: (self: any, Args: SolarArgs?) -> SolarValue,
	DropDown: (self: any, Args: SolarArgs?) -> SolarDropDown,
	CheckBox: (self: any, Args: SolarArgs?) -> SolarCheckBox,
	Button: (self: any, Args: SolarArgs?) -> SolarButton,
	Array: (self: any, Args: SolarArgs?) -> SolarArray,
	Content: (self: any, Args: SolarArgs?) -> SolarContent,
	TabBar: (self: any, Args: SolarArgs?) -> SolarTabBar,

	Close: (self: any) -> (),
	Open: (self: any) -> (),
	SetPage: (self: any, Page: number) -> (),
	GetPage: () -> { SolarBaseWidget? },
	AddPage: (self: any) -> number,
	GetPageFromId: (self: any, id: number) -> { SolarBaseWidget? },
	GetPages: (self: any) -> { { SolarBaseWidget? } },
	RemovePage: (self: any, id: number) -> (),

	GetTabs: (self: any) -> { SolarTab? },

	Opened: Signal,
	Closed: Signal,
	Step: Signal,
} & SolarWidget

type SolarText = {
	TextEditable: boolean,
} & SolarWidget & SolarSubWidget

type SolarValue = {
	ValueEditable: boolean,
	Value: CommonType | nil,
} & SolarWidget & SolarSubWidget

type SolarDropDown = {
	State: {
		Value: CommonType,
		Open: boolean,
	},
	Locked: CommonType,
	SetOpen: (self: any, Open: boolean, Force: boolean?) -> (),
	Option: (self: any, Args: SolarArgs?) -> SolarDropDownOption,
	Step: Signal,
} & SolarWidget & SolarSubWidget

type SolarDropDownOption = {
	Class: string,
	Value: CommonType,
	State: {
		Selected: boolean,
	}
}

type SolarCheckBox = {
	State: {
		Value: boolean,
	},
	Locked: boolean,
} & SolarWidget & SolarSubWidget

type SolarButton = {
	Clickable: boolean,

	Mouse1Down: Signal,
	Mouse1Up: Signal,

	Mouse2Down: Signal,
	Mouse2Up: Signal,
} & SolarWidget & SolarSubWidget

type SolarArray = {
	Empty: (self: any, Args: SolarArgs?) -> SolarWidget,
	Text: (self: any, Args: SolarArgs?) -> SolarText,
	Value: (self: any, Args: SolarArgs?) -> SolarValue,
	CheckBox: (self: any, Args: SolarArgs?) -> SolarCheckBox,
	Button: (self: any, Args: SolarArgs?) -> SolarButton,
	Array: (self: any, Args: SolarArgs?) -> SolarArray,

	Step: Signal,
} & SolarWidget & SolarSubWidget

type SolarContent = {
	Size: UDim2,
	DisplayName: boolean,

	Empty: (self: any, Args: SolarArgs?) -> SolarWidget,
	Text: (self: any, Args: SolarArgs?) -> SolarText,
	Value: (self: any, Args: SolarArgs?) -> SolarValue,
	DropDown: (self: any, Args: SolarArgs?) -> SolarDropDown,
	CheckBox: (self: any, Args: SolarArgs?) -> SolarCheckBox,
	Button: (self: any, Args: SolarArgs?) -> SolarButton,
	Content: (self: any, Args: SolarArgs?) -> SolarContent,
	Array: (self: any, Args: SolarArgs?) -> SolarArray,
} & SolarWidget & SolarSubWidget

type SolarTabBar = {
	Tab: (self: any, Args: SolarArgs?) -> (),
	GetTab: (self: any, Tabid: number) -> SolarTab,
	GetTabs: (self: any) -> { SolarTab? },
} & SolarWidget

type SolarTab = {
	Page: { SolarBaseWidget? },
	State: {
		Open: boolean,
	},
} & SolarWidget & SolarSubWidget

export type SolarBaseWidget = SolarWidget & SolarWindow & SolarText & SolarValue & SolarDropDown & SolarDropDownOption & SolarCheckBox & SolarDropDown & SolarDropDownOption & SolarButton & SolarArray & SolarContent & SolarTabBar & SolarTab & SolarSubWidget

type SolarStyle = {
	Widgets: { BaseGui },
	Colors: { [string]: Color3 },
	Fonts: { [string]: Enum.Font },
}

-- Widgets
local Widgets = {}

local function GetWidget(id: string)
	if assert(Widgets[id], '"' .. id .. '"' .. " is not a valid widget.") then
		return Widgets[id]
	end
end

local function CreateWidget(id: string, constructor: SolarWidgetConstructor)
	if assert(Widgets[id] == nil, '"' .. id .. '"' .. " is already registered.") then
		Widgets[id] = constructor
	end
end

CreateWidget("BaseWidget", function(Args: SolarArgs?)
	Args = Args or {}

	local Widget: SolarWidget = {}
	Widget.Name = Args.Name or "Widget"
	Widget.Class = "BaseWidget"
	Widget.Parent = Args.Parent or nil
	Widget.Window = Args.Window or nil

	return Widget
end)

do
	CreateWidget("Window", function(Args)
		Args = Args or {}
		local Widget: SolarWindow = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "Window"
		Widget.Class = "Window"
		Widget.Window = Widget
		Widget.Icon = Args.Icon or nil

		Widget.Moveable = Args.Moveable or true
		Widget.Resizable = Args.Resizable or true

		Widget.Position = Args.Position or Vector2.one * 75
		Widget.Size = Args.Size or Vector2.new(400, 300)

		Widget.MaxSize = Args.MaxSize or Vector2.one * math.huge
		Widget.MinSize = Args.MinSize or Vector2.new(200, 32)

		Widget.ScreenLocked = Args.ScreenLocked or false
		Widget.Closable = Args.Closeable or true

		Widget.State = {
			Open = Args.Open or true,
			Moving = false,
			Resizing = false,
			MouseIn = false,
			CurrentPage = 1,
		}

		Widget.Opened = Signals.new()
		Widget.Closed = Signals.new()
		Widget.Step = Signals.new()

		local Pages = { {} }
		local TabBars = {}

		local MoveOffset, SizeOffset = Vector2.zero, Vector2.zero

		local function GetCurrentPage()
			-- Fail save
			if Pages[Widget.State.CurrentPage] == nil then
				Widget:SetPage(1)
			end

			return Pages[Widget.State.CurrentPage]
		end

		local Gui = {
			ClassName = "Frame",
			ClipsDescendants = true,

			TitleBar = {
				ClassName = "Frame",
				Size = UDim2.new(1, 0, 0, 32),

				MoveButton = {
					ClassName = "ImageButton",
					Size = UDim2.fromScale(1, 1),
					ZIndex = 5,
					--Transparency = 1,
				} :: ImageButton,

				WindowName = {
					ClassName = "TextLabel",
					Size = UDim2.fromScale(1, 1),
					BackgroundTransparency = 1,
					Text = Widget.Name,
				} :: TextLabel,

				CloseButton = {
					ClassName = "ImageButton",

					AnchorPoint = Vector2.new(1, 0),
					Position = UDim2.fromScale(1, 0.5),
					Size = UDim2.fromOffset(32, 32),

					ZIndex = 6,
				} :: ImageButton,

				Icon = {
					ClassName = "ImageLabel",

					Size = UDim2.fromOffset(32, 32),
					ResampleMode = Enum.ResamplerMode.Pixelated,
				} :: ImageLabel,

				ZIndex = 3,
			} :: Frame,

			Resizer = {
				ClassName = "ImageButton",
				Size = UDim2.new(0, 10, 0, 10),
				Position = UDim2.fromScale(1, 1),
				ZIndex = 4,
				AnchorPoint = Vector2.one,
			} :: ImageButton,

			Content = {
				ClassName = "ScrollingFrame",
				Position = UDim2.new(0.5, 0, 0.5, 16),
				Size = UDim2.new(1, 0, 1, -32),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ClipsDescendants = true,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(0, 0),
			} :: ScrollingFrame,
		} :: Frame

		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local MouseEnter = Gui.MouseEnter:Connect(function()
			Widget.State.MouseIn = true
		end)

		local MouseLeave = Gui.MouseLeave:Connect(function()
			Widget.State.MouseIn = false
		end)

		local MouseUpConnection = UserInputService.InputEnded:Connect(function(InputObject: InputObject)
			if InputObject.UserInputType == Enum.UserInputType.MouseButton1 then
				if Widget.State.Moving then
					Widget.State.Moving = false
					MoveOffset = Vector2.zero
				end

				if Widget.State.Resizing then
					Widget.State.Resizing = false
					SizeOffset = Vector2.zero
				end
			end
		end)

		local MoveConnection = Gui.TitleBar.MoveButton.MouseButton1Down:Connect(function()
			Widget.State.Moving = true
			MoveOffset = Widget.Position - UserInputService:GetMouseLocation()
		end)

		local ResizeConnection = Gui.Resizer.MouseButton1Down:Connect(function()
			Widget.State.Resizing = true

			SizeOffset = Widget.Position + Widget.Size - UserInputService:GetMouseLocation()
		end)

		local CloseConnection = Gui.TitleBar.CloseButton.MouseButton1Down:Connect(function()
			Widget:Close()
		end)

		local Step = Solar.Stepped:Connect(function(deltaTime: number)
			Gui.Name = Widget.Name
			Gui.Visible = Widget.State.Open

			if Widget.State.Open then
				Gui.Parent = Solar.Gui

				if Widget.State.Moving and Widget.Moveable then
					Widget.Position = UserInputService:GetMouseLocation() + MoveOffset
				else
					Widget.State.Moving = false
					MoveOffset = Vector2.zero
				end

				if Widget.State.Resizing and Widget.Resizable then
					Widget.Size = SizeOffset + UserInputService:GetMouseLocation() - Widget.Position
				else
					SizeOffset = Vector2.zero
					Widget.State.Resizing = false
				end

				Widget.Size = Vector2.new(
					math.min(math.max(Widget.Size.X, Widget.MinSize.X), Widget.MaxSize.X),
					math.min(math.max(Widget.Size.Y, Widget.MinSize.Y), Widget.MaxSize.Y)
				)

				if Widget.ScreenLocked then
					Widget.Position = Vector2.new(
						math.min(math.max(Widget.Position.X, 0), ScreenResolution.X - Widget.Size.X),
						math.min(math.max(Widget.Position.Y, 0), ScreenResolution.Y - Widget.Size.Y)
					)
				end

				Gui.TitleBar.CloseButton.Visible = Widget.Closable

				Gui.Size = Utils.Vec2ToUD2(Widget.Size)
				Gui.Position = Utils.Vec2ToUD2(Widget.Position)

				Gui.TitleBar.WindowName.Text = Widget.Name

				Gui.TitleBar.MoveButton.Visible = Widget.Moveable
				Gui.Resizer.Visible = Widget.Resizable

				local Y = 0
				local Y2 = 0
				for i, SubWidget: SolarBaseWidget in next, GetCurrentPage() do
					if SubWidget.Class == nil then
						table.remove(GetCurrentPage(), i)
						continue
					end

					if SubWidget.Gui and not SubWidget.Gui.Visible then
						continue
					end
					SubWidget.Gui.Parent = Widget.Gui.Content

					SubWidget.Gui.AnchorPoint =
						Vector2.new(SubWidget.Side == "Right" and 1 or SubWidget.Side == "Left" and 0 or 0.5, 0)
					SubWidget.Gui.Position = UDim2.new(
						SubWidget.Side == "Right" and 1 or SubWidget.Side == "Left" and 0 or 0.5,
						0,
						0,
						SubWidget.Side == "Right" and Y2 or Y
					)

					if SubWidget.Side == "Right" then
						Y2 += SubWidget.Gui.AbsoluteSize.Y
					elseif SubWidget.Side == "Left" then
						Y += SubWidget.Gui.AbsoluteSize.Y
					else
						Y2 += SubWidget.Gui.AbsoluteSize.Y
						Y += SubWidget.Gui.AbsoluteSize.Y
					end
				end

				local TY = 0
				for i, v: SolarTabBar in next, TabBars do
					if v.Class == nil then
						table.remove(TabBars, i)
						continue
					end
					v.Gui.Position = UDim2.fromOffset(0, Widget.Gui.TitleBar.AbsoluteSize.Y + TY)

					TY += v.Gui.AbsoluteSize.Y
				end

				Widget.Step:Fire(deltaTime)
				Styler.ApplyStyle(Widget, Gui)

				-- >:(
				Gui.Content.Position += UDim2.fromOffset(0, TY / 2)
				Gui.Content.Size -= UDim2.fromOffset(0, TY)
			end
		end)

		function Widget:SetPage(Page: number)
			assert(Pages[Page], "Page #" .. Page .. " cannot be found.")
			Widget.State.CurrentPage = Page

			for i, v in next, Pages do
				if i ~= Widget.State.CurrentPage then
					for index, SubWidget: SolarBaseWidget in next, v do
						SubWidget.Gui.Parent = nil
					end
				end
			end
		end

		Widget.GetPage = GetCurrentPage

		function Widget:GetPageFromId(id: number)
			assert(Pages[id], "Page #" .. id .. " cannot be found.")
			return Pages[id]
		end

		function Widget:AddPage()
			Pages[#Pages + 1] = {}
			return #Pages
		end

		function Widget:RemovePage(id: number)
			if id <= 1 then
				return 
			end
			assert(Pages[id], "Page #" .. id .. " cannot be found.")
			for i, v in next, Pages[id] do
				v:Destroy()
			end
			Pages[id] = nil
			if Widget.State.CurrentPage == id then
				Widget:SetPage(id - 1)
			end
		end

		function Widget:GetPages()
			return Pages
		end

		function Widget:GetTabs()
			local Tabs = {}
			for i, v: SolarTabBar in next, TabBars do
				for i2, v2: SolarTab in next, v:GetTabs() do
					table.insert(Tabs, v2)
				end
			end
			return Tabs
		end

		function Widget:Open()
			if Widget.State.Open then
				return
			end
			Widget.State.Open = true
			Widget.Opened:Fire()
		end

		function Widget:Close()
			if not Widget.State.Open then
				return
			end
			Widget.State.Open = false
			Widget.Closed:Fire()
		end

		function Widget:Destroy()
			MouseEnter:Disconnect()
			MouseLeave:Disconnect()
			MouseUpConnection:Disconnect()
			ResizeConnection:Disconnect()
			MoveConnection:Disconnect()
			CloseConnection:Disconnect()

			for i, Page in next, Pages do
				for i, Widget: SolarBaseWidget in next, Page do
					Widget:Destroy()
				end
			end

			Step:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
		end

		-- SubWidget Stuffs
		function Widget:Empty(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("Empty")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:Text(Args: SolarArgs?): SolarText
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("Text")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:Value(Args: SolarArgs?): SolarValue
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("Value")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:CheckBox(Args: SolarArgs?): SolarCheckBox
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("CheckBox")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:DropDown(Args: SolarArgs?): SolarDropDown
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("DropDown")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:Button(Args: SolarArgs?): SolarButton
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("Button")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:Array(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("Array")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:Content(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local SubWidget = GetWidget("Content")(Args)

			table.insert(GetCurrentPage(), SubWidget)

			return SubWidget
		end

		function Widget:TabBar(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget

			local TabBar = GetWidget("TabBar")(Args)

			table.insert(TabBars, TabBar)
			TabBar.Gui.Parent = Gui.TitleBar
			return TabBar
		end

		return Widget
	end)

	CreateWidget("Empty", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarWidget = GetWidget("BaseWidget")(Args)
		Widget.Name = ""
		Widget.Class = "Empty"

		local Gui = {
			ClassName = "Frame",
			Size = UDim2.new(1, 0, 0, 30),
			BackgroundTransparency = 1,
		} :: BaseGui
		Gui = Utils.newInstanceFromTable(Gui)
		Widget.Gui = Gui

		local StepConnection = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			StepConnection:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
		end

		return Widget
	end)

	CreateWidget("Text", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarText = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "Text"
		Widget.Class = "Text"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil
		Widget.Side = Args.Side or "Left"
		Widget.TextEditable = Args.TextEditable or false

		local Gui = {
			ClassName = "Frame",
			Text = {
				ClassName = "TextBox",

				Text = Widget.Name,

				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),

				ClearTextOnFocus = false,
				MultiLine = true,
			} :: TextBox,
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local Step = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Gui.Size = UDim2.new(1, 0, 0, Gui.Text.TextBounds.Y)
			Gui.Text.TextEditable = Widget.Editable
			Gui.Text.Text = Widget.Name

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			Step:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
			Widget = nil
		end

		return Widget
	end)

	CreateWidget("Value", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarValue = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "Value"
		Widget.Class = "Value"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil
		Widget.Side = Args.Side or "Left"
		Widget.ValueEditable = Args.ValueEditable or true

		Widget.Value = Args.Value or 0

		local Gui = {
			ClassName = "Frame",
			Text = {
				ClassName = "TextBox",

				Text = Widget.Name,

				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),

				TextEditable = false,
				ClearTextOnFocus = false,
			} :: TextBox,
			Value = {
				ClassName = "TextBox",

				Text = tostring(Widget.Value),

				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),

				TextEditable = Widget.ValueEditable,
				ClearTextOnFocus = false,
			} :: TextBox,
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local Step = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Gui.Size = UDim2.new(1, 0, 0, Gui.Text.TextBounds.Y + 4)
			Gui.Value.Size = UDim2.new(0, Gui.Value.TextBounds.X, 1, 0)
			Gui.Value.TextEditable = Widget.ValueEditable
			
			Gui.Text.Text = Widget.Name

			if Gui.Value:IsFocused() then
				local Value = Gui.Value.Text
				local NewValue = tonumber(Value) ~= nil and tonumber(Value) or toboolean(Value) ~= nil and toboolean(Value) or Value
				Widget.Value = NewValue
			else
				Gui.Value.Text = tostring(Widget.Value)
			end

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			Step:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
			Widget = nil
		end

		return Widget
	end)

	CreateWidget("DropDown", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarDropDown = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "DropDown"
		Widget.Class = "DropDown"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil
		Widget.Side = Args.Side or "Left"

		Widget.State = {
			Value = Args.Value or "Option 1",
			Open = false
		}

		Widget.Locked = Args.Locked or false

		local Options = {}
		local OptionIndex = 1
		local SelectConnections = {}

		local Gui = {
			ClassName = "Frame",

			Size = UDim2.new(1, 0, 0, 30),
			ZIndex = 2,

			NameLabel = {
				ClassName = "TextBox",

				Text = Widget.Name,

				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 20, 0.5, 0),

				ClearTextOnFocus = false,
				MultiLine = true,
				TextEditable = false,
			} :: TextBox,

			Selector = {
				ClassName = "ImageButton",

				AnchorPoint = Vector2.new(0, .5),
				Position = UDim2.new(0, 0, .5, 0),
				Size = UDim2.new(0, 50, 1, 0),

				DropDownIcon = {
					ClassName = "ImageLabel",
				} :: ImageLabel,

				Value = {
					ClassName = "TextLabel",

					Text = Widget.State.Value,
				} :: TextLabel,

				DropDown = {
					ClassName = "Frame",
					Position = UDim2.new(0, 0, 1, 0),
					Size = UDim2.fromScale(1, 0),
				} :: Frame,
			} :: ImageButton,
		} :: Frame

		local DropDownGui = {
			ClassName = "TextButton",
			Size = UDim2.new(1, 0, 0, 20),
		} :: TextButton

		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local DropDownConnection = Gui.Selector.MouseButton1Down:Connect(function()
			Widget:SetOpen(not Widget.State.Open)
		end)

		local Step = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Gui.NameLabel.Text = Widget.Name
			Gui.NameLabel.Size = UDim2.new(0, Gui.NameLabel.TextBounds.X, 1, 0)
			Gui.Selector.Value.Text = tostring(Widget.State.Value)
			if Widget.Locked then
				Widget:SetOpen(false, true)
			end

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:SetOpen(Open: boolean, Force: boolean?)
			if Widget.Locked and (Force == nil or not Force) then
				return
			end
			Widget.State.Open = Open

			if Widget.State.Open then
				local Y = 0
				for i, v: SolarDropDownOption in next, Options do
					v.State.Selected = (i == OptionIndex)
	
					local DropDownGui = Utils.newInstanceFromTable(DropDownGui) :: BaseGui
					DropDownGui.Text = v.Value
					DropDownGui.Parent = Gui.Selector.DropDown
					DropDownGui.Position = UDim2.fromOffset(0, Y)

					Styler.ApplyStyle(v, DropDownGui)

					SelectConnections[i] = DropDownGui.MouseButton1Down:Connect(function()
						local OriginalLocked = Widget.Locked
						Widget.Locked = false
						Widget.State.Value = v.Value
						Widget:SetOpen(false)
						Widget.Locked = OriginalLocked
					end)
	
					Y += DropDownGui.AbsoluteSize.Y
				end
				Gui.Selector.DropDown.Size = UDim2.new(1, 0, 0, Y)
			else
				Gui.Selector.DropDown.Size = UDim2.fromScale(1, 0)
				for i, v in next, Gui.Selector.DropDown:GetChildren() do
					v:Destroy()
				end

				for i, v in next, SelectConnections do
					v:Disconnect()
				end
			end
		end

		function Widget:Option(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local Option: SolarDropDownOption = {}
			Option.Class = "DropDownOption"
			Option.Value = (#Options+1 == OptionIndex and Widget.State.Value) or Args.Name or "Option"
			Option.State = {
				Selected = false,
			}

			Options[#Options+1] = Option

			return Option
		end

		Widget:Option()

		function Widget:Destroy()
			Step:Disconnect()
			DropDownConnection:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
			Values = nil
			Widget = nil
		end

		return Widget
	end)

	CreateWidget("CheckBox", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarCheckBox = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "CheckBox"
		Widget.Class = "CheckBox"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil
		Widget.Side = Args.Side or "Left"
		Widget.State = {
			Value = Args.Value or false
		}
		Widget.Locked = Args.Locked or false

		local Gui = {
			ClassName = "Frame",

			Size = UDim2.new(1, 0, 0, 30),

			NameLabel = {
				ClassName = "TextBox",

				Text = Widget.Name,

				AnchorPoint = Vector2.new(0, 0.5),
				Position = UDim2.new(0, 20, 0.5, 0),

				ClearTextOnFocus = false,
				MultiLine = true,
				TextEditable = false,
			} :: TextBox,

			Box = {
				ClassName = "ImageButton",

				AnchorPoint = Vector2.new(0, .5),
				Position = UDim2.new(0, 0, .5, 0),

				Check = {
					ClassName = "ImageLabel",
	
					AnchorPoint = Vector2.new(.5, .5),
					Position = UDim2.fromScale(.5, .5),
				} :: ImageLabel,
			} :: ImageButton,
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local Clicked = Gui.Box.MouseButton1Down:Connect(function()
			if Widget.Locked then return end
			Widget.State.Value = not Widget.State.Value
		end)

		local Step = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Gui.NameLabel.Text = Widget.Name
			Gui.NameLabel.Size = UDim2.new(0, Gui.NameLabel.TextBounds.X, 1, 0)

			Gui.Box.Check.Visible = Widget.State.Value

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			Step:Disconnect()
			Clicked:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
			Widget = nil
		end

		return Widget
	end)

	CreateWidget("Button", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarButton = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "Button"
		Widget.Class = "Button"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil
		Widget.Side = Args.Side or "Left"

		Widget.Clickable = Args.Clickable or true

		Widget.Mouse1Down = Signals.new()
		Widget.Mouse1Up = Signals.new()

		Widget.Mouse2Down = Signals.new()
		Widget.Mouse2Up = Signals.new()

		local Gui = {
			ClassName = "Frame",
			Size = UDim2.new(1, 0, 0, 30),
			Button = {
				ClassName = "TextButton",

				Text = Widget.Name,

				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.5, 0, 0.5, 0),
			} :: TextButton,
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local MouseButton1Down = Gui.Button.MouseButton1Down:Connect(function()
			if Widget.Clickable then
				Widget.Mouse1Down:Fire()
			end
		end)

		local MouseButton1Up = Gui.Button.MouseButton1Up:Connect(function()
			if Widget.Clickable then
				Widget.Mouse1Up:Fire()
			end
		end)

		local MouseButton2Down = Gui.Button.MouseButton2Down:Connect(function()
			if Widget.Clickable then
				Widget.Mouse2Down:Fire()
			end
		end)

		local MouseButton2Up = Gui.Button.MouseButton2Up:Connect(function()
			if Widget.Clickable then
				Widget.Mouse2Up:Fire()
			end
		end)

		local Step = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Gui.Button.Text = Widget.Name

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			MouseButton1Down:Disconnect()
			MouseButton1Up:Disconnect()
			MouseButton2Down:Disconnect()
			MouseButton2Up:Disconnect()
			Step:Disconnect()
			Gui:Destroy()
			table.clear(Widget)
			Widget = nil
		end

		return Widget
	end)

	CreateWidget("Array", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarArray = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "Array"
		Widget.Class = "Array"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil

		Widget.Step = Signals.new()

		local SubWidgets = {}

		local Gui = {
			ClassName = "Frame",

			Size = UDim2.new(1, 0, 0, 40),

			Array = {
				ClassName = "Frame",
				Size = UDim2.fromScale(1, 1),
			} :: Frame,
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui)
		Widget.Gui = Gui

		local StepConnection = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Widget.Step:Fire()
			Gui.Name = Widget.Name
			local Amount = #SubWidgets
			local X = 0
			for i, v: SolarBaseWidget in next, SubWidgets do
				if v.Class == nil then
					table.remove(SubWidgets, i)
					continue
				end

				if v.Gui and not v.Gui.Visible then
					continue
				end

				v.Gui.Parent = Gui.Array
				v.Gui.Size = UDim2.fromScale(1 / Amount, 1)
				v.Gui.Position = UDim2.fromOffset(X, 0)
				X += v.Gui.AbsoluteSize.X
			end

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			StepConnection:Disconnect()
			for i, v: SolarBaseWidget in next, SubWidgets do
				v:Destroy()
			end

			Gui:Destroy()
		end

		-- SubWidgets
		function Widget:Empty(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window
			Args.Side = "Center"

			local SubWidget = GetWidget("Empty")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Text(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window
			Args.Side = "Center"

			local SubWidget = GetWidget("Text")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Value(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window
			Args.Side = "Center"

			local SubWidget = GetWidget("Value")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:CheckBox(Args: SolarArgs?): SolarCheckBox
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("CheckBox")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Button(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window
			Args.Side = "Center"

			local SubWidget = GetWidget("Button")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Array(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Array")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		return Widget
	end)

	CreateWidget("Content", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarContent = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "Content"
		Widget.Class = "Content"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil

		Widget.DisplayName = Args.DisplayName or false
		Widget.Size = Args.Size or UDim2.new(1, 0, 0, 300)

		local SubWidgets = {}

		local Gui = {
			ClassName = "Frame",
			Size = Widget.Size,
			Content = {
				ClassName = "ScrollingFrame",
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(1, 0, 1, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				ClipsDescendants = true,
				AutomaticCanvasSize = Enum.AutomaticSize.Y,
				CanvasSize = UDim2.new(0, 0),
			} :: ScrollingFrame,

			DisplayName = {
				ClassName = "TextLabel",
				Text = Widget.Name,
				Visible = Widget.DisplayName,

				TextSize = 8,
				ZIndex = 2,
			} :: TextLabel,
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local StepConnection = (Widget.Parent.Step or Widget.Window.Step):Connect(function()
			Gui.Name = Widget.Name
			Gui.Size = Widget.Size

			local Y = 0
			local Y2 = 0
			for i, SubWidget: SolarBaseWidget in next, SubWidgets do
				if SubWidget.Class == nil then
					table.remove(SubWidgets, i)
					continue
				end

				if SubWidget.Gui and not SubWidget.Gui.Visible then
					continue
				end
				SubWidget.Gui.Parent = Widget.Gui.Content

				SubWidget.Gui.AnchorPoint =
					Vector2.new(SubWidget.Side == "Right" and 1 or SubWidget.Side == "Left" and 0 or 0.5, 0)
				SubWidget.Gui.Position = UDim2.new(
					SubWidget.Side == "Right" and 1 or SubWidget.Side == "Left" and 0 or 0.5,
					0,
					0,
					SubWidget.Side == "Right" and Y2 or Y
				)

				if SubWidget.Side == "Right" then
					Y2 += SubWidget.Gui.AbsoluteSize.Y
				elseif SubWidget.Side == "Left" then
					Y += SubWidget.Gui.AbsoluteSize.Y
				else
					Y2 += SubWidget.Gui.AbsoluteSize.Y
					Y += SubWidget.Gui.AbsoluteSize.Y
				end
			end

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			StepConnection:Disconnect()
			for i, v: SolarBaseWidget in next, SubWidgets do
				v:Destroy()
			end

			Gui:Destroy()
		end

		-- SubWidgets
		function Widget:Empty(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Empty")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Text(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Text")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Value(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Value")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:DropDown(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("DropDown")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:CheckBox(Args: SolarArgs?): SolarCheckBox
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("CheckBox")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Button(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Button")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Content(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Content")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		function Widget:Array(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window

			local SubWidget = GetWidget("Array")(Args)

			table.insert(SubWidgets, SubWidget)

			return SubWidget
		end

		return Widget
	end)

	CreateWidget("TabBar", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarTabBar = GetWidget("BaseWidget")(Args)
		Widget.Name = Args.Name or "TabBar"
		Widget.Class = "TabBar"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil

		local Tabs = {}

		local Gui = {
			ClassName = "Frame",

			Size = UDim2.new(1, 0, 0, 15),
		} :: Frame
		Gui = Utils.newInstanceFromTable(Gui)
		Widget.Gui = Gui

		local StepConnection = Widget.Window.Step:Connect(function()
			Gui.Name = Widget.Name
			local TX = 0
			for i, v: SolarTab in next, Tabs do
				v.Gui.Position = UDim2.fromOffset(TX, v.Gui.Position.Y.Offset)
				TX += v.Gui.AbsoluteSize.X
			end

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Tab(Args: SolarArgs?)
			Args = Args or {}
			Args.Parent = Widget
			Args.Window = Widget.Window
			Args.PageId = #Widget.Window:GetPages() == #Widget.Window:GetTabs() + 1 and 1 or Widget.Window:AddPage()

			local Tab = GetWidget("Tab")(Args)
			Tabs[#Tabs + 1] = Tab
			Tab.Gui.Parent = Gui
			return Tab
		end

		function Widget:Destroy()
			StepConnection:Disconnect()
			for i, v in next, Tabs do
				v:Destroy()
			end
			Gui:Destroy()
			table.clear(Widget)
		end

		function Widget:GetTab(Tabid)
			assert(Tabs[Tabid], "Tab #" .. Tabid .. " does not exist.")
			return Tabs[Tabid]
		end

		function Widget:GetTabs()
			return Tabs
		end

		if #Widget.Window:GetTabs() == 0 then
			Widget:Tab({ Name = Widget.Window.Name })
		end

		return Widget
	end)

	CreateWidget("Tab", function(Args: SolarArgs?)
		Args = Args or {}
		local Widget: SolarTab = {}
		Widget.Name = Args.Name or "Tab"
		Widget.Class = "Tab"
		Widget.Window = Args.Window
		Widget.Parent = Args.Parent or nil

		Widget.Page = Widget.Window:GetPageFromId(Args.PageId)
		Widget.State = {
			Open = Widget.Window.GetPage() == Widget.Page,
		}

		local Gui = {
			ClassName = "TextButton",
			Text = Widget.Name,
		} :: TextButton
		Gui = Utils.newInstanceFromTable(Gui) :: BaseGui
		Widget.Gui = Gui

		local PageId = Args.PageId

		local ClickedConnection = Gui.MouseButton1Down:Connect(function()
			Widget.Window:SetPage(PageId)
		end)

		local StepConnection = Widget.Window.Step:Connect(function()
			Gui.Name = Widget.Name
			Gui.Text = Widget.Name
			Widget.State.Open = Widget.Window.GetPage() == Widget.Page

			Styler.ApplyStyle(Widget, Gui)
		end)

		function Widget:Destroy()
			ClickedConnection:Disconnect()
			StepConnection:Disconnect()
			Widget.Window:RemovePage(PageId)
			Gui:Destroy()
			table.clear(Widget)
		end

		return Widget
	end)
end

local Initialized = false
function Solar.Init(Gui: ScreenGui?, Style: SolarStyle?)
	Solar.Style = Style or Solar.Style
	Solar.Gui = Gui or Instance.new("ScreenGui")
	if not Gui then
		Utils.ApplyProperties(
			Solar.Gui,
			{
				Parent = PlayerGui,
				IgnoreGuiInset = true,
				DisplayOrder = 256,
				Name = "SolarGUI",
				ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
			} :: ScreenGui
		)
	end

	Initialized = true

	RunService.RenderStepped:Connect(function(deltaTime)
		ScreenResolution = workspace.CurrentCamera.ViewportSize

		Solar.Stepped:Fire(deltaTime)
	end)

	function Solar:Window(Args: SolarArgs?): SolarWindow
		return GetWidget("Window")(Args)
	end

	function Solar:DemoWindow()
		local Window = Solar:Window({ Name = "Solar Demo Window", Icon = "rbxassetid://16928568790" })

		Window:Text({ Name = "Normal Text" })
		Window:Text({ Name = "Rightside Text", Side = "Right" })
		Window:Empty()
		Window:Text({
			Name = "Anything can be customized with Styles,\nif you dont have a style applied solar may struggle to render\nthings properly so make sure you have one applied.",
		})
		Window:Empty()
		Window:Text({ Name = "Theres nothing on the Alt tab" })
		Window:CheckBox({Name = "CheckBox"})

		local TabBar = Window:TabBar()
		TabBar:GetTab(1).Name = "Main"
		TabBar:Tab({ Name = "Alt" })
		TabBar:Tab({ Name = "Misc" })

		Window:SetPage(2)
		Window:Text({ Name = "Made you look!" })
		Window:Empty()
		Window:Text({ Name = "Anyways, heres an array" })
		local Array = Window:Array()
		Array:Text({ Name = "Text!" })
		Array:Text({ Name = "Text?" })
		Array:Button({ Name = "Button!" })
		local SubArray = Array:Array()
		SubArray:Button({ Name = "" })
		SubArray:Text({ Name = "sub-Array!" })

		Window:SetPage(3)
		local Content = Window:Content()
		Content.DisplayName = true
		Content:CheckBox({Name = "Check Box 1"})
		local SubContent = Content:Content({Name = "Sub Content!"})
		SubContent:CheckBox({Name = "Check Box 2"})
		Window:Button({ Name = "Go back to " .. TabBar:GetTab(1).Name }).Mouse1Down:Connect(function()
			Window:SetPage(1)
		end)

		local Array = Window:Array()
		Array:CheckBox()
		Array:CheckBox()
		Array:CheckBox()
		Array:CheckBox()

		TabBar:Tab({Name = "Drop Down Demo"})
		Window:SetPage(4)
		local DropDown = Window:DropDown({Name = "Drop Down Test"})
		DropDown:Option({Name = "Option 2"})

		Window:SetPage(1)
		Window:TabBar():Tab({Name = "Test"})
		Window:SetPage(5)
		Window:Value()

		local Array = Window:Array()
		Array:CheckBox()
		Array:Value({Name = "Array Value"})

		local Content = Window:Content()
		Content:CheckBox()
		Content:DropDown():Option({Name = "Option 2"})
		Content:Value({Name = "Array Value"})

		Window:SetPage(1)
	end
end

return Solar
