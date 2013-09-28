require File.expand_path('../apis.rb', __FILE__)

MAX_COUNT = 20
query = ARGV[0].downcase
query = /#{ARGV[0].gsub("*", ".*?")}/i if query.include?("*")
matched_apis = APIS.find_all{|api| api[0].downcase.index query}
matched_apis += APIS.find_all{|api| api[1].downcase.index query} if matched_apis.count < MAX_COUNT
matched_apis.uniq!

matched_apis = matched_apis.sort do |a, b|
  ia = a[0].index(query)
  ib = b[0].index(query)

  if ia.nil? || ib.nil?
    ia.nil? ? 1 : -1
  else
    index = ia && ib ? ia <=> ib : 0
    index != 0 ? index : (a[0] <=> b[0])
  end
end[0...MAX_COUNT]

items = ""
matched_apis.each_with_index do |api, i|
  # net/http/httptest => net/http/
  pkg_parent = (api[1].split(": ").first.split("/")[0...-1] + [""]).join("/")
  items << <<-XML
  <item uid="#{i}" arg="#{pkg_parent}#{api[0]}" valid="yes">
    <title>#{api[0]}</title>
    <subtitle>#{api[1]}</subtitle>
    <icon type="">./icon.png</icon>
  </item>
  XML
end

puts <<-XML
<?xml version="1.0"?>
<items>
  #{items}
</items>
XML
