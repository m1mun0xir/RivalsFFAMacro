# RivalsMacro 0.3.0.4 — C# / WinUI 3 Edition

> **0.3.0.3 修正:** `BackdropService.cs` に `Microsoft.UI.Composition.SystemBackdrops` の using を追加し、`MicaKind` を正しい名前空間から参照するよう修正しました。

> **0.3.0.2 修正:** `ThemeManager.cs` で WinUI 3 の `Color` 構造体を正しい `Windows.UI.Color` として明示的に参照するよう変更しました。

> **0.3.0.2 修正:** WinUI 3 の `NavigationView.PaneBackground` を削除し、ペイン背景をテーマリソースで設定する方式に変更。`InfoBar.Severity` は `Info` ではなく `Informational` を使用します。

RivalsMacro の新しい C# 開発ラインです。0.3.0.4 は **新しいアプリ基盤・UI・タイマーコアの移植開始版** です。1.0.0.0 の完成版ではありません。

> **0.3.0.4 修正:** XAMLデータバインディングで使用する `LogEntry` を `init` 専用の位置引数付きrecordから、引数なしコンストラクターと公開setterを持つ通常クラスに変更。生成される `XamlTypeInfo.g.cs` の CS8852 を防止するコンパイル時回帰テストを追加。XAML/code-behind/イベント/プロジェクト参照の事前検査も追加。

## この版に含まれるもの

- C# / .NET 10 / WinUI 3 の新規ソリューション
- Windows App SDK 2.6.5（2026-11-10 時点の Microsoft Learn 記載の最新安定版）
- Mica を基本にした Dark Glass 系メインウィンドウ
- Dark Glass / Minimal Dark / Cyber Gaming の3テーマ
- Blue / Purple / Cyan / Green の4アクセントカラー
- メイン画面とHUDの外観設定を分離する設定モデル
- 別ウィンドウの HUD プレビュー
- CLOCK A（基準時計）/ CLOCK B（補正表示時計）のコアロジック
- キャプチャ時刻を使う OCR 測定値インターフェース
- 大きな差の2回確認、小さな差の段階補正、速度推定のコアロジック
- FFA 状態遷移の初期モデル
- JSON 設定保存、ログ基盤、コアスモークテスト（LogEntry XAML setter回帰検査を含む28ケース）

## まだ含まれないもの

この版は開発ラインの切り替えと基礎実装です。以下は次の開発段階です。

- Windows Graphics Capture の実キャプチャアダプター
- Tesseract / OpenCV の実OCRアダプターと画面ROI自動検出
- グローバルホットキーの実登録
- 実際のマウス・キーボード入力アダプター
- 武器座標キャリブレーションの実画面ピッカー
- FFAの長時間実機テストと同期パラメータ調整
- MSIX / インストーラーの正式な署名・配布パッケージ

UIにある一部のボタンは、現時点ではプレビューまたは準備中表示です。ゲーム内の操作が実行されると誤解させないよう、未接続の機能は明示しています。

## 開発環境

推奨:

- Windows 11
- Visual Studio 2026 の **WinUI application development** ワークロード
- .NET 10 SDK
- Windows App SDK 2.6.5 Runtime（このプロジェクトは unpackaged / framework-dependent）

Microsoft の現行ガイドでは、WinUI 3 の新規開発に .NET 10 SDK と Visual Studio 2026 / WinUI application development ワークロードが案内されています。

## 起動

1. ZIPをWindows PCで展開。
2. Visual Studio 2026で `src/RivalsMacro.sln` を開く。
3. `RivalsMacro.App` をスタートアッププロジェクトにする。
4. プラットフォームを `x64` にして F5。

または、.NET 10 SDK と Windows App SDK Runtime がセットアップ済みなら、プロジェクトルートで `run.bat` を実行します。

```powershell
./verify-project.ps1  # XAML・code-behind・既知のコンパイル契約を検査
./test-core.ps1       # Core + LogEntry regression tests
./build.ps1           # 検査 → テスト → ソリューション全体をビルド
./run.ps1
```

初回は NuGet パッケージの復元が必要なため、インターネット接続が必要です。

## 設計メモ

- CLOCK A は OCR で書き換えない基準時計。
- CLOCK B は OCR 測定値をキャプチャ時刻に投影して補正する表示時計。
- OCR処理完了時刻ではなく、フレーム取得時刻を同期基準にする。
- 0.2秒以下は小さな補正、0.2〜0.6秒は強めの緩やかな補正、0.6秒以上は複数回の整合確認後に再同期する初期値。
- 整数秒OCRでは表示量子化があるため、連続する短い2サンプルのみから時計速度を決めない。
- 実ゲームのタイマー表示方式・OCR遅延に対する数値は実機ログで調整する。

詳細な確認項目は `BUILD_AND_TESTS_JA.md` を参照してください。

## ライセンス

個人開発用の初期ソースです。第三者配布前に、依存ライブラリ・アイコン・署名・プライバシー表示・対象ゲームのルールを確認してください。
