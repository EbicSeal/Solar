--!nocheck
local Solar = require(script.Solar) -- Module path here

local function randomize(t: {any})
	for i, v in next, t do
		local valueType = typeof(v)
		if valueType == "number" then
			t[i] = math.random(v - math.random(0, 100), v + math.random(0, 100))
		elseif valueType == "boolean" then
			t[i] = (math.random() == 1 or false)
		elseif valueType == "UDim" then
			t[i] = UDim.new(v.Scale * math.random(-10, 10) / 10, v.Offset + math.random(-50, 50))
		elseif valueType == "Color3" then
			t[i] = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
		elseif valueType == "ColorSequence" then
			t[i] = ColorSequence.new({
				ColorSequenceKeypoint.new(0, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
				ColorSequenceKeypoint.new(1, Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))),
			})
		elseif valueType == "UDim2" then
			t[i] = UDim2.new(v.X.Scale * math.random(-10, 10) / 10, v.X.Offset + math.random(-50, 50), v.Y.Scale * math.random(-10, 10) / 10, v.Y.Offset + math.random(-50, 50))
		elseif valueType == "table" then
			t[i] = randomize(v)
		elseif valueType == "EnumItem" then
			t[i] = v.EnumType:GetEnumItems()[math.random(1, #v.EnumType:GetEnumItems())]
		end
	end
	
	return t
end

local DefaultStyle = {
	-- Colors
	Colors = {
		Main = Color3.fromRGB(150, 70, 140),
		Second = Color3.fromRGB(30, 30, 30),
		Third = Color3.fromRGB(25, 25, 25),
		Fourth = Color3.fromRGB(40, 40, 40),
		
		DefaultTextColor = Color3.fromRGB(230, 230, 230),
	},

	-- Fonts
	Fonts = {
		Default = Enum.Font.Code,
		TitleBar = Enum.Font.SourceSans,
	},
	
	Images = {
		CloseButton = "rbxassetid://16927871674",
		CheckBox = "rbxassetid://16962400397",
		DropDownClosed = "rbxassetid://16970123100",
		DropDownOpen = "rbxassetid://16970129962",
		ScrollTop = "rbxassetid://16873350157",
		ScrollMid = "rbxassetid://16873350157",
		ScrollBottom = "rbxassetid://16873350157",
	}
}

local Glass = {
	Color = ColorSequence.new(
		{
			ColorSequenceKeypoint.new(0, Color3.new(.5, .5, .5)),
			ColorSequenceKeypoint.new(1, Color3.new(1, 1, 1))
		}
	),
	Rotation = -90
} :: UIGradient & any

DefaultStyle.Widgets = {
	Window = {
		BackgroundColor3 = DefaultStyle.Colors.Second,

		Border = {
			Thickness = 1,
			Color = DefaultStyle.Colors.Main,
		} :: UIStroke & any,
		BorderSizePixel = 0,

		TitleBar = {
			BackgroundColor3 = DefaultStyle.Colors.Main,
			BorderSizePixel = 0,

			MoveButton = {
				Transparency = 1,
				AutoButtonColor = false,
			} :: ImageButton & any,

			WindowName = {
				Size = function(Widget: Solar.SolarBaseWidget)
					if Widget.Icon then
						return UDim2.new(1, -37, 1, 0)
					else
						return UDim2.new(1, -5, 1, 0)
					end
				end,
				Position = function(Widget: Solar.SolarBaseWidget)
					if Widget.Icon then
						return UDim2.fromOffset(37, 0)
					else
						return UDim2.fromOffset(5, 0)
					end
				end,
				TextXAlignment = Enum.TextXAlignment.Left,

				Font = DefaultStyle.Fonts.TitleBar,
				TextColor3 = DefaultStyle.Colors.DefaultTextColor,
				TextSize = 18,
			} :: TextLabel & any,
			
			Icon = {
				Visible = function(Widget: Solar.SolarBaseWidget)
					return Widget.Icon ~= nil
				end,
				
				Image = function(Widget: Solar.SolarBaseWidget)
					return Widget.Icon or ""
				end,
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
			} :: ImageLabel & any,
			
			CloseButton = {
				ResampleMode = Enum.ResamplerMode.Pixelated,
				Image = DefaultStyle.Images.CloseButton,
				
				BorderSizePixel = 0,
				BackgroundTransparency = 1,
				
				Border = {
					Color = DefaultStyle.Colors.Second,
				} :: UIStroke & any,
				
				AnchorPoint = Vector2.new(1, .5),
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(1, -8, .5)
			} :: ImageButton & any,
			
			Gradient = Glass,
		} :: Frame & any,

		Resizer = {
			BackgroundColor3 = DefaultStyle.Colors.Main,

			Size = UDim2.fromOffset(4, 4),

			BorderSizePixel = 0,

			AutoButtonColor = false,
		} :: ImageButton & any,

		Content = {
			Position = UDim2.new(0.5, 0, 0.5, 16),
			Size = UDim2.new(1, -10, 1, -41),
			AnchorPoint = Vector2.new(0.5, 0.5),

			MidImage = DefaultStyle.Images.ScrollMid,
			TopImage = DefaultStyle.Images.ScrollTop,
			BottomImage = DefaultStyle.Images.ScrollBottom,

			BackgroundColor3 = DefaultStyle.Colors.Third,

			BorderSizePixel = 0,

			ScrollBarImageColor3 = DefaultStyle.Colors.Main,
			ScrollBarThickness = 2,

			Border = {
				Color = DefaultStyle.Colors.Fourth,
			} :: UIStroke & any,	
		} :: ScrollingFrame & any,
	} :: CanvasGroup & any,
	
	Empty = {
		Size = UDim2.new(1, 0, 0, 20)
	} :: Frame & any,
	
	Text = {
		BackgroundTransparency = 1,
		Text = {
			BackgroundTransparency = 1,
			
			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Size = UDim2.new(1, -7, 0.8),
			Font = DefaultStyle.Fonts.Default,
			TextSize = 12,
			TextXAlignment = function(Widget: Solar.SolarBaseWidget)
				return Enum.TextXAlignment[Widget.Side]
			end,
		} :: TextBox & any,
	} :: Frame & any,
	
	Value = {
		BackgroundTransparency = 1,
		Text = {
			BackgroundTransparency = 1,
			
			Position = UDim2.new(0, 3, .5, 0),
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.Text.TextBounds.X, 1, -6)
			end,
			
			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Font = DefaultStyle.Fonts.Default,
			TextSize = 12,
			TextXAlignment = function(Widget: Solar.SolarBaseWidget)
				return Enum.TextXAlignment[Widget.Side]
			end,
		} :: TextBox & any,
		Value = {
			BackgroundColor3 = DefaultStyle.Colors.Second,
			
			Position = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.Text.TextBounds.X + 8, .5, 0)
			end,
			
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.Value.TextBounds.X + 3, 1, -2)
			end,
			
			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Font = DefaultStyle.Fonts.Default,
			TextSize = 12,
			
			Border = {
				Color = DefaultStyle.Colors.Fourth,
			} :: UIStroke & any,
			
			Gradient = Glass,
		} :: TextBox & any,
	} :: Frame & any,
	
	CheckBox = {
		BackgroundTransparency = 1,
		NameLabel = {
			BackgroundTransparency = 1,

			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(1, Widget.Gui.NameLabel.TextBounds.X, 1)
			end,
			Font = DefaultStyle.Fonts.Default,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		} :: TextBox & any,
		
		Box = {
			BackgroundColor3 = DefaultStyle.Colors.Third,
			Position = UDim2.new(0, 5, .5, 0),
			Size = UDim2.fromOffset(10, 10),
			AutoButtonColor = false,
			
			
			Border = {
				Color = DefaultStyle.Colors.Fourth,
			} :: UIStroke & any,
			
			Gradient = Glass,
			
			Check = {
				BackgroundTransparency = 1,
				Image = DefaultStyle.Images.CheckBox,
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ImageColor3 = DefaultStyle.Colors.Main,
				Size = UDim2.fromScale(1, 1),
				
				Visible = function(Widget: Solar.SolarBaseWidget)
					return Widget.State.Value
				end,
			} :: ImageLabel & any,
		} :: ImageButton & any,
	} :: Frame & any,
	
	DropDown = {
		BackgroundTransparency = 1,
		NameLabel = {
			BackgroundTransparency = 1,

			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(1, Widget.Gui.NameLabel.TextBounds.X, 1)
			end,
			Position = UDim2.new(0, 115, .5, 0),
			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Font = DefaultStyle.Fonts.Default,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		} :: TextBox & any,

		Selector = {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, .5),
			Position = UDim2.new(0, 3, .5, 0),
			Size = UDim2.new(0, 100, .5, 0),

			DropDownIcon = {
				BackgroundColor3 = DefaultStyle.Colors.Third,
				
				Border = {
					Color = DefaultStyle.Colors.Fourth,
					Thickness = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				} :: UIStroke & any,
				
				Gradient = Glass,
				
				Image = function(Widget: Solar.SolarBaseWidget)
					return Widget.State.Open == true and DefaultStyle.Images.DropDownOpen or DefaultStyle.Images.DropDownClosed
				end,
				
				Size = function(Widget: Solar.SolarBaseWidget)
					return UDim2.fromOffset(Widget.Gui.Selector.AbsoluteSize.Y, Widget.Gui.Selector.AbsoluteSize.Y)
				end,
			} :: ImageLabel,

			Value = {
				BackgroundColor3 = DefaultStyle.Colors.Third,

				Border = {
					Color = DefaultStyle.Colors.Fourth,
					Thickness = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				} :: UIStroke & any,
				
				Gradient = Glass,
				
				Size = function(Widget: Solar.SolarBaseWidget)
					return UDim2.new(1, -Widget.Gui.Selector.AbsoluteSize.Y, 1, 0)
				end,
				Position = function(Widget: Solar.SolarBaseWidget)
					return UDim2.fromOffset(Widget.Gui.Selector.AbsoluteSize.Y, 0)
				end,
				
				Text = function(Widget: Solar.SolarBaseWidget)
					return " " .. tostring(Widget.State.Value)
				end,
				TextColor3 = DefaultStyle.Colors.DefaultTextColor,
				Font = DefaultStyle.Fonts.Default,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			} :: TextLabel,

			DropDown = {
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.fromScale(1, 0),
				
				Visible = function(Widget: Solar.SolarBaseWidget)
					return Widget.State.Open
				end,
				
				BackgroundColor3 = DefaultStyle.Colors.Third,

				Border = {
					Color = DefaultStyle.Colors.Fourth,
					Thickness = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				} :: UIStroke & any,
			} :: Frame,
		} :: ImageButton,
	} :: Frame & any,
	
	DropDownOption = {
		BackgroundColor3 = DefaultStyle.Colors.Third,
		TextColor3 = DefaultStyle.Colors.DefaultTextColor,
		Font = DefaultStyle.Fonts.Default,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
		
		Gradient = Glass,
		
		Border = {
			Color = DefaultStyle.Colors.Fourth,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		} :: UIStroke & any,
	} :: TextButton,
	
	Button = {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, 0, 0, 30),
		Button = {
			BackgroundColor3 = DefaultStyle.Colors.Third,
			AutoButtonColor = false,

			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Size = UDim2.new(1, -6, 1, -6),
			TextSize = 12,
			Font = Enum.Font.Code,

			Border = {
				Color = DefaultStyle.Colors.Fourth,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			} :: UIStroke & any,
			
			Gradient = Glass,
		} :: TextButton & any,
	} :: Frame & any,
	
	Array = {
		BackgroundTransparency = 1,
		Array = {
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, -4, 1, -4),
			AnchorPoint = Vector2.new(0.5, 0.5),

			BackgroundColor3 = DefaultStyle.Colors.Third,

			BorderSizePixel = 0,

			Border = {
				Color = DefaultStyle.Colors.Fourth,
			} :: UIStroke & any,	
		} :: Frame & any,
	} :: Frame & any,
	
	Content = {
		BackgroundTransparency = 1,
		Content = {
			BackgroundColor3 = DefaultStyle.Colors.Third,

			MidImage = DefaultStyle.Images.ScrollMid,
			TopImage = DefaultStyle.Images.ScrollTop,
			BottomImage = DefaultStyle.Images.ScrollBottom,

			ScrollBarImageColor3 = DefaultStyle.Colors.Main,
			ScrollBarThickness = 2,

			Position = function(Widget: Solar.SolarBaseWidget)
				if Widget.DisplayName then
					return UDim2.new(.5, 0, .5, 6)
				else
					return UDim2.fromScale(.5, .5)
				end
			end,
			Size = function(Widget: Solar.SolarBaseWidget)
				if Widget.DisplayName then
					return UDim2.new(1, -6, 0, Widget.Size.Y.Offset - 15)
				else
					return UDim2.new(1, -6, 0, Widget.Size.Y.Offset - 6)
				end
			end,

			BorderSizePixel = 0,

			Border = {
				Color = DefaultStyle.Colors.Fourth,
			} :: UIStroke & any,
		} :: ScrollingFrame & any,

		DisplayName = {
			BackgroundColor3 = DefaultStyle.Colors.Third,

			Position = UDim2.new(0, 6, 0, 2),
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.DisplayName.TextBounds.X + 3, 0, 10)
			end,
			Visible = function(Widget: Solar.SolarBaseWidget)
				return Widget.DisplayName
			end,
			BorderSizePixel = 0,
			TextColor3 = DefaultStyle.Colors.DefaultTextColor,
			Font = DefaultStyle.Fonts.Default,

			Border = {
				Color = DefaultStyle.Colors.Fourth,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			} :: UIStroke & any,
		} :: TextLabel & any,
	} :: Frame & any,
	
	TabBar = {
		BackgroundTransparency = 1,
		Position = function(Widget: Solar.SolarBaseWidget)
			return Widget.Gui.Position + UDim2.new(0, 5, 0, 3)
		end,
		
	} :: Frame & any,
	
	Tab = {
		BackgroundColor3 = function(Widget: SolarTab)
			if Widget.State.Open then
				return DefaultStyle.Colors.Second
			else
				return DefaultStyle.Colors.Third
			end
		end,
		AutoButtonColor = false,

		TextSize = 14,
		TextColor3 = DefaultStyle.Colors.DefaultTextColor,
		Font = DefaultStyle.Fonts.Default,

		Size = function(Widget: SolarTab)
			return UDim2.new(0, Widget.Gui.TextBounds.X + 10, 1, Widget.State.Open and 2 or 0)
		end,
		
		Position = function(Widget: SolarTab)
			return UDim2.fromOffset(Widget.Gui.Position.X.Offset, Widget.State.Open and -2 or 0)
		end,

		BorderSizePixel = 0,

		Border = {
			Color = DefaultStyle.Colors.Fourth,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		} :: UIStroke & any,
		
		Gradient = Glass
	} :: TextLabel & any,
}


-- Theme randomizer, makes it basicly unusable.
-- randomize(DefaultStyle)

game:GetService("StarterGui"):SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

Solar.Init(nil, DefaultStyle)

Solar:DemoWindow()