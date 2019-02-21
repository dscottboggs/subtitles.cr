# If you put the call to #command_line_interface in the main file, it will be
# run when "subtitles" is required. This separates the action into a separate
# file, which can then be compiled to an executable, like so:
#
# ```
# crystal build --release --static -o subtitles src/cli.cr
# ```
require "./subtitles"
Subtitles::Config.command_line_interface
