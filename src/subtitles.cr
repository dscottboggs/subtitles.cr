require "./core_ext/**"
require "./format"
require "./config"

module Subtitles
  # :nodoc:
  VERSION = "0.1.0"
  extend self

  @@logger : Logger?

  # :nodoc:
  def logger : Logger
    @@logger ||= Config.logger
  end

  # Detect what filetype the given IO contains, if any. This cycles through all
  # available types and calls #detect on them. If a filetype is detected, the
  # **class** of that type will be returned for instantiation. If none of the
  # available filetypes match the given IO, nil will be returned.
  #
  # For example:
  # ```
  # if subs = Subtitles.detect(content).try &.new(content)... # subs is a new instance of some Format
  # else
  #   # subs is nil
  # end
  # ```
  def detect(content : IO) : Format.class | Nil
    {% for format in Formats %}
    if detected = {{format.id}}.detect content
      return detected
    end
    {% end %}
  end

  # Opens the given file, calls `#detect(IO)` on the open file, closes it,
  # and returns the result.
  def detect(*, file filepath : String) : Format.class | Nil
    File.open(filepath) { |file| detect content: file }
  end

  # parse the given filepath into a Caption object, if possible, or return nil.
  def parse(*, filepath : String)
    File.open filepath do |file|
      parse file
    end
  end

  alias Captions = Array(Caption | Style) | Array(Caption)

  # parse the given IO into a Caption object, if possible, or return nil.
  def parse(content : IO) : Captions?
    if detected = detect content
      detected.new(content).to_captions
    end
  end

  # Accepts an Array(Caption|Style) and returns an Array(Caption)
  def filter_styles(from captions : Captions) : Array(Caption)
    captions.reject { |ent| ent.is_a? Style }.as Array(Caption)
  end

  # Parse the given IO into a Caption object, or raise an exception.
  def parse!(content) : Captions
    (parse content) || raise "Couldn't detect the filetype of #{content.inspect}"
  end

  # Detect the filetype of the given file by its extension rather than its
  # contents
  def by_extension(file : File) : Format.class | Nil
    by_extension file.path
  end

  # Detect the filetype of the given filepath by its extension rather than
  # its contents
  def by_extension(filepath : String) : Format.class | Nil
    Format.from_extension File.basename(filepath).split('.').last
  end

  # The same as `#by_extension`, except raises on failure rather than returning
  # nil
  def by_extension!(file) : Format.class
    by_extension(file) || raise "filetype for #{file.inspect} is not yet implemented"
  end

  # At once -- parse, resync, and output a converted subtitle
  def convert(content : IO, to format : Format.class, resync resync_option : Time::Span? = nil)
    captions = parse(content)
    resync captions, offset: resync_option if resync_option
    format.build captions
  end

  # Resync the given `Captions`' timestamps. That is, increase or decrease the
  # start and end time of every dispalyed caption by a given amount of time.
  def resync(captions : Array(Caption), offset : Time::Span)
    resync(captions) { |start, end| {start + offset, end + offset} }
  end

  # Resync the given `Captions`' timestamps. That is, increase or decrease the
  # start and end time of every dispalyed caption by a given number of frames.
  def resync(captions : Array(Caption),
             offset : Number,
             frame_rate : Time::Span = (1 / 24_f32).seconds,
             ratio = 1_f64)
    offset *= frame_rate
    resync captions do |start, end|
      {Math.round(start * ratio + offset), Math.round(end * ratio + offset)}
    end
  end

  # Resync the given `Captions`' timestamps. That is, increase or decrease the
  # start and end time of every dispalyed caption by the amount of time returned
  # from the block.
  #
  # A block attacked to this method MUST return a Tuple of two values, each
  # of which is a Time::Span. It also must accept two parameters, which are the
  # start and end times of each caption in the list. For example, to make every
  # subtitle 10 milliseconds later, you could do
  #
  # ```
  # Subtitles.resync captions do |start, end_time|
  #   { start + 10.milliseconds, end_time + 10.milliseconds }
  # end
  # ```
  def resync(captions : Array(Caption),
             &block : { Time::Span, Time::Span } -> { Time::Span, Time::Span })
    synced = [] of Caption
    captions.each_with_index do |caption, index|
      temp = caption.clone
      temp.start, temp.end = yield caption.start, caption.end
      temp.duration = temp.end - temp.start
      synced << temp
    end
    synced
  end
end
