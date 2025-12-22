/// Log level for controlling output verbosity
pub type LogLevel {
  Verbose
  Silent
}

@internal
pub fn log(log_level: LogLevel, printer: fn() -> Nil) -> Nil {
  case log_level {
    Verbose -> printer()
    Silent -> Nil
  }
}
