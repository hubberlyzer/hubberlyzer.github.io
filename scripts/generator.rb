require 'hubberlyzer'
require 'erb'
require 'json'

require_relative "sample_users.rb"

# profiler = Hubberlyzer::Profiler.new

# puts "Fetching profile links from team"
# links = profiler.githubber_links("https://github.com/orgs/github/people", 7)

# if links.length < 1
# 	puts "Error! Failed to fetch any links."
# 	return
# end

# puts "Fetching and parsing profile information"
# users = profiler.fetch_profile_pages(links)

# puts users.inspect

analyzer = Hubberlyzer::Analyzer.new(USERS)

lang_sum = analyzer.sum_by_language
lang_count = analyzer.top_language("count", 20)
lang_star = analyzer.top_language("star", 20)


# Load language colors
lang_colors = JSON.parse File.read(File.expand_path('../colors.json', __FILE__))

# Format the count data to the required structure for Pie chart
lang_count_pie = []
lang_count.each do |lang|
	color = lang_colors[lang[0]]
	next if color.nil?
	lang_count_pie << {"label" => lang[0], "value" => lang[1], "color" => color}
end
lang_count_pie = JSON.generate(lang_count_pie)


# Format the star count data for Bar chart
lang_star_bar = {}
lang_star_bar["labels"] = lang_star.map { |e| e[0] }
lang_star_bar["datasets"] = []
lang_star_bar["datasets"][0] = {
	label: "Stars Received",
	fillColor: "#FF9900",
  strokeColor: "#d8d8d8",
  highlightFill: "#CC6600",
  highlightStroke: "#d8d8d8",
  data: lang_star.map { |e| e[1] }
}
lang_star_bar = JSON.generate(lang_star_bar)

lang_count_hash = Hash[lang_count]
lang_star_ratio_bar = {}
lang_star_ratio_bar["labels"] = lang_star.map { |e| e[0] }
lang_star_ratio_bar["datasets"] = []
lang_star_ratio_bar["datasets"][0] = {
	label: "Stars Received",
	fillColor: "#4183c4",
  highlightFill: "#0033CC",
  data: lang_star.map { |e| (e[1].to_f/lang_sum[e[0]]["count"]).round(2) }
}


lang_star_ratio_bar["datasets"][1] = {
	label: "Repos Created",
	fillColor: "#333",
  data: Array.new(lang_star.length, 1)
}

lang_star_ratio_bar = JSON.generate(lang_star_ratio_bar)


js_path = File.expand_path("../../assets/js", __FILE__)

data_tpl = ERB.new(File.read("data.js.erb"))
html_content = data_tpl.result(binding)

File.open(File.join(js_path, "data.js"), "w") do |file|
  file.puts html_content
end


puts "Creating index page"
view_path = File.expand_path("../../views", __FILE__)
                 
head = File.read(File.join(view_path, "_head.html"))
footer = File.read(File.join(view_path, "_footer.html"))
navbar = File.read(File.join(view_path, "_navbar.html"))

# index.html.erb file location
index = File.join(File.expand_path("../../views", __FILE__), "index.html.erb")

output = File.join(File.expand_path("../../", __FILE__), "index.html")

template = ERB.new(File.read(index))

html_content = template.result(binding)

File.open(output, "w") do |file|
  file.puts html_content
end