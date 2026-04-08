#tag Module
Protected Module MobileTheme
	#tag Method, Flags = &h0
		Function ThemeCSS() As String
		  // ═══════════════════════════════════════════════════════════════
		  // SINGLE CONFIGURATION POINT — Edit token values here to
		  // customize the entire MobileWeb theme. All controls reference
		  // these tokens via CSS var(--mobile-*).
		  // ═══════════════════════════════════════════════════════════════

		  Return "@layer mobile-tokens{:root{" _
		  + "--mobile-blue-500:#3b82f6;--mobile-blue-600:#2563eb;--mobile-blue-700:#1d4ed8;" _
		  + "--mobile-gray-50:#f8fafc;--mobile-gray-100:#f1f5f9;--mobile-gray-200:#e2e8f0;" _
		  + "--mobile-gray-300:#cbd5e1;--mobile-gray-400:#94a3b8;--mobile-gray-500:#64748b;" _
		  + "--mobile-gray-800:#1e293b;--mobile-gray-900:#0f172a;" _
		  + "--mobile-red-500:#ef4444;--mobile-green-500:#22c55e;--mobile-amber-500:#f59e0b;" _
		  + "--mobile-primary:var(--mobile-blue-700);--mobile-primary-hover:var(--mobile-blue-600);" _
		  + "--mobile-on-primary:#ffffff;" _
		  + "--mobile-surface:var(--mobile-gray-50);--mobile-surface-hover:var(--mobile-gray-100);" _
		  + "--mobile-border:var(--mobile-gray-300);" _
		  + "--mobile-text:var(--mobile-gray-900);--mobile-text-secondary:var(--mobile-gray-500);" _
		  + "--mobile-danger:var(--mobile-red-500);--mobile-success:var(--mobile-green-500);" _
		  + "--mobile-warning:var(--mobile-amber-500);--mobile-disabled-opacity:0.5;" _
		  + "--mobile-space-xs:0.25rem;--mobile-space-sm:0.5rem;--mobile-space-md:1rem;" _
		  + "--mobile-space-lg:1.5rem;--mobile-space-xl:2rem;" _
		  + "--mobile-font:-apple-system,BlinkMacSystemFont,'Segoe UI',Roboto,sans-serif;" _
		  + "--mobile-text-xs:0.75rem;--mobile-text-sm:0.875rem;--mobile-text-base:1rem;" _
		  + "--mobile-text-lg:1.125rem;--mobile-text-xl:1.25rem;" _
		  + "--mobile-font-normal:400;--mobile-font-medium:500;" _
		  + "--mobile-font-semibold:600;--mobile-font-bold:700;" _
		  + "--mobile-radius-sm:0.25rem;--mobile-radius-md:0.5rem;" _
		  + "--mobile-radius-lg:0.75rem;--mobile-radius-xl:1rem;--mobile-radius-full:9999px;" _
		  + "--mobile-shadow-sm:0 1px 2px rgba(0,0,0,0.05);" _
		  + "--mobile-shadow-md:0 4px 6px -1px rgba(0,0,0,0.1);" _
		  + "--mobile-shadow-lg:0 10px 15px -3px rgba(0,0,0,0.1);" _
		  + "--mobile-ease:cubic-bezier(0.25,0,0.3,1);" _
		  + "--mobile-duration-fast:0.15s;--mobile-duration-normal:0.2s;--mobile-duration-slow:0.3s;" _
		  + "--mobile-tap-size:44px;--mobile-tap-highlight:rgba(0,0,0,0.05)" _
		  + "}" _
		  + "@media(prefers-color-scheme:dark){:root{" _
		  + "--mobile-primary:var(--mobile-blue-500);--mobile-primary-hover:var(--mobile-blue-600);" _
		  + "--mobile-surface:var(--mobile-gray-800);--mobile-surface-hover:var(--mobile-gray-900);" _
		  + "--mobile-text:var(--mobile-gray-100);--mobile-text-secondary:var(--mobile-gray-400);" _
		  + "--mobile-border:var(--mobile-gray-500);" _
		  + "--mobile-shadow-sm:0 1px 2px rgba(0,0,0,0.2);" _
		  + "--mobile-shadow-md:0 4px 6px -1px rgba(0,0,0,0.3);" _
		  + "--mobile-shadow-lg:0 10px 15px -3px rgba(0,0,0,0.3)" _
		  + "}}}"
		End Function
	#tag EndMethod

	#tag Method, Flags = &h0
		Sub EnsureThemeFile()
		  If SharedThemeFile <> Nil Then Return

		  SharedThemeFile = New WebFile
		  SharedThemeFile.Data = ThemeCSS()
		  SharedThemeFile.Session = Nil
		  SharedThemeFile.Filename = "mobile-theme.css"
		  SharedThemeFile.MIMEType = "text/css"
		End Sub
	#tag EndMethod


	#tag Property, Flags = &h0
		Shared SharedThemeFile As WebFile
	#tag EndProperty

#tag EndModule
