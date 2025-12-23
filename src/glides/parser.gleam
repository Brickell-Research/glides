import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import glides/presentation.{type Presentation, Presentation}
import glides/slide.{type Slide, Slide}
import jot.{
  type Container, type Document, type Inline, Heading, Paragraph, Text,
  ThematicBreak,
}

/// Parse a Djot string into a Presentation
pub fn parse(djot_content: String) -> Presentation {
  djot_content
  |> jot.parse
  |> document_to_presentation
}

/// Convert a jot Document to a Presentation
fn document_to_presentation(document: Document) -> Presentation {
  let #(title, author, containers) = extract_frontmatter(document.content)
  let slides = split_into_slides(containers)

  Presentation(title: title, author: author, slides: slides)
}

/// Extract frontmatter (title/author) from the beginning of the document
/// Frontmatter format: starts with ThematicBreak, then paragraph with
/// key: value pairs, ending with em-dash (—) which is what --- becomes in djot
pub fn extract_frontmatter(
  containers: List(Container),
) -> #(Option(String), Option(String), List(Container)) {
  case containers {
    [ThematicBreak, Paragraph(_, inlines), ..rest] -> {
      let text = inlines_to_text(inlines)
      // Check if it ends with em-dash (which is what --- becomes in djot)
      case string.ends_with(text, "—") {
        True -> {
          let frontmatter_text = string.drop_end(text, 1)
          let #(title, author) = parse_frontmatter_text(frontmatter_text)
          #(title, author, rest)
        }
        False -> {
          // Not frontmatter, treat as regular content
          #(None, None, containers)
        }
      }
    }
    _ -> #(None, None, containers)
  }
}

/// Parse frontmatter text containing key: value pairs separated by newlines
fn parse_frontmatter_text(text: String) -> #(Option(String), Option(String)) {
  text
  |> string.split("\n")
  |> list.fold(#(None, None), fn(acc, line) {
    let #(title, author) = acc
    case string.split_once(line, ":") {
      Ok(#(key, value)) -> {
        let key = string.trim(string.lowercase(key))
        let value = string.trim(value)
        case key {
          "title" -> #(Some(value), author)
          "author" -> #(title, Some(value))
          _ -> acc
        }
      }
      Error(_) -> acc
    }
  })
}

/// Split containers into slides on ThematicBreak (---)
pub fn split_into_slides(containers: List(Container)) -> List(Slide) {
  do_split_into_slides(containers, list.new(), list.new())
}

fn do_split_into_slides(
  containers: List(Container),
  cur_slide_container: List(Container),
  cur_slide_list: List(Slide),
) -> List(Slide) {
  case containers {
    [] -> {
      case cur_slide_container {
        [] -> cur_slide_list
        _ -> list.append(cur_slide_list, [make_slide(cur_slide_container)])
      }
    }
    [ThematicBreak, ..rest] ->
      case cur_slide_list, cur_slide_container {
        [], [] ->
          do_split_into_slides(rest, cur_slide_container, cur_slide_list)
        _, _ -> {
          let new_slide_list =
            list.append(cur_slide_list, [make_slide(cur_slide_container)])
          let new_slide_container = []
          do_split_into_slides(rest, new_slide_container, new_slide_list)
        }
      }
    [first, ..rest] -> {
      do_split_into_slides(
        rest,
        list.append(cur_slide_container, [first]),
        cur_slide_list,
      )
    }
  }
}

/// Create a Slide from content, extracting title from first heading if present
pub fn make_slide(content: List(Container)) -> Slide {
  case content {
    [Heading(_, _, inlines), ..rest] ->
      Slide(title: Some(inlines), content: rest)
    _ -> Slide(title: None, content: content)
  }
}

/// Convert inline elements to plain text (useful for frontmatter parsing)
pub fn inlines_to_text(inlines: List(Inline)) -> String {
  inlines
  |> list.map(inline_to_text)
  |> list.fold("", fn(acc, text) { acc <> text })
}

fn inline_to_text(inline: Inline) -> String {
  case inline {
    Text(text) -> text
    jot.Code(text) -> text
    jot.Emphasis(inner) -> inlines_to_text(inner)
    jot.Strong(inner) -> inlines_to_text(inner)
    jot.Link(_, inner, _) -> inlines_to_text(inner)
    jot.Image(_, inner, _) -> inlines_to_text(inner)
    jot.Span(_, inner) -> inlines_to_text(inner)
    jot.Linebreak -> "\n"
    jot.NonBreakingSpace -> " "
    jot.Footnote(_) -> ""
    jot.MathInline(text) -> text
    jot.MathDisplay(text) -> text
  }
}
