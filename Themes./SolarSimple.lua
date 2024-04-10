--!nocheck
local Style = {
	-- Colors
	Colors = {
		Main = Color3.fromRGB(193, 193, 193),
		WindowBorder = Color3.fromRGB(230, 230, 230),
		Second = Color3.fromRGB(100, 100, 100),
		Third = Color3.fromRGB(130, 130, 130),
		Fourth = Color3.fromRGB(160, 160, 160),
		ProgressBar = Color3.fromRGB(0, 161, 0),

		DefaultTextColor = Color3.fromRGB(5, 5, 5),
	},

	-- Fonts
	Fonts = {
		Default = Enum.Font.Code,
		TitleBar = Enum.Font.Code,
	},

	Images = {
		CloseButton = "rbxassetid://16927871674",
		CheckBox = "rbxassetid://16962400397",
		DropDownClosed = "rbxassetid://16970123100",
		DropDownOpen = "rbxassetid://16970129962",
		ScrollTop = "rbxassetid://16873350157",
		ScrollMid = "rbxassetid://16873350157",
		ScrollBottom = "rbxassetid://16873350157",
		
		WindowIcon = "rbxassetid://17083195662"
	}
}

Style.Widgets = {
	Window = {
		BackgroundColor3 = Style.Colors.Main,

		Border = {
			Thickness = 1,
			Color = Style.Colors.WindowBorder,
		} :: UIStroke & any,
		BorderSizePixel = 0,

		TitleBar = {
			BackgroundColor3 = Style.Colors.WindowBorder,
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
			
			BackgroundTransparency = 1,
			BackgroundColor3 = Style.Colors.Third,

			BorderSizePixel = 0,

			ScrollBarImageColor3 = Style.Colors.Main,
			ScrollBarThickness = 2,
			
			Border = {
				Color = Style.Colors.WindowBorder,
			} :: UIStroke & any,
		} :: ScrollingFrame & any,
	} :: CanvasGroup & any,
	
	Content = {
		BackgroundTransparency = 1,
		Content = {
			BackgroundColor3 = Style.Colors.Main,

			MidImage = Style.Images.ScrollMid,
			TopImage = Style.Images.ScrollTop,
			BottomImage = Style.Images.ScrollBottom,

			ScrollBarImageColor3 = Style.Colors.Main,
			ScrollBarThickness = 2,
			
			Position = function(Widget: Solar.SolarBaseWidget)
				if Widget.DisplayName then
					return UDim2.new(.5, 0, .5, 3)
				else
					return UDim2.fromScale(.5, .5)
				end
			end,
			Size = function(Widget: Solar.SolarBaseWidget)
				if Widget.DisplayName then
					return UDim2.new(1, -6, 0, Widget.Size.Y.Offset - 12)
				else
					return UDim2.new(1, -6, 0, Widget.Size.Y.Offset - 6)
				end
			end,

			
			BorderSizePixel = 0,

			Border = {
				Color = Style.Colors.WindowBorder,
			} :: UIStroke & any,
		} :: ScrollingFrame & any,

		DisplayName = {
			BackgroundColor3 = Style.Colors.Main,

			Position = UDim2.fromOffset(6, 2),
			Size = function(Widget: Solar.SolarBaseWidget)
				return UDim2.new(0, Widget.Gui.DisplayName.TextBounds.X + 3, 0, 10)
			end,
			Visible = function(Widget: Solar.SolarBaseWidget)
				return Widget.DisplayName
			end,
			BorderSizePixel = 0,
			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,
		} :: TextLabel & any,
	} :: Frame & any,

	Text = {
		BackgroundTransparency = 1,
		Text = {
			BackgroundTransparency = 1,

			TextColor3 = Style.Colors.DefaultTextColor,
			Size = UDim2.new(1, -2, 1, -2),
			Font = Style.Fonts.Default,
			TextXAlignment = Enum.TextXAlignment.Left,
			TextSize = 14,
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

		} :: TextBox & any,
	} :: Frame & any,

	CheckBox = {
		BackgroundTransparency = 1,
		NameLabel = {
			BackgroundTransparency = 1,

			TextColor3 = Style.Colors.DefaultTextColor,
			Size = UDim2.new(1, -20, 1),
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

			Check = {
				BackgroundTransparency = 1,
				Image = Style.Images.CheckBox,
				ResampleMode = Enum.ResamplerMode.Pixelated,
				ImageColor3 = Style.Colors.Second,
				Size = UDim2.fromScale(1, 1),
				BorderSizePixel = 0,

				Visible = function(Widget: Solar.SolarBaseWidget)
					return Widget.State.Value
				end,
			} :: ImageLabel & any,
		} :: ImageButton & any,
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
				Color = Style.Colors.Second, 
			} :: UIStroke,
			
			Progress = {
				BorderSizePixel = 0,
				BackgroundColor3 = Style.Colors.ProgressBar,
			} :: Frame,
		} :: Frame,

		ProgressText = {
			BackgroundTransparency = 1,
			
			TextColor3 = Style.Colors.DefaultTextColor,
			Font = Style.Fonts.Default,
			TextSize = 12,
		} :: TextLabel,
	} :: Frame,

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

		Border = {
			Color = Style.Colors.Fourth,
			Thickness = 1,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		} :: UIStroke & any,
	} :: TextButton,

	Button = {
		BackgroundTransparency = 1,
		Button = {
			BackgroundColor3 = Style.Colors.Main,
			AutoButtonColor = false,

			TextColor3 = Style.Colors.DefaultTextColor,
			Size = UDim2.new(1, -4, 1, -4),
			TextSize = 12,
			Font = Enum.Font.Code,

			Border = {
				Color = Style.Colors.Second,
				Thickness = 1,
				ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
			} :: UIStroke & any,

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

	TabBar = {
		BackgroundTransparency = 1,
		Position = function(Widget: Solar.SolarBaseWidget)
			return Widget.Gui.Position + UDim2.new(0, 5, 0, 3)
		end,

	} :: Frame & any,

	Tab = {
		BackgroundColor3 = function(Widget: Solar.SolarBaseWidget)
			if Widget.State.Open then
				return Style.Colors.Main
			else
				return Style.Colors.Fourth
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
			Color = Style.Colors.WindowBorder,
			ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
		} :: UIStroke & any,

	} :: TextLabel & any,
}

return Style
