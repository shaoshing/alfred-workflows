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

def query word
  definitions = []

  if word && word.empty?
    definitions << no_definition_found
    return definitions
  end

  shanbay_query = open("http://www.shanbay.com/api/v1/bdc/search/?word=#{word}").read
  shanbay_json = JSON.parse(shanbay_query)

  if shanbay_json["status_code"] == 1
    definitions << no_definition_found
    return definitions
  end

  pronunciation = CGI.unescapeHTML(shanbay_json["data"]["pron"])
  zh_definition = shanbay_json["data"]["definition"]
  en_definition = shanbay_json["data"]["en_definitions"].values.join(", ")

  definitions << {:arg => word, :title => pronunciation, :subtitle => zh_definition, :icon => "shanbay"}
  definitions << {:arg => word, :title => "EN definition", :subtitle => en_definition, :icon => "shanbay"}
  return definitions
end


word = ARGV[0].strip
alfred_xml(query(word))
