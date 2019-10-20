class Category
  getter id, name, hashtag, slug, description

  ALL = [
    Category.new(0,  "All",                      "all",         "all",                      "All posts."),
    Category.new(1,  "Community",                "community",   "community",                "Initiatives in the Rust community."),
    Category.new(2,  "Computer Science",         "compsci",     "computer-science",         "Covering data structures, algorithms, memory safety, etc."),
    Category.new(3,  "Crates",                   "crates",      "crates",                   "Notable new or updated crates."),
    Category.new(4,  "DevOps and Deployment",    "devops",      "devops-and-deployment",    "Building and deploying Rust, containerisation, continuous integration, etc."),
    Category.new(5,  "Embedded",                 "embedded",    "embedded",                 "Rust on microcontrollers, IoT, devices."),
    Category.new(6,  "Games and Graphics",       "graphics",    "games-and-graphics",       "Games built with Rust and other graphics related work."),
    Category.new(7,  "Getting Started",          "starting",    "getting-started",          "Introductory posts, guides and tutorials for getting started with Rust."),
    Category.new(8,  "Language",                 "language",    "language",                 "General posts about the Rust language."),
    Category.new(9,  "Operating Systems",        "os",          "operating-systems",        "Using Rust to build or explore operating systems."),
    Category.new(10, "Performance",              "performance", "performance",              "Optimisation, benchmarks, etc."),
    Category.new(11, "Rust 2018",                "Rust2018",    "rust-2018",                "Hopes and dreams for Rust in 2018."),
    Category.new(12, "Rust 2019",                "rust2019",    "rust-2019",                "Ideas from the community for Rust in 2019, and the next edition."),
    Category.new(13, "Tools and Applications",   "tools",       "tools-and-applications",   "Command line tools and GUI applications."),
    Category.new(14, "Security",                 "security",    "security",                 "Security, cryptography, etc."),
    Category.new(15, "Web and Network Services", "web",         "web-and-network-services", "Web applications, web assembly, network daemons, etc."),
  ]

  # Return the list of category ids that are valid for a PostCategory record
  def self.valid_ids
    ALL.compact_map { |category| category.all? ? nil : category.id }
  end

  def initialize(@id : Int16, @name : String, @hashtag : String, @slug : String, @description : String)
  end

  def all?
    id.zero?
  end
end
