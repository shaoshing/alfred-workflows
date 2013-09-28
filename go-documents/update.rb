

unless go_root = ENV["GOROOT"]
  puts "the $GOROOT env must be ste."
  exit
end

go_api_path = "#{go_root}/api/go1.txt"
unless api_text = File.read(go_api_path) rescue nil
  puts "could not read Go api from path: #{go_api_path}"
  exit
end

apis = {}
for definition in api_text.lines do
  # ignore api definitions similar to below:
  #   pkg archive/tar, type Header struct, Devmajor int64
  #   pkg go/ast, type Decl interface, End() token.Pos
  #   pkg go/build, var Default Context
  #   pkg syscall (windows-amd64), const SW_RESTORE ideal-int
  next if definition =~ /(.+\,.+(struct|interface)[\,|\:].+)|(syscall.+const )/

  definition = definition.          #=> pkg log/syslog (darwin-386), const LOG_ALERT Priority
                gsub("pkg ", "").   #=> log/syslog (darwin-386), const LOG_ALERT Priority
                gsub(", ", ": ").   #=> log/syslog (darwin-386): const LOG_ALERT Priority
                gsub(/ \([\w\-]+\)\:/, ":"). #=> log/syslog: const LOG_ALERT Priority
                strip

  name = definition.          #=> log/syslog: const LOG_ALERT Priority
          gsub(/^.+\//, "").  #=> syslog: const LOG_ALERT Priority
          gsub(": ", ".").    #=> syslog.const LOG_ALERT Priority
          gsub(/(const|func|method|type|var) /, ""). #=> syslog.LOG_ALERT *Priority
          gsub(/ \*?[\w\-]+?$/, ""). #=> syslog.LOG_ALERT
          # tar.(*Reader) Next() (*Header.error) => tar.Reader.Next
          gsub(/\.\(\*?/, ".").gsub(/\) /, ".").gsub(/ *\(.*$/, "").gsub(/ interface.+/, "")


  if name =~ /\.$/
    puts "Malformed name: #{name}"
  end

  pkg_name = name.split(".").first
  unless apis[name]
    pkg = definition.split(":").first
    apis[pkg_name] = "#{pkg}: import \\\"#{pkg}\\\""
  end

  apis[name] = definition
end

ruby_apis = <<-RUBY
APIS = [
#{apis.to_a.map{|a| "  [\"#{a[0]}\", \"#{a[1]}\"]"}.join(", \n")}
]

RUBY

File.write("apis.rb", ruby_apis)
