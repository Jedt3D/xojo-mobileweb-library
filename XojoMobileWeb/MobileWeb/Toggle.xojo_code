#tag Class
Protected Class Toggle
Inherits WebSDKUIControl
	#tag Event
		Sub DrawControlInLayoutEditor(g As Graphics)
		  // Background
		  g.DrawingColor = &cF8FAFC
		  g.FillRectangle(0, 0, g.Width, g.Height)

		  // Draw toggle track
		  Var trackW As Double = 52
		  Var trackH As Double = 32
		  Var trackX As Double = 10
		  Var trackY As Double = (g.Height - trackH) / 2
		  Var thumbSize As Double = 28

		  If mIsOn Then
		    // On state - primary color
		    g.DrawingColor = &c1D4ED8
		    g.FillRoundRectangle(trackX, trackY, trackW, trackH, trackH, trackH)
		    // Thumb (right position)
		    g.DrawingColor = &cFFFFFF
		    g.FillOval(trackX + trackW - thumbSize - 2, trackY + 2, thumbSize, thumbSize)
		  Else
		    // Off state - gray
		    g.DrawingColor = &cCBD5E1
		    g.FillRoundRectangle(trackX, trackY, trackW, trackH, trackH, trackH)
		    // Thumb (left position)
		    g.DrawingColor = &cFFFFFF
		    g.FillOval(trackX + 2, trackY + 2, thumbSize, thumbSize)
		  End If

		  // Label
		  If mLabel <> "" Then
		    g.FontSize = 14
		    g.DrawingColor = &c0F172A
		    Var labelX As Double
		    If mLabelPosition = 0 Then
		      // Right of toggle
		      labelX = trackX + trackW + 10
		    Else
		      // Left of toggle - would need to shift track, just show right for preview
		      labelX = trackX + trackW + 10
		    End If
		    g.DrawText(mLabel, labelX, g.Height / 2 + g.TextHeight / 4)
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
		  Select Case name.Lowercase
		  Case "toggled"
		    mIsOn = parameters.Value("value")
		    RaiseEvent Toggled(mIsOn)
		    Return True
		  End Select
		End Function
	#tag EndEvent

	#tag Event
		Function HandleRequest(request As WebRequest, response As WebResponse) As Boolean
		End Function
	#tag EndEvent

	#tag Event
		Function JavaScriptClassName() As String
		  Return "MobileWeb.Toggle"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  js.Value("isOn") = mIsOn
		  js.Value("label") = mLabel
		  js.Value("labelPosition") = mLabelPosition
		  js.Value("enabled") = Self.Enabled
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionCSSURLs(session As WebSession) As String()
		  MobileTheme.EnsureThemeFile()

		  If SharedCSSFile = Nil Then
		    SharedCSSFile = New WebFile
		    SharedCSSFile.Data = "@layer mobile-components{" _
		    + ".mobile-toggle{display:inline-flex;align-items:center;gap:var(--mobile-space-sm);" _
		    + "cursor:pointer;user-select:none;-webkit-user-select:none;" _
		    + "min-height:var(--mobile-tap-size);font-family:var(--mobile-font);" _
		    + "font-size:var(--mobile-text-base);color:var(--mobile-text);" _
		    + "-webkit-tap-highlight-color:transparent}" _
		    + ".mobile-toggle.is-label-left{flex-direction:row-reverse}" _
		    + ".mobile-toggle__track{position:relative;width:52px;height:32px;" _
		    + "background:var(--mobile-border);border-radius:var(--mobile-radius-full);" _
		    + "padding:2px;transition:background var(--mobile-duration-normal) var(--mobile-ease);" _
		    + "flex-shrink:0}" _
		    + ".mobile-toggle__track.is-on{background:var(--mobile-primary)}" _
		    + ".mobile-toggle__thumb{width:28px;height:28px;background:var(--mobile-on-primary);" _
		    + "border-radius:50%;transition:transform var(--mobile-duration-normal) var(--mobile-ease);" _
		    + "box-shadow:var(--mobile-shadow-sm)}" _
		    + ".mobile-toggle__track.is-on .mobile-toggle__thumb{transform:translateX(20px)}" _
		    + ".mobile-toggle__label{font-weight:var(--mobile-font-normal);" _
		    + "line-height:1.4}" _
		    + ".mobile-toggle.is-disabled{opacity:var(--mobile-disabled-opacity);" _
		    + "cursor:default;pointer-events:none}" _
		    + "}"
		    SharedCSSFile.Session = Nil
		    SharedCSSFile.Filename = "MobileToggle.css"
		    SharedCSSFile.MIMEType = "text/css"
		  End If

		  Return Array(MobileTheme.SharedThemeFile.URL, SharedCSSFile.URL)
		End Function
	#tag EndEvent

	#tag Event
		Function SessionHead(session As WebSession) As String
		End Function
	#tag EndEvent

	#tag Event
		Function SessionJavascriptURLs(session As WebSession) As String()
		  If SharedJSFile = Nil Then
		    SharedJSFile = New WebFile
		    SharedJSFile.Data = "var MobileWeb;(function(MobileWeb){" _
		    + "class Toggle extends XojoWeb.XojoVisualControl{" _
		    + "constructor(id,events){super(id,events);" _
		    + "this.isOn=false;this.label='';this.labelPosition=0;this.toggleEnabled=true;" _
		    + "this._touchFired=false;" _
		    + "var el=this.DOMElement();" _
		    + "if(el){el.style.position='relative';" _
		    + "this.wrapper=document.createElement('div');" _
		    + "this.wrapper.className='mobile-toggle';" _
		    + "this.trackEl=document.createElement('div');" _
		    + "this.trackEl.className='mobile-toggle__track';" _
		    + "this.thumbEl=document.createElement('div');" _
		    + "this.thumbEl.className='mobile-toggle__thumb';" _
		    + "this.trackEl.appendChild(this.thumbEl);" _
		    + "this.labelEl=document.createElement('span');" _
		    + "this.labelEl.className='mobile-toggle__label';" _
		    + "this.wrapper.appendChild(this.trackEl);" _
		    + "this.wrapper.appendChild(this.labelEl);" _
		    + "el.appendChild(this.wrapper);" _
		    + "var self=this;" _
		    + "this.wrapper.addEventListener('touchend',function(e){" _
		    + "e.preventDefault();self._touchFired=true;self.handleTap()});" _
		    + "this.wrapper.addEventListener('click',function(){" _
		    + "if(self._touchFired){self._touchFired=false;return}" _
		    + "self.handleTap()})" _
		    + "}}" _
		    + "updateControl(data){try{var update=JSON.parse(data);" _
		    + "this.isOn=update.isOn===true;" _
		    + "this.label=update.label||'';" _
		    + "this.labelPosition=typeof update.labelPosition==='number'?update.labelPosition:0;" _
		    + "this.toggleEnabled=update.enabled!==false;" _
		    + "this.rebuild();" _
		    + "super.updateControl(data)" _
		    + "}catch(e){console.log('MobileWeb.Toggle UC ERROR:',e.message)}}" _
		    + "rebuild(){if(!this.wrapper)return;" _
		    + "if(this.isOn){this.trackEl.classList.add('is-on')}" _
		    + "else{this.trackEl.classList.remove('is-on')}" _
		    + "this.labelEl.textContent=this.label;" _
		    + "this.labelEl.style.display=this.label?'':'none';" _
		    + "if(this.labelPosition===1){this.wrapper.classList.add('is-label-left')}" _
		    + "else{this.wrapper.classList.remove('is-label-left')}" _
		    + "if(this.toggleEnabled){this.wrapper.classList.remove('is-disabled')}" _
		    + "else{this.wrapper.classList.add('is-disabled')}}" _
		    + "handleTap(){if(!this.toggleEnabled)return;" _
		    + "this.isOn=!this.isOn;this.rebuild();" _
		    + "var params=new XojoWeb.JSONItem();" _
		    + "params.set('value',this.isOn);" _
		    + "this.triggerServerEvent('Toggled',params,false)}" _
		    + "render(){super.render();" _
		    + "var el=this.DOMElement();if(!el)return;" _
		    + "this.applyUserStyle();this.applyTooltip(el)}}" _
		    + "MobileWeb.Toggle=Toggle" _
		    + "})(MobileWeb||(MobileWeb={}));"
		    SharedJSFile.Session = Nil
		    SharedJSFile.Filename = "MobileToggle.js"
		    SharedJSFile.MIMEType = "application/javascript"
		  End If

		  Return Array(SharedJSFile.URL)
		End Function
	#tag EndEvent


	#tag Hook, Flags = &h0
		Event Toggled(value As Boolean)
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mIsOn
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mIsOn = value
			  UpdateControl
			End Set
		#tag EndSetter
		IsOn As Boolean
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mLabel
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLabel = value
			  UpdateControl
			End Set
		#tag EndSetter
		Label As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mLabelPosition
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mLabelPosition = value
			  UpdateControl
			End Set
		#tag EndSetter
		LabelPosition As Integer
	#tag EndComputedProperty


	#tag Property, Flags = &h21
		Private mIsOn As Boolean
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLabel As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mLabelPosition As Integer
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared SharedCSSFile As WebFile
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared SharedJSFile As WebFile
	#tag EndProperty


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
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Height"
			Visible=true
			Group="Position"
			InitialValue="44"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="200"
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
			Visible=false
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
			Name="Left"
			Visible=true
			Group="Position"
			InitialValue="0"
			Type="Integer"
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
			Name="_mName"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
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
			Name="Enabled"
			Visible=true
			Group="Appearance"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="IsOn"
			Visible=true
			Group="Behavior"
			InitialValue="False"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Label"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="LabelPosition"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
