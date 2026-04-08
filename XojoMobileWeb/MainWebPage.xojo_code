#tag WebPage
Begin WebPage MainWebPage
   AllowTabOrderWrap=   True
   Compatibility   =   ""
   ControlCount    =   1
   ControlID       =   ""
   CSSClasses      =   ""
   Enabled         =   False
   Height          =   400
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
   Begin Toggle Toggle1
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
End
#tag EndWebPage

#tag WindowCode
#tag EndWindowCode

#tag Events Toggle1
	#tag Event
		Sub Toggled(value As Boolean)
		  System.DebugLog("Toggle1 toggled: " + If(value, "ON", "OFF"))
		End Sub
	#tag EndEvent
#tag EndEvents
