require 'hubberlyzer'
require 'erb'
require 'json'

class Generator
  attr_accessor :lang_colors, :hubbers, :lang_star, :lang_count, :js_path, :root_path, :view_path

  def initialize
    # Load language colors
    @lang_colors = JSON.parse File.read(File.expand_path('../colors.json', __FILE__))
    @js_path = File.expand_path("../../assets/js", __FILE__)
    @root_path = File.expand_path("../../", __FILE__)
    @view_path = File.expand_path("../../views", __FILE__)
  end

  # url - the link to organization's people page (e.g. https://github.com/orgs/github/people)
  # max_page - maximum number of pages to fetch
  # output - the name of the renderred html file, default is "index.html"
  def run(url, max_page, output=nil, options={})
    puts "Fetching githubbers' profiles ..."
    get_hubbers(url, max_page, options)

    puts "Rendering html page ..."
    render_html(output)
  end

  # Use sample data from the file
  def run_sample
    require_relative "sample_users.rb"

    puts "Loading sample data ..."
    @hubbers = SAMPLE_USERS

    puts "Rendering index.html page ..."
    render_html
  end

  def get_hubbers(url, max_page, options={})
    profiler = Hubberlyzer::Profiler.new
    @hubbers = profiler.get_githubbers(url, max_page, options)
    @hubbers
  end

  # Creat the index html page, default is "index.html"
  def render_html(output_filename=nil)
    output_filename ||= "index.html"

    # generate the data
    top_used_languages    = get_top_used_languages(20)
    top_starred_languages = get_top_starred_languages(20)
    top_impact_languages  = get_top_impact_languages(20)
    top_star_memebers     = get_top_star_memebers(10)
    top_count_memebers    = get_top_count_memebers(10)

    head = File.read(File.join(view_path, "_head.html"))
    navbar = File.read(File.join(view_path, "_navbar.html"))
    index = File.join(view_path, "index.html.erb")
    output = File.join(File.expand_path("../../", __FILE__), output_filename)

    template = ERB.new(File.read(index))

    html_content = template.result(binding)

    File.open(output, "w") do |file|
      file.puts html_content
    end
  end
  
  # Pie chart for top used languages based on total count of repos
  def get_top_used_languages(top=20)
    @lang_count = analyzer.top_language("count", top)

    # Format the count data to the required structure for Pie chart of chartjs
    lang_count_pie = []
    @lang_count.each do |lang|
      color = lang_colors[lang[0]]
      next if color.nil?
      lang_count_pie << {"label" => lang[0], "value" => lang[1], "color" => color}
    end
    lang_count_pie = JSON.generate(lang_count_pie)
    lang_count_pie
  end

  # Bar chart for top starred languages based on total number of stars
  def get_top_starred_languages(top=20)
    @lang_star = analyzer.top_language("star", top)

    # Format the star count data for Bar chart
    lang_star_bar = {}
    lang_star_bar["labels"] = @lang_star.map { |lang| lang[0] }
    lang_star_bar["datasets"] = []
    lang_star_bar["datasets"][0] = {
      label: "Stars Received",
      fillColor: "#FF9900",
      strokeColor: "#d8d8d8",
      highlightFill: "#CC6600",
      highlightStroke: "#d8d8d8",
      data: @lang_star.map { |lang| lang[1] }
    }
    lang_star_bar = JSON.generate(lang_star_bar)
    lang_star_bar
  end

  # Bar chart of top languages based on the star/repos ratio
  def get_top_impact_languages(top=20)
    @lang_star ||= analyzer.top_language("star", top)

    lang_star_ratio_bar = {}
    lang_star_ratio_bar["labels"] = @lang_star.map { |lang| lang[0] }
    lang_star_ratio_bar["datasets"] = []
    lang_star_ratio_bar["datasets"][0] = {
      label: "Stars Received",
      fillColor: "#4183c4",
      highlightFill: "#0033CC",
      data: @lang_star.map { |lang| (lang[1].to_f/lang_sum[lang[0]]["count"]).round(2) }
    }

    lang_star_ratio_bar["datasets"][1] = {
      label: "Repos Created",
      fillColor: "#333",
      data: Array.new(@lang_star.length, 1)
    }

    lang_star_ratio_bar = JSON.generate(lang_star_ratio_bar)
    lang_star_ratio_bar
  end

  # Top star received memebers of each top language
  def get_top_star_memebers(top=10)
    @lang_star ||= analyzer.top_language("star", top)

    candidates = @lang_star[0...top].inject({}) do |h, lang|
      h[lang[0]] = analyzer.member_contrib(lang[0], "star")[0...top]
      h
    end
    candidates
  end

  # Top repos created memebers of each top language
  def get_top_count_memebers(top=10)
    @lang_count ||= analyzer.top_language("count", top)

    candidates = @lang_count[0...top].inject({}) do |h, lang|
      h[lang[0]] = analyzer.member_contrib(lang[0], "count")[0...top]
      h
    end
    candidates
  end
  
  def analyzer
    if @hubbers.nil?
      raise RuntimeError, "You should generate some data first!"
    end
    @analyzer ||= Hubberlyzer::Analyzer.new(@hubbers)
  end

  def lang_sum
    @lang_sum ||= analyzer.sum_by_language
  end
end

# Generator.new.run_sample
# Generator.new.run("https://github.com/orgs/github/people", 7, "index.html", max_concurrency: 4)
# Generator.new.run("https://github.com/orgs/google/people", 11, "google.html", max_concurrency: 4)
# Generator.new.run("https://github.com/orgs/linkedin/people", 2, "linkedin.html", max_concurrency: 2)
# Generator.new.run("https://github.com/orgs/Microsoft/people", 7, "microsoft.html", max_concurrency: 4)
Generator.new.run("https://github.com/orgs/facebook/people", 4, "facebook.html", max_concurrency: 4)

