#import "@preview/drafting:0.2.0": margin-note, set-page-properties
#import "@preview/subpar:0.1.1"
#import "parcio-bib.typ": is-parcio-bib

#let ovgu-blue = rgb("#0068B4")
#let ovgu-darkgray = rgb("#606060")
#let ovgu-lightgray = rgb("#C0C0C0")
#let ovgu-orange = rgb("#F39100")
#let ovgu-purple = rgb("#7A003F")
#let ovgu-red = rgb("#D13F58")

#let large = 14.4pt
#let Large = 17.28pt
#let LARGE = 20.74pt
#let huge = 24.88pt

// TODO box (default: no inline).
#let todo(inline: false, body) = if inline {
  rect(
    fill: ovgu-orange, stroke: black + 0.5pt, radius: 0.25em, width: 100%, body,
  )
} else {
  set rect(fill: ovgu-orange)
  margin-note(stroke: ovgu-orange, body)
}

// #let research-question(body) =
// #figure(
//   kind: "RQ", supplement: "RQ", numbering: "1",
// )[
//   #grid(columns: (auto, auto), gutter: 2pt, [*RQ #numbering("1"):*], body)
// ]

// Like \section* (unnumbered level 2 heading, does not appear in ToC).
#let section = heading.with(level: 2, outlined: false, numbering: none)
// Neat inline-section in smallcaps and sans font.
#let inline-section(title) = smallcaps[*#text(font: "Libertinus Sans", title)*]
// Fully empty page, no page numbering.
#let empty-page = page([], footer: [])
// Subfigures.
#let subfigure = subpar.grid.with(numbering: (num) => {
  numbering("1.1", counter(heading).get().first(), num)
}, numbering-sub-ref: (sup, sub) => {
  numbering("1.1a", counter(heading).get().first(), sup, sub)
})

// Custom ParCIO table as illustrated in the template.
#let parcio-table(max-rows: 0, ..args) = table(
  ..args, row-gutter: (2.5pt, auto), stroke: (x, y) => (
    left: 0.5pt, right: 0.5pt, top: if y <= 1 { 0.5pt }, bottom: if y == 0 or y == max-rows - 1 { 0.5pt },
  ),
)

// Custom Janek table
#let j-table(..args) = {
  figure(
    [
      #set table(stroke: (x, y) => (top: if y > 0 { 0.5pt + gray }, left: if x > 0 {
        0.5pt + gray
      }, bottom: if y == 0 { 0.5pt + gray }))
      #rect(
        table(..args, row-gutter: (2.5pt, auto)), radius: 6pt, inset: 0%, stroke: 0.5pt + gray,
      )
    ], kind: table,
  )
}

// ----------------------
//   ACTUAL TEMPLATE
// ----------------------
#let project(
  title, author, abstract, thesis-type: "Bachelor/Master", reviewers: (), date: datetime.today(), lang: "en", body,
) = {
  set document(title: title, author: author.name)
  set page("a4", margin: 2.5cm, number-align: right, numbering: "i", footer: [])
  set text(font: "Libertinus Serif", 12pt, lang: lang)
  set heading(numbering: "1.1.")
  set par(justify: true)
  set math.equation(numbering: "(1)")

  let _translation-file = toml("translations.toml")
  let translations = _translation-file.at(lang, default: _translation-file.at(_translation-file.default-lang))

  // Make URLs use monospaced font.
  show link: it => {
    if (type(it.dest) == str) {
      set text(font: "Inconsolata", 12pt * 0.95)
      underline(it)
    } else {
      it
    }
  }

  // Enable heading specific figure numbering and increase spacing.
  set figure(
    numbering: n => numbering("1.1", counter(heading).get().first(), n), gap: 1em,
  )
  show figure: set block(spacing: 1.5em)

  // Add final period after fig-numbering (1.1 -> 1.1.).
  // Additionally, left align caption if it spans multiple lines.
  show figure.caption: c => {
    grid(
      columns: 2, column-gutter: 4pt, align(top)[#c.supplement #c.counter.display(c.numbering).#c.separator], align(left, c.body),
    )
  }

  // Create the "Chapter X." heading for every level 1 heading that is numbered.
  show heading.where(level: 1): h => {
    set text(huge, font: "Libertinus Sans")

    if h.numbering != none {
      pagebreak(weak: true)
      v(2.3cm)

      // Reset figure counters:
      counter(figure.where(kind: image)).update(0)
      counter(figure.where(kind: table)).update(0)
      counter(figure.where(kind: raw)).update(0)

      if h.body == [Appendix] {
        counter(heading).update(1)
        [Appendix #counter(heading).display(h.numbering)]
      } else {
        translations.chapter + " " + counter(heading.where(level: 1)).display()
      }
      [\ #v(0.2em) #h.body]
    } else {
      v(2.3cm)
      h
    }
  }

  show heading.where(level: 2): h => {
    if h.numbering != none {
      [#counter(heading).display()~~#h.body]
    } else {
      h
    }
  }

  // Make @heading automatically say "Chapter XYZ" instead of "Section XYZ",
  // unless we want to manually specify it.
  set ref(supplement: it => {
    if it.func() == heading {
      if it.level > 1 {
        translations.section
      } else {
        translations.chapter
      }
    } else {
      it.supplement
    }
  })

  // Redirect bib-citations to the manually inserted ones.
  show cite: c => {
    // if is-parcio-bib.get() and not str(c.key).starts-with("_") {
    // show regex(".+"): x => link(label("_" + str(c.key)), x)
    // c
    // } else {
    c
    // }
  }

  // Customize ToC to look like template.
  set outline(fill: repeat[~~.], indent: none, title: translations.contents)
  show outline: o => {
    show heading: pad.with(bottom: 1em)
    o
  }

  // Level 2 and deeper.
  show outline.entry: it => {
    let cc = it.body.children.first().text

    box(
      grid(
        columns: (auto, 1fr, auto), h(1.5em + ((it.level - 2) * 2.5em)) + link(it.element.location())[#cc#h(1em)#it.element.body], it.fill, box(width: 1.5em) + it.page,
      ),
    )
  }

  // Level 1 chapters get bold and no dots.
  show outline.entry.where(level: 1): it => {
    set text(font: "Libertinus Sans")
    let cc = if it.element.body == [Appendix] {
      "A." // hotfix
    } else if it.body.has("children") {
      it.body.children.first()
    } else {
      h(-0.5em)
    }

    v(0.1em)
    box(
      grid(
        columns: (auto, 1fr, auto), strong(link(it.element.location())[#cc #h(0.5em) #it.element.body]), h(1fr), strong(it.page),
      ),
    )
  }

  show raw: set text(font: "Inconsolata")
  show raw.where(block: true): r => {
    if (r.lang == "pintora") {
      r // pintora renders as a graph not code
    } else {
      set par(justify: false)
      show raw.line: l => {
        box(
          table(
            columns: (-1.25em, 100%), stroke: 0pt, inset: 0em, column-gutter: 1em, align: (x, y) => if x == 0 { right } else { left }, text(fill: ovgu-darkgray, str(l.number)), l.body,
          ),
        )
      }

      set align(left)
      rect(width: 100%, stroke: gray + 0.5pt, inset: 0.75em, radius: 6pt, r)
    }
  }

  show heading.where(level: 2): set text(font: "Libertinus Sans", Large)
  show heading.where(level: 3): set text(font: "Libertinus Sans", Large)
  show heading: it => it + v(0.69em)

  set footnote.entry(separator: line(length: 40%, stroke: 0.5pt))
  set list(marker: (sym.bullet, "◦"))

  let (second-reviewer, supervisor) = translations.title-page

  // -------------- TITLE PAGE -------------- //
  // STYLIZING TITLE PAGE AND ABSTRACT BEGINS HERE:
  align(center)[
    #image(alt: "Blue OVGU logo", width: 66%, "ovgu.svg")
  ]

  v(4.75em)

  align(
    center,
  )[
    #text(Large, font: "Libertinus Serif")[*#thesis-type #translations.thesis*]
    #v(2.5em)
    #text(huge, font: "Libertinus Sans")[
      #set par(justify: false)
      *#title*
    ]
    #v(1.25em)

    #set text(Large)
    #show raw: set text(large * 0.95)
    #align(
      center,
    )[
      #author.name\
      #v(0.75em, weak: true)#link("mailto:" + author.mail)[#raw(author.mail)]
    ]

    #v(0.5em)
    #text(
      Large,
    )[
      #show regex("[a-zA-Z]+"): r => translations.date.months.at(date.month() - 1)
      #date.display(translations.date.date-format)
    ]
    #v(5.35em)

    // first and second reviewer are required, supervisor is optional.
    #if reviewers.len() >= 1 {
      let first-reviewer-name = reviewers.first()
      let supervisor-name = reviewers.at(1)
      // let supervisor-name = reviewers.at(2, default: none)

      [
        #second-reviewer:\
        #first-reviewer-name\ \
        #v(-1.5em)

        // #second-reviewer:\
        // #second-reviewer-name\ \
        // #v(-1.5em)

        #if supervisor-name != none [
          #supervisor:\
          #supervisor-name
        ]
      ]
    }
  ]

  // show raw: set text(12pt * 0.95)
  pagebreak(to: "odd")
  set-page-properties()

  v(-8.5em)
  align(center + horizon)[
    #text(font: "Libertinus Sans", [*Abstract*])\ \
    #align(left, abstract)
  ]

  pagebreak()

  align(
    horizon,
  )[

    #text(font: "Libertinus Sans", [*Acknowledgments*])\ \
    I am grateful to all the people who have been part of the whole thesis from
    planning to implementation to final editing. A special thanks goes to my
    supervisor, Till, and the staff at the IKS. I would also like to thank my close
    friends and family who have supported and tolerated me and made my time so much
    more enjoyable. Thank you, Lara, for your endless support.

    Janek]

  v(8.5em)

  align(
    horizon,
  )[

    #text(font: "Libertinus Sans", [*Danksagungen*])\ \
    Ich bin allen Personen dankbar, die an der Arbeit beteiligt waren, von der
    Planung über die Durchführung bis zum finalen Entwurf. Ein besonderer Dank geht
    an meinen Betreuer, Till, und den Mitarbeitern des IKS. Außerdem möchte ich mich
    bei meinen engen Freunden und meiner Familie bedanken, die mich unterstützt und
    geduldet haben und mir die Zeit so viel angenehmer gemacht haben. Danke dir,
    Lara, für deine unermüdliche Unterstützung.

    Janek]

  pagebreak()
  body
}

