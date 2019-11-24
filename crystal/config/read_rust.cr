module ReadRust
  class Config
    Habitat.create do
      setting revision : String?
      setting allow_sign_up : Bool
    end

    def self.revision : String
      settings.revision || Time.utc.to_unix.to_s
    end

    def self.allow_sign_up?
      settings.allow_sign_up
    end
  end
end

ReadRust::Config.configure do |settings|
  settings.revision = revision_from_env
  settings.allow_sign_up = allow_sign_up_from_env
end

private def revision_from_env : String?
  ENV["READRUST_REVISION"]? || warn_missing_revision
end

private def warn_missing_revision
  puts "READRUST_REVISION is not set".colorize.yellow if Lucky::Env.production?
  nil
end

private def allow_sign_up_from_env : Bool
  if Lucky::Env.production?
    ["1", "true"].includes?(ENV["READRUST_ALLOW_SIGNUP"]?)
  else
    ["1", "true"].includes?(ENV["READRUST_ALLOW_SIGNUP"]? || "1")
  end
end

