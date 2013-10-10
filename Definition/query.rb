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
      <title>#{CGI.escapeHTML(item[:title])}</title>
      <subtitle>#{CGI.escapeHTML(item[:subtitle])}</subtitle>
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
  if word !~ /^[\w\ ]+$/
    return []
  end

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
    :subtitle => "View definition in Youdao", :icon => "youdao"}]
end

def check_merriam_webster word
  encoded_word = URI::encode(word)
  [{:arg => "http://www.merriam-webster.com/dictionary/#{encoded_word}", :title => "Merriam-Webster",
    :subtitle => "View definition in Merriam-Webster", :icon => "mw"}]
end

def check_urban_dictionary word
  encoded_word = URI::encode(word)
  [{:arg => "http://www.urbandictionary.com/define.php?term=#{encoded_word}", :title => "Urban Dictionary",
    :subtitle => "View definition in Urban Dictionary", :icon => "ud"}]
end

def check_longman word
  encoded_word = URI::encode(word)
  [{:arg => "http://www.ldoceonline.com/dictionary/#{encoded_word}", :title => "Longman",
    :subtitle => "View definition in Longman", :icon => "lm"}]
end

word = ARGV[0].strip

if word && word.empty?
  alfred_xml(no_definition_found)
else
  definitions = check_shanbay(word) +
    check_youdao(word) +
    check_merriam_webster(word) +
    check_urban_dictionary(word) +
    check_longman(word)
  alfred_xml(definitions)
end
