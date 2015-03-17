require 'hubberlyzer'
require 'erb'

# Fetch information
hubberlyzer = Hubberlyzer::Profiler.new
links = hubberlyzer.githubber_links("https://github.com/about/team")

if links.length == 0
	puts "Error! Failed to fetch any links."
	return
end

info = hubberlyzer.fetch_profile_pages(links)

root_path = File.expand_path("../../views", __FILE__)
                 
head = File.read(File.join(root_path, "_head.html"))
footer = File.read(File.join(root_path, "_footer.html"))
navbar = File.read(File.join(root_path, "_navbar.html"))

# index.html.erb file location
index = File.join(File.expand_path("../../views", __FILE__), "index.html.erb")

output = File.join(File.expand_path("../../", __FILE__), "index.html")

template = ERB.new(File.read(index))

html_content = template.result(binding)

File.open(output, "w") do |file|
  file.puts html_content
end