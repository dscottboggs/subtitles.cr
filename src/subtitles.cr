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

  def to_captions(content : IO) : Caption
    if detected = detect(content)
      detected.new(content).parse
    end
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
