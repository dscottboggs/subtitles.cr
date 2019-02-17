require "./ssa"
module Subtitles
  class ASS < SSA
    def self.styles_section_header
      "[V4+ Styles]"
    end

    def self.first_dialogue_column
      "0"
    end

    def self.first_format_column
      "Layer"
    end

    def self.default_style
      "Style: DefaultVCD, Arial,28,&H00B4FCFC,&H00B4FCFC,&H00000008,&H80000008,-1,0,0,0,100,100,0.00,0.00,1,1.00,2.00,2,30,30,30,0"
    end

    def self.style_format_columns
      "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding"
    end
  end
end
