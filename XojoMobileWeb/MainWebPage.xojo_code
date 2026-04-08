#tag WebPage
Begin WebPage MainWebPage
   AllowTabOrderWrap=   True
   Compatibility   =   ""
   ControlCount    =   3
   ControlID       =   ""
   CSSClasses      =   ""
   Enabled         =   False
   Height          =   600
   ImplicitInstance=   True
   Index           =   -2147483648
   Indicator       =   0
   IsImplicitInstance=   False
   LayoutDirection =   0
   LayoutType      =   0
   Left            =   0
   LockBottom      =   False
   LockHorizontal  =   False
   LockLeft        =   True
   LockRight       =   False
   LockTop         =   True
   LockVertical    =   False
   MinimumHeight   =   400
   MinimumWidth    =   600
   PanelIndex      =   0
   ScaleFactor     =   0.0
   TabIndex        =   0
   Title           =   "MobileWeb Demo"
   Top             =   0
   Visible         =   True
   Width           =   600
   _ImplicitInstance=   False
   _mDesignHeight  =   0
   _mDesignWidth   =   0
   _mName          =   ""
   _mPanelIndex    =   -1
   Begin MobileToggle Toggle1
      ControlID       =   ""
      Enabled         =   True
      Height          =   44
      Index           =   -2147483648
      Indicator       =   0
      IsOn            =   False
      Label           =   "Dark Mode"
      LabelPosition   =   0
      Left            =   40
      LockBottom      =   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      PanelIndex      =   0
      TabIndex        =   0
      Top             =   40
      Visible         =   True
      Width           =   200
      _mName          =   ""
      _mPanelIndex    =   -1
   End
   Begin MobileSegment Segment1
      ControlID       =   ""
      Enabled         =   True
      Height          =   36
      Index           =   -2147483648
      Indicator       =   0
      ItemList        =   "All,Active,Done"
      Left            =   40
      LockBottom      =   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      PanelIndex      =   0
      SelectedIndex   =   0
      TabIndex        =   1
      Top             =   100
      Visible         =   True
      Width           =   300
      _mName          =   ""
      _mPanelIndex    =   -1
   End
   Begin MobileCard Card1
      Body            =   "This is a sample card with body text to test the MobileWeb Card control."
      ControlID       =   ""
      Elevated        =   True
      Enabled         =   True
      Height          =   200
      ImageURL        =   ""
      Index           =   -2147483648
      Indicator       =   0
      Left            =   40
      LockBottom      =   False
      LockHorizontal  =   False
      LockLeft        =   True
      LockRight       =   False
      LockTop         =   True
      LockVertical    =   False
      PanelIndex      =   0
      Subtitle        =   "A mobile-first control"
      TabIndex        =   2
      Title           =   "MobileWeb Card"
      Top             =   160
      Visible         =   True
      Width           =   300
      _mName          =   ""
      _mPanelIndex    =   -1
   End
End
#tag EndWebPage

#tag WindowCode
#tag EndWindowCode

#tag Events Toggle1
	#tag Event
		Sub Toggled(value As Boolean)
		  System.DebugLog("Toggle1: " + If(value, "ON", "OFF"))
		End Sub
	#tag EndEvent
#tag EndEvents

#tag Events Segment1
	#tag Event
		Sub SelectionChanged(index As Integer, name As String)
		  System.DebugLog("Segment1: index=" + index.ToString + " name=" + name)
		End Sub
	#tag EndEvent
#tag EndEvents

#tag Events Card1
	#tag Event
		Sub Pressed()
		  System.DebugLog("Card1: pressed")
		End Sub
	#tag EndEvent
#tag EndEvents
