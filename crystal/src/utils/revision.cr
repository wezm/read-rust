module ReadRust
  class Revision
    Habitat.create do
      setting revision : String?
    end

    def self.revision : String
      settings.revision || Time.utc.to_unix.to_s
    end
  end
end
