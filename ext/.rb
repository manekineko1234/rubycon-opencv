require_relative "./ext/opencv_aruco_detector/opencv_aruco_detector.so"
require "sdl2"

ok = ArucoDetector.open()
if  !ok
  puts "カメラのオープンに失敗しました。"
  exit 1
end

SDL2.init(SDL2::INIT_AUDIO)
SDL2::Mixer.init(SDL2::Mixer::INIT_FLAC | SDL2::Mixer::INIT_MP3 | SDL2::Mixer::INIT_OGG)
SDL2::Mixer.open
SDL2::Mixer::Channels.allocate(200)

$long_sound = [
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_1do.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_2re.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_3mi.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_4fa.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_5so.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_6ra.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_7si.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano1_8do.wav')
]

$short_sound = [
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_1do.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_2re.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_3mi.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_4fa.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_5so.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_6ra.wav'),
  SDL2::Mixer::Chunk.load('maou_se_inst_piano2_7si.wav')
]



# IDが動いたら音を鳴らす関数
def play_alert_sound(id)
  # チャンネル, 音 , 再生回数 (1回のみ再生)
  unless SDL2::Mixer::Channels.play?(id) then
    SDL2::Mixer::Channels.play(id, $long_sound[id], 0) #長い音
  end
  short_id = rand($short_sound.length)
  SDL2::Mixer::Channels.play(20+short_id, $short_sound[short_id], 0) #単発
  SDL2::Mixer::Channels.set_volume(20+short_id, 30)
end

# 音を楽しむ場所
# for i in 1..100
#   play_alert_sound(0)
#   sleep(0.3)
# end


# 4点の座標から中心点を計算する関数
def center(corners)
  # corners[0],[1],[2],[3]...で計算する　一次元配列でデータを取ってきている
  x = (corners[0] + corners[2] + corners[4] + corners[6]) / 4.0
  y = (corners[1] + corners[3] + corners[5] + corners[7]) / 4.0
  [x, y]
end


# 2点間の距離を計算する関数
def distance(a,b)
  x = a[0] - b[0]
  y = a[1] - b[1]
 result = Math.sqrt(x**2 + y**2)
  return result
end

# 高さの検出
def height(corners)
  height_y = (corners[5] + corners[7])
  return height_y
end
my_dict = {}


# 100回ループ
1000.times do
  markers = ArucoDetector.get() #[[id,x1,y1...]]
  new_dict = {}

  markers.each do |marker|
    id = marker[0]
    corners = marker[1..8]
    c = center(corners)

    next unless c # データが不完全ならスキップ

    # new_dictにIDのキーがなければ、空の配列を初期値として設定
    unless new_dict.key?(id)
      new_dict[id] = []
    end

    # 中心座標 c ([x, y]) をリストに追加
    new_dict[id] << c
    puts "ID: #{id} corners: #{corners.inspect} center: #{c.inspect}"
  end
    # 前回のmy_dictと比較
  my_dict.each_key do |id|
    # new_dictにidがないなら次のループへスキップ
    next unless new_dict.key?(id)

    old_markers = my_dict[id]
    new_markers = new_dict[id]

    # 配列の長さを比較し、短い方を short、長い方を long
    if old_markers.length < new_markers.length
      short = old_markers
      long  = new_markers
    else
      short = new_markers
      long  = old_markers
    end

    min = 100000000000
    short.each do |mbase|
      long.each do |mdis|
        dis = distance(mbase,mdis)
        if dis < min
          min = dis
        end
      end
    end

    puts min
    if min > 10
      play_alert_sound(id) # IDにしておけばIDとの紐づけを行うことで、IDごとに音を」鳴らすことができる
    end
  end

  my_dict = new_dict
  ArucoDetector.wait(100)
end


$long_sound.each do |chunk|
  chunk.destroy
end
$short_sound.each do |chunk|
  chunk.destroy
end 

SDL2::Mixer.quit
SDL2.quit
puts "Program finished. Resources cleaned up."
