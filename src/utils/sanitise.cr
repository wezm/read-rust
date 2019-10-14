@[Link("striptags")]
lib LibStriptags
  fun strip_tags(input: UInt8*, input_len: Int32, output: UInt8**, output_len: Int32*)
  fun strip_tags_free(string: UInt8*)
end

module Sanitise
  def self.strip_tags(input : String) : String?
    LibStriptags.strip_tags(input.to_unsafe, input.bytesize, out output, out length)

    if output.null?
      return nil
    end

    result = String.new(output, length)
    LibStriptags.strip_tags_free(output)
    result.strip
  end
end
