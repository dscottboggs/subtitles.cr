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
    # The textual representation of the subtitles.
    abstract def content : IO

    # Convert this Substation subtitles file to an intermediary format for
    # conversion to another format. This process can be lossy, depending on the
    # format.
    abstract def to_captions

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
