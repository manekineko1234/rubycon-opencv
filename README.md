# play jenga music

音のなるジェンガで遊ぶ

# 動作環境

windows 11

# Ruby install

* [Rubyinstaller](https://rubyinstaller.org/downloads/)(最新Verを入れる&Devkit付き　私はRuby3.4.5-1を使用)
* Only User を選択してNext
* MSY32のチェックボックスをクリック　→　install
* 最後のチェックボックスをクリック
* [1,3] になっていることを確認して　ENTER
* start command pronmpt with ruby を起動


start command prompt with ruby で実行

    ridk exec pacman -S mingw-w64-ucrt-x86_64-opencv mingw-w64-ucrt-x86_64-qt6-base
    
もし通らなかった場合は

    pacmen -Syuu
    ridk exec pacman -Suu mingw-w64-ucrt-x86_64-opencv mingw-w64-ucrt-x86_64-qt6-base

vscode等でリポジトリをクローンし、以下のディレクトリに移動

ext/opencv_aruco_detector

    ridk exec ruby extconf.rb
    ridk exec make

ビルド完了

# SDL2 install

以下のURL参照（https://packages.msys2.org/packages/mingw-w64-ucrt-x86_64-SDL2）

    pacman -S mingw-w64-ucrt-x86_64-SDL2
    pacman -S mingw-w64-ucrt-x86_64-SDL2_image
    pacman -S mingw-w64-ucrt-x86_64-SDL2_mixer
    pacman -S mingw-w64-ucrt-x86_64-SDL2_ttf

ruby-sdl2のインストール

    gem install ruby-sdl2

# 実行

ルートに戻って

    ridk exec ruby main.rb

実行される
