pkg_name, anchor = ARGV[0].split(".", 2)
`open http://golang.org/pkg/#{pkg_name}/#{anchor && "##{anchor}"}`
