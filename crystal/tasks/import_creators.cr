# name: Kat Marchán
# avatar: zcat.jpg
# support:
#   name: Support on GitHub
#   link: 'https://github.com/users/zkat/sponsorship'
# code:
#   name: 'zcat'
#   link: 'https://github.com/zcat'
# description: |
#   Kat is getting involved with the Rust ecosystem, writing
#   libraries like <a href="https://crates.io/crates/ssri">ssri</a>, and
#   <a href="https://github.com/zkat/cacache-rs">cacache</a>. They're
#   looking forward to doing more for the Rust community as they keep
#   learning the language.
# tags: [crates]

module Import
  class Link
    YAML.mapping(
      name: String,
      link: String,
    )
  end

  class Creator
    YAML.mapping(
      name: String,
      avatar: String,
      support: Link,
      code: Link,
      description: String,
      tags: Array(String)
    )
  end
end

class ImportCreators < LuckyCli::Task
  summary "Imports creators from Read Rust 1.0"

  def call(io : IO = STDOUT)
    if ARGV.size < 1
      io.puts "Usage: lucky import_creators creators.yml"
      io.puts "E.g. lucky import_creators ~/Projects/read-rust/content/_data/creators.yaml"
    else
      import(io)
    end
  end

  private def import(io)
    creators = Array(Import::Creator).from_yaml(File.read(ARGV[0]))

    AppDatabase.transaction do
      creators.each do |creator|
        io.puts creator.name
        saved_creator = SaveCreator.create!(
          name: creator.name,
          avatar: creator.avatar,
          support_link_name: creator.support.name,
          support_link_url: creator.support.link,
          code_link_name: creator.code.name,
          code_link_url: creator.code.link,
          description: creator.description
        )

        creator.tags.each do |tag_name|
          tag = TagQuery.new.name(tag_name).first?
          if tag.nil?
            tag = SaveTag.create!(name: tag_name)
          end

          SaveCreatorTag.create!(creator_id: saved_creator.id, tag_id: tag.id)
        end
      end

      true
    end
  end
end
