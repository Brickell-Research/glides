import gleam/int
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import glides/presentation.{type Presentation}
import glides/slide.{type Slide}
import jot.{type Container, type Inline}

/// Render a complete presentation to HTML
pub fn render_presentation(presentation: Presentation) -> String {
  let total = list.length(presentation.slides)
  let slides_html =
    presentation.slides
    |> list.index_map(fn(slide, index) { render_slide(slide, index, total) })
    |> string.concat

  html_wrapper(presentation.title, slides_html)
}

/// Render a single slide to HTML
pub fn render_slide(slide: Slide, _index: Int, _total: Int) -> String {
  let title_html = render_title(slide.title)
  let content_html = render_containers(slide.content)

  "<section class=\"slide\">"
  <> title_html
  <> "<div class=\"slide-content\">"
  <> content_html
  <> "</div></section>"
}

/// Render slide title (list of inlines) to HTML
pub fn render_title(title: Option(List(Inline))) -> String {
  case title {
    None -> ""
    Some(inlines) ->
      "<h1 class=\"slide-title\">" <> render_inlines(inlines) <> "</h1>"
  }
}

/// Render a list of containers to HTML
pub fn render_containers(containers: List(Container)) -> String {
  containers
  |> list.map(render_container)
  |> string.concat
}

/// Render a single container to HTML
pub fn render_container(container: Container) -> String {
  case container {
    jot.Paragraph(_, inlines) -> "<p>" <> render_inlines(inlines) <> "</p>"
    jot.Heading(_, level, inlines) -> {
      let tag = "h" <> int.to_string(level)
      "<" <> tag <> ">" <> render_inlines(inlines) <> "</" <> tag <> ">"
    }
    jot.Codeblock(_, language, content) -> {
      let class_attr = case language {
        Some(lang) -> " class=\"language-" <> lang <> "\""
        None -> ""
      }
      "<pre><code"
      <> class_attr
      <> ">"
      <> escape_html(content)
      <> "</code></pre>"
    }
    jot.ThematicBreak -> "<hr>"
    jot.BulletList(_, _, items) -> {
      let items_html =
        items
        |> list.map(fn(item) { "<li>" <> render_containers(item) <> "</li>" })
        |> string.concat
      "<ul>" <> items_html <> "</ul>"
    }
    jot.BlockQuote(_, items) ->
      "<blockquote>" <> render_containers(items) <> "</blockquote>"
    jot.Div(_, items) -> "<div>" <> render_containers(items) <> "</div>"
    jot.RawBlock(content) -> content
  }
}

/// Render a list of inlines to HTML
pub fn render_inlines(inlines: List(Inline)) -> String {
  inlines
  |> list.map(render_inline)
  |> string.concat
}

/// Render a single inline to HTML
pub fn render_inline(inline: Inline) -> String {
  case inline {
    jot.Text(text) -> escape_html(text)
    jot.Code(content) -> "<code>" <> escape_html(content) <> "</code>"
    jot.Emphasis(inlines) -> "<em>" <> render_inlines(inlines) <> "</em>"
    jot.Strong(inlines) -> "<strong>" <> render_inlines(inlines) <> "</strong>"
    jot.Link(_, inlines, destination) -> {
      let href = case destination {
        jot.Url(url) -> url
        jot.Reference(ref) -> "#" <> ref
      }
      "<a href=\"" <> href <> "\">" <> render_inlines(inlines) <> "</a>"
    }
    jot.Image(_, inlines, destination) -> {
      let src = case destination {
        jot.Url(url) -> url
        jot.Reference(ref) -> ref
      }
      let alt = render_inlines(inlines)
      "<img src=\"" <> src <> "\" alt=\"" <> alt <> "\">"
    }
    jot.Span(_, inlines) -> "<span>" <> render_inlines(inlines) <> "</span>"
    jot.Linebreak -> "<br>"
    jot.NonBreakingSpace -> "&nbsp;"
    jot.Footnote(ref) ->
      "<sup><a href=\"#fn-" <> ref <> "\">" <> ref <> "</a></sup>"
    jot.MathInline(content) ->
      "<span class=\"math\">" <> escape_html(content) <> "</span>"
    jot.MathDisplay(content) ->
      "<div class=\"math-display\">" <> escape_html(content) <> "</div>"
  }
}

/// Escape HTML special characters
fn escape_html(text: String) -> String {
  text
  |> string.replace("&", "&amp;")
  |> string.replace("<", "&lt;")
  |> string.replace(">", "&gt;")
  |> string.replace("\"", "&quot;")
}

/// Generate the HTML document wrapper (head, body, styles, scripts)
pub fn html_wrapper(title: Option(String), content: String) -> String {
  let title_text = case title {
    Some(t) -> t
    None -> "Presentation"
  }

  "<!DOCTYPE html>
<html lang=\"en\">
<head>
<meta charset=\"UTF-8\">
<meta name=\"viewport\" content=\"width=device-width, initial-scale=1.0\">
<title>" <> title_text <> "</title>" <> default_styles() <> "</head>
<body>" <> content <> "<div id=\"slide-counter\"></div>" <> navigation_script() <> "</body>
</html>"
}

/// Generate navigation JavaScript
pub fn navigation_script() -> String {
  "<script>
(function() {
  let currentSlide = 0;
  const slides = document.querySelectorAll('section.slide');
  const total = slides.length;

  function showSlide(index) {
    if (index < 0) index = 0;
    if (index >= total) index = total - 1;
    currentSlide = index;

    slides.forEach((slide, i) => {
      slide.style.display = i === currentSlide ? 'flex' : 'none';
    });

    updateCounter();
  }

  function updateCounter() {
    const counter = document.getElementById('slide-counter');
    if (counter) {
      counter.textContent = (currentSlide + 1) + ' / ' + total;
    }
  }

  function nextSlide() {
    showSlide(currentSlide + 1);
  }

  function prevSlide() {
    showSlide(currentSlide - 1);
  }

  document.addEventListener('keydown', function(e) {
    switch(e.key) {
      case 'ArrowRight':
      case ' ':
        nextSlide();
        break;
      case 'ArrowLeft':
        prevSlide();
        break;
      case 'f':
        document.documentElement.requestFullscreen();
        break;
    }
  });

  showSlide(0);
})();
</script>"
}

/// Generate default CSS styles
pub fn default_styles() -> String {
  "<style>
* {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html, body {
  height: 100%;
  font-family: system-ui, -apple-system, sans-serif;
  background: #1a1a2e;
  color: #eee;
}

section.slide {
  display: none;
  flex-direction: column;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  padding: 2rem 4rem;
  text-align: center;
}

section.slide:first-of-type {
  display: flex;
}

.slide-title {
  font-size: 3rem;
  margin-bottom: 1.5rem;
  color: #fff;
}

.slide-content {
  font-size: 1.5rem;
  line-height: 1.6;
  max-width: 80%;
}

.slide-content h1, .slide-content h2, .slide-content h3 {
  margin: 1rem 0;
}

.slide-content p {
  margin: 0.75rem 0;
}

.slide-content ul, .slide-content ol {
  text-align: left;
  margin: 1rem 0;
  padding-left: 2rem;
}

.slide-content li {
  margin: 0.5rem 0;
}

.slide-content code {
  background: #2d2d44;
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
  font-family: 'Fira Code', monospace;
}

.slide-content pre {
  background: #2d2d44;
  padding: 1.5rem;
  border-radius: 8px;
  text-align: left;
  overflow-x: auto;
  margin: 1rem 0;
}

.slide-content pre code {
  background: none;
  padding: 0;
}

.slide-content a {
  color: #64b5f6;
}

#slide-counter {
  position: fixed;
  bottom: 1rem;
  right: 1rem;
  font-size: 0.9rem;
  color: #888;
}

@media print {
  section.slide {
    display: flex !important;
    page-break-after: always;
    min-height: 100vh;
  }
}
</style>"
}
