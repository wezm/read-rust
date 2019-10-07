require "./spec_helper"
require "webmock"

describe Feedbin::UrlBuilder do
  context "with query string" do
    it "encodes properly" do
      Feedbin::UrlBuilder.url("/test", {mode: "extended/test"}).to_s.should eq "https://api.feedbin.com/v2/test?mode=extended%2Ftest"
    end
  end

  context "without query string" do
    it "encludes the query string" do
      Feedbin::UrlBuilder.url("/test").to_s.should eq "https://api.feedbin.com/v2/test"
    end
  end
end

describe Feedbin::Client do
  Spec.before_each &->WebMock.reset

  describe "entry" do
    it "returns an Entry" do
      WebMock.stub(:get, "api.feedbin.com/v2/entries/3648.json?mode=extended")
        .to_return(body_io: File.open("spec/support/fixtures/feedbin-entry.json"))

      client = Feedbin::Client.new("test", "pass")
      entry = client.entry(123)
      entry.should_not be_nil
    end
  end
end
