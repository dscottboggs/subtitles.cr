require "./ass"
require "./ssa"

# Common methods shared between the very similar SSA and ASS formats.
module Subtitles
  abstract class Substation < Format
    getter content : IO

    SRT_TIME_FORMAT = "%H:%M:%S.%L"

    property eol = "\r\n"

    macro abstract_class_method(method_name)
    def self.{{method_name.id}}
      {% raise "attempted to call abstract class method {{@type.class.id}}.{{method_name.id}}" %}
    end
  end

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
      content = IO::Memory.new
      content << "[Script Info]" << eol
      content << "; Script generated by Subtitles.cr" << eol
      content << "ScriptType: v4.00" << eol
      content << "Collisions: Normal" << eol
      content << eol
      content << styles_section_header << eol
      content << style_format_columns << eol
      content << (style_in?(captions) || default_style) << eol
      content << eol
      content << "[Events]" << eol
      content << "Format: #{first_format_column}, Start, End, Style, Name, MarginL, MarginR, MarginV, Effect, Text" << eol
      captions.reject(&.is_a? Style).as(Array(Caption)).each do |caption|
        content << "Dialogue: #{first_dialogue_column},"
        content << caption.start.to_s << ","
        content << caption.end.to_s << ","
        content << ",DefaultVCD, NTP,0000,0000,0000,,"
        content << caption.text.gsub(/\r?\n/, "\\N") << eol
      end
      new content
    end

    def self.style_in?(captions : Array(Caption | Style)) : Style?
      captions.each do |caption|
        if found = caption.is_a? Style
          captions.delete found
          return found.as Style
        end
      end
    end

    module Regexes
      Part           = /^\s*\[([^\]]+)\]\r?\n([\s\S]*)(\r?\n)*$/i
      Line           = /^\s*([^:]+):\s*(.*)(\r?\n)?$/
      Inline         = /\s*,\s*/
      ScriptInfo     = /^\s*\[Script Info\]\r?\n/
      Events         = /\s*\[Events\]\r?\n/
      PositionMarker = /\{\\pos\(\d+,\d+\)\}/
    end

    property columns = [] of String

    private def parse(meta : Meta, match : Regex::MatchData) : Void
      meta.data[match[1]] = match[2]
    end

    private def parse(*, format : String)
      format.split Regexes::Inline
    end

    private def parse_style(string : String, columns : Array(String)) : Style
      style = Style.new
      values = string.split Regexes::Inline
      values.each_with_index do |value, idx|
        style.data[columns[idx]] = value if idx < columns.size
      end
      style
    end

    private def parse(*,
                      styles captions : Array(Caption | Style),
                      match : Regex::MatchData,
                      columns : Array(String)?) : Array(String)?
      name = match[1].strip
      value = match[2].strip
      puts "parsing style tag #{name}: #{value}"
      case name
      when "Format"
        return parse format: value
      when "Style"
        if cols = columns
          captions << parse_style value, cols
        else
          raise StyleBeforeFormat.new content.tell
        end
      end
      nil
    end

    private def parse(*, # require named arguments
                      dialogue captions : Array(Caption | Style),
                      text : String,
                      columns : Array(String)) : Void
      values = text
        .gsub(Regexes::PositionMarker, "")
        .split Regexes::Inline, columns.size
      data = {} of String => String
      columns.each_with_index do |column, idx|
        data[column] = values[idx]? || ""
      end
      captions << Caption.new(
        start: (parse_time data["Start"]),
        end: (parse_time data["End"]),
        content: data["Text"],
        text: data["Text"].gsub("\\N", eol).gsub(/\{[^\}]+\}/, "")
      )
    end

    def to_captions(eol = "\r\n")
      captions = [] of Caption | Style
      meta = nil
      style_columns = nil
      event_columns = nil
      while part = content.gets eol + eol, chomp: true
        lines = part.split(eol).reject { |line| /^\s*;/.match line }.map &.strip
        lines
        tag = lines.shift.delete { |char| ['[', ' ', ']', '\t'].includes? char }
        tag
        lines.each do |line|
          next if /^\s*;/.match line
          if line_match = Regexes::Line.match line
            case tag
            when "ScriptInfo"
              meta ||= Meta.new
              parse meta, line_match
            when "V4Styles", "V4+Styles"
              if cols = parse styles: captions, match: line_match, columns: style_columns
                style_columns = cols
              end
            when "Events"
              name, value = line_match[1].strip, line_match[2].strip
              # puts "parsing event tag #{name}: #{value}"
              case name
              when "Format"
                event_columns = value.split Regexes::Inline
                next
              when "Dialogue"
                if cols = event_columns
                  parse dialogue: captions, text: value, columns: cols
                else
                  raise DialogueBeforeFormat.new content.tell
                end
              end
            else
              Subtitles.logger.debug "Got unrecognized tag #{tag}"
            end
          end
        end
      end
      captions
    end

    def self.detect(content : String)
      if Regexes::ScriptInfo.match(content) && Regexes::Events.match(content)
        if content.includes? "[V4+ Styles]"
          ASS
        else
          SSA
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
