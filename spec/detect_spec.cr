require "./spec_helper"

{% for status in [READY, PENDING] %}
\{% for filetype in {{status.id}} %}
describe Subtitles::\{{filetype.id}} do
  \{% if {{status}} == READY %}it\{% else %}pending\{% end %} "is detected" do
    Subtitles::\{{filetype.id}}
      .detect(fixture "\{{filetype.id.downcase}}")
      .should eq Subtitles::\{{filetype.id}}
  end
end
\{% end %}
{% end %}
