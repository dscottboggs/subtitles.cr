require "logger"

module Subtitles
  module Config
    module Arguments
      LogFileOptions  = {"--log-file", "--logfile"}
      LogLevelOptions = {"--log-level", "--loglevel"}
      HelpOptions = { "-h", "--help", "help" }
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

    HELP

    module Defaults
      def self.log_file
        if lf = ENV["subtitles_log_file"]?
          return File.open lf
        elsif Config.from_args? && (idx = ARGV.index { |arg| Arguments::LogFileOptions.includes? arg })
          ARGV.delete_at idx
          return File.open ARGV.delete_at idx
        end
        STDOUT
      end
    end

    @@log_file : IO?

    def self.log_file : IO
      @@log_file ||= if lf = ENV["subtitles_log_file"]?
                       return File.open lf
                     elsif Config.from_args? && (idx = ARGV.index { |arg| Arguments::LogFileOptions.includes? arg })
                       ARGV.delete_at idx
                       return File.open ARGV.delete_at idx
                     else
                       STDOUT
                     end
    end

    @@log_level : Logger::Severity?

    def self.log_level : Logger::Severity
      @@log_level ||= if ll = ENV["subtitles_log_level"]?
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

    @@logger : Logger?

    def self.logger : Logger
      @@logger ||= (Logger.new log_file, log_level)
    end

    class_property? from_args : Bool = true

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
end
