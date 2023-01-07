# frozen_string_literal: true
require 'debug'
require "faraday"
require "json"
require "down"

# album_json
is_error = ->(j) { j[:ret] != 200 }
has_next_page = ->(j) { j[:data][:pageNum] * j[:data][:pageSize] <= j[:data][:trackTotalCount]  }
tracks = ->(j) { j[:data][:tracks] }

# tracks
index_title_id = ->(tracks) { tracks.map { [_1[:index], _1[:title], _1[:trackId]] } }

# audio
src = ->(aj) { aj[:data][:src] }

download = ->(index, title, id) {
  r = Faraday.get("https://www.ximalaya.com/revision/play/v1/audio", { id: id, ptype:1})
  audio_j = JSON.parse(r.body, symbolize_names: true)
  tempfile = Down.download( src.call(audio_j))
  File.extname(tempfile.path)
  FileUtils.mv(tempfile, "#{index.to_s.rjust(4, "0")}#{title}#{File.extname(tempfile.path)}")
}

#   r = Faraday.get("https://www.ximalaya.com/revision/play/v1/audio", { id: item[2], ptype:1})
#   audio_j = JSON.parse(r.body, symbolize_names: true)
#   tempfile = Down.download( src.call(audio_j))
#   File.extname(tempfile.path)
#   FileUtils.mv(tempfile, "#{item[0].to_s.rjust(4, "0")}#{item[1]}#{File.extname(tempfile.path)}")

# main
album_id = 4027997

album_url = "https://www.ximalaya.com/revision/album/v1/getTracksList"
page_num = 1


result = []
while true
  response = Faraday.get(album_url, {albumId: album_id, pageNum: page_num, pageSize: 30}, {'Accept' => 'application/json'})
  album_json = JSON.parse(response.body, symbolize_names: true)
  result = result + index_title_id.call(tracks.call(album_json))

  break if !has_next_page.call(album_json)
  
  page_num = page_num + 1
end

debugger
# index_title_id.call(tracks.call(album_json)).each do |item|
#   r = Faraday.get("https://www.ximalaya.com/revision/play/v1/audio", { id: item[2], ptype:1})
#   audio_j = JSON.parse(r.body, symbolize_names: true)
#   tempfile = Down.download( src.call(audio_j))
#   File.extname(tempfile.path)
#   FileUtils.mv(tempfile, "#{item[0].to_s.rjust(4, "0")}#{item[1]}#{File.extname(tempfile.path)}")
# end

#album_json[:data][:tracks][0][:albumId]
#audio_id = 4027997
#https://www.ximalaya.com/revision/play/v1/audio?id=14150492&ptype=1
#https://www.ximalaya.com/revision/play/v1/audio?id=14150493&ptype=1

