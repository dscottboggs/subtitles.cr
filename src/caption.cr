require "json"
require "./converters"

module Subtitles
  # An intermediary format to store the data in while converting from one format to another.
  class Caption
    include ::JSON::Serializable

    @[::JSON::Field(converter: MillisecondsSpanConverter)]
    property start : Time::Span

    @[::JSON::Field(converter: MillisecondsSpanConverter)]
    property end : Time::Span

    @[::JSON::Field(converter: MillisecondsSpanConverter)]
    property duration : Time::Span

    @[::JSON::Field(converter: SanitizeString)]
    property content : String

    @[::JSON::Field(converter: SanitizeString)]
    property text : String

    @[::JSON::Field(converter: SanitizeStringHash)]
    property data : Hash(String, String)?

    def initialize(@start, @end, @duration, @content, @text); end

    def initialize(*, @start, @end, @content, @text)
      @duration = @end - @start
    end

    def initialize(*, @start, @duration, @content, @text)
      @end = @start + @duration
    end
  end
end
