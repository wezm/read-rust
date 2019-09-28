require "../spec/support/boxes/**"

# Add seeds here that are *required* for your app to work.
# For example, you might need at least one admin user or you might need at least
# one category for your blog posts for the app to work.
#
# Use `Db::CreateSampleSeeds` if your only want to add sample data helpful for
# development.
class Db::CreateRequiredSeeds < LuckyCli::Task
  summary "Add database records required for the app to work"

  def call
    # Using a Avram::Box:
    #
    # Use the defaults, but override just the email
    # UserBox.create &.email("me@example.com")

    # Using a SaveOperation:
    #
    # SaveUser.create!(email: "me@example.com", name: "Jane")
    #
    # You likely want to be able to run this file more than once. To do that,
    # only create the record if it doesn't exist yet:
    #
    # unless UserQuery.new.email("me@example.com").first?
    #  SaveUser.create!(email: "me@example.com", name: "Jane")
    # end
    [
      ["Community", "community", "community", "Initiatives in the Rust community."],
      ["Computer Science", "compsci", "computer-science", "Covering data structures, algorithms, memory safety, etc."],
      ["Crates", "crates", "crates", "Notable new or updated crates."],
      ["DevOps and Deployment", "devops", "devops-and-deployment", "Building and deploying Rust, containerisation, continuous integration, etc."],
      ["Embedded", "embedded", "embedded", "Rust on microcontrollers, IoT, devices."],
      ["Games and Graphics", "graphics", "games-and-graphics", "Games built with Rust and other graphics related work."],
      ["Getting Started", "starting", "getting-started", "Introductory posts, guides and tutorials for getting started with Rust."],
      ["Language", "language", "language", "General posts about the Rust language."],
      ["Operating Systems", "os", "operating-systems", "Using Rust to build or explore operating systems."],
      ["Performance", "performance", "performance", "Optimisation, benchmarks, etc."],
      ["Rust 2018", "Rust2018", "rust-2018", "Hopes and dreams for Rust in 2018."],
      ["Rust 2019", "rust2019", "rust-2019", "Ideas from the community for Rust in 2019, and the next edition."],
      ["Tools and Applications", "tools", "tools-and-applications", "Command line tools and GUI applications."],
      ["Security", "security", "security", "Security, cryptography, etc."],
      ["Web and Network Services", "web", "web-and-network-services", "Web applications, web assembly, network daemons, etc."],
    ].each do |c|
      SaveCategory.create!(name: c[0], hashtag: c[1], slug: c[2], description: c[3]) unless CategoryQuery.new.slug(c[2]).first?
    end

    puts "Done adding required data"
  end
end
