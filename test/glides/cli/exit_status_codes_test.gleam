import gleam/list
import glides/cli/exit_status_codes.{Failure, Success}
import test_helpers

/// ==== to_int ====
pub fn to_int_test() {
  [
    #(Success, 0, "Expected success to equal 0."),
    #(Failure, 1, "Expected failure to equal 1."),
  ]
  |> list.each(fn(test_case) {
    let #(input, expected_output, failure_msg) = test_case
    let actual_output = exit_status_codes.to_int(input)

    test_helpers.expect_with_failure_msg(
      actual_output,
      expected_output,
      failure_msg,
    )
  })
}
