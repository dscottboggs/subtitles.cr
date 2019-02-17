module Subtitles
  class SSA < Format
    getter content : IO

    SRT_TIME_FORMAT = "%H:%M:%S,%L"

    property eol = "\r\n"

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

    # Build SSA-compatible subtitles from the given `Caption`s.
    def self.new(captions : Array(Caption | Style), eol = "\r\n")
      content = String.build do |ssa|
        ssa << "[Script Info]" << eol
        ssa << "; Script generated by Subtitles.cr" << eol
        ssa << "ScriptType: v4.00" << eol
        ssa << "Collisions: Normal" << eol
        ssa << eol
        ssa << "[V4 Styles]" << eol
        ssa << "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding" << eol
        ssa << (style_in?(captions) || "Style: DefaultVCD, Arial,28,&H00B4FCFC,&H00B4FCFC,&H00000008,&H80000008,-1,0,0,0,100,100,0.00,0.00,1,1.00,2.00,2,30,30,30,0") << eol
        ssa << eol
        ssa << "[Events]" << eol
        ssa << "Format: Marked, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text" << eol
        captions.reject(&.is_a? Style).as(Array(Caption)).each do |caption|
          ssa << "Dialogue: Marked=0,"
          ssa << caption.start.to_s << ","
          ssa << caption.end.to_s << ","
          ssa << ",DefaultVCD, NTP,0000,0000,0000,,"
          ssa << caption.text.gsub(/\r?\n/, "\\N") << eol
        end
      end
      self.class.new content, eol
    end

    def style_in?(captions : Array(Caption | Style)) : Style?
      if found = captions.find?(&.is_a? Style)
        captions.del found
        return found
      end
    end

    PART_REGEX   = /^\s*\[([^\]]+)\]\r?\n([\s\S]*)(\r?\n)*$/i
    LINE_REGEX   = /^\s*([^:]+):\s*(.*)(\r?\n)?$/
    INLINE_REGEX = /\s*,\s*/
    property columns = [] of String

    def parse(eol = "\r\n")
      captions = [] of Caption | Style
      meta = nil
      columns = nil
      while part = content.gets eol + eol, chomp: true
        if part_match = PART_REGEX.match part
          tag = part_match[1]
          part_match[2].split(/\r?\n/).each do |line|
            next if /^\s*;/.match line
            if line_match = LINE_REGEX.match line
              case tag
              when "Script Info"
                meta ||= Meta.new
                meta.data[line_match[1]] = line_match[2]
              when "V4 Styles", "V4+ Styles"
                name = line_match[1].strip
                value = line_match[2].strip
                case name
                when "Format"
                  columns = value.split INLINE_REGEX
                  next
                when "Style"
                  if cols = columns
                    style = Style.new
                    values = value.split INLINE_REGEX
                    values.each_with_index do |val, idx|
                      style.data[cols[idx]] = value if idx < cols.size
                    end
                    captions << style
                  else
                    raise StyleBeforeFormat.new content.tell
                  end
                end
              when "Events"
                name, value = line_match[1].strip, line_match[2].strip
                case name
                when "Format"
                  columns = value.split INLINE_REGEX
                  next
                when "Dialogue"
                  if the_columns = columns
                    values = value.split INLINE_REGEX, the_columns.size - 1
                    data = {} of String => String
                    the_columns.each_with_index do |column, idx|
                      data[column] = values[idx]
                    end
                    captions << Caption.new(
                      start: (parse_time data["Start"]),
                        end: (parse_time data["End"]),
                          content: data["Text"],
                          text: data["Text"].gsub("\\N", eol).gsub(/\{[^\}]+\}/, "")
                    )
                    next
                  else
                    raise DialogueBeforeFormat.new content.tell
                  end
                end
              end
            end
          end
        end
      end
      captions
    end

    SCRIPT_INFO_REGEX = /^\s*\[Script Info\]\r?\n/
    EVENTS_REGEX      = /\s*\[Events\]\r?\n/

    def self.detect(content : String)
      if SCRIPT_INFO_REGEX.match(content) && EVENTS_REGEX.match(content)
        if content.includes? "[V4+ Styles]"
          raise "ASS not yet implemented"
        else
          self
        end
      end
    end
    private def parse_time(string : String) : Time::Span
      time = Time.parse string, SRT_TIME_FORMAT, Time::Location::UTC
      Time::Span.new days: 0, hours: time.hour, minutes: time.minute, seconds: time.second, nanoseconds: time.nanosecond
    end



    class StyleBeforeFormat < Exception
      def initialize(position)
        super "The [Format] tag must come before [Style]. Found [Style] first at #{position.inspect}"
      end
    end
    class DialogueBeforeFormat < Exception
      def initialize(position)
        super "The [Format] tag must come before any [Dialogue]. Found [Dialogue] first at #{position.inspect}"
      end
    end
  end
end
