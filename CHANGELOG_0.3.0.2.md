# RivalsMacro 0.3.0.2

## 修正
- `ThemeManager.cs` に `using Color = Windows.UI.Color;` を追加し、`Color` 型が解決できない CS0246 を修正。
- アプリ／Core の Version、AssemblyVersion、FileVersion と画面上のバージョン表記を 0.3.0.2 に更新。

## 補足
- `RivalsMacro.Core` のDLL参照エラーは、アプリ側のコンパイル失敗に伴う連鎖エラーと考えられます。まず本修正後にソリューションをリビルドして確認してください。
- この環境では Windows / .NET 10 / Windows App SDK の実ビルドは実行できていません。
