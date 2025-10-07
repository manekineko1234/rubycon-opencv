# play jenga music

音のなるジェンガで遊ぶ

# 動作環境

windows 11

# install

* Rubyinstallerで最新VerのRubyを入れる（devkit付き)
* [Rubyinstaller](https://rubyinstaller.org/downloads/)(最新Verを入れる)
* only users いれる
* MSY32のチェックボックスをクリック　→　install
* 最後のチェックボックスをクリック
* start command pronmpt with ruby を起動
* [1,3] 担っていることを確認して　ENTER

[1,3]ENTERの後の手順：

    ridk exec pacman -S mingw-w64-ucrt-x86_64-opencv mingw-w64-ucrt-x86_64-qt6-base
    
もし通らなかった場合は：

    pacmen -Syuu
    ridk exec pacman -Suu mingw-w64-ucrt-x86_64-opencv mingw-w64-ucrt-x86_64-qt6-base
ext/opencv_aruco_detector

    ridk exec ruby extconf.rb
    ridk exec make

ビルド完了

ルートに戻って

    ridk exec ruby main.rb

実行される
