#tag Class
Protected Class CallbackControl
Inherits WebSDKControl
	#tag Event
		Function ExecuteEvent(name As String, parameters As JSONItem) As Boolean
		  // convert the data from base64 back into a string
		  parameters.Value("data") = DecodeBase64(parameters.Value("data"))
		  RaiseEvent BrowserCallback(name, parameters)
		  Return True
		End Function
	#tag EndEvent

	#tag Event
		Function HandleRequest(request As WebRequest, response As WebResponse) As Boolean
		  // Hidden from end users
		End Function
	#tag EndEvent

	#tag Event
		Function JavaScriptClassName() As String
		  // this is case-sensitive and must match the javascript class exactly
		  Return "example.callback"
		End Function
	#tag EndEvent

	#tag Event
		Sub Serialize(js As JSONItem)
		  // Hidden from end users
		End Sub
	#tag EndEvent

	#tag Event
		Function SessionHead(session As WebSession) As String
		  // Hidden from end users
		End Function
	#tag EndEvent

	#tag Event
		Function SessionJavascriptURLs(session As WebSession) As String()
		  // Create a webfile to contain the callback javascript code,
		  // but globally without session info so we're not creating this
		  // over and over
		  If SharedJSClassFile = Nil Then
		    SharedJSClassFile = New WebFile
		    SharedJSClassFile.MIMEType = "text/javascript"
		    SharedJSClassFile.Session = Nil
		    SharedJSClassFile.Filename = "callbackcontrol.js"
		    SharedJSClassFile.Data = kJSCode
		  End If
		  
		  Return Array (SharedJSClassFile.URL)
		End Function
	#tag EndEvent


	#tag Method, Flags = &h0
		Sub Constructor()
		  // Calling the overridden superclass constructor.
		  // Note that this may need modifications if there are multiple constructor choices.
		  // Possible constructor calls:
		  // Constructor() -- From WebSDKControl
		  // Constructor() -- From WebControl
		  Super.Constructor
		  
		End Sub
	#tag EndMethod

	#tag Method, Flags = &h0
		Function MakeCallback(eventName as string, data as string) As String
		  // encode the passed data as base64 so we don't get transmission errors
		  
		  Return "XojoWeb.getNamedControl('" + Self.controlID + "').callback('" + eventName + "','" + EncodeBase64(data, 0) + "');" 
		  
		End Function
	#tag EndMethod


	#tag Hook, Flags = &h0
		Event BrowserCallback(method as string, parameters as jsonitem)
	#tag EndHook


	#tag Note, Name = Usage
		
		This is a non-ui WebSDK control that acts as a relay between html controls on a web page
		and a web application
		
		1. Place an instance of the control on a webpage
		
		2. To create a javascript callback, call the MakeCallback method with an event name string and a unique 
		   bit of data to be sent to differentiate between multiple controls.
		
		3. When the call is made on the browser, the BrowserCallback event will fire with the same values
		
		
		
		
	#tag EndNote


	#tag Property, Flags = &h21
		#tag Note
			This property is so we don't have separate WebFile objects for each session, since the contents will always be the same.
		#tag EndNote
		Private Shared SharedJSClassFile As WebFile
	#tag EndProperty


	#tag Constant, Name = kJSCode, Type = String, Dynamic = False, Default = \"var example;\n(function (example) {\n    class callback extends XojoWeb.XojoControl {\n        constructor(target\x2C events) {\n            super(target\x2C events);\n        }\n        callback(eventName\x2C datum) {\n\t    datum \x3D { data : datum };\n            this.triggerServerEvent(eventName\x2C datum\x2C true);\n        }\n    }\n    example.callback \x3D callback;\n})(example || (example \x3D {}));", Scope = Private
	#tag EndConstant


	#tag ViewBehavior
		#tag ViewProperty
			Name="_mPanelIndex"
			Visible=false
			Group="Behavior"
			InitialValue="-1"
			Type="Integer"
			EditorType=""
		#tag EndViewProperty
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
			Name="Enabled"
			Visible=false
			Group="Appearance"
			InitialValue=""
			Type="Boolean"
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
	#tag EndViewBehavior
End Class
#tag EndClass
