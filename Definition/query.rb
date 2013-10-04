require 'open-uri'
require 'json'
require 'CGI'

def no_definition_found
  {:arg => "No definitions found", :title => "", :subtitle => ""}
end

def alfred_xml items
  items_xml = ""
  items.each_with_index do |item, index|
    items_xml << <<-XML
    <item uid="#{index}" arg="#{item[:arg]}">
      <title>#{item[:title]}</title>
      <subtitle>#{item[:subtitle]}</subtitle>
      <icon type="">./#{item[:icon]}.png</icon>
    </item>
    XML
  end

  puts <<-XML
  <items>
    #{items_xml}
  </items>
  XML
end

def check_shanbay word
  encoded_word = URI::encode(word)

  shanbay_query = open("http://www.shanbay.com/api/v1/bdc/search/?word=#{encoded_word}").read
  shanbay_json = JSON.parse(shanbay_query)
  if shanbay_json["status_code"] == 1
    return []
  end

  pronunciation = CGI.unescapeHTML(shanbay_json["data"]["pron"])
  zh_definition = shanbay_json["data"]["definition"]
  en_definition = shanbay_json["data"]["en_definitions"].values.join(", ")

  [
    {:arg => "http://www.shanbay.com/api/learning/add/#{encoded_word}",
    :title => pronunciation, :subtitle => zh_definition, :icon => "shanbay"},
    {:arg => "http://www.shanbay.com/api/learning/add/#{encoded_word}",
    :title => "EN definition", :subtitle => en_definition, :icon => "shanbay"}
  ]
end

def check_youdao word
  encoded_word = URI::encode(word)
  [{:arg => "http://dict.youdao.com/search?q=#{encoded_word}", :title => "Youdao",
    :subtitle => "Get definition in Youdao", :icon => "youdao"}]
end


word = ARGV[0].strip

if word && word.empty?
  alfred_xml(no_definition_found)
else
  definitions = check_shanbay(word) + check_youdao(word)
  alfred_xml(definitions)
end
