require "./spec_helper"

{% for filetype in READY %}
describe Subtitles::{{filetype.id}} do
  it "parses the example text" do
    content = fixture "{{filetype.id.downcase}}"
    captions = pp! Subtitles::{{filetype.id}}.new(content).parse eol: "\n"
    captions.size.should be > 1
    # TODO better tests of parsed data
    if File.directory? "./output"
      File.write(filename: "./output/parsed.{{filetype.id}}.json", content: captions.to_s)
    end
  end
end
{% end %}

{% for filetype in PENDING %}
describe "Subtitles::{{filetype.id}}" do
  pending "parses the example text" do
    content = fixture "{{filetype.id.downcase}}"
    captions = Subtitles::{{filetype.id}}.new(content).parse eol: "\n"
    captions.size.should be > 1
    # TODO better tests of parsed data
    if File.directory? "./output"
      File.write(filename: "./output/parsed.{{filetype.id}}.json", content: captions.to_s)
    end
  end
end
{% end %}
