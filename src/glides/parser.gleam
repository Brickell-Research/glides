import gleam/list
import gleam/option.{type Option, None, Some}
import glides/presentation.{type Presentation, Presentation}
import glides/slide.{type Slide, Slide}
import jot.{
  type Container, type Document, type Inline, Heading, Paragraph, Text,
  ThematicBreak,
}

/// Parse a Djot string into a Presentation
pub fn parse(djot_content: String) -> Presentation {
  let document = jot.parse(djot_content)
  document_to_presentation(document)
}

/// Convert a jot Document to a Presentation
fn document_to_presentation(document: Document) -> Presentation {
  let #(title, author, containers) = extract_frontmatter(document.content)
  let slides = split_into_slides(containers)

  Presentation(title: title, author: author, slides: slides)
}

/// Extract frontmatter (title/author) from the beginning of the document
/// TODO: Implement frontmatter parsing
fn extract_frontmatter(
  containers: List(Container),
) -> #(Option(String), Option(String), List(Container)) {
  // TODO: Parse frontmatter - look for ThematicBreak at start,
  // then paragraph with key: value pairs ending with em-dash (—)
  #(None, None, containers)
}

/// Split containers into slides on ThematicBreak (---)
pub fn split_into_slides(containers: List(Container)) -> List(Slide) {
  // TODO: Implement slide splitting on ThematicBreak

  do_split_into_slides(containers, list.new(), list.new())
}

fn do_split_into_slides(
  containers: List(Container),
  cur_slide_container: List(Container),
  cur_slide_list: List(Slide),
) -> List(Slide) {
  case containers {
    [] -> {
      case cur_slide_list, cur_slide_container {
        // first one
        [], [] -> do_split_into_slides([], cur_slide_container, cur_slide_list)
        _, _ -> {
          let new_slide_list =
            list.append(cur_slide_list, [make_slide(cur_slide_container)])
          let new_slide_container = []
          do_split_into_slides([], new_slide_container, new_slide_list)
        }
      }
    }
    [ThematicBreak, ..rest] ->
      case cur_slide_list, cur_slide_container {
        // first one
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
      let new_slide_list = cur_slide_list
      let new_slide_container = list.append(cur_slide_container, [first])
      do_split_into_slides(rest, new_slide_container, new_slide_list)
    }
  }
}

/// Create a Slide from content, extracting title from first heading if present
pub fn make_slide(content: List(Container)) -> Slide {
  // TODO: Extract title from first Heading if present
  Slide(title: None, content: content)
}

/// Convert inline elements to plain text (useful for frontmatter parsing)
pub fn inlines_to_text(inlines: List(Inline)) -> String {
  // TODO: Implement inline to text conversion
  ""
}
