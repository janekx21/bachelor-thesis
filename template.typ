// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
#let project(title: "", authors: (), date: none, topleft: none, body) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Linux Libertine", lang: "en")

  // Set paragraph spacing.
  show par: set block(above: 1.2em, below: 1.2em)

  text(topleft)
  v(4em, weak: true)

  // Title row.
  align(center)[
    #block(text(1.5em, "Bachelor Thesis"))
    #v(4em, weak: true)
    #block(text(weight: 700, 1.75em, title))
    #v(1.2em, weak: true)
    #date
  ]

  // Author information.
  pad(
    top: 0.8em, bottom: 0.8em, x: 2em, grid(
      columns: (1fr,) * calc.min(3, authors.len()), gutter: 1em, ..authors.map(author => align(center)[
        *#author.name* \
        #author.email
      ]),
    ),
  )

  // Numbering of Headings for References.
  set heading(numbering: "1.")

  show outline.entry.where(level: 1): it => {
    v(12pt, weak: true)
    strong(it)
  }

  // Main body.
  set par(justify: true)

  show raw: it => if it.block {
    block(
      fill: rgb("#f5f5f5"), inset: 4pt, outset: 2pt, radius: 4pt, breakable: false, width: 100%, text(it),
    )
  } else {
    box(
      fill: rgb("#f5f5f5"), outset: (x: 0pt, y: 2pt), inset: (x: 2pt, y: 0pt), radius: 2pt, text(it),
    )
  }

  body
}
