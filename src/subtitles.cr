require "./core_ext/**"
require "./format"
require "./config"

module Subtitles
  VERSION = "0.1.0"
  extend self

  @@logger : Logger?

  def logger : Logger
    @@logger ||= Config.logger
  end

  def detect(content : IO) : Format.class | Nil
    {% for format in Formats %}
    if detected = {{format.id}}.detect content
      return detected
    end
    {% end %}
  end

  def parse(*, filepath : String)
    File.open filepath do |file|
      parse file
    end
  end

  alias Captions = Array(Caption | Style) | Array(Caption)

  def parse(content : IO) : Captions?
    if detected = detect content
      detected.new(content).to_captions
    end
  end

  def filter_styles(from captions : Captions) : Array(Caption)
    captions.reject { |ent| ent.is_a? Style }.as Array(Caption)
  end

  def parse!(content) : Captions
    (parse content) || raise "Couldn't detect the filetype of #{content.inspect}"
  end

  def by_extension(file : File) : Format.class | Nil
    by_extension file.path
  end

  def by_extension(filepath : String) : Format.class | Nil
    Format.from_extension File.basename(filepath).split('.').last
  end

  def by_extension!(file) : Format.class
    by_extension(file) || raise "filetype for #{file.inspect} is not yet implemented"
  end

  def convert(content : IO, to format : Format.class, resync resync_option = false)
    captions = parse(content)
    resync captions if resync_option
    format.build captions
  end

  def resync(captions : Array(Caption), offset : Number)
    resync(captions) { |start, end| {start + offset, end + offset} }
  end

  def resync(captions : Array(Caption), offset : Number, frame_rate : Number, ratio = 1_f64)
    offset *= frame_rate
    resync captions do |start, end|
      {Math.round(start * ratio + offset), Math.round(end * ratio + offset)}
    end
  end

  def resync(captions : Array(Caption))
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
