require "spec"
require "../src/subtitles.cr"

READY   = {:SRT, :JSON, :SSA}
PENDING = {:ASS, :LRC, :SBV, :SMI, :SUB, :VTT}

SPEC_DIR = File.real_path __DIR__

def fixture(filetype : String) : String
  File.read "#{SPEC_DIR}/fixtures/sample.#{filetype}"
end
