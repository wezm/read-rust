Lucky::HTMLPage.configure do |settings|
  settings.render_component_comments = !Lucky::Env.production?
end
