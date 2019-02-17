require "./caption"
require "./meta"
require "./style"

module Subtitles
  enum Formats
    VTT
    LRC
    SMI
    SSA
    ASS
    SUB
    SRT
    SBV
    JSON
  end

  # Each subtitle format (like ASS, SRT, JSON, etc.) should be compatible with this interface.
  abstract class Format
    abstract def content : IO

    abstract def parse

    def initialize(@content : IO); end

    def initialize(content string : String)
      @content = IO.new string
    end

    def initialize(*, filepath : String)
      @content = File.open filepath
    end

    def finalize
      if content.responds_to? :close
        content.close
      end
    end

    # TODO #resync
  end
end

require "./format/*"
