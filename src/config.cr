require "logger"

# :nodoc:
USAGE = 64

module Subtitles
  module Config
    # Aliases for various command-line arguments that may be specified.
    module Arguments
      LogFileOptions  = {"--log-file", "--logfile"}
      LogLevelOptions = {"--log-level", "--loglevel"}
      HelpOptions     = {"-h", "--help", "help"}
    end

    HELP_TEXT = <<-HELP
    subtitles.cr -- convert between subtitles formats

    Usage: subtitles /path/to/original.subtitles /path/to/output.format

    ...where the .format value indicates the filetype you wish to output. The
    input filetype will be automatically detected from the file contents.

    Available formats:
      - .srt          -- SubRip subtitles
      - .ass and .ssa -- Substation Alpha subtitles
      - .json         -- A JSON representation of the internal intermediary
                         format.

    Optionally one can specify the `--to` option, to specify an output format.
    The --to option takes the place of the file extension for a file which
    doesn't have one.

    HELP

    # Run the CLI on the specified args
    def self.command_line_interface(args = ARGV)
      infile, outfile, to_arg = nil, nil, nil
      while arg = args.shift?
        if Arguments::LogFileOptions.includes? arg
          args.shift # again to eat another arg
        elsif Arguments::LogLevelOptions.includes? arg
          args.shift # again to eat another arg
        elsif Arguments::HelpOptions.includes? arg
          STDERR.puts HELP_TEXT
          exit
        elsif {"--to", "-to"}.includes? arg
          to_arg = args.shift
        else
          if infile
            outfile = if arg === "-"
                        STDOUT
                      else
                        File.open arg, mode: "w"
                      end
          else
            infile = if arg === "-"
                       STDIN
                     else
                       File.open arg
                     end
          end
        end
      end
      if (input = infile) && (output = outfile)
        filetype = if output.is_a? File
                     Subtitles.by_extension!(output.as File)
                   else
                     Subtitles::Format.from_extension(to_arg.not_nil!) || raise "no valid filetype found for #{output.inspect}"
                   end
        intermediary = filetype.new(Subtitles.parse!(content: input).tap do |captions|
          puts "writing #{captions.size} captions from #{input.inspect} to #{output.inspect}"
        end)
        if (content = intermediary.content).responds_to? :size
          puts content.size
        end
        if (written = IO.copy(src: intermediary.content.rewind, dst: output)) < 16
          if (content = intermediary.content).responds_to? :size
            raise "only wrote #{written} bytes to the file -- expected #{content.size}"
          else
            raise "only wrote #{written} bytes for #{content.inspect}"
          end
        end
        output.flush
        input.close unless input == STDIN
        output.close unless output == STDOUT
      else
        STDERR.puts "Got input file #{infile.inspect} and output file #{outfile.inspect}"
        exit USAGE unless ENV["testing"]?
      end
    end

    # Default configuration values
    module Default
      # The default log file is
      def self.log_file
        if lf = ENV["subtitles_log_file"]?
          return File.open lf
        elsif Config.from_args? && (idx = ARGV.index { |arg| Arguments::LogFileOptions.includes? arg })
          ARGV.delete_at idx
          return File.open ARGV.delete_at idx
        end
        STDOUT
      end

      def self.log_level
        if ll = ENV["subtitles_log_level"]?
          log_level_string_value ll
        elsif ENV["debug"]? || ENV["subtitles_test"]?
          Logger::Severity::DEBUG
        elsif Config.from_args? && (idx = ARGV.index { |arg| Arguments::LogLevelOptions.includes? arg })
          ARGV.delete_at idx
          log_level_string_value ARGV.delete_at idx
        else
          Logger::Severity::INFO
        end
      end

      private def self.log_level_string_value(string level)
        case level.downcase
        when "debug" then Logger::Severity::DEBUG
        when "error" then Logger::Severity::ERROR
        when "fatal" then Logger::Severity::FATAL
        when "info"  then Logger::Severity::INFO
        when "warn"  then Logger::Severity::WARN
        else              raise "invalid log level #{level}"
        end
      end
    end

    @@log_file : IO?

    # where to output any logging info.
    def self.log_file : IO
      @@log_file ||= Default.log_file
    end

    @@log_level : Logger::Severity?

    # The amount of debugging information to log
    def self.log_level : Logger::Severity
      @@log_level ||= Default.log_level
    end

    @@logger : Logger?

    # A global(-ish) Logger instance
    def self.logger : Logger
      @@logger ||= (Logger.new log_file, log_level)
    end

    # Set to false to disable gathering command line arguments
    class_property? from_args : Bool = true
  end
end
