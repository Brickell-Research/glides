import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import glides/parser
import jot
import simplifile
import test_helpers

// ==== parse ====
pub fn parse_test() {
  [
    // #(file, expected_title, expected_author, expected_slide_count, failure_msg)
    #(
      "test/test_corpus/simple.djot",
      None,
      None,
      3,
      "simple.djot: 3 slides, no frontmatter",
    ),
    #(
      "test/test_corpus/single_slide.djot",
      None,
      None,
      1,
      "single_slide.djot: 1 slide, no frontmatter",
    ),
    #(
      "test/test_corpus/no_titles.djot",
      None,
      None,
      3,
      "no_titles.djot: 3 slides without headings",
    ),
    #("test/test_corpus/empty.djot", None, None, 0, "empty.djot: 0 slides"),
    #(
      "test/test_corpus/with_frontmatter.djot",
      Some("My Presentation"),
      Some("Jane Doe"),
      2,
      "with_frontmatter.djot: 2 slides with title and author",
    ),
    #(
      "test/test_corpus/frontmatter_only.djot",
      Some("Just Frontmatter"),
      Some("Test Author"),
      0,
      "frontmatter_only.djot: frontmatter with em-dash edge case, 0 slides",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(file, expected_title, expected_author, expected_slides, failure_msg) =
      test_case
    let assert Ok(content) = simplifile.read(file)
    let presentation = parser.parse(content)

    // assert title
    test_helpers.expect_with_failure_msg(
      presentation.title,
      expected_title,
      failure_msg <> " (title)",
    )

    // assert author
    test_helpers.expect_with_failure_msg(
      presentation.author,
      expected_author,
      failure_msg <> " (author)",
    )

    // assert slide count
    test_helpers.expect_with_failure_msg(
      list.length(presentation.slides),
      expected_slides,
      failure_msg <> " (slide count)",
    )
  })
}

// ==== extract_frontmatter ====
pub fn extract_frontmatter_test() {
  [
    // #(containers, expected_title, expected_author, expected_rest_count, failure_msg)
    #([], None, None, 0, "Empty containers should have no frontmatter"),
    #(
      [jot.Paragraph(dict.new(), [jot.Text("Just text")])],
      None,
      None,
      1,
      "Paragraph without ThematicBreak should have no frontmatter",
    ),
    #(
      [jot.ThematicBreak, jot.Paragraph(dict.new(), [jot.Text("No em-dash")])],
      None,
      None,
      2,
      "ThematicBreak + Paragraph without em-dash should have no frontmatter",
    ),
    #(
      [
        jot.ThematicBreak,
        jot.Paragraph(dict.new(), [jot.Text("title: My Title\n—")]),
      ],
      Some("My Title"),
      None,
      0,
      "Frontmatter with title only",
    ),
    #(
      [
        jot.ThematicBreak,
        jot.Paragraph(dict.new(), [jot.Text("author: Jane Doe\n—")]),
      ],
      None,
      Some("Jane Doe"),
      0,
      "Frontmatter with author only",
    ),
    #(
      [
        jot.ThematicBreak,
        jot.Paragraph(dict.new(), [
          jot.Text("title: My Title\nauthor: Jane Doe\n—"),
        ]),
      ],
      Some("My Title"),
      Some("Jane Doe"),
      0,
      "Frontmatter with title and author",
    ),
    #(
      [
        jot.ThematicBreak,
        jot.Paragraph(dict.new(), [
          jot.Text("title: My Title\nauthor: Jane Doe\n—"),
        ]),
        jot.Heading(dict.new(), 1, [jot.Text("Slide 1")]),
      ],
      Some("My Title"),
      Some("Jane Doe"),
      1,
      "Frontmatter followed by content",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(
      containers,
      expected_title,
      expected_author,
      expected_rest,
      failure_msg,
    ) = test_case
    let #(title, author, rest) = parser.extract_frontmatter(containers)

    // assert title
    test_helpers.expect_with_failure_msg(
      title,
      expected_title,
      failure_msg <> " (title)",
    )

    // assert author
    test_helpers.expect_with_failure_msg(
      author,
      expected_author,
      failure_msg <> " (author)",
    )

    // assert remaining container count
    test_helpers.expect_with_failure_msg(
      list.length(rest),
      expected_rest,
      failure_msg <> " (rest count)",
    )
  })
}

// ==== split_into_slides ====
pub fn split_into_slides_test() {
  [
    // #(containers, expected_slide_count, failure_msg)
    #([], 0, "Empty containers should produce 0 slides"),
    #(
      [jot.Paragraph(dict.new(), [jot.Text("Hello")])],
      1,
      "Single paragraph should produce 1 slide",
    ),
    #(
      [
        jot.Paragraph(dict.new(), [jot.Text("Slide 1")]),
        jot.ThematicBreak,
        jot.Paragraph(dict.new(), [jot.Text("Slide 2")]),
      ],
      2,
      "Paragraph, ThematicBreak, Paragraph should produce 2 slides",
    ),
    #(
      [jot.ThematicBreak, jot.ThematicBreak, jot.ThematicBreak],
      0,
      "Only ThematicBreaks should produce 0 slides (no content)",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(containers, expected_count, failure_msg) = test_case
    let slides = parser.split_into_slides(containers)

    // assert slide count
    test_helpers.expect_with_failure_msg(
      list.length(slides),
      expected_count,
      failure_msg,
    )
  })
}

// ==== make_slide ====
pub fn make_slide_test() {
  [
    // #(content, expected_has_title, failure_msg)
    #([], False, "Empty content should have no title"),
    #(
      [jot.Paragraph(dict.new(), [jot.Text("Just text")])],
      False,
      "Paragraph-only content should have no title",
    ),
    #(
      [jot.Heading(dict.new(), 1, [jot.Text("Title")])],
      True,
      "Heading-only content should have title",
    ),
    #(
      [
        jot.Heading(dict.new(), 1, [jot.Text("Title")]),
        jot.Paragraph(dict.new(), [jot.Text("Body")]),
      ],
      True,
      "Heading + Paragraph should have title",
    ),
    #(
      [
        jot.Paragraph(dict.new(), [jot.Text("Body")]),
        jot.Heading(dict.new(), 1, [jot.Text("Title")]),
      ],
      False,
      "Paragraph then Heading should NOT have title (heading must be first)",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(content, expected_has_title, failure_msg) = test_case
    let slide = parser.make_slide(content)

    // assert slide title
    test_helpers.expect_with_failure_msg(
      option.is_some(slide.title),
      expected_has_title,
      failure_msg,
    )
  })
}

// ==== inlines_to_text ====
pub fn inlines_to_text_test() {
  [
    // #(inlines, expected_text, failure_msg)
    #([], "", "Empty inlines should produce empty string"),
    #([jot.Text("Hello")], "Hello", "Single text inline"),
    #(
      [jot.Text("Hello "), jot.Text("World")],
      "Hello World",
      "Multiple text inlines",
    ),
    #(
      [jot.Strong([jot.Text("bold")])],
      "bold",
      "Strong inline should extract text",
    ),
    #(
      [jot.Emphasis([jot.Text("italic")])],
      "italic",
      "Emphasis inline should extract text",
    ),
    #([jot.Code("code")], "code", "Code inline should extract text"),
    #(
      [jot.Text("a"), jot.Linebreak, jot.Text("b")],
      "a\nb",
      "Linebreak should become newline",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(inlines, expected_text, failure_msg) = test_case
    let text = parser.inlines_to_text(inlines)

    // assert text
    test_helpers.expect_with_failure_msg(text, expected_text, failure_msg)
  })
}
