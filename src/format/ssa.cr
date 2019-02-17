require "./substation"

module Subtitles
  class SSA < Substation
    def self.styles_section_header
      "[V4 Styles]"
    end

    def self.first_dialogue_column
      "Marked=0"
    end

    def self.first_format_column
      "Marked"
    end

    def self.default_style
      "Style: DefaultVCD, Arial,28,11861244,11861244,11861244,-2147483640,-1,0,1,1,2,2,30,30,30,0,0"
    end

    def self.style_format_columns
      "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, TertiaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding"
    end
  end
end
