require "./substation"

module Subtitles
  class SSA < Substation
    # The below comments are copy-pasted into the Substation and SSA classes as
    # well, please be sure to update all 3 together. Crystal will do this
    # automatically after [#6989](https://github.com/crystal-lang/crystal/pull/6989)
    # is merged, and the docs in this file should be deleted after that feature
    # is merged.

    # The header for the Styles section. Either [V4 Styles] or [V4+ Styles]
    def self.styles_section_header
      "[V4 Styles]"
    end

    # The content of the first column of a dialogue row.
    def self.first_dialogue_column
      "Marked=0"
    end

    # The content of the first column of a format row.
    def self.first_format_column
      "Marked"
    end

    # The default style for subtitles coming from formats without formatting
    # options.
    def self.default_style
      "Style: DefaultVCD, Arial,28,11861244,11861244,11861244,-2147483640,-1,0,1,1,2,2,30,30,30,0,0"
    end

    # The column headers for the default style
    def self.style_format_columns
      "Format: Name, Fontname, Fontsize, PrimaryColour, SecondaryColour, TertiaryColour, BackColour, Bold, Italic, BorderStyle, Outline, Shadow, Alignment, MarginL, MarginR, MarginV, AlphaLevel, Encoding"
    end
  end
end
