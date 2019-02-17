require "json"
require "./converters"

module Subtitles
  # An intermediary format to store the data in while converting from one format to another.
  class Caption
    include ::JSON::Serializable

    # The time when the caption should begin to be shown
    @[::JSON::Field(converter: MillisecondsSpanConverter)]
    property start : Time::Span

    # The time when the caption should disappear
    @[::JSON::Field(converter: MillisecondsSpanConverter)]
    property end : Time::Span

    # The duration for which the caption should be shown
    @[::JSON::Field(converter: MillisecondsSpanConverter)]
    property duration : Time::Span

    # The unformatted content
    @[::JSON::Field(converter: SanitizeString)]
    property content : String

    # The formatted plaintext
    @[::JSON::Field(converter: SanitizeString)]
    property text : String

    # Extra data that may be stored to this caption
    @[::JSON::Field(converter: SanitizeStringHash)]
    property data : Hash(String, String)?

    def initialize(@start, @end, @duration, @content, @text); end

    # Automatically calculate the duration value.
    def initialize(*, @start, @end, @content, @text)
      @duration = @end - @start
    end

    # Automatically caluculate the end value.
    def initialize(*, @start, @duration, @content, @text)
      @end = @start + @duration
    end
  end
end
