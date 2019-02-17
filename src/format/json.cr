module Subtitles
  class JSON
    JSON_FT_REGEX = /^\s*\[\s*\{(\s*.+\s*)+\}\s*\]\s*$/

    getter content : IO

    def parse
      Array(Caption).from_json content
    end

    # These initalize methods have to be pulled in manually from the parent class

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

    def initialize(captions : Array(Caption), eol = "\r\n")
      @content = captions.to_json
    end

    def self.detect(content)
      return self if JSON_FT_REGEX.match content
    end
  end
end
