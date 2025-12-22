import gleam/option.{type Option}
import glides/slide.{type Slide}

/// A complete presentation with metadata and slides
pub type Presentation {
  Presentation(
    title: Option(String),
    author: Option(String),
    slides: List(Slide),
  )
}
