require "./spec_helper"

{% for filetype in READY %}
describe Subtitles::{{filetype.id}} do
  it "is detected" do
    Subtitles::{{filetype.id}}
      .detect(fixture "{{filetype.id.downcase}}")
      .should eq Subtitles::{{filetype.id}}
  end
end
{% end %}

{% for filetype in PENDING %}
describe "Subtitles::{{filetype.id}}" do
  pending "is detected" do
    Subtitles::{{filetype.id}}
      .detect(fixture "{{filetype.id.downcase}}")
      .should eq Subtitles::{{filetype.id}}
  end
end
{% end %}
