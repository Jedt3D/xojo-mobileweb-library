#tag Class
Protected Class ExampleCustomButton
Inherits WebSDKUIControl
	#tag Event
		Sub DrawControlInLayoutEditor(g As Graphics)
		  // This event is not required.
		  //
		  // The only purpose of this event is to display a preview in
		  // the IDE, similar to how the control will look like in the
		  // browser.
		  //
		  // As this code will run as a script in the IDE, if it doesn't
		  // compile for any reason, you will see what happened in the
		  // Messages panel.
		  
		  // You will not need to re-open the project or restart the
		  // IDE, in order to see the changes.
		  
		  // indicate the visible state in the IDE
		  If Not BooleanProperty("Visible") Then
		    ' only draws a rectangle in grey
		    g.DrawingColor = &c94949400
		    g.DrawRectangle(0, 0, g.Width, g.Height)
		    Return
		  End If
		  
		  If  BooleanProperty("hasBackgroundColor") Then
		    // We will use the background color
		    g.DrawingColor = ColorProperty("BackgroundColor")
		  Else
		    // use indicator color
		    Var bgi As Integer = IntegerProperty("Indicator")
		    Var className As String
		    Select Case bgi
		    Case 0
		      className = ".btn-light"
		    Case 1
		      className = ".btn-primary"
		    Case 2
		      className = ".btn-secondary"
		    Case 3
		      className = ".btn-success"
		    Case 4
		      className = ".btn-danger"
		    Case 5
		      className = ".btn-warning"
		    Case 6
		      className = ".btn-info"
		    Case 7
		      className = ".btn-light"
		    Case 8
		      className = ".btn-dark"
		    Case 9
		      className = ".btn-link"
		    Case Else
		      className = ".card"
		    End Select
		    g.DrawingColor = CSSColorValue( className, "background-color", &cFFFFFFFF)
		    
		  End If
		  
		  // But if the Enabled property is turned off...
		  If Not BooleanProperty("Enabled") Then
		    // We will create a dimmed color, so that it looks
		    // similar to how it will look in the browser.
		    Var hue As Double = g.DrawingColor.Hue
		    Var saturation As Double = g.DrawingColor.Saturation - 0.3
		    Var value As Double = g.DrawingColor.Value + 0.1
		    g.DrawingColor = Color.HSV(hue, saturation, value)
		  End If
		  
		  // We can finally draw the background shape, using the
		  // desired border radius. In order to mimic the browser
		  // renderer, we'll have to multiply it by 2.
		  Var radius As Integer = IntegerProperty("BorderRadius") * 2
		  If BooleanProperty("isOutline") Then
		    g.DrawRoundRectangle(0, 0, g.Width, g.Height, radius, radius)
		  Else
		    g.FillRoundRectangle(0, 0, g.Width, g.Height, radius, radius)
		  End If
		  
		  // Then, the button caption. By default Bootstrap will
		  // use 16px for the font size. You can practice creating
		  // a new property to hold this value, to make it configurable.
		  g.FontSize = 16
		  Var btnsize As Integer = IntegerProperty("buttonSize")
		  Select Case btnsize
		  Case 0 // small
		    g.FontSize = 12
		  Case 2 // large
		    g.FontSize = 20
		  Else
		    g.FontSize = 16
		  End Select
		  Var caption As String = StringProperty("Caption")
		  Var textSize As Double = g.TextWidth(caption)
		  Var posX As Integer = g.Width / 2 - textSize / 2
		  Var posY As Integer = g.Height / 2 + g.FontSize / 3
		  If  BooleanProperty("hasTextColor") Then
		    // use the defined text color
		    g.DrawingColor = ColorProperty("TextColor")
		  Else
		    // use indicator color
		    Var bgi As Integer = IntegerProperty("Indicator")
		    Var className As String
		    Select Case bgi
		    Case 0
		      className = ".btn-light"
		    Case 1
		      className = ".btn-primary"
		    Case 2
		      className = ".btn-secondary"
		    Case 3
		      className = ".btn-success"
		    Case 4
		      className = ".btn-danger"
		    Case 5
		      className = ".btn-warning"
		    Case 6
		      className = ".btn-info"
		    Case 7
		      className = ".btn-light"
		    Case 8
		      className = ".btn-dark"
		    Case 9
		      className = ".btn-link"
		    Case Else
		      className = ".card"
		    End Select
		    If BooleanProperty("isOutline") Then
		      g.DrawingColor = CSSColorValue( className, "background-color", &cFFFFFFFF)
		    Else
		      g.DrawingColor = CSSColorValue( className, "color", &cFFFFFFFF)
		    End If
		  End If
		  g.DrawText(caption, posX, posY)
		  
		  
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
		  // Any time we call the "triggerServerEvent()" method in our
		  // JavaScript code, the Xojo Web Framework will take care
		  // of the communication, and we will receive it here.
		  //
		  // In case there are different kind of events, you can filter
		  // them by name. Optionally, "triggerServerEvent()" has
		  // support for sending an arbitrary amount of parameters,
		  // related to the kind of event is happening.
		  
		  Select Case name.Lowercase
		  Case "pressed"
		    // In this example, we will just need to listen to the
		    // "pressed" event we are sending from our kJavaScriptCode.
		    //
		    // We've defined a new "Pressed" event in this class, so
		    // the end user can implement it.
		    RaiseEvent Pressed
		    
		  End Select
		End Function
	#tag EndEvent

	#tag Event
		Function HandleRequest(request As WebRequest, response As WebResponse) As Boolean
		  // This event is similar to the Application.HandleURL event,
		  // except it will only be triggered on this control instance
		  // specific URL.
		  //
		  // The URL will needs to have the format /sdk/<ControlID>
		  //
		  // For example, if our domain is "example.org"
		  // and the control instance ID is "gNWJcv", the URL
		  // will be: https://example.org/sdk/gNWJcv
		  //
		  // You can use this event to populate an HTML table,
		  // dynamically, in a request-response manner. The response
		  // will normally be some JSON encoded data.
		  //
		  // If you are handling this request, you will need to
		  // Return True.
		  //
		  // In case your control isn't expecting a response, it's
		  // probably more appropiate to use ExecuteEvent instead.
		  //
		  // While we won't use this event in this example, we are
		  // implementing it anyway, so the user doesn't see it in the
		  // list of events available to implement.
		End Function
	#tag EndEvent

	#tag Event
		Function JavaScriptClassName() As String
		  // We will need to return a String like <namespace>.<className>.
		  // This should match with the name you're using in your
		  // JavaScript code. See the constant kJavaScriptCode for the
		  // source.
		  //
		  // Every control needs to use a namespace, to avoid collisions
		  // between other third party controls. In this case, we will
		  // be using "Example".
		  //
		  // There are reserved namespaces, like "Xojo".
		  //
		  // Please check the "WebSDK Docs.pdf" document included in
		  // your Xojo installation folder for more information about
		  // namespaces.
		  
		  Return "Example.CustomButton"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  // Every time we call the "UpdateControl" method, in this
		  // Xojo class, the framework will understand we want to
		  // update some properties of our control. As soon as the
		  // framework thinks it's appropiate, it will use this event
		  // to give you an opportunity to add your custom properties.
		  //
		  // Any property you serialize here, it will be sent to your
		  // control instance, running in the browser. It will be
		  // received in the "updateControl()" method, that you will
		  // have to implement in your JavaScript class.
		  
		  js.Value("borderRadius") = BorderRadius
		  
		  // The way Xojo represents colors as strings is different
		  // to what JavaScript expects. We'll have to tweak it a bit.
		  js.Value("backgroundColor") = BackgroundColor.ToString.Replace("&h00", "#")
		  js.Value("textColor") = TextColor.ToString.Replace("&h00", "#")
		  
		  // Any property that could contain problematic characters,
		  // like quotes, needs to be encoded. EncodeBase64, combined
		  // with EncodeURLComponent works great, even with emojis.
		  js.Value("caption") = EncodeBase64(EncodeURLComponent(Caption))
		  
		  // other properties
		  js.Value("hasBackgroundColor") = hasBackgroundColor
		  js.Value("hasTextColor") = hasTextColor
		  Dim indic As String = "btn"
		  If isOutline Then
		    indic = indic+"-outline"
		  End If
		  js.Value("bootstrapIndicator") = indic+Indicator.ToString
		  js.Value("buttonSize") = "btn-"+buttonSize.toString
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionCSSURLs(session As WebSession) As String()
		  // This WebFile instance will be shared between every instance.
		  // If it doesn't exists, we'll have to create. This will happen
		  // just once.
		  If CSSCodeWebFile = Nil Then
		    CSSCodeWebFile = New WebFile
		    
		    // Here we'll insert the code from our constant.
		    CSSCodeWebFile.Data = kCSSCode
		    
		    // As this instance will be shared between every session,
		    // it's important to set this parameter to Nil. Otherwise,
		    // only the first session will be able to download this file.
		    CSSCodeWebFile.Session = Nil
		    
		    // Add a file name and the proper mime type.
		    CSSCodeWebFile.Filename = "ExampleCustomButton.css"
		    CSSCodeWebFile.MIMEType = "text/css"
		  End If
		  
		  // Finally, we just need to return the array of required files.
		  // In this example we just need one. If you are integrating a
		  // third-party library, maybe you'll need to include a URL
		  // from a external server. In that case, a full URL is also
		  // valid.
		  Return Array(CSSCodeWebFile.URL)
		End Function
	#tag EndEvent

	#tag Event
		Function SessionHead(session As WebSession) As String
		  // This event fires each time a new session starts. You should
		  // return a String containing the items you wish to add to the
		  // <head> tag.
		  //
		  // While we won't use this event in this example, we are
		  // implementing it anyway, so the user doesn't see it in the
		  // list of events available to implement.
		End Function
	#tag EndEvent

	#tag Event
		Function SessionJavascriptURLs(session As WebSession) As String()
		  // This WebFile instance will be shared between every instance.
		  // If it doesn't exists, we'll have to create. This will happen
		  // just once.
		  If JavaScriptCodeWebFile = Nil Then
		    JavaScriptCodeWebFile = New WebFile
		    
		    // Here we'll insert the code from our constant.
		    JavaScriptCodeWebFile.Data = kJavaScriptCode
		    
		    // As this instance will be shared between every session,
		    // it's important to set this parameter to Nil. Otherwise,
		    // only the first session will be able to download this file.
		    JavaScriptCodeWebFile.Session = Nil
		    
		    // Add a file name and the proper mime type.
		    JavaScriptCodeWebFile.Filename = "ExampleCustomButton.js"
		    JavaScriptCodeWebFile.MIMEType = "application/javascript"
		  End If
		  
		  // Finally, we just need to return the array of required files.
		  // In this example we just need one. If you are integrating a
		  // third-party library, maybe you'll need to include a URL
		  // from a external server. In that case, a full URL is also
		  // valid.
		  Return Array(JavaScriptCodeWebFile.URL)
		End Function
	#tag EndEvent


	#tag Hook, Flags = &h0
		Event Pressed()
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBackgroundColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBackgroundColor = value
			  
			  // Calling UpdateControl will make the Web SDK to prepare and
			  // send a JSON object to the browser. Your properties will be
			  // serialized in the "Serialize" event.
			  UpdateControl
			End Set
		#tag EndSetter
		BackgroundColor As Color
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBorderRadius
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBorderRadius = value
			  
			  // Calling UpdateControl will make the Web SDK to prepare and
			  // send a JSON object to the browser. Your properties will be
			  // serialized in the "Serialize" event.
			  UpdateControl
			End Set
		#tag EndSetter
		BorderRadius As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mbuttonSize
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mbuttonSize = value
			  UpdateControl
			  
			End Set
		#tag EndSetter
		buttonSize As webmodule.bootstrapSizes
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mCaption
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mCaption = value
			  
			  // Calling UpdateControl will make the Web SDK to prepare and
			  // send a JSON object to the browser. Your properties will be
			  // serialized in the "Serialize" event.
			  UpdateControl
			End Set
		#tag EndSetter
		Caption As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared CSSCodeWebFile As WebFile
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mhasBackgroundColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mhasBackgroundColor = value
			  UpdateControl
			  
			End Set
		#tag EndSetter
		hasBackgroundColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mhasTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mhasTextColor = value
			  UpdateControl
			  
			End Set
		#tag EndSetter
		hasTextColor As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return misOutline
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  misOutline = value
			  UpdateControl
			  
			End Set
		#tag EndSetter
		isOutline As Boolean
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private Shared JavaScriptCodeWebFile As WebFile
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBackgroundColor As Color = &c62AB2B
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBorderRadius As Integer = 10
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mbuttonSize As webmodule.bootstrapSizes = webmodule.bootstrapSizes.default
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mCaption As String = "Untitled"
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mhasBackgroundColor As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mhasTextColor As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h21
		Private misOutline As Boolean = false
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mTextColor As Color = &cFFFFFF
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTextColor
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTextColor = value
			  
			  // Calling UpdateControl will make the Web SDK to prepare and
			  // send a JSON object to the browser. Your properties will be
			  // serialized in the "Serialize" event.
			  UpdateControl
			End Set
		#tag EndSetter
		TextColor As Color
	#tag EndComputedProperty


	#tag Constant, Name = kCSSCode, Type = String, Dynamic = False, Default = \".ExampleCustomButton .btn { width: 100%; height: 100%; }", Scope = Private
	#tag EndConstant

	#tag Constant, Name = kJavaScriptCode, Type = String, Dynamic = False, Default = \"var Example;\n(function (Example) {\n\n        // IE does not know about the target attribute. It looks for srcElement\n        // This function will get the event target in a browser-compatible way\n        function getEventTarget(e) {\n            e \x3D e || window.event;\n            return e.target || e.srcElement;\n        }\n\n    class ExampleCustomButton extends XojoWeb.XojoVisualControl {\n        constructor(id\x2C events) {\n            super(id\x2C events);\n            const el \x3D this.DOMElement();\n\n            this.buttonEl \x3D document.createElement(\'button\');\n            this.buttonEl.type \x3D \'button\';\n            this.buttonEl.innerText \x3D \'Untitled\';\n            this.buttonEl.classList.add(\'btn\');\n\n            const that \x3D this;\n            this.buttonEl.addEventListener(\'pointerup\'\x2C function(ev) {\xC2\xA0that.pressedHandler(ev) });\n\n            el.appendChild(this.buttonEl);\n        }\n        updateControl(data) {\n            super.updateControl(data);\n            const json \x3D JSON.parse(data);\n\n            // removes all classes starting with prefix\n            const prefix \x3D \'btn-\';\n            const classes \x3D this.buttonEl.className.split(\" \").filter(c \x3D> !c.startsWith(prefix));\n            this.buttonEl.className \x3D classes.join(\" \").trim();\n\n            if (json.hasBackgroundColor){\n                if (json.backgroundColor) {\n                    this.buttonEl.style.backgroundColor \x3D json.backgroundColor;\n                    this.buttonEl.style.borderColor \x3D json.backgroundColor;\n                }\n            }\n            else {\n                this.buttonEl.classList.add( json.bootstrapIndicator);\n            }\n            if (json.hasTextColor) {\n                if (json.textColor) {\n                    this.buttonEl.style.color \x3D json.textColor;\n                }\n            } else {\n                this.buttonEl.classList.add( json.bootstrapIndicator);\n            }\n            if ( json.buttonSize !\x3D \'\') {\n                this.buttonEl.classList.add( json.buttonSize);\n            }\n            if (typeof json.borderRadius !\x3D\x3D \'undefined\') {\n                this.buttonEl.style.borderRadius \x3D `${json.borderRadius}px`;\n            }\n            if (typeof json.enabled !\x3D\x3D \'undefined\') {\n                this.buttonEl.disabled \x3D !json.enabled;\n            }\n            if (typeof json.caption !\x3D\x3D \'undefined\') {\n                this.buttonEl.innerText \x3D decodeURIComponent(atob(json.caption));\n            }\n            this.refresh();\n        }\n        render() {\n            super.render();\n            const el \x3D this.DOMElement();\n            if (!el) {\n                return;\n            }\n\n            this.setAttributes();\n            this.applyUserStyle();\n            this.applyTooltip(el);\n        }\n        pressedHandler(ev) {\n            this.triggerServerEvent(\'pressed\');\n        }\n\n    }\n    Example.CustomButton \x3D ExampleCustomButton;\n})(Example || (Example \x3D {}));", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="PanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Index"
			Visible=true
			Group="ID"
			InitialValue="-2147483648"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Super"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="34"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="100"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockBottom"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockHorizontal"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockLeft"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockRight"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockTop"
			Visible=true
			Group="Position"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LockVertical"
			Visible=true
			Group="Position"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Top"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Enabled"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Caption"
			Visible=true
			Group="Behavior"
			InitialValue="Untitled"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="TabIndex"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Visible"
			Visible=true
			Group="Visual Controls"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Indicator"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="WebUIControl.Indicators"
			EditorType="Enum"
			#tag EnumValues
				"0 - Default"
				"1 - Primary"
				"2 - Secondary"
				"3 - Success"
				"4 - Danger"
				"5 - Warning"
				"6 - Info"
				"7 - Light"
				"8 - Dark"
				"9 - Link"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="BorderRadius"
			Visible=true
			Group="Visual Controls"
			InitialValue="10"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="hasTextColor"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="TextColor"
			Visible=true
			Group="Visual Controls"
			InitialValue="&cFFFFFF"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="hasBackgroundColor"
			Visible=true
			Group="Visual Controls"
			InitialValue="false"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="BackgroundColor"
			Visible=true
			Group="Visual Controls"
			InitialValue="&c62AB2B"
			Type="Color"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="isOutline"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="buttonSize"
			Visible=true
			Group="Visual Controls"
			InitialValue=""
			Type="webmodule.bootstrapSizes"
			EditorType="Enum"
			#tag EnumValues
				"0 - small"
				"1 - default"
				"2 - large"
				"3 - extralarge"
			#tag EndEnumValues
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ControlID"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
