#tag Module
Protected Module WebModule
	#tag Method, Flags = &h0
		Function toBootstrapSize(extends s as String) As bootstrapSizes
		  Select Case s
		  Case "small"
		    Return bootstrapSizes.small
		  Case "large"
		    Return bootstrapSizes.large
		  Case "extralarge"
		    Return bootstrapSizes.extralarge
		  Else
		    Return bootstrapSizes.default
		  End Select
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToIndicator(extends i as String) As WebUIControl.Indicators
		  Dim res As WebUIControl.Indicators
		  
		  Select Case i
		  Case "primary"
		    res = WebUIControl.Indicators.Primary
		  Case "secondary"
		    res = WebUIControl.Indicators.Secondary
		  Case "info"
		    res = WebUIControl.Indicators.Info
		  Case "success"
		    res = WebUIControl.Indicators.Success
		  Case "warning"
		    res = WebUIControl.Indicators.Warning
		  Case "danger"
		    res = WebUIControl.Indicators.Danger
		  Case "light"
		    res = WebUIControl.Indicators.Light
		  Case "dark"
		    res = WebUIControl.Indicators.Dark
		  Case "link"
		    res = WebUIControl.Indicators.Link
		  Case ""
		    res = WebUIControl.Indicators.Default
		  Else
		    Raise New OutOfBoundsException
		  End Select
		  
		  Return res
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToIndicator(extends i as webmodule.indicators) As WebUIControl.Indicators
		  Dim res As WebUIControl.Indicators
		  
		  Select Case i
		  Case WebModule.indicators.primary
		    res = WebUIControl.Indicators.Primary
		  Case WebModule.indicators.secondary
		    res = WebUIControl.Indicators.Secondary
		  Case WebModule.indicators.info
		    res = WebUIControl.Indicators.Info
		  Case WebModule.indicators.success
		    res = WebUIControl.Indicators.Success
		  Case WebModule.indicators.warning
		    res = WebUIControl.Indicators.Warning
		  Case WebModule.indicators.danger
		    res = WebUIControl.Indicators.Danger
		  Case WebModule.indicators.light
		    res = WebUIControl.Indicators.Light
		  Case WebModule.indicators.dark
		    res = WebUIControl.Indicators.Dark
		  Case WebModule.indicators.link
		    res = WebUIControl.Indicators.Link
		  Case WebModule.indicators.default
		    res = WebUIControl.Indicators.default
		  Else
		    Raise New OutOfBoundsException
		  End Select
		  
		  Return res
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString(extends s as bootstrapSizes) As String
		  Dim res As String
		  
		  Select Case s
		  Case WebModule.bootstrapSizes.default
		    res = ""
		  Case WebModule.bootstrapSizes.small
		    res = "sm"
		  Case WebModule.bootstrapSizes.large
		    res = "lg"
		  Case WebModule.bootstrapSizes.extralarge
		    res = "xl"
		  Else
		    Raise New OutOfBoundsException
		  End Select
		  
		  Return res
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString(extends s as shadows) As String
		  Dim res As String
		  
		  Select Case s
		  Case WebModule.shadows.noShadow
		    res = "shadow-none"
		  Case WebModule.shadows.smallShadow
		    res = "shadow-sm"
		  Case WebModule.shadows.regularShadow
		    res = "shadow"
		  Case WebModule.shadows.largeShadow
		    res = "shadow-lg"
		  Else
		    Raise New OutOfBoundsException
		  End Select
		  
		  Return res
		  
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Function ToString(extends i as WebUIControl.Indicators) As String
		  Dim res As String
		  
		  Select Case i
		  Case WebUIControl.Indicators.Primary
		    res = "-primary"
		  Case WebUIControl.Indicators.Secondary
		    res = "-secondary"
		  Case WebUIControl.Indicators.Info
		    res = "-info"
		  Case WebUIControl.Indicators.Success
		    res = "-success"
		  Case WebUIControl.Indicators.Warning
		    res = "-warning"
		  Case WebUIControl.Indicators.Danger
		    res = "-danger"
		  Case WebUIControl.Indicators.Light
		    res = "-light"
		  Case WebUIControl.Indicators.Dark
		    res = "-dark"
		  Case WebUIControl.Indicators.Link
		    res = "-link"
		  Case WebUIControl.Indicators.Default
		    res = ""
		  Else
		    Raise New OutOfBoundsException
		  End Select
		  
		  Return res
		  
		End Function
	#tag EndMethod


	#tag Enum, Name = bootstrapSizes, Flags = &h0
		small
		  default
		  large
		extralarge
	#tag EndEnum

	#tag Enum, Name = indicators, Flags = &h0
		default
		  primary
		  secondary
		  success
		  danger
		  warning
		  info
		  light
		  dark
		  muted
		  white
		  black50
		  white50
		link
	#tag EndEnum

	#tag Enum, Name = shadows, Flags = &h0
		noShadow
		  smallShadow
		  regularShadow
		largeShadow
	#tag EndEnum


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
End Module
#tag EndModule
