import gleam/option.{type Option}
import glides/presentation.{type Presentation}
import glides/slide.{type Slide}
import jot.{type Container, type Inline}

/// Render a complete presentation to HTML
pub fn render_presentation(presentation: Presentation) -> String {
  // TODO: Implement
  ""
}

/// Render a single slide to HTML
pub fn render_slide(slide: Slide, index: Int, total: Int) -> String {
  // TODO: Implement
  ""
}

/// Render slide title (list of inlines) to HTML
pub fn render_title(title: Option(List(Inline))) -> String {
  // TODO: Implement
  ""
}

/// Render a list of containers to HTML
pub fn render_containers(containers: List(Container)) -> String {
  // TODO: Implement
  ""
}

/// Render a single container to HTML
pub fn render_container(container: Container) -> String {
  // TODO: Implement
  ""
}

/// Render a list of inlines to HTML
pub fn render_inlines(inlines: List(Inline)) -> String {
  // TODO: Implement
  ""
}

/// Render a single inline to HTML
pub fn render_inline(inline: Inline) -> String {
  // TODO: Implement
  ""
}

/// Generate the HTML document wrapper (head, body, styles, scripts)
pub fn html_wrapper(title: Option(String), content: String) -> String {
  // TODO: Implement
  ""
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
