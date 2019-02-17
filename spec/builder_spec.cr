require "./spec_helper"

{% for specify in {READY, PENDING} %}
  \{% for filetype in {{specify.id}} %}
    describe "Subtitles::\{{filetype.id}}" do
      \{% if {{specify}} == READY %}it\{% else %}pending\{% end %} "builds the snapshot example" do
        Subtitles::\{{filetype.id}}.new(captions: Sample).should_match_snapshot
      end
    end
  \{% end %}
{% end %}
