#tag Class
Protected Class CellBackgroundColor
Inherits WebListboxCellRenderer
	#tag Event
		Sub Deserialize(js As JSONItem)
		  // Restore the values of the column to the object
		  
		  Var parts() As String = Split(js.Value("color").StringValue, "/")
		  If UBound(parts) < 3 Then
		    Return
		  End If
		  
		  mColor =RGB(Val(parts(0)), Val(parts(1)), Val(parts(2)), Val(parts(3)))
		End Sub
	#tag EndEvent

	#tag Event
		Function JavascriptClassCode(s As WebSession) As String
		  Dim sa() As String
		  sa.AddRow "class ExampleColorBackground extends XojoWeb.ListboxCellRenderer {"
		  sa.AddRow "  render(controlID, row, data, rowIndex, columnIndex, cell) {"
		  sa.AddRow "    let parts = data.color.split('/');"
		  sa.AddRow "    let r = parseInt(parts[0]);"
		  sa.AddRow "    let g = parseInt(parts[1]);"
		  sa.AddRow "    let b = parseInt(parts[2]);"
		  sa.AddRow "    let a = 1 - (parseInt(parts[3]) / 100);"
		  sa.AddRow "    cell.style.backgroundColor = 'rgba(' + r + ', ' + g + ', ' + b + ', ' + a + ')';"
		  sa.AddRow "    cell.innerHTML = '';"
		  sa.AddRow "  }"
		  sa.AddRow "}"
		  
		  Return Join(sa, EndOfLine.Windows)
		End Function
	#tag EndEvent

	#tag Event
		Function Serialize() As JSONItem
		  // Use this code to convert the value(s) needed to render your codes to JSON.
		  // This is also used by non-datasource listboxes to store these settings for your column.
		  
		  Dim js As New JSONItem
		  
		  js.Value("color") = Str(mColor.Red) + "/" + Str(mColor.Green) + "/" + Str(mColor.Blue) + "/" + Str(mColor.Alpha)
		  
		  Return js
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor(c as color)
		  // Calling the overridden superclass constructor.
		  Super.Constructor
		  
		  mColor = c
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h21
		Private mColor As Color
	#tag EndProperty


	#tag ViewBehavior
		#tag ViewProperty
			Name="Name"
			Visible=true
			Group="ID"
			InitialValue=""
			Type="String"
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
	#tag EndViewBehavior
End Class
#tag EndClass
