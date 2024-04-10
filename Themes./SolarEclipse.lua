--!nocheck
local Style = {
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
		
		WindowIcon = "rbxassetid://16928568790"
	}
}

local Glass = {
	Color = ColorSequence.new(
		{
			ColorSequenceKeypoint.new(0, Color3.new(1, 1, 1)),
			ColorSequenceKeypoint.new(1, Color3.new(.5, .5, .5)),
		}
	),
	Rotation = 90
} :: UIGradient & any

Style.Widgets = {
	Window = {
		BackgroundColor3 = Style.Colors.Second,

		Border = {
			Thickness = 1,
			Color = Style.Colors.Main,
		} :: UIStroke & any,
		BorderSizePixel = 0,

		TitleBar = {
			BackgroundColor3 = Style.Colors.Main,
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

				Font = Style.Fonts.TitleBar,
				TextColor3 = Style.Colors.DefaultTextColor,
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
				Image = Style.Images.CloseButton,

				BorderSizePixel = 0,
				BackgroundTransparency = 1,

				Border = {
					Color = Style.Colors.Second,
				} :: UIStroke & any,

				AnchorPoint = Vector2.new(1, .5),
				Size = UDim2.fromOffset(16, 16),
				Position = UDim2.new(1, -8, .5)
			} :: ImageButton & any,

			Gradient = Glass,
		} :: Frame & any,

		Resizer = {
			BackgroundColor3 = Style.Colors.Main,

			Size = UDim2.fromOffset(4, 4),

			BorderSizePixel = 0,

			AutoButtonColor = false,
		} :: ImageButton & any,

		Content = {
			Position = UDim2.new(0.5, 0, 0.5, 16),
			Size = UDim2.new(1, -10, 1, -41),
			AnchorPoint = Vector2.new(0.5, 0.5),

			MidImage = Style.Images.ScrollMid,
			TopImage = Style.Images.ScrollTop,
			BottomImage = Style.Images.ScrollBottom,

			BackgroundColor3 = Style.Colors.Third,

			BorderSizePixel = 0,

			ScrollBarImageColor3 = Style.Colors.Main,
			ScrollBarThickness = 2,

			Border = {
				Color = Style.Colors.Fourth,
			} :: UIStroke & any,
		} :: ScrollingFrame & any,
	} :: CanvasGroup & any,

	Text = {
		BackgroundTransparency = 1,
		Text = {
			BackgroundTransparency = 1,

			TextColor3 = Style.Colors.DefaultTextColor,
			Size = UDim2.new(1, -2, 1, -2),
			Font = Style.Fonts.Default,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 12,
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

			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,
			TextSize = 12,
			TextXAlignment = function(Widget: Solar.SolarBaseWidget)
				return Enum.TextXAlignment[Widget.Side]
			end,
		} :: TextBox & any,
		Value = {
			BackgroundColor3 = Style.Colors.Second,

			Position = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.Text.TextBounds.X + 8, .5, 0)
			end,

			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.Value.TextBounds.X + 3, 1, -2)
			end,

			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,
			TextSize = 12,

			Border = {
				Color = Style.Colors.Fourth,
			} :: UIStroke & any,

			Gradient = Glass,
		} :: TextBox & any,
	} :: Frame & any,
	
	Progress = {
		BorderSizePixel = 0,
		BackgroundTransparency = 1,
		Bar = {
			BackgroundColor3 = Style.Colors.Third,
			Size = UDim2.new(1, -4, 1, -4),
			Position = UDim2.fromScale(.5, .5),
			AnchorPoint = Vector2.new(.5, .5),

			Border = {
				Color = Style.Colors.Fourth, 
			} :: UIStroke,

			Progress = {
				BorderSizePixel = 0,
				BackgroundColor3 = Style.Colors.Main,
				
				Gradient = Glass,
			} :: Frame,
		} :: Frame,

		ProgressText = {
			BackgroundTransparency = 1,

			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,
			TextSize = 12,
		} :: TextLabel,
	} :: Frame,

	CheckBox = {
		BackgroundTransparency = 1,
		NameLabel = {
			BackgroundTransparency = 1,

			TextColor3 = Style.Colors.DefaultTextColor,
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(1, Widget.Gui.NameLabel.TextBounds.X, 1)
			end,
			Font = Style.Fonts.Default,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
		} :: TextBox & any,

		Box = {
			BackgroundColor3 = Style.Colors.Third,
			Position = UDim2.new(0, 5, .5, 0),
			Size = UDim2.fromOffset(10, 10),
			AutoButtonColor = false,


			Border = {
				Color = Style.Colors.Fourth,
			} :: UIStroke & any,

			Gradient = Glass,

			Check = {
				BackgroundTransparency = 1,
				Image = Style.Images.CheckBox,
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ImageColor3 = Style.Colors.Main,
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
			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,
			TextSize = 12,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextYAlignment = Enum.TextYAlignment.Top,
		} :: TextBox & any,

		Selector = {
			BackgroundTransparency = 1,
			AnchorPoint = Vector2.new(0, .5),
			Position = UDim2.new(0, 3, .5, 0),
			Size = UDim2.new(0, 100, .5, 0),

			DropDownIcon = {
				BackgroundColor3 = Style.Colors.Third,

				Border = {
					Color = Style.Colors.Fourth,
					Thickness = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				} :: UIStroke & any,

				Gradient = Glass,

				Image = function(Widget: Solar.SolarBaseWidget)
					return Widget.State.Open == true and Style.Images.DropDownOpen or Style.Images.DropDownClosed
				end,

				Size = function(Widget: Solar.SolarBaseWidget)
					return UDim2.fromOffset(Widget.Gui.Selector.AbsoluteSize.Y, Widget.Gui.Selector.AbsoluteSize.Y)
				end,
			} :: ImageLabel,

			Value = {
				BackgroundColor3 = Style.Colors.Third,

				Border = {
					Color = Style.Colors.Fourth,
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
				TextColor3 = Style.Colors.DefaultTextColor,
				Font = Style.Fonts.Default,
				TextSize = 12,
				TextXAlignment = Enum.TextXAlignment.Left,
			} :: TextLabel,

			DropDown = {
				Position = UDim2.new(0, 0, 1, 0),
				Size = UDim2.fromScale(1, 0),

				Visible = function(Widget: Solar.SolarBaseWidget)
					return Widget.State.Open
				end,

				BackgroundColor3 = Style.Colors.Third,

				Border = {
					Color = Style.Colors.Fourth,
					Thickness = 1,
					ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
				} :: UIStroke & any,
			} :: Frame,
		} :: ImageButton,
	} :: Frame & any,

	DropDownOption = {
		BackgroundColor3 = Style.Colors.Third,
		TextColor3 = Style.Colors.DefaultTextColor,
		Font = Style.Fonts.Default,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,

		Gradient = Glass,

		Border = {
			Color = Style.Colors.Fourth,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		} :: UIStroke & any,
	} :: TextButton,

	Button = {
		BackgroundTransparency = 1,
		Button = {
			BackgroundColor3 = Style.Colors.Third,
			AutoButtonColor = false,

			TextColor3 = Style.Colors.DefaultTextColor,
			Size = UDim2.new(1, -4, 1, -4),
			TextSize = 12,
			Font = Enum.Font.Code,

			Border = {
				Color = Style.Colors.Fourth,
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

			BackgroundColor3 = Style.Colors.Third,

			BorderSizePixel = 0,

			Border = {
				Color = Style.Colors.Fourth,
			} :: UIStroke & any,	
		} :: Frame & any,
	} :: Frame & any,

	Content = {
		BackgroundTransparency = 1,
		Content = {
			BackgroundColor3 = Style.Colors.Third,

			MidImage = Style.Images.ScrollMid,
			TopImage = Style.Images.ScrollTop,
			BottomImage = Style.Images.ScrollBottom,

			ScrollBarImageColor3 = Style.Colors.Main,
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
				Color = Style.Colors.Fourth,
			} :: UIStroke & any,
		} :: ScrollingFrame & any,

		DisplayName = {
			BackgroundColor3 = Style.Colors.Third,

			Position = UDim2.new(0, 6, 0, 3),
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.DisplayName.TextBounds.X + 3, 0, 10)
			end,
			Visible = function(Widget: Solar.SolarBaseWidget)
				return Widget.DisplayName
			end,
			BorderSizePixel = 0,
			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,

			Border = {
				Color = Style.Colors.Fourth,
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
		BackgroundColor3 = function(Widget: Solar.SolarBaseWidget)
			if Widget.State.Open then
				return Style.Colors.Second
			else
				return Style.Colors.Third
			end
		end,
		AutoButtonColor = false,

		TextSize = 14,
		TextColor3 = Style.Colors.DefaultTextColor,
		Font = Style.Fonts.Default,

		Size = function(Widget: Solar.SolarBaseWidget)
			return UDim2.new(0, Widget.Gui.TextBounds.X + 10, 1, Widget.State.Open and 2 or 0)
		end,

		Position = function(Widget: Solar.SolarBaseWidget)
			return UDim2.fromOffset(Widget.Gui.Position.X.Offset, Widget.State.Open and -2 or 0)
		end,

		BorderSizePixel = 0,

		Border = {
			Color = Style.Colors.Fourth,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		} :: UIStroke & any,

		Gradient = Glass
	} :: TextLabel & any,
}

return Style