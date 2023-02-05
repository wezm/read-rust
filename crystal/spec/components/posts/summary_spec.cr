require "../../spec_helper"

include ContextHelper

private class TestMountPage
  include Lucky::HTMLPage

  needs summary : String

  def render
    mount Posts::Summary, post: post, current_user: nil, show_categories: true, highlight: nil
    view
  end

  private def post
    post = PostFactory.create &.summary(@summary)
    PostQuery.new.preload_post_categories.preload_tags.find(post.id)
  end
end

describe Posts::Summary do
  context "render" do
    it "escapes the summary" do
      contents = TestMountPage.new(summary: "I've Rc<RefCell<T>>", context: build_context).render.to_s
      contents.should contain("<blockquote><p>I&#39;ve Rc&lt;RefCell&lt;T&gt;&gt;</p></blockquote>")
    end

    it "replaces DC2 and DC4 characters with mark tags" do
      contents = TestMountPage.new(summary: "This \u{0012}keyword\u{0014} matches", context: build_context).render.to_s
      contents.should contain("<blockquote><p>This <mark>keyword</mark> matches</p></blockquote>")
    end
  end
end
