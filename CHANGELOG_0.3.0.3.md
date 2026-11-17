# RivalsMacro 0.3.0.3

## 修正
- `BackdropService.cs` に `using Microsoft.UI.Composition.SystemBackdrops;` を追加。
- `MicaKind.BaseAlt` を正しい名前空間から参照するよう修正。
- App / Core の Version、AssemblyVersion、FileVersion を `0.3.0.3` に更新。
- 画面上のバージョン表示、起動ログ、README、開始ガイドを更新。

## 補足
- 0.3.0.2 までの修正（ThemeManager の Color 参照、NavigationView の背景指定、InfoBarSeverity）は引き継いでいます。
- Windows 上での Visual Studio 実ビルドはこの作業環境では実行していません。Visual Studio でクリーン後にリビルドして確認してください。
