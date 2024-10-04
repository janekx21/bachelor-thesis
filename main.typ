#import "template/template.typ": *
#import "@preview/pintorita:0.1.1"

#show raw.where(lang: "pintora"): it => pintorita.render(it.text)

// Title, Author, Abstract,
// optional: thesis-type to specify "Bachelor", "Master", "PhD", etc.,
// optional: reviewers to specify "first-reviewer", "second-reviewer" and (if needed) "supervisor".
// optional: date to specify your deadline (default: datetime.today())
// optional: lang to specify the language for text features like "" or hyphenation (specify as ISO 639-1/2/3 code, default: "en")
#show: project.with(
  "Design and development of an OWL 2 manchester syntax language server", (name: "Janek Winkler", mail: "janek.winkler@st.ovgu.de"), include "chapters/abstract.typ", thesis-type: "Bachelor", reviewers: ("Prof. Dr. Musterfrau", "Prof. Dr. Mustermann", "Dr. Evil"),
)

// Set lower roman numbering for ToC and abstract.
#set page(margin: 2.5cm, footer: none)
#outline(depth: 3)

#empty-page

// Set arabic numbering for everything else and reset page counter.
#set page(numbering: "1", footer: context{
  let page-count = counter(page).get().first()
  let page-align = if calc.odd(page-count) { right } else { left }
  align(page-align, counter(page).display("1"))
})
#counter(page).update(1)

// --- ACTUAL CONTENT OF THESIS. --- //

// #include "chapters/introduction/intro.typ"
// #include "chapters/background/background.typ"
// #include "chapters/eval/eval.typ"
// #include "chapters/conclusion/conc.typ"
#include "chapters/ba.typ"

// --------------------------------- //

#empty-page

// #parcio-bib("lib.bib", style: "bibliography/apalike.csl", enable-backrefs: true)
#bibliography("lib.bib")

#empty-page

#include "appendix.typ"

#empty-page

#include "legal.typ"
