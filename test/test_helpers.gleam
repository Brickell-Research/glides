/// custom test assertion handler that takes in a message to display on failure
pub fn expect_with_failure_msg(actual: a, expected: a, failure_msg: String) {
  case actual == expected {
    True -> Nil
    False -> panic as failure_msg
  }
}
