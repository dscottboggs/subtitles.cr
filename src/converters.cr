require "json"

# Convert an integer representing a number of milliseconds to a Time::Span and
# vice-versa.
module MillisecondsSpanConverter
  MILLIS_TO_NANOS = 1e6

  def self.from_json(value : JSON::PullParser)
    Time::Span.new nanoseconds: (value.read_int * MILLIS_TO_NANOS).to_i64
  end

  def self.to_json(value : Time::Span, json builder : JSON::Builder)
    builder.string((value.total_nanoseconds / MILLIS_TO_NANOS).to_i)
  end
end

# Methods for sanitizing individual strings within structures of strings.
module Sanitizer
  def sanitize(string : String)
    string.gsub "\\\\", "\\"
  end

  def dirty(sanitized string : String)
    string.gsub "\\", "\\\\"
  end
end

# Filter troublesome characters from the JSON. Currently just doubles up on
# backslashes.
module SanitizeString
  extend Sanitizer

  def self.from_json(value : JSON::PullParser)
    dirty value.read_string
  end

  def self.to_json(value : String, builder : JSON::Builder)
    builder.string sanitize value
  end
end

# The same filter as SanitizeString, just for a Hash of String to String
module SanitizeStringHash
  extend Sanitizer
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
end
