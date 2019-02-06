module Subtitles
  class JSON
    JSON_FT_REGEX = /^\[\s*\{.*\}\s*\]$/
    def parse
      Array(Caption).from_json content
    end
    def self.build(captions)
      content.to_json
    end

    def self.detect(content)
      return self.class if JSON_FT_REGEX.match content
    end
  end
end
