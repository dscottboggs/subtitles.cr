require "../format"

module Subtitles
  class SRT < Format
    SRT_REGEX      = /^\d+\r?\n\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?\s*\-\-\>\s*\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?/i
    SRT_PART_REGEX = /^(\d+)\r?\n(\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?)\s*\-\-\>\s*(\d{1,2}:\d{1,2}:\d{1,2}([.,]\d{1,3})?)\r?\n([\s\S]*)(\r?\n)*$/i

    def initialize(captions : Captions, eol = "\r\n")
      @content = IO::Memory.new
      Subtitles.filter_styles(from: captions).each_with_index do |caption, index|
        @content << (index + 1).to_s << eol
        @content << caption.start << " --> " << caption.end << eol
        @content << caption.text << eol << eol
      end
    end

    getter content : IO

    # These initalize methods have to be pulled in manually from the parent class

    # initialize with the content
    def initialize(@content : IO); end

    # :ditto:
    def initialize(content string : String)
      @content = IO::Memory.new string
    end

    # Read in an SSA compatible subtitle from the given filepath.
    def initialize(*, filepath : String)
      @content = File.open filepath
    end

    def to_captions(eol = "\r\n") : Array(Caption)
      captions = [] of Caption
      while part = content.gets(eol * 2, chomp: true)
        if match = SRT_PART_REGEX.match part
          lines = match[6].split /\r?\n/
          captions << Caption.new(
            start: parse_time(match[2]),
            end: parse_time(match[4]),
            content: match[6],
            text: lines.join(eol)
          )
        else
          Subtitles.logger.debug "got unrecognized part: #{part}"
        end
      end
      captions
    end

    SRT_TIME_FORMAT = "%H:%M:%S,%L"

    private def parse_time(string : String) : Time::Span
      time = Time.parse string, SRT_TIME_FORMAT, Time::Location::UTC
      Time::Span.new days: 0, hours: time.hour, minutes: time.minute, seconds: time.second, nanoseconds: time.nanosecond
    end

    def self.detect(content : String)
      if SRT_REGEX.match content
        self
      end
    end

    def self.detect(content : IO)
      # File#peek returns 8096 bytes, more than enough to check the filetype,
      # but other IO types may not implement peek. As a fallback, reads the
      # first 3 lines into a string and checks those, and then rewinds the IO.
      #
      # This method **always** rewinds the IO.
      text = if head = content.rewind.peek
               if head.size > 512
                 str = String.new slice: Bytes.new(512) { |idx| head[idx] }
                 str.gsub { |char| char if char.ascii? }
               else
                 String.new head
               end
             else
               String.build do |str|
                 3.times do
                   str << content.gets limit: 1024
                 end
                 content.rewind
               end
             end
      self if SRT_REGEX.match text
    end
  end
end
