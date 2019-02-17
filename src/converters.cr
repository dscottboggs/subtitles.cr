require "json"

module MillisecondsSpanConverter
  MILLIS_TO_NANOS = 1e6

  def self.from_json(value : JSON::PullParser)
    Time::Span.new nanoseconds: (value.read_int * MILLIS_TO_NANOS).to_i
  end

  def self.to_json(value : Time::Span, json : JSON::Builder)
    builder.string((value.total_nanos / MILLIS_TO_NANOS).to_i)
  end
end

# Filter troublesome characters from the JSON. Currently just doubles up on
# backslashes.
module SanitizeString
  def self.from_json(value : JSON::PullParser)
    value.read_string.gsub "\\\\", "\\"
  end

  def self.to_json(value : String, builder : JSON::Builder)
    builder.string value.gsub "\\", "\\\\"
  end
end

module SanitizeStringHash
  alias StringHash = Hash(String, String)

  def self.from_json(value : JSON::PullParser)
    StringHash.new(value).map do |key, value|
      {(dirty key), (dirty value)}
    end.to_h
  end

  def self.to_json(value : StringHash, builder : JSON::Builder)
    value.map do |key, value|
      {(sanitize key), (sanitize value)}
    end.to_h.to_json builder
  end

  private def self.sanitize(string : String)
    string.gsub "\\\\", "\\"
  end

  private def self.dirty(sanitized string : String)
    string.gsub "\\", "\\\\"
  end
end
