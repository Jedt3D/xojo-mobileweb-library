#tag Class
Protected Class Card
Inherits WebSDKUIControl
	#tag Event
		Sub DrawControlInLayoutEditor(g As Graphics)
		  // Background
		  g.DrawingColor = &cF8FAFC
		  g.FillRectangle(0, 0, g.Width, g.Height)

		  // Card background with rounded corners
		  g.DrawingColor = &cFFFFFF
		  g.FillRoundRectangle(4, 4, g.Width - 8, g.Height - 8, 12, 12)

		  // Card border
		  g.DrawingColor = &cE2E8F0
		  g.DrawRoundRectangle(4, 4, g.Width - 8, g.Height - 8, 12, 12)

		  // Shadow hint (subtle bottom line)
		  g.DrawingColor = &cCBD5E1
		  g.DrawRoundRectangle(5, 5, g.Width - 8, g.Height - 8, 12, 12)

		  Var contentY As Double = 8
		  Var contentX As Double = 12
		  Var contentW As Double = g.Width - 24

		  // Image placeholder area
		  Var imgH As Double = 60
		  If g.Height > 120 Then
		    g.DrawingColor = &cE2E8F0
		    g.FillRoundRectangle(4, 4, g.Width - 8, imgH, 12, 0)
		    // Image icon placeholder
		    g.DrawingColor = &c94A3B8
		    Var iconX As Double = (g.Width - 24) / 2
		    Var iconY As Double = (imgH - 16) / 2 + 4
		    g.DrawRectangle(iconX, iconY, 24, 16)
		    g.DrawLine(iconX, iconY + 16, iconX + 10, iconY + 6)
		    g.DrawLine(iconX + 10, iconY + 6, iconX + 16, iconY + 10)
		    g.DrawLine(iconX + 16, iconY + 10, iconX + 24, iconY + 2)
		    contentY = imgH + 12
		  End If

		  // Title
		  Var titleText As String = mTitle
		  If titleText = "" Then titleText = "Card Title"
		  g.FontSize = 16
		  g.DrawingColor = &c0F172A
		  g.DrawText(titleText, contentX, contentY + g.TextHeight)
		  contentY = contentY + g.TextHeight + 4

		  // Subtitle
		  Var subtitleText As String = mSubtitle
		  If subtitleText = "" Then subtitleText = "Subtitle"
		  g.FontSize = 12
		  g.DrawingColor = &c64748B
		  g.DrawText(subtitleText, contentX, contentY + g.TextHeight)
		  contentY = contentY + g.TextHeight + 8

		  // Body
		  Var bodyText As String = mBody
		  If bodyText = "" Then bodyText = "Body text..."
		  g.FontSize = 13
		  g.DrawingColor = &c94A3B8
		  // Only draw if there's room
		  If contentY + g.TextHeight < g.Height - 12 Then
		    g.DrawText(bodyText, contentX, contentY + g.TextHeight)
		  End If
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
		  Select Case name.Lowercase
		  Case "pressed"
		    RaiseEvent Pressed()
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
		  Return "MobileWeb.Card"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  js.Value("title") = mTitle
		  js.Value("subtitle") = mSubtitle
		  js.Value("body") = mBody
		  js.Value("imageURL") = mImageURL
		  js.Value("elevated") = mElevated
		  js.Value("enabled") = Self.Enabled
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionCSSURLs(session As WebSession) As String()
		  MobileTheme.EnsureThemeFile()

		  If SharedCSSFile = Nil Then
		    SharedCSSFile = New WebFile
		    SharedCSSFile.Data = "@layer mobile-components{" _
		    + ".mobile-card{background:var(--mobile-surface);border-radius:var(--mobile-radius-lg);" _
		    + "overflow:hidden;font-family:var(--mobile-font);color:var(--mobile-text);" _
		    + "-webkit-tap-highlight-color:transparent;cursor:pointer;user-select:none;" _
		    + "-webkit-user-select:none;transition:box-shadow var(--mobile-duration-normal) var(--mobile-ease)}" _
		    + ".mobile-card.has-shadow{box-shadow:var(--mobile-shadow-md)}" _
		    + ".mobile-card__image{width:100%;display:block;object-fit:cover;max-height:200px}" _
		    + ".mobile-card__header{padding:var(--mobile-space-md) var(--mobile-space-md) 0}" _
		    + ".mobile-card__title{font-size:var(--mobile-text-lg);font-weight:var(--mobile-font-semibold);line-height:1.3}" _
		    + ".mobile-card__subtitle{font-size:var(--mobile-text-sm);color:var(--mobile-text-secondary);margin-top:var(--mobile-space-xs)}" _
		    + ".mobile-card__body{padding:var(--mobile-space-sm) var(--mobile-space-md) var(--mobile-space-md);" _
		    + "font-size:var(--mobile-text-base);line-height:1.5}" _
		    + ".mobile-card.is-disabled{opacity:var(--mobile-disabled-opacity);cursor:default;pointer-events:none}" _
		    + "}"
		    SharedCSSFile.Session = Nil
		    SharedCSSFile.Filename = "MobileCard.css"
		    SharedCSSFile.MIMEType = "text/css"
		  End If

		  Return Array(SharedCSSFile.URL)
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
		    + "class Card extends XojoWeb.XojoVisualControl{" _
		    + "constructor(id,events){super(id,events);" _
		    + "this.cardTitle='';this.subtitle='';this.body='';this.imageURL='';this.elevated=true;this.cardEnabled=true;" _
		    + "this._touchFired=false;" _
		    + "var el=this.DOMElement();" _
		    + "if(el){el.style.position='relative';" _
		    + "this.wrapper=document.createElement('div');" _
		    + "this.wrapper.className='mobile-card';" _
		    + "this.wrapper.style.cssText='width:100%;height:100%;box-sizing:border-box';" _
		    + "el.appendChild(this.wrapper);" _
		    + "var self=this;" _
		    + "this.wrapper.addEventListener('touchend',function(e){" _
		    + "e.preventDefault();self._touchFired=true;self.handleTap()});" _
		    + "this.wrapper.addEventListener('click',function(){" _
		    + "if(self._touchFired){self._touchFired=false;return}" _
		    + "self.handleTap()})" _
		    + "}}" _
		    + "updateControl(data){try{var update=JSON.parse(data);" _
		    + "this.cardTitle=update.title||'';" _
		    + "this.subtitle=update.subtitle||'';" _
		    + "this.body=update.body||'';" _
		    + "this.imageURL=update.imageURL||'';" _
		    + "this.elevated=update.elevated!==false;" _
		    + "this.cardEnabled=update.enabled!==false;" _
		    + "this.rebuild();" _
		    + "super.updateControl(data)" _
		    + "}catch(e){console.log('MobileWeb.Card UC ERROR:',e.message)}}" _
		    + "rebuild(){if(!this.wrapper)return;" _
		    + "while(this.wrapper.firstChild){this.wrapper.removeChild(this.wrapper.firstChild)}" _
		    + "if(this.imageURL){var img=document.createElement('img');" _
		    + "img.className='mobile-card__image';img.src=this.imageURL;img.alt=this.cardTitle;" _
		    + "this.wrapper.appendChild(img)}" _
		    + "if(this.cardTitle||this.subtitle){var header=document.createElement('div');" _
		    + "header.className='mobile-card__header';" _
		    + "if(this.cardTitle){var t=document.createElement('div');" _
		    + "t.className='mobile-card__title';t.textContent=this.cardTitle;" _
		    + "header.appendChild(t)}" _
		    + "if(this.subtitle){var s=document.createElement('div');" _
		    + "s.className='mobile-card__subtitle';s.textContent=this.subtitle;" _
		    + "header.appendChild(s)}" _
		    + "this.wrapper.appendChild(header)}" _
		    + "if(this.body){var bd=document.createElement('div');" _
		    + "bd.className='mobile-card__body';bd.textContent=this.body;" _
		    + "this.wrapper.appendChild(bd)}" _
		    + "if(this.elevated){this.wrapper.classList.add('has-shadow')}" _
		    + "else{this.wrapper.classList.remove('has-shadow')}" _
		    + "if(this.cardEnabled){this.wrapper.classList.remove('is-disabled')}" _
		    + "else{this.wrapper.classList.add('is-disabled')}}" _
		    + "handleTap(){if(!this.cardEnabled)return;" _
		    + "var params=new XojoWeb.JSONItem();" _
		    + "this.triggerServerEvent('Pressed',params,false)}" _
		    + "render(){super.render();" _
		    + "var el=this.DOMElement();if(!el)return;" _
		    + "this.applyUserStyle();this.applyTooltip(el)}}" _
		    + "MobileWeb.Card=Card" _
		    + "})(MobileWeb||(MobileWeb={}));"
		    SharedJSFile.Session = Nil
		    SharedJSFile.Filename = "MobileCard.js"
		    SharedJSFile.MIMEType = "application/javascript"
		  End If

		  Return Array(SharedJSFile.URL)
		End Function
	#tag EndEvent


	#tag Hook, Flags = &h0
		Event Pressed()
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mTitle
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mTitle = value
			  UpdateControl
			End Set
		#tag EndSetter
		Title As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mSubtitle
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mSubtitle = value
			  UpdateControl
			End Set
		#tag EndSetter
		Subtitle As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mBody
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mBody = value
			  UpdateControl
			End Set
		#tag EndSetter
		Body As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mImageURL
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mImageURL = value
			  UpdateControl
			End Set
		#tag EndSetter
		ImageURL As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mElevated
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mElevated = value
			  UpdateControl
			End Set
		#tag EndSetter
		Elevated As Boolean
	#tag EndComputedProperty


	#tag Property, Flags = &h21
		Private mTitle As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSubtitle As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mBody As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mImageURL As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mElevated As Boolean = True
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
			InitialValue="200"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="300"
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
			Name="Title"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Subtitle"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Body"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="ImageURL"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Elevated"
			Visible=true
			Group="Behavior"
			InitialValue="True"
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
