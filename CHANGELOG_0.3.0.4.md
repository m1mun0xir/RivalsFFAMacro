# RivalsMacro 0.3.0.4

## Fixed
- Replaced the XAML-bound `LogEntry` positional record with a mutable class.
- Added a public parameterless constructor for WinUI runtime activation.
- Changed `Time`, `Level`, and `Message` to public `get; set;` properties so generated `XamlTypeInfo.g.cs` accessors can assign values without CS8852.
- Added compile-time regression tests that compile the exact `LogEntry.cs` source used by the app and assign all three properties.
- Expanded core phase/clock regression coverage to 28 cases, including OCR capture-latency projection and reflection verification that XAML-bound setters are not init-only.
- Added `verify-project.ps1` to validate XAML well-formedness, code-behind event handlers, project references, version consistency, and known WinUI regressions before build.
- Updated `build.ps1` to run source validation and regression tests before building the full solution.

## Notes
- This package has not been built with the Windows/.NET/WinUI SDK in this environment. Run `build.ps1` on the Windows development PC to perform the actual XAML compilation and app build.
