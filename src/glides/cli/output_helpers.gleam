import gleam/io
import gleam_community/ansi

@internal
pub fn print_help() -> Nil {
  io.println("")
  io.println(ansi.bold(ansi.cyan("  ┌─────────────────────────────────────┐")))
  io.println(
    ansi.bold(ansi.cyan("  │"))
    <> ansi.bold("           ✨ GLIDES ✨              ")
    <> ansi.bold(ansi.cyan("│")),
  )
  io.println(
    ansi.bold(ansi.cyan("  │"))
    <> ansi.dim("    Djot to HTML Slideshow Tool     ")
    <> ansi.bold(ansi.cyan("│")),
  )
  io.println(ansi.bold(ansi.cyan("  └─────────────────────────────────────┘")))
  io.println("")
  io.println(ansi.bold(ansi.yellow("USAGE:")))
  io.println("  glides " <> ansi.green("compile") <> " <file.djot>")
  io.println("")
  io.println(ansi.bold(ansi.yellow("COMMANDS:")))
  io.println(
    "  " <> ansi.green("compile") <> "    Compile a djot file to HTML slides",
  )
  io.println("")
  io.println(ansi.bold(ansi.yellow("OPTIONS:")))
  io.println("  " <> ansi.cyan("-h, --help") <> "     Show this help message")
  io.println("  " <> ansi.cyan("-V, --version") <> "  Show version information")
  io.println("")
}

@internal
pub fn print_usage() -> Nil {
  io.println("")
  io.println(
    ansi.dim("Usage: ") <> "glides " <> ansi.green("compile") <> " <file.djot>",
  )
  io.println(ansi.dim("Run 'glides --help' for more information."))
  io.println("")
}

@internal
pub fn print_version() -> Nil {
  io.println(ansi.bold("glides") <> " " <> ansi.cyan("v1.0.0"))
}

@internal
pub fn print_compiling(file_path: String) -> Nil {
  io.println(ansi.bold(ansi.cyan("▶")) <> " Compiling " <> ansi.dim(file_path))
}

@internal
pub fn print_success(message: String) -> Nil {
  io.println(ansi.bold(ansi.green("✓")) <> " " <> message)
}

@internal
pub fn print_error(message: String) -> Nil {
  io.println(ansi.bold(ansi.red("✗")) <> " " <> ansi.red(message))
}
