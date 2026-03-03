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

# gv_sound = SDL2::Mixer::Chunk.load('gameover.mp3') # 全然 .wavにする

# sound = SDL2::Mixer::Chunk.load('bgm.mp3') # 全然 .wavにする

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
  return unless id

  # id 0,1,2 はそれぞれ固有の音・チャンネルで鳴らす
  case id.to_i
  when 0
    chunk   = ($long_sound[0] rescue nil) || ($short_sound[0] rescue nil)
    channel = 1
  when 1
    chunk   = ($long_sound[1] rescue nil) || ($short_sound[1] rescue nil)
    channel = 2
  when 2
    chunk   = ($long_sound[2] rescue nil) || ($short_sound[2] rescue nil)
    channel = 3
  else
    chunk   = ($long_sound[id] rescue nil) || ($short_sound[id] rescue nil) || $short_sound.sample
    channel = id.to_i
  end

  if chunk && !SDL2::Mixer::Channels.play?(channel)
    SDL2::Mixer::Channels.play(channel, chunk, 0)
  end

  # 補助音（短い音）を別チャネルでランダムに鳴らす
  if $short_sound && $short_sound.any?
    sid = rand($short_sound.length)
    s_chunk = $short_sound[sid]
    s_channel = 20 + sid
    if s_chunk && !SDL2::Mixer::Channels.play?(s_channel)
      SDL2::Mixer::Channels.play(s_channel, s_chunk, 0)
      SDL2::Mixer::Channels.set_volume(s_channel, 30)
    end
  end
end

sound = SDL2::Mixer::Chunk.load('bgm.wav') rescue nil

gv_sound = SDL2::Mixer::Chunk.load('gameover1.wav') rescue nil

# バックグラウンドBGM
def play_BGM(sound)
  unless SDL2::Mixer::Channels.play?(100) then
    SDL2::Mixer::Channels.play(100, sound, 0) #BGM
  end
end

def play_sound_gameover(gv_sound)
  unless SDL2::Mixer::Channels.play?(50) then
    SDL2::Mixer::Channels.play(100, gv_sound, 0) #長い音
  end
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

# マーカー自体の高さの検出
def marker_height(corners)
  #  上側のY座標の平均（y1とy2）
  y_top = (corners[1] + corners[3]) / 2.0
  # 下側のY座標の平均 (y3とy4)
  y_bottom = (corners[5] + corners[7]) / 2.0
  # 上側と下側のY座標の差 (絶対値) が高さになる
  total_height = (y_bottom - y_top).abs
  return total_height
end

# ジェンガの段数を求める関数
def jenga_step(height, marker_height)
  return 0 if marker_height == 0
  (height / marker_height).round
end



my_dict = {}
prev_step = 0

# 1000回ループ
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

    # cをnew_dict[id]についた
    new_dict[id] << c
    puts "ID: #{id} corners: #{corners.inspect} center: #{c.inspect}"
  end

  count = 0
  
  # ジェンガの段数を計算
  low = -1
  high = 100000
  avg_marker_height = 0
  marker_count = 0
  
  new_dict.each do |key, value|
    value.each do |c|
      c_y = c[1]
      if low < c_y
        low = c_y
      end
      if high > c_y 
        high = c_y
      end
    end
  end
  
  # マーカーの高さの平均を計算
  markers.each do |marker|
    corners = marker[1..8]
    mh = marker_height(corners)
    avg_marker_height += mh
    marker_count += 1
  end
  
  avg_marker_height = avg_marker_height / marker_count if marker_count > 0
  
  total_height = (low - high).abs
  current_step = jenga_step(total_height, avg_marker_height)
  
  puts "Total Height: #{total_height}, Avg Marker Height: #{avg_marker_height}, Current Step: #{current_step}, Prev Step: #{prev_step}"
  
  # 段数が減ったら、ジェンガが崩れたと判定
  if prev_step > 0 && current_step < prev_step
    count = 2  # ジェンガが崩れた
  end

  puts ("count: #{count}")
  if count >= 1
    play_BGM(sound)
    SDL2::Mixer::Channels.set_volume(100, 30) # BGMの音量を下げる
  end
  if count >= 2
    play_sound_gameover(gv_sound) # ジェンガが崩れたときに、gameover音を鳴らす
    SDL2::Mixer::Channels.set_volume(50, 200) # gameover音の音量を上げる

    loop do
    end
  end

  my_dict = new_dict
  prev_step = current_step
  ArucoDetector.wait(200)
end

  # # ジェンガの高さを求める
  # low = -1
  # high = 100000
  # new_dict.each do |key,value|
  #   value.each do |c|
      
  #     c_y = c[1]
  #     if low < c_y
  #       low = c_y
  #     end
  #     if high > c_y 
  #       high = c_y
  #     end
  #   end
  # end

    # steps = (high - low) / 

    #   # ジェンガの段数が高くなるほどに、曲をハラハラさせる（曲自体を変えるか、ピッチを変えるかは検討中）
    #   if steps > 12 # 数値は仮
    #     play_alert_sound(chunk)
    #   elsif steps > 14
    #     play_alert_sound(chunk1)
    #   else
    #     play_BGM(sound)
    #   end




$long_sound.each do |chunk|
  chunk.destroy
end
$short_sound.each do |chunk|
  chunk.destroy
end  

SDL2::Mixer.quit
SDL2.quit
puts "Program finished. Resources cleaned up."



# マーカー一個の高さを」取ることによって、一個の高さと、low,higtの高さによって、何段かがわかる

#　marker_heightがマーカーの高さ　
# jenga_height = height(low,higt) // marker_height(corners)
