require "spec"
require "../src/subtitles.cr"

READY   = {:SRT, :JSON, :ASS, :SSA}
PENDING = {:LRC, :SBV, :SMI, :SUB, :VTT}

SPEC_DIR = File.real_path __DIR__

def fixture(filetype : String) : String
  File.read "#{SPEC_DIR}/fixtures/sample.#{filetype}"
end

def snapshot_filename(for format)
  "#{__DIR__}/snapshots/snapshot.#{format.to_s.downcase.split("::").last}"
end

def snapshot_text(for format)
  File.read snapshot_filename for: format
end

def snapshot_exists?(for format)
  filename = snapshot_filename for: format
  (File.exists? filename) && (File.size filename) != 0
end

def write_snapshot(for format, from io)
  File.open filename: (snapshot_filename for: format), mode: "w" do |file|
    IO.copy io, file
  end
end

{% for filetype in READY + PENDING %}
module Subtitles
  class {{filetype.id}}
    def should_match_snapshot
      unless snapshot_exists? for: self.class
        write_snapshot(for: self.class, from: content)
      end
      content.rewind.gets_to_end.should eq snapshot_text for: self.class
    end
  end
end
{% end %}

Sample = Subtitles::JSON.new(fixture("json")).to_captions
