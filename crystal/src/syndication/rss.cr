module RSS
  class Channel
    def initialize(@title : String, @link : String, @feed_url : String, @description : String, @items : Array(Item), @last_build_date : Time)
    end

    def to_xml
      XML.build(encoding: "UTF-8") do |xml|
        xml.element("rss", "xmlns:dc": "http://purl.org/dc/elements/1.1/", "xmlns:content": "http://purl.org/rss/1.0/modules/content/", "xmlns:atom": "http://www.w3.org/2005/Atom", version: "2.0") do
          xml.element("channel") do
            xml.element("title") { xml.text @title }
            xml.element("description") { xml.cdata @description }
            xml.element("link") { xml.text @link }
            xml.element("atom", "link", nil, rel: "self", href: @feed_url)
            # xml.element("generator") { xml.text @generator }
            xml.element("lastBuildDate") { xml.text @last_build_date.to_rfc2822 }

            @items.each &.to_xml(xml)
          end
        end
      end
    end
  end

  class Item
    def initialize(@guid : Guid, @title : String, @link : String, @author : String, @description : String, @pub_date : Time)
    end

    def to_xml(xml : XML::Builder)
      xml.element("item") do
        @guid.to_xml(xml)
        xml.element("pubDate") { xml.text @pub_date.to_rfc2822 }
        xml.element("title") { xml.text @title }
        xml.element("link") { xml.text @link }
        xml.element("dc", "creator", nil) { xml.text @author }
        xml.element("description") { xml.cdata formatted_description(@description) }
      end
    end

    # Derived from https://github.com/luckyframework/lucky/blob/086df892004accc6db50a8268e629af601a1d8e4/src/lucky/page_helpers/html_text_helpers.cr#L127
    private def formatted_description(text : String) : String
      split_paragraphs(text).join("<br><br>")
    end

    # Derived from https://github.com/luckyframework/lucky/blob/086df892004accc6db50a8268e629af601a1d8e4/src/lucky/page_helpers/text_helpers.cr#L258
    private def split_paragraphs(text : String) : Array(String)
      return Array(String).new if text.blank?

      text.gsub(/\r\n?/, "\n").split(/\n\n+/).map do |t|
        t.gsub(/([^\n]\n)(?=[^\n])/, "\\1<br>") || t
      end
    end
  end

  struct Guid
    def initialize(@value : String, @is_permalink : Bool)
    end

    def to_xml(xml : XML::Builder)
      xml.element("guid", "isPermaLink": @is_permalink) { xml.text @value }
    end
  end
end
