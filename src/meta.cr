module Subtitles
  class Meta
    property data : Hash(String, String)

    def initialize(@data = {} of String => String); end
  end
end
