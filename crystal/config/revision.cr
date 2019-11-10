ReadRust::Revision.configure do |settings|
  settings.revision = revision_from_env
end

private def revision_from_env : String?
  ENV["READRUST_REVISION"]? || warn_missing_revision
end

private def warn_missing_revision
  puts "READRUST_REVISION is not set".colorize.yellow if Lucky::Env.production?
  nil
end
