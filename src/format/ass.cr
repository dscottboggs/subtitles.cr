require "../format"
require "./substation"

module Subtitles
  class ASS < Substation
    # The below comments are copy-pasted into the Substation and SSA classes as
    # well, please be sure to update all 3 together. Crystal will do this
    # automatically after [#6989](https://github.com/crystal-lang/crystal/pull/6989)
    # is merged, and the docs in this file should be deleted after that feature
    # is merged.

    # The header for the Styles section. Either [V4 Styles] or [V4+ Styles]
    def self.styles_section_header
      "[V4+ Styles]"
    end

    # The content of the first column of a dialogue row.
    def self.first_dialogue_column
      "0"
    end

    # The content of the first column of a format row.
    def self.first_format_column
      "Layer"
    end

    # The default style for subtitles coming from formats without formatting
    # options.
    def self.default_style
      "Style: DefaultVCD, Arial,28,&H00B4FCFC,&H00B4FCFC,&H00000008,&H80000008,-1,0,0,0,100,100,0.00,0.00,1,1.00,2.00,2,30,30,30,0"
    end

    # The column headers for the default style
    def self.style_format_columns
      "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, OutlineColour, BackColour, Bold, Italic, Underline, StrikeOut, ScaleX, ScaleY, Spacing, Angle, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, Encoding"
    end
  end
end
