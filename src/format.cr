require "./core_ext/**"
require "./caption"
require "./meta"
require "./style"

module Subtitles
  Formats = {
    :SSA,
    :ASS,
    :SRT,
    :JSON,
    # :VTT,
    # :LRC,
    # :SMI,
    # :SUB,
    # :SBV,
  }

  # Each subtitle format (like ASS, SRT, JSON, etc.) should be compatible with this interface.
  abstract class Format
    # The textual representation of the subtitles.
    abstract def content : IO

    # Convert this Substation subtitles file to an intermediary format for
    # conversion to another format. This process can be lossy, depending on the
    # format.
    abstract def to_captions

    # detect this filetype
    abstract_class_method :detect

    #
    # def initialize(content : IO); end
    #
    # def initialize(content string : String)
    #   content = IO.new string
    # end
    #
    # def initialize(*, filepath : String)
    #   @content = File.open filepath
    # end
    #
    # def initialize(*, captions : Captions)
    #   raise "Attempted to initialize abstract class #{self.class}"
    #   @content = IO.new
    # end

    # :nodoc:
    def finalize
      # If the content attribute is a File, we need to close it.
      if content.responds_to? :close
        content.close
      end
    end

    # return the appropriate filetype for the given extension string.
    def self.from_extension(extension string : String) : self.class | Nil
      raise "invalid extension #{string.inspect}" if string.includes?("/") || string.includes? "."
      case string
      when "ssa"  then SSA
      when "ass"  then ASS
      when "srt"  then SRT
      when "json" then JSON
      end
    end
  end
end

require "./format/*"
