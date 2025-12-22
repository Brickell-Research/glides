import gleam/list
import glides/cli/exit_status_codes.{Failure, Success}
import glides/cli/handler
import test_helpers

// ==== handle_args ====
pub fn handle_args_test() {
  [
    // #(command/arg(s), expected_output, failure_msg)
    // help arg
    #(["--help"], Success, "Expected --help args to succeed"),
    #(["-H"], Success, "Expected -H args to succeed"),
    // version arg
    #(["--version"], Success, "Expected --version args to succeed"),
    #(["-V"], Success, "Expected -V args to succeed"),
    // empty args
    #([], Success, "Expected empty args to succeed"),
    // unknown command/arg
    #(["unknown"], Failure, "Expected unknown command to fail"),
    #(["--unknown"], Failure, "Expected unknown arg to fail"),
    // compile command, with and without args
    #(["compile"], Failure, "Expected compile without file arg to fail"),
    #(
      ["compile", "nonexistent.djot"],
      Failure,
      "Expected compile with file command of nonexistent file to fail",
    ),
    #(
      ["compile", "gleam.toml"],
      Success,
      "Expected compile with existing file arg to succeed",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(input, expected_output, failure_msg) = test_case
    let actual_output = handler.handle_args_silent(input)

    test_helpers.expect_with_failure_msg(
      actual_output,
      expected_output,
      failure_msg,
    )
  })
}
