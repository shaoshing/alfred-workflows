query = ARGV[0].to_s
user, host = query.include?("@") ? ARGV[0].to_s.downcase.split("@") : [nil, query]
host, params = host.to_s.split(" ", 2)

ssh_configs = []
File.read("#{ENV["HOME"]}/.ssh/config").split("Host ")[1..-1].each do |config|
  hostname_config = config.match(/^HostName (.+)$/)
  user_config = config.match(/^User (.+)$/)
  next unless hostname_config
  ssh_configs << {
    :host => config.lines.to_a[0].strip,
    :hostname => hostname_config[1],
    :user => user_config ? user_config[1] : "root"
  }
end

if user
  ssh_configs.reject! do |config|
    !config[:user].downcase.include?(user)
  end
end

if host
  ssh_configs.reject! do |config|
    !config[:host].downcase.include?(host) && !config[:hostname].downcase.include?(host)
  end
end


items = ""
ssh_configs.each_with_index do |config, index|
  ssh = "#{config[:user]}@#{config[:host]}"

  items << <<-XML
  <item uid="#{index}" arg="#{ssh}">
    <title>#{ssh}</title>
    <subtitle>#{config[:hostname]}</subtitle>
    <icon type="">./icon.png</icon>
  </item>
  XML
end

puts <<-XML
<items>
  #{items}
</items>
XML
