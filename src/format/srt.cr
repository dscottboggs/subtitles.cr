require "../format"

module Subtitles

  class SRT < Format
    SRT_REGEX = /^\d+\r?\n\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?\s*\-\-\>\s*\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?/i
    SRT_PART_REGEX = /^(\d+)\r?\n(\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?)\s*\-\-\>\s*(\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?)\r?\n([\s\S]*)(\r?\n)*$/i

    def initialize(captions : Array(Caption), eol = "\r\n")
      @content = String.build do |srt|
        captions.each_with_index do |caption, index|
          srt << (index + 1).to_s << eol
          srt << caption.start << " --> " << caption.end << eol
          srt << caption.text << eol << eol
        end
      end
    end

    def parse(format : Format? = nil, eol = "\r\n") : Array(Caption)
      captions = [] of Caption
      while part = content.gets eol, chomp: true
        if match = SRT_PART_REGEX.match part
          lines = match[6].split /\r?\n/
          captions << Caption.new(
            type: "caption",
            index: match[1].to_i,
            start: parse_time(match[2].to_i),
            end: parse_time(match[4].to_i),
            content: lines.join(eol)
          )
        else
          Subtitles.logger.debug "got unrecognized part: #{part}"
        end
      end
      captions
    end

    SRT_TIME_FORMAT = "%H:%M:%S,%L"
    def self.parse_time(string : String) : Time::Span
      time = Time.parse string, SRT_TIME_FORMAT, Time::Location::UTC
      Time::Span.new days: 0, hours: time.hour, minutes: time.minute, seconds: time.second, nanoseconds: time.nanosecond
    end

    def self.detect(content : String)
      if SRT_REGEX.match content
        self.class
      end
    end
  end
end
