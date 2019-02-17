require "./spec_helper"

{% for status in [READY, PENDING] %}
\{% for filetype in {{status}} %}
describe Subtitles::\{{filetype.id}} do
  \{% if {{status}} == READY %}it\{% else %}pending\{% end %} "parses the example text" do
    content = fixture "\{{filetype.id.downcase}}"
    captions = Subtitles::\{{filetype.id}}.new(content).to_captions eol: "\n"
    captions.size.should be > 1
    # TODO better tests of parsed data
    if File.directory? "./output"
      File.write(filename: "./output/parsed.\{{filetype.id}}.json", content: captions.to_s)
    end
  end
end
\{% end %}
{% end %}
