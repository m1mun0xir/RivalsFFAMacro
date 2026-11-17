# ビルド・テスト手順（v0.3.0.4）

## 今回の修正内容

`DiagnosticsPage.xaml` の `ListView` は `ObservableCollection<LogEntry>` を表示します。v0.3.0.3 の `LogEntry` は位置引数付き `record` だったため、`Time` / `Level` / `Message` が暗黙に `init` 専用プロパティになっていました。WinUI の XAML コンパイラが生成する `XamlTypeInfo.g.cs` は、XAML のオブジェクト情報からこれらのプロパティに setter 経由で値を設定しようとするため、CS8852 が発生します。

今回の回帰テストでは、このファイルをテストプロジェクトにリンクしているため、アプリが使う同一ソースに対してテスト側からプロパティ代入をコンパイルします。さらにreflectionでinit-onlyを示す `IsExternalInit` required modifier が付いていないことも検査します。

v0.3.0.4 では `LogEntry` を通常の `sealed class` に変更し、以下を追加しています。

- public parameterless constructor
- `Time`, `Level`, `Message` の public `get; set;`
- 既存コード互換の3引数constructor
- 従来と同じ `ToString()` 形式

## 推奨チェック

プロジェクトルートで PowerShell を開き、次を実行してください。

```powershell
.\verify-project.ps1
.\test-core.ps1
.\build.ps1
```

`build.ps1` は次の順に動きます。

1. すべてのXAMLが正しいXMLであることを確認
2. `x:Class` と code-behind、イベントハンドラーの対応を確認
3. XAMLに公開する `LogEntry` が引数なしconstructorと書き込み可能なpropertyを持つことを確認
4. `LogEntry.cs` の実ソースをテストプロジェクトにもコンパイルし、テストコードから3プロパティを代入（`init` に戻すとコンパイルエラーになる）
5. Reflectionで3プロパティのsetterに `IsExternalInit` が付いていないことも確認
6. CLOCK A/B・フェーズ管理・OCR撮影時刻の回帰テストを実行
7. 最後にWinUIアプリを含むソリューション全体を `Debug x64` でビルド

## Visual Studioから個別に実行する場合

- `RivalsMacro.sln` を開く
- `RivalsMacro.App` をスタートアッププロジェクトにする
- `Debug` / `x64` を選択
- `ビルド > ソリューションのクリーン`
- `ビルド > ソリューションのリビルド`
- 成功したら `F5`

XAMLの生成ファイルは `obj` にキャッシュされます。更新後も古い生成コードのエラーが残る場合は、Visual Studioを閉じて各プロジェクトの `bin` と `obj` を削除してから `build.ps1` を実行してください。

## この環境で未実行の検証

この作業環境には `dotnet` CLI / Windows App SDK / WinUI XAML compiler がありません。そのため、ここではWindows実機の最終ビルド成功を保証できません。ソース検証とテストコードの追加までを行い、実際のアプリビルドはWindows PC上で `build.ps1` を実行して確認します。
