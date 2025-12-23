import gleam/string
import glides/cli/exit_status_codes.{type ExitStatusCode, Failure, Success}
import glides/cli/logger.{type LogLevel, Silent, Verbose}
import glides/cli/output_helpers
import glides/parser
import glides/render
import simplifile

/// Handle CLI arguments and return appropriate exit status
pub fn handle_args(args: List(String)) -> ExitStatusCode {
  handle_args_with_log_level(args, Verbose)
}

/// Handle CLI arguments silently (for testing)
pub fn handle_args_silent(args: List(String)) -> ExitStatusCode {
  handle_args_with_log_level(args, Silent)
}

fn handle_args_with_log_level(
  args: List(String),
  log_level: LogLevel,
) -> ExitStatusCode {
  case args {
    ["compile", file_path] -> compile_with_log_level(file_path, log_level)
    ["compile"] -> {
      logger.log(log_level, fn() {
        output_helpers.print_error("Missing file path")
      })
      logger.log(log_level, fn() { output_helpers.print_usage() })
      Failure
    }
    ["--help"] | ["-H"] -> {
      logger.log(log_level, fn() { output_helpers.print_help() })
      Success
    }
    ["--version"] | ["-V"] -> {
      logger.log(log_level, fn() { output_helpers.print_version() })
      Success
    }
    [] -> {
      logger.log(log_level, fn() { output_helpers.print_help() })
      Success
    }
    [unknown, ..] -> {
      logger.log(log_level, fn() {
        output_helpers.print_error("Unknown command: " <> unknown)
      })
      logger.log(log_level, fn() { output_helpers.print_usage() })
      Failure
    }
  }
}

/// Compile a djot file to HTML slides
pub fn compile(file_path: String) -> ExitStatusCode {
  compile_with_log_level(file_path, Verbose)
}

fn compile_with_log_level(
  file_path: String,
  log_level: LogLevel,
) -> ExitStatusCode {
  case simplifile.read(file_path) {
    Ok(content) -> {
      logger.log(log_level, fn() { output_helpers.print_compiling(file_path) })

      // Parse and render
      let presentation = parser.parse(content)
      let html = render.render_presentation(presentation)

      // Generate output path (.djot -> .html)
      let output_path = case string.ends_with(file_path, ".djot") {
        True -> string.drop_end(file_path, 5) <> ".html"
        False -> file_path <> ".html"
      }

      // Write output
      case simplifile.write(output_path, html) {
        Ok(_) -> {
          logger.log(log_level, fn() {
            output_helpers.print_success("Compiled to " <> output_path)
          })
          Success
        }
        Error(_) -> {
          logger.log(log_level, fn() {
            output_helpers.print_error("Failed to write: " <> output_path)
          })
          Failure
        }
      }
    }
    Error(_) -> {
      logger.log(log_level, fn() {
        output_helpers.print_error("File not found: " <> file_path)
      })
      Failure
    }
  }
}
