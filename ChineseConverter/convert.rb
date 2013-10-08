# encoding: UTF-8
load File.expand_path(__FILE__ + "/../tradsim.rb")

def alfred_xml items
  items_xml = ""
  items.each_with_index do |item, index|
    items_xml << <<-XML
    <item uid="#{index}" arg="#{item[:arg]}">
      <title>#{item[:title]}</title>
      <subtitle>#{item[:subtitle]}</subtitle>
      <icon type="">./icon.png</icon>
    </item>
    XML
  end

  puts <<-XML
  <items>
    #{items_xml}
  </items>
  XML
end

items = []
text = ARGV[0].strip.force_encoding "UTF-8"
if !text.empty?
  convertedText = Tradsim.toggle(text)
  isTheSame = text == convertedText ? "same text" : "text changed"
  items << {:arg => convertedText, :title => convertedText, :subtitle => isTheSame}
end
alfred_xml(items)
