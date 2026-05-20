# AGENTS.md

このリポジトリは iOS App `Testy` と Linux CUI target `TestyOnLinux` の開発・レビュー用です。
Codex または自動レビュー agent は、以下の方針に従って作業してください。

## 基本方針

- レビューでは、iOS App のビルド、Linux Static SDK クロスビルド、`blocks` 連携、`overlayNetwork` 経由の通信、UI 変更、CI 失敗、テスト不足を優先して確認する。
- 変更を求められていないレビューでは、ファイル編集、コミット、push、merge、tag 作成、release 作成をしない。
- 指摘は、対象ファイル、行番号、重要度、理由、可能なら修正案を含める。
- 推測だけで断定しない。ローカル確認または GitHub Actions のログに基づいて説明する。
- iOS は `Testy.xcodeproj`、Linux は `Package.swift` を入口として扱う。

## 実行してよい主な確認コマンド

読み取り系:

```sh
git status --short --branch
git diff
git diff --stat
git log --oneline --decorate -n 20
git show --stat
rg <pattern>
rg --files
sed -n '1,220p' <file>
```

iOS build:

```sh
xcodebuild -project Testy.xcodeproj -scheme Testy -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

Swift Package / Linux:

```sh
swift --version
swift package resolve
swift build -v
swift test -v
swift sdk list
swift build -v --swift-sdk x86_64-swift-linux-musl --build-path .build/linux-musl
```

macOS 上で Swift 6.1.2 toolchain を明示して使う必要がある場合:

```sh
TOOLCHAINS=org.swift.612202505261a swift build -v --swift-sdk x86_64-swift-linux-musl --build-path .build/linux-musl
```

GitHub / pull request 確認:

```sh
gh pr view
gh pr diff
gh pr checks
gh run list --branch <branch> --limit 5
gh run view <run-id>
gh run view <run-id> --log
```

CI 設定の構文確認:

```sh
ruby -e 'require "yaml"; YAML.load_file(".github/workflows/ci.yml"); puts "YAML OK"'
```

## 条件付きで実行してよい操作

- ユーザーが明示的に依頼した場合のみ、ファイル編集、コミット、push、PR 作成を行う。
- `gh pr create`、`gh pr comment`、`gh pr review` は、ユーザーの依頼または自動レビューの目的に必要な場合のみ使う。
- 依存関係や toolchain のインストールは、CI の再現やユーザーの依頼に必要な場合に限る。
- CI では `Testy`、`blocks`、`overlayNetwork` を兄弟ディレクトリに checkout する。
- `SharedDesignSystem` は現時点で GitHub remote がないローカル兄弟 package なので、CI では `.github/ci/SharedDesignSystem` を `../SharedDesignSystem` として配置する。

## してはならない操作

- ユーザーの明示的な許可なしに、以下を実行しない。

```sh
git reset --hard
git clean -fdx
git checkout -- <file>
git push --force
git push --force-with-lease
gh pr merge
gh release create
gh auth login
gh auth token
rm -rf
```

- secret、token、署名鍵、認証情報を表示、保存、ログ出力しない。
- `.git` の履歴を書き換える操作を、レビュー目的だけで行わない。
- CI で `/Users/yoichi/appOutput/Testy` のような個人環境の絶対パスを使わない。CI では `.build/linux-musl` を使う。
- Linux 検証を `swift:5.8` などの Linux container native build で代替しない。Static Linux SDK クロスビルドを優先する。
- 失敗した CI を `continue-on-error` で隠して成功扱いにしない。

## レビュー時の重点

- iOS UI 変更では SwiftUI view、navigation、権限、通知、入力検証を確認する。
- Linux target では `Sources/Testy/iOS` が除外され、CUI/domain 側だけでビルドできることを確認する。
- `blocks` と `overlayNetwork` の API 変更が `Testy` 側に波及していないか確認する。
- `#if os(...)`、Darwin、Glibc、Musl、POSIX API の型差分を確認する。
- public API 変更がある場合は、README、tests、CI の更新漏れを確認する。

## 推奨する報告形式

レビュー結果は次の順で報告する。

1. 重要な問題点
2. 根拠となるファイル・行・ログ
3. 修正案
4. 実行した確認コマンド
5. 残っているリスク

問題が見つからない場合も、その旨と確認した範囲を明記する。
