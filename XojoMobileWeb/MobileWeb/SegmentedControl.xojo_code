#tag Class
Protected Class SegmentedControl
Inherits WebSDKUIControl
	#tag Event
		Sub DrawControlInLayoutEditor(g As Graphics)
		  // Background pill
		  Var pillH As Double = 36
		  Var pillY As Double = (g.Height - pillH) / 2
		  Var pillX As Double = 4
		  Var pillW As Double = g.Width - 8
		  Var cornerR As Double = 10

		  g.DrawingColor = &cE2E8F0
		  g.FillRoundRectangle(pillX, pillY, pillW, pillH, cornerR, cornerR)

		  // Sample segments
		  g.FontSize = 13
		  Var labels() As String = Array("All", "Active", "Done")
		  Var segPad As Double = 12
		  Var segGap As Double = 2
		  Var segH As Double = pillH - 4
		  Var segY As Double = pillY + 2
		  Var segR As Double = cornerR - 2

		  // Calculate segment widths
		  Var totalTextW As Double = 0
		  For Each lbl As String In labels
		    totalTextW = totalTextW + g.TextWidth(lbl) + segPad * 2
		  Next

		  Var segX As Double = pillX + 2

		  For i As Integer = 0 To labels.LastIndex
		    Var lbl As String = labels(i)
		    Var segW As Double = g.TextWidth(lbl) + segPad * 2

		    If i = 0 Then
		      // Selected segment - white with shadow effect
		      g.DrawingColor = &cFFFFFF
		      g.FillRoundRectangle(segX, segY, segW, segH, segR, segR)
		      // Subtle shadow border
		      g.DrawingColor = &cD0D5DD
		      g.DrawRoundRectangle(segX, segY, segW, segH, segR, segR)
		      // Text
		      g.DrawingColor = &c0F172A
		    Else
		      // Unselected segment
		      g.DrawingColor = &c64748B
		    End If

		    g.DrawText(lbl, segX + segPad, segY + segH / 2 + g.TextHeight / 4)
		    segX = segX + segW + segGap
		  Next
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
		  Select Case name.Lowercase
		  Case "selectionchanged"
		    mSelectedIndex = parameters.Value("index")
		    Var itemName As String = parameters.Value("name")
		    RaiseEvent SelectionChanged(mSelectedIndex, itemName)
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
		  Return "MobileWeb.SegmentedControl"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  // Parse ItemList into a JSON array
		  Var parts() As String = mItemList.Split(",")
		  Var jItems As New JSONItem
		  For Each part As String In parts
		    Var trimmed As String = part.Trim
		    If trimmed <> "" Then jItems.Add(trimmed)
		  Next
		  js.Value("items") = jItems
		  js.Value("selectedIndex") = mSelectedIndex
		  js.Value("enabled") = Self.Enabled
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionCSSURLs(session As WebSession) As String()
		  MobileTheme.EnsureThemeFile()

		  If SharedCSSFile = Nil Then
		    SharedCSSFile = New WebFile
		    SharedCSSFile.Data = "@layer mobile-components{" _
		    + ".mobile-segment{display:inline-flex;background:var(--mobile-gray-200);" _
		    + "border-radius:var(--mobile-radius-lg);padding:2px;gap:2px;" _
		    + "font-family:var(--mobile-font);user-select:none;-webkit-user-select:none;" _
		    + "-webkit-tap-highlight-color:transparent}" _
		    + ".mobile-segment__button{padding:var(--mobile-space-xs) var(--mobile-space-md);" _
		    + "border:none;background:transparent;" _
		    + "border-radius:var(--mobile-radius-lg);" _
		    + "font-size:var(--mobile-text-sm);font-weight:var(--mobile-font-medium);" _
		    + "color:var(--mobile-text-secondary);cursor:pointer;" _
		    + "transition:all var(--mobile-duration-normal) var(--mobile-ease);" _
		    + "min-height:32px;line-height:1.4;white-space:nowrap}" _
		    + ".mobile-segment__button.is-selected{background:var(--mobile-on-primary);" _
		    + "color:var(--mobile-text);box-shadow:var(--mobile-shadow-sm);" _
		    + "font-weight:var(--mobile-font-semibold)}" _
		    + ".mobile-segment__button:active{transform:scale(0.97)}" _
		    + ".mobile-segment.is-disabled{opacity:var(--mobile-disabled-opacity);" _
		    + "pointer-events:none}" _
		    + "}"
		    SharedCSSFile.Session = Nil
		    SharedCSSFile.Filename = "MobileSegmentedControl.css"
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
		    + "class SegmentedControl extends XojoWeb.XojoVisualControl{" _
		    + "constructor(id,events){super(id,events);" _
		    + "this.items=[];this.selectedIndex=0;this.segEnabled=true;" _
		    + "this._touchFired=false;" _
		    + "var el=this.DOMElement();" _
		    + "if(el){el.style.position='relative';" _
		    + "this.wrapper=document.createElement('div');" _
		    + "this.wrapper.className='mobile-segment';" _
		    + "this.wrapper.style.cssText='width:100%;height:100%;box-sizing:border-box';" _
		    + "el.appendChild(this.wrapper)}}" _
		    + "updateControl(data){try{var update=JSON.parse(data);" _
		    + "if(Array.isArray(update.items)){this.items=update.items}" _
		    + "if(typeof update.selectedIndex==='number'){this.selectedIndex=update.selectedIndex}" _
		    + "this.segEnabled=update.enabled!==false;" _
		    + "this.rebuild();" _
		    + "super.updateControl(data)" _
		    + "}catch(e){console.log('MobileWeb.SegmentedControl UC ERROR:',e.message)}}" _
		    + "rebuild(){if(!this.wrapper)return;" _
		    + "this.wrapper.replaceChildren();" _
		    + "var self=this;" _
		    + "for(var i=0;i<this.items.length;i++){" _
		    + "var btn=document.createElement('button');" _
		    + "btn.className='mobile-segment__button';" _
		    + "btn.textContent=this.items[i];" _
		    + "if(i===this.selectedIndex){btn.classList.add('is-selected')}" _
		    + "btn.addEventListener('touchend',(function(idx){return function(e){" _
		    + "e.preventDefault();self._touchFired=true;self.handleSelect(idx)}})(i));" _
		    + "btn.addEventListener('click',(function(idx){return function(){" _
		    + "if(self._touchFired){self._touchFired=false;return}" _
		    + "self.handleSelect(idx)}})(i));" _
		    + "this.wrapper.appendChild(btn)}" _
		    + "if(this.segEnabled){this.wrapper.classList.remove('is-disabled')}" _
		    + "else{this.wrapper.classList.add('is-disabled')}}" _
		    + "handleSelect(index){if(!this.segEnabled)return;" _
		    + "this.selectedIndex=index;this.rebuild();" _
		    + "var params=new XojoWeb.JSONItem();" _
		    + "params.set('index',index);" _
		    + "params.set('name',this.items[index]||'');" _
		    + "this.triggerServerEvent('SelectionChanged',params,false)}" _
		    + "render(){super.render();" _
		    + "var el=this.DOMElement();if(!el)return;" _
		    + "this.applyUserStyle();this.applyTooltip(el)}}" _
		    + "MobileWeb.SegmentedControl=SegmentedControl" _
		    + "})(MobileWeb||(MobileWeb={}));"
		    SharedJSFile.Session = Nil
		    SharedJSFile.Filename = "MobileSegmentedControl.js"
		    SharedJSFile.MIMEType = "application/javascript"
		  End If

		  Return Array(SharedJSFile.URL)
		End Function
	#tag EndEvent


	#tag Hook, Flags = &h0
		Event SelectionChanged(index As Integer, name As String)
	#tag EndHook


	#tag Method, Flags = &h0
		Sub AddItem(name As String)
		  If mItemList = "" Then
		    mItemList = name
		  Else
		    mItemList = mItemList + "," + name
		  End If
		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveItem(name As String)
		  Var parts() As String = mItemList.Split(",")
		  Var result() As String
		  For Each part As String In parts
		    Var trimmed As String = part.Trim
		    If trimmed <> "" And trimmed <> name Then
		      result.Add(trimmed)
		    End If
		  Next
		  mItemList = String.FromArray(result, ",")
		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearItems()
		  mItemList = ""
		  mSelectedIndex = 0
		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AllItems() As String()
		  Var parts() As String = mItemList.Split(",")
		  Var result() As String
		  For Each part As String In parts
		    Var trimmed As String = part.Trim
		    If trimmed <> "" Then result.Add(trimmed)
		  Next
		  Return result
		End Function
	#tag EndMethod


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mItemList
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mItemList = value
			  UpdateControl
			End Set
		#tag EndSetter
		ItemList As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mSelectedIndex
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mSelectedIndex = value
			  UpdateControl
			End Set
		#tag EndSetter
		SelectedIndex As Integer
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Var items() As String = AllItems()
			  If mSelectedIndex >= 0 And mSelectedIndex <= items.LastIndex Then
			    Return items(mSelectedIndex)
			  End If
			  Return ""
			End Get
		#tag EndGetter
		SelectedItem As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Var items() As String = AllItems()
			  Return items.Count
			End Get
		#tag EndGetter
		Count As Integer
	#tag EndComputedProperty


	#tag Property, Flags = &h21
		Private mItemList As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mSelectedIndex As Integer
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
			InitialValue="36"
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
			Name="ItemList"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectedIndex"
			Visible=true
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="SelectedItem"
			Visible=false
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Count"
			Visible=false
			Group="Behavior"
			InitialValue="0"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
	#tag EndViewBehavior
End Class
#tag EndClass
