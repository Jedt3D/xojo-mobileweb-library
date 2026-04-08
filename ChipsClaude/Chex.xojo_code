#tag Class
Protected Class Chex
Inherits WebSDKUIControl
	#tag Event
		Sub DrawControlInLayoutEditor(g As Graphics)
		  // Background
		  g.DrawingColor = &cF8FAFC
		  g.FillRoundRectangle(0, 0, g.Width, g.Height, 8, 8)
		  g.DrawingColor = &cCBD5E1
		  g.DrawRoundRectangle(0, 0, g.Width, g.Height, 8, 8)
		  
		  // Draw sample checkboxes
		  g.FontSize = 16
		  Var labels() As String = Array("Apple", "Banana", "Coconut", "Durian")
		  Var y As Double = 8
		  Var rowH As Double = 24
		  Var cbSize As Double = 14
		  Var gap As Double = 4
		  
		  For i As Integer = 0 To labels.LastIndex
		    Var lbl As String = labels(i)
		    Var cx As Double = 12
		    Var cy As Double = y + (rowH - cbSize) / 2
		    Var isChecked As Boolean = (i = 0 Or i = 2)
		    
		    // Draw checkbox
		    If isChecked Then
		      g.DrawingColor = &c1D4ED8
		      g.FillRoundRectangle(cx, cy, cbSize, cbSize, 3, 3)
		      g.DrawingColor = &cFFFFFF
		      g.DrawLine(cx + 3, cy + cbSize / 2, cx + cbSize / 2 - 1, cy + cbSize - 4)
		      g.DrawLine(cx + cbSize / 2 - 1, cy + cbSize - 4, cx + cbSize - 3, cy + 3)
		    Else
		      g.DrawingColor = &cFFFFFF
		      g.FillRoundRectangle(cx, cy, cbSize, cbSize, 3, 3)
		      g.DrawingColor = &cCBD5E1
		      g.DrawRoundRectangle(cx, cy, cbSize, cbSize, 3, 3)
		    End If
		    
		    // Draw label
		    g.DrawingColor = &c0F172A
		    g.DrawText(lbl, cx + cbSize + 8, y + rowH / 2 + g.TextHeight / 4)
		    
		    y = y + rowH + gap
		  Next
		End Sub
	#tag EndEvent

	#tag Event
		Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
		  Select Case name.Lowercase
		  Case "selectionchanged"
		    mStateJSON = parameters.Value("stateJSON")
		    RaiseEvent SelectionChanged
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
		  Return "WebSDKSamples.Chex"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  Var items As String = mItemsJSON
		  Var state As String = mStateJSON
		  If items = "" Then items = "[]"
		  If state = "" Then state = "{}"
		  js.Value("itemsJSON") = New JSONItem(items)
		  js.Value("stateJSON") = New JSONItem(state)
		  js.Value("enabled") = Self.Enabled
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionCSSURLs(session As WebSession) As String()
		  If SharedCSSFile = Nil Then
		    SharedCSSFile = New WebFile
		    SharedCSSFile.Data = ".xojo-chex__list{display:flex;flex-direction:column;gap:0.25rem;padding:0.25rem}.xojo-chex__item{display:flex;align-items:center;gap:0.5rem;padding:4px 8px;font-size:16px;font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;cursor:pointer;user-select:none;border-radius:4px}.xojo-chex__item:hover{background:#f1f5f9}.xojo-chex__item.is-disabled{opacity:0.5;cursor:default;pointer-events:none}.xojo-chex__item input[type='checkbox']{width:16px;height:16px;accent-color:#1d4ed8;cursor:pointer}.xojo-chex__item.is-disabled input[type='checkbox']{cursor:default}.xojo-chex__label{color:#0f172a;line-height:1.4}"
		    SharedCSSFile.Session = Nil
		    SharedCSSFile.Filename = "Chex.css"
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
		    SharedJSFile.Data = "var WebSDKSamples;(function(WebSDKSamples){class Chex extends XojoWeb.XojoVisualControl{constructor(id,events){super(id,events);this.items=[];this.state={};this.chexEnabled=true;var el=this.DOMElement();if(el){el.style.position='relative';this.listEl=document.createElement('div');this.listEl.className='xojo-chex__list';el.appendChild(this.listEl)}}updateControl(data){try{var update=JSON.parse(data);var items=update.itemsJSON;var state=update.stateJSON;if(Array.isArray(items)){this.items=items.filter(function(e){return typeof e==='string'})}if(state&&typeof state==='object'&&!Array.isArray(state)){var s={};for(var k in state){if(state.hasOwnProperty(k))s[k]=state[k]===true}this.state=s}this.chexEnabled=typeof update.enabled==='boolean'?update.enabled:true;this.rebuildList()}catch(e){console.log('UC ERROR:',e.message)}super.updateControl(data)}rebuildList(){if(!this.listEl)return;this.listEl.replaceChildren();var self=this;for(var i=0;i<this.items.length;i++){var item=this.items[i];var row=document.createElement('label');row.className='xojo-chex__item';if(!this.chexEnabled)row.classList.add('is-disabled');var cb=document.createElement('input');cb.type='checkbox';cb.checked=this.state[item]===true;cb.disabled=!this.chexEnabled;cb.addEventListener('change',(function(name){return function(){if(!self.chexEnabled)return;self.handleToggle(name,this.checked)}})(item));var lbl=document.createElement('span');lbl.className='xojo-chex__label';lbl.textContent=item;row.appendChild(cb);row.appendChild(lbl);this.listEl.appendChild(row)}}handleToggle(item,checked){this.state[item]=checked;this.rebuildList();var params=new XojoWeb.JSONItem();params.set('stateJSON',JSON.stringify(this.state));this.triggerServerEvent('SelectionChanged',params,false)}render(){super.render();var el=this.DOMElement();if(!el)return;this.applyUserStyle();this.applyTooltip(el)}}WebSDKSamples.Chex=Chex})(WebSDKSamples||(WebSDKSamples={}));"
		    SharedJSFile.Session = Nil
		    SharedJSFile.Filename = "Chex.js"
		    SharedJSFile.MIMEType = "application/javascript"
		  End If
		  Return Array(SharedJSFile.URL)
		End Function
	#tag EndEvent


	#tag Hook, Flags = &h0
		Event SelectionChanged()
	#tag EndHook


	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mItemsJSON
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mItemsJSON = value
			  UpdateControl
			End Set
		#tag EndSetter
		ItemsJSON As String
	#tag EndComputedProperty

	#tag Property, Flags = &h21
		Private mItemsJSON As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private mStateJSON As String
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared SharedCSSFile As WebFile
	#tag EndProperty

	#tag Property, Flags = &h21
		Private Shared SharedJSFile As WebFile
	#tag EndProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Return mStateJSON
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  mStateJSON = value
			  UpdateControl
			End Set
		#tag EndSetter
		StateJSON As String
	#tag EndComputedProperty


	#tag Method, Flags = &h21
		Private Function ParseItems() As String()
		  Var result() As String
		  If mItemsJSON = "" Or mItemsJSON = "[]" Then Return result
		  Try
		    Var j As New JSONItem(mItemsJSON)
		    For i As Integer = 0 To j.Count - 1
		      result.Add(j.ValueAt(i))
		    Next
		  Catch e As RuntimeException
		  End Try
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Function ParseState() As Dictionary
		  Var result As New Dictionary
		  If mStateJSON = "" Or mStateJSON = "{}" Then Return result
		  Try
		    Var j As New JSONItem(mStateJSON)
		    For i As Integer = 0 To j.Count - 1
		      Var key As String = j.Name(i)
		      Var b As Boolean = j.Value(key)
		      result.Value(key) = b
		    Next
		  Catch e As RuntimeException
		  End Try
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h21
		Private Sub RebuildJSON(items() As String, state As Dictionary)
		  Var jItems As New JSONItem
		  For Each item As String In items
		    jItems.Add(item)
		  Next
		  mItemsJSON = jItems.ToString

		  Var jState As New JSONItem
		  For Each item As String In items
		    If state.HasKey(item) Then
		      Var b As Boolean = state.Value(item)
		      jState.Value(item) = b
		    Else
		      jState.Value(item) = False
		    End If
		  Next
		  mStateJSON = jState.ToString

		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub AddItem(name As String, selected As Boolean = False)
		  Var items() As String = ParseItems()
		  Var state As Dictionary = ParseState()
		  items.Add(name)
		  state.Value(name) = selected
		  RebuildJSON(items, state)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub RemoveItem(name As String)
		  Var items() As String = ParseItems()
		  Var state As Dictionary = ParseState()
		  For i As Integer = items.LastIndex DownTo 0
		    If items(i) = name Then
		      items.RemoveAt(i)
		    End If
		  Next
		  If state.HasKey(name) Then state.Remove(name)
		  RebuildJSON(items, state)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub ClearItems()
		  mItemsJSON = "[]"
		  mStateJSON = "{}"
		  UpdateControl
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetSelected(name As String, value As Boolean)
		  Var items() As String = ParseItems()
		  Var state As Dictionary = ParseState()
		  state.Value(name) = value
		  RebuildJSON(items, state)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function IsSelected(name As String) As Boolean
		  Var state As Dictionary = ParseState()
		  If state.HasKey(name) Then
		    Var b As Boolean = state.Value(name)
		    Return b
		  End If
		  Return False
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SelectAll()
		  Var items() As String = ParseItems()
		  Var state As New Dictionary
		  For Each item As String In items
		    state.Value(item) = True
		  Next
		  RebuildJSON(items, state)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub DeselectAll()
		  Var items() As String = ParseItems()
		  Var state As New Dictionary
		  For Each item As String In items
		    state.Value(item) = False
		  Next
		  RebuildJSON(items, state)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function AllItems() As String()
		  Return ParseItems()
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function SelectedItems() As String()
		  Var items() As String = ParseItems()
		  Var state As Dictionary = ParseState()
		  Var result() As String
		  For Each item As String In items
		    If state.HasKey(item) Then
		      Var b As Boolean = state.Value(item)
		      If b Then result.Add(item)
		    End If
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub SetFromDictionary(d As Dictionary)
		  Var items() As String
		  Var keys() As Variant = d.Keys
		  For Each key As Variant In keys
		    items.Add(key.StringValue)
		  Next
		  RebuildJSON(items, d)
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToDictionary() As Dictionary
		  Var items() As String = ParseItems()
		  Var state As Dictionary = ParseState()
		  Var result As New Dictionary
		  For Each item As String In items
		    If state.HasKey(item) Then
		      Var b As Boolean = state.Value(item)
		      result.Value(item) = b
		    Else
		      result.Value(item) = False
		    End If
		  Next
		  Return result
		End Function
	#tag EndMethod

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Var items() As String = ParseItems()
			  Return Join(items, ",")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Var parts() As String = value.Split(",")
			  Var jItems As New JSONItem
			  Var jState As New JSONItem
			  For Each part As String In parts
			    Var trimmed As String = part.Trim
			    If trimmed <> "" Then
			      jItems.Add(trimmed)
			      jState.Value(trimmed) = False
			    End If
			  Next
			  mItemsJSON = jItems.ToString
			  mStateJSON = jState.ToString
			  UpdateControl
			End Set
		#tag EndSetter
		ItemList As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Var items() As String = ParseItems()
			  Var state As Dictionary = ParseState()
			  Var selected() As String
			  For Each item As String In items
			    If state.HasKey(item) Then
			      Var b As Boolean = state.Value(item)
			      If b Then selected.Add(item)
			    End If
			  Next
			  Return Join(selected, ",")
			End Get
		#tag EndGetter
		#tag Setter
			Set
			  Var items() As String = ParseItems()
			  Var selectedNames() As String = value.Split(",")
			  Var selectedSet As New Dictionary
			  For Each name As String In selectedNames
			    Var trimmed As String = name.Trim
			    If trimmed <> "" Then selectedSet.Value(trimmed) = True
			  Next
			  Var jState As New JSONItem
			  For Each item As String In items
			    jState.Value(item) = selectedSet.HasKey(item)
			  Next
			  mStateJSON = jState.ToString
			  UpdateControl
			End Set
		#tag EndSetter
		DefaultSelected As String
	#tag EndComputedProperty

	#tag ComputedProperty, Flags = &h0
		#tag Getter
			Get
			  Var items() As String = ParseItems()
			  Return items.Count
			End Get
		#tag EndGetter
		Count As Integer
	#tag EndComputedProperty


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
			InitialValue="180"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="Width"
			Visible=true
			Group="Position"
			InitialValue="240"
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
			InitialValue=""
			Type="Boolean"
			EditorType=""
		#tag EndViewProperty
		#tag ViewProperty
			Name="ItemsJSON"
			Visible=false
			Group="Behavior"
			InitialValue="[]"
			Type="String"
			EditorType="MultiLineEditor"
		#tag EndViewProperty
		#tag ViewProperty
			Name="StateJSON"
			Visible=false
			Group="Behavior"
			InitialValue="{}"
			Type="String"
			EditorType="MultiLineEditor"
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
			Name="DefaultSelected"
			Visible=true
			Group="Behavior"
			InitialValue=""
			Type="String"
			EditorType="MultiLineEditor"
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
