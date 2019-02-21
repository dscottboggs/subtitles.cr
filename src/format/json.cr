require "../format"

module Subtitles
  # A JSON representation of the internal intermediary format.
  class JSON < Format
    JSON_FT_REGEX = /^\s*\[\s*\{\s*"/

    getter content : IO

    def to_captions(eol = nil)
      Array(Caption).from_json content
    end

    # These initalize methods are shared with the other cousin classes and must
    # be manually maintained to be similar :/

    # initialize with the content
    def initialize(@content : IO); end

    # :ditto:
    def initialize(content string : String)
      @content = IO::Memory.new string
    end

    # Read in a JSON-formatted subtitle from the given filepath.
    def initialize(*, filepath : String)
      @content = File.open filepath
    end

    def initialize(captions : Captions, eol = "\r\n")
      @content = IO::Memory.new
      Subtitles.filter_styles(from: captions).to_json @content
    end

    def self.detect(content : IO)
      bytes = if head = content.peek
                Bytes.new(size: 16) { |index| head[index] }
              else
                slice = Bytes.new 16
                content.read slice
                content.rewind
                slice
              end
      if JSON_FT_REGEX.match String.new(slice: bytes)
        self
      end
    end
  end
end
