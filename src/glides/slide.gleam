import gleam/option.{type Option}
import jot.{type Container, type Inline}

/// A single slide in a presentation
pub type Slide {
  Slide(title: Option(List(Inline)), content: List(Container))
}
