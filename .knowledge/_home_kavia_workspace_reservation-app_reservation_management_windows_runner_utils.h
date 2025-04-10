{"is_source_file": true, "format": "C++ Header File", "description": "Header file that declares utility functions for console management and string conversion in a runner application.", "external_files": [], "external_methods": [], "published": ["CreateAndAttachConsole", "Utf8FromUtf16", "GetCommandLineArguments"], "classes": [], "methods": [{"name": "CreateAndAttachConsole", "description": "Creates a console for the process, and redirects stdout and stderr to it for both the runner and the Flutter library."}, {"name": "Utf8FromUtf16", "description": "Takes a null-terminated wchar_t* encoded in UTF-16 and returns a std::string encoded in UTF-8. Returns an empty std::string on failure."}, {"name": "GetCommandLineArguments", "description": "Gets the command line arguments passed in as a std::vector<std::string>, encoded in UTF-8. Returns an empty std::vector<std::string> on failure."}], "calls": [], "search-terms": ["CreateAndAttachConsole", "Utf8FromUtf16", "GetCommandLineArguments"], "state": 2, "file_id": 38, "knowledge_revision": 91, "git_revision": "ead6fc0cf75e86ffd7b2128aeb730786d976ae73", "ctags": [], "filename": "/home/kavia/workspace/reservation-app/reservation_management/windows/runner/utils.h", "hash": "c741fb9cddbf3a62f4688b6cca39ddcc", "format-version": 4, "code-base-name": "default", "revision_history": [{"91": "ead6fc0cf75e86ffd7b2128aeb730786d976ae73"}]}