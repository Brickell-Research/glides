import gleam/dict
import gleam/list
import gleam/option.{None, Some}
import gleam/string
import glides/parser
import glides/render
import glides/slide.{Slide}
import jot
import simplifile
import test_helpers

// ==== render_inline ====
pub fn render_inline_test() {
  [
    // #(inline, expected_html, failure_msg)
    #(jot.Text("Hello"), "Hello", "Text should render as-is"),
    #(jot.Text("<script>"), "&lt;script&gt;", "Text should escape HTML"),
    #(
      jot.Code("let x = 1"),
      "<code>let x = 1</code>",
      "Code should wrap in code tag",
    ),
    #(
      jot.Emphasis([jot.Text("italic")]),
      "<em>italic</em>",
      "Emphasis should wrap in em tag",
    ),
    #(
      jot.Strong([jot.Text("bold")]),
      "<strong>bold</strong>",
      "Strong should wrap in strong tag",
    ),
    #(
      jot.Link(dict.new(), [jot.Text("link")], jot.Url("https://example.com")),
      "<a href=\"https://example.com\">link</a>",
      "Link should render as anchor tag",
    ),
    #(jot.Linebreak, "<br>", "Linebreak should render as br tag"),
    #(jot.NonBreakingSpace, "&nbsp;", "NonBreakingSpace should render as nbsp"),
  ]
  |> list.each(fn(test_case) {
    let #(inline, expected_html, failure_msg) = test_case
    let html = render.render_inline(inline)

    test_helpers.expect_with_failure_msg(html, expected_html, failure_msg)
  })
}

// ==== render_inlines ====
pub fn render_inlines_test() {
  [
    // #(inlines, expected_html, failure_msg)
    #([], "", "Empty inlines should produce empty string"),
    #([jot.Text("Hello")], "Hello", "Single text inline"),
    #(
      [jot.Text("Hello "), jot.Strong([jot.Text("World")])],
      "Hello <strong>World</strong>",
      "Multiple inlines should concatenate",
    ),
    #(
      [jot.Emphasis([jot.Strong([jot.Text("nested")])])],
      "<em><strong>nested</strong></em>",
      "Nested inlines should render correctly",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(inlines, expected_html, failure_msg) = test_case
    let html = render.render_inlines(inlines)

    test_helpers.expect_with_failure_msg(html, expected_html, failure_msg)
  })
}

// ==== render_container ====
pub fn render_container_test() {
  [
    // #(container, expected_contains, failure_msg)
    #(
      jot.Paragraph(dict.new(), [jot.Text("Hello")]),
      "<p>Hello</p>",
      "Paragraph should wrap in p tag",
    ),
    #(
      jot.Heading(dict.new(), 1, [jot.Text("Title")]),
      "<h1>Title</h1>",
      "Heading 1 should wrap in h1 tag",
    ),
    #(
      jot.Heading(dict.new(), 2, [jot.Text("Subtitle")]),
      "<h2>Subtitle</h2>",
      "Heading 2 should wrap in h2 tag",
    ),
    #(
      jot.Codeblock(dict.new(), Some("gleam"), "pub fn main() {}"),
      "<pre><code class=\"language-gleam\">pub fn main() {}</code></pre>",
      "CodeBlock with language should have language class",
    ),
    #(
      jot.Codeblock(dict.new(), None, "plain code"),
      "<pre><code>plain code</code></pre>",
      "CodeBlock without language should not have class",
    ),
    #(jot.ThematicBreak, "<hr>", "ThematicBreak should render as hr"),
  ]
  |> list.each(fn(test_case) {
    let #(container, expected_html, failure_msg) = test_case
    let html = render.render_container(container)

    test_helpers.expect_with_failure_msg(html, expected_html, failure_msg)
  })
}

// ==== render_containers ====
pub fn render_containers_test() {
  [
    // #(containers, expected_html, failure_msg)
    #([], "", "Empty containers should produce empty string"),
    #(
      [jot.Paragraph(dict.new(), [jot.Text("One")])],
      "<p>One</p>",
      "Single container",
    ),
    #(
      [
        jot.Paragraph(dict.new(), [jot.Text("One")]),
        jot.Paragraph(dict.new(), [jot.Text("Two")]),
      ],
      "<p>One</p><p>Two</p>",
      "Multiple containers should concatenate",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(containers, expected_html, failure_msg) = test_case
    let html = render.render_containers(containers)

    test_helpers.expect_with_failure_msg(html, expected_html, failure_msg)
  })
}

// ==== render_title ====
pub fn render_title_test() {
  [
    // #(title, expected_html, failure_msg)
    #(None, "", "None title should produce empty string"),
    #(
      Some([jot.Text("My Title")]),
      "<h1 class=\"slide-title\">My Title</h1>",
      "Title should wrap in h1 with class",
    ),
    #(
      Some([jot.Text("Title with "), jot.Strong([jot.Text("bold")])]),
      "<h1 class=\"slide-title\">Title with <strong>bold</strong></h1>",
      "Title with formatting",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(title, expected_html, failure_msg) = test_case
    let html = render.render_title(title)

    test_helpers.expect_with_failure_msg(html, expected_html, failure_msg)
  })
}

// ==== render_slide ====
pub fn render_slide_test() {
  [
    // #(slide, index, total, expected_contains, failure_msg)
    #(
      Slide(title: None, content: []),
      0,
      1,
      "section",
      "Empty slide should contain section tag",
    ),
    #(
      Slide(title: Some([jot.Text("Hello")]), content: []),
      0,
      3,
      "slide-title",
      "Slide with title should contain slide-title class",
    ),
    #(
      Slide(title: None, content: [
        jot.Paragraph(dict.new(), [jot.Text("Content")]),
      ]),
      1,
      3,
      "<p>Content</p>",
      "Slide with content should render content",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(slide, index, total, expected_contains, failure_msg) = test_case
    let html = render.render_slide(slide, index, total)

    test_helpers.expect_with_failure_msg(
      string.contains(html, expected_contains),
      True,
      failure_msg,
    )
  })
}

// ==== render_presentation (integration tests with corpus) ====
pub fn render_presentation_test() {
  [
    // #(file, expected_contains_list, failure_msg)
    #(
      "test/test_corpus/simple.djot",
      [
        "<html",
        "</html>",
        "<section",
        "Welcome",
        "Second Slide",
        "Code Example",
      ],
      "simple.djot should render all slides with proper HTML structure",
    ),
    #(
      "test/test_corpus/single_slide.djot",
      ["<section", "Only One Slide"],
      "single_slide.djot should render single slide",
    ),
    #(
      "test/test_corpus/with_frontmatter.djot",
      ["<title>My Presentation</title>", "Welcome", "Second Slide"],
      "with_frontmatter.djot should use title in document head",
    ),
    #(
      "test/test_corpus/empty.djot",
      ["<html", "</html>"],
      "empty.djot should still produce valid HTML structure",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(file, expected_contains_list, failure_msg) = test_case
    let assert Ok(content) = simplifile.read(file)
    let presentation = parser.parse(content)
    let html = render.render_presentation(presentation)

    // Check each expected string is contained in the output
    expected_contains_list
    |> list.each(fn(expected) {
      test_helpers.expect_with_failure_msg(
        string.contains(html, expected),
        True,
        failure_msg <> " (missing: " <> expected <> ")",
      )
    })
  })
}

// ==== html_wrapper ====
pub fn html_wrapper_test() {
  [
    // #(title, content, expected_contains_list, failure_msg)
    #(
      None,
      "<section>test</section>",
      [
        "<!DOCTYPE html>",
        "<html",
        "</html>",
        "<head>",
        "<body>",
        "<section>test</section>",
      ],
      "HTML wrapper should contain basic structure",
    ),
    #(
      Some("My Slides"),
      "",
      ["<title>My Slides</title>"],
      "HTML wrapper should use provided title",
    ),
    #(
      None,
      "",
      ["<title>Presentation</title>"],
      "HTML wrapper should use default title when none provided",
    ),
  ]
  |> list.each(fn(test_case) {
    let #(title, content, expected_contains_list, failure_msg) = test_case
    let html = render.html_wrapper(title, content)

    expected_contains_list
    |> list.each(fn(expected) {
      test_helpers.expect_with_failure_msg(
        string.contains(html, expected),
        True,
        failure_msg <> " (missing: " <> expected <> ")",
      )
    })
  })
}

// ==== navigation_script ====
pub fn navigation_script_test() {
  let script = render.navigation_script()

  [
    // expected_contains, failure_msg
    #("<script>", "Script should be wrapped in script tags"),
    #("</script>", "Script should be wrapped in script tags"),
    #("ArrowRight", "Script should handle ArrowRight key"),
    #("ArrowLeft", "Script should handle ArrowLeft key"),
    #("addEventListener", "Script should add event listeners"),
  ]
  |> list.each(fn(test_case) {
    let #(expected, failure_msg) = test_case

    test_helpers.expect_with_failure_msg(
      string.contains(script, expected),
      True,
      failure_msg,
    )
  })
}

// ==== default_styles ====
pub fn default_styles_test() {
  let styles = render.default_styles()

  [
    // expected_contains, failure_msg
    #("<style>", "Styles should be wrapped in style tags"),
    #("</style>", "Styles should be wrapped in style tags"),
    #(".slide", "Styles should include slide class"),
    #("section", "Styles should style section elements"),
  ]
  |> list.each(fn(test_case) {
    let #(expected, failure_msg) = test_case

    test_helpers.expect_with_failure_msg(
      string.contains(styles, expected),
      True,
      failure_msg,
    )
  })
}
