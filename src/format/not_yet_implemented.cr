{% for format in {:vtt, :lrc, :smi, :sub, :sbv} %}
# .{{format.id}} files are not yet supported.
class Subtitles::{{format.id.upcase}} < Subtitles::Format
  def self.detect(*args, **options)
    nil
  end
  {% for method in {:content, :to_captions, :initialize} %}
  def {{method.id}}(*args, **options)
    raise ".{{format.id}} files are not yet supported"
  end
  {% end %}
end

{% end %}
