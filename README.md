# Translucent Image viewer

画像を半透明にして表示します. 要 `macOS High Sierra以降`.

<a href="https://github.com/syam8192/TranslucentImage/releases/download/1.2.1%2Balpha/TranslucentImage_1_2_1_alpha.zip">ダウンロード - v1.2.1+alpha</a>

- 最初に開いたウインドウに画像ファイルをドロップすると、その画像を表示します
- 以後も、画像ファイルをドロップすると、その画像に切り替わります
- `Window＞Capture`を選択するか、`[Command]+[C]`でキャプチャモードになります
  - <strong>本アプリのウインドウがある画面</strong>がやや暗くなり、マウスのドラッグで選択した領域をキャプチャして設定します
  - macの`システム環境設定＞セキュリティとプライバシー＞画面収録`でTranslucentImageにチェックしてください<br>さもないとウインドウの下の壁紙をキャプチャします。
  - `[Esc]`またはマウスの右クリックで中止します
  - 現状、マルチモニタ環境ではプライマリモニタでしか正常に動きません..
- マウスの`ホイール`で、透明度を変更します
- `[control]`+マウスの`ホイール`で、表示倍率を変更します
- キーボードの`カーソルキー`で、ウインドウ位置を 1 px ずつ移動します
- キーボードの`[shift]+カーソルキー`で、ウインドウ位置を 8 px ずつ移動します
- `[option]`キーを押している間、差分表示に切り替わります（差が色として表示され、一致するピクセルは黒になります）
- `Window＞Always On Top`をチェックすると、このウインドウを常に手前に表示します
- ウインドウを閉じると、本アプリケーションは終了します


サンプル
<img src="https://user-images.githubusercontent.com/1811412/105612491-df570d80-5dff-11eb-84a7-ae0230a6ab18.gif"/>
