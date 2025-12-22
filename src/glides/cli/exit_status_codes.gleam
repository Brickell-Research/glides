/// Exit status codes for the CLI
pub type ExitStatusCode {
  Success
  Failure
}

/// Convert an exit status code to its integer representation
@internal
pub fn to_int(code: ExitStatusCode) -> Int {
  case code {
    Success -> 0
    Failure -> 1
  }
}
