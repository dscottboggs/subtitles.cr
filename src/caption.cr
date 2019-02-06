require "json"
module Subtitles
  enum CaptionType
    Subrip
    SRT
    ASS
    JSON
  end

  # An intermediary format to store the data in while converting from one format to another.
  class Caption
    include JSON::Serializable
    property index : Int64
    property start : Time::Span
    property end : Time::Span
    property duration : Time::Span
    property content : String
    property text : String
    property meta : Meta?

    def initialize(@type, @index, @start, @end, @duration, @content, @text); end
    def initialize(@type, @index, @start, @end, @content, @text)
      @duration = @end - @start
    end
    def initialize(@type, @index, @start, @duration, @content, @text)
      @end = @start + @duration
    end
  end
end
