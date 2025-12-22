import argv
import glides/cli/exit_status_codes
import glides/cli/handler

pub fn main() -> Nil {
  let exit_code =
    argv.load().arguments
    |> handler.handle_args()
    |> exit_status_codes.to_int()

  halt(exit_code)
}

@external(erlang, "erlang", "halt")
@external(javascript, "./glides_ffi.mjs", "halt")
fn halt(code: Int) -> Nil
