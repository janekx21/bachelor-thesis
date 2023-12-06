// The project function defines how your document looks.
// It takes your content and some metadata and formats it.
#let project(title: "", authors: (), date: none, body) = {
  // Set the document's basic properties.
  set document(author: authors.map(a => a.name), title: title)
  set page(numbering: "1", number-align: center)
  set text(font: "Linux Libertine", lang: "de")

  // Set paragraph spacing.
  show par: set block(above: 1.2em, below: 1.2em)

  set par(leading: 0.625em) // <- Should be 5 Pages. (.5 to .75)

  // Title row.
  align(center)[
    #block(text(weight: 700, 1.75em, title))
    #v(1.2em, weak: true)
    #date
  ]

  // Author information.
  pad(top: 0.8em, bottom: 0.8em, x: 2em, grid(
    columns: (1fr,) * calc.min(3, authors.len()),
    gutter: 1em,
    ..authors.map(author => align(center)[
      *#author.name* \
      #author.email
    ]),
  ))

  // Numbering of Headings for References.
  set heading(numbering: "1.")

  // Main body.
  set par(justify: true)

  body
}
