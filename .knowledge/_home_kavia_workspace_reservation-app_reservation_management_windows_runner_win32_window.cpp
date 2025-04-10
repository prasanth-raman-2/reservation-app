{"is_source_file": true, "format": "C++", "description": "This file implements the Win32 Window functionalities for a Flutter application, managing window creation, messaging, and theming in a Windows environment.", "external_files": ["win32_window.h", "dwmapi.h", "flutter_windows.h", "resource.h"], "external_methods": ["LoadLibraryA", "GetProcAddress", "FreeLibrary", "CreateWindow", "ShowWindow", "RegisterClass", "UnregisterClass", "GetModuleHandle", "SetWindowLongPtr", "GetWindowLongPtr", "DestroyWindow", "PostQuitMessage", "UpdateTheme", "DwmSetWindowAttribute", "RegGetValue"], "published": ["WindowClassRegistrar", "Win32Window"], "classes": [{"name": "WindowClassRegistrar", "description": "Manages the registration and unregistration of the window class for the Win32 window."}, {"name": "Win32Window", "description": "Represents the main window of the Flutter application on Windows, handling creation, message processing, and lifecycle events."}], "methods": [{"name": "Create", "description": "Creates the window with the provided title and dimensions, adjusting for DPI scaling."}, {"name": "Show", "description": "Shows the window with normal priority."}, {"name": "WndProc", "description": "Processes window messages for the Win32 window, including creation, destruction, and resizing."}, {"name": "MessageHandler", "description": "Handles specific messages sent to the window, managing lifecycle events and state changes."}, {"name": "Destroy", "description": "Cleans up and destroys the window, unregistering the class if no windows are active."}, {"name": "SetChildContent", "description": "Sets the child window content and manages its position within the main window."}, {"name": "GetClientArea", "description": "Returns the client area dimensions of the window."}, {"name": "GetHandle", "description": "Returns the HWND handle of the window."}, {"name": "SetQuitOnClose", "description": "Sets whether the application should quit when the window is closed."}, {"name": "OnCreate", "description": "No-op for subclasses to override for custom behavior during window creation."}, {"name": "OnDestroy", "description": "No-op for subclasses to override for custom behavior during window destruction."}, {"name": "UpdateTheme", "description": "Updates the window's theme based on the user's theme preference."}], "calls": ["LoadLibraryA", "GetProcAddress", "FreeLibrary", "RegisterClass", "CreateWindow", "ShowWindow", "DefWindowProc", "SetWindowPos", "DestroyWindow", "PostQuitMessage", "RegGetValue", "DwmSetWindowAttribute"], "search-terms": ["Win32Window", "WindowClassRegistrar", "DPI scaling", "MessageHandler", "window creation", "themable window"], "state": 2, "file_id": 43, "knowledge_revision": 100, "git_revision": "ead6fc0cf75e86ffd7b2128aeb730786d976ae73", "ctags": [], "filename": "/home/kavia/workspace/reservation-app/reservation_management/windows/runner/win32_window.cpp", "hash": "928e86a2be27eca688669dce6c9177d9", "format-version": 4, "code-base-name": "default", "revision_history": [{"100": "ead6fc0cf75e86ffd7b2128aeb730786d976ae73"}]}