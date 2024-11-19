#import "@preview/cetz:0.2.2": canvas, draw, tree

#counter(heading).update(0)
#set heading(numbering: "A.1")
#set figure(numbering: n => numbering("A.1", counter(heading).get().first(), n))

#heading(supplement: "Appendix")[Appendix]<appendix>

== How to read S-expressions <how_to_read_s_expression>

Symbolic expressions are expressions inside tree structures. They were invented
and used for lisp languages, where they are data structures and source code.
Tree-sitter uses them, with some extended syntax, to display syntax trees and
for queries. An S-expression is either an atom like `x` or an S-expression of
the form `(x y)`. A long list would be written as `(a (b (c (d NIL))))`, where `NIL` is
a special end of list atom, but tree-sitter unrolls those lists into `(a b c d)`.

```lisp
(root (leaf) (node (leaf) (leaf)))
```

This is an S-expression with abbreviated notation to represent lists with more
than two members. The `root` is the root of the tree, `node` is a node with one
parent and two children and `leaf` nodes are tree leafs. This results in the
following tree.

#figure(
  caption: "Example tree",
)[
  #set align(center)
  #let data = ([root], ([leaf]), ([node], [leaf], [leaf]))
  #canvas(
    {
      import draw: *

      set-style(
        content: (padding: .2), fill: rgb("#f5f5f5"), line: (fill: gray.lighten(60%), stroke: gray.lighten(60%)),
      )

      tree.tree(
        data, spread: 4, grow: 1.5, draw-node: (node, ..) => {
          circle((), radius: .5, stroke: none)
          content((), node.content)
        }, draw-edge: (from, to, ..) => {
          line(
            (a: from, number: .6, b: to), (a: to, number: .6, b: from), mark: (end: ">"),
          )
        }, name: "tree",
      )
      // Draw a "custom" connection between two nodes
      // let (a, b) = ("tree.0-0-1", "tree.0-1-0",)
      // line((a, .6, b), (b, .6, a), mark: (end: ">", start: ">"))
    },
  )
]

Tree-sitter uses a range syntax to show where the syntax tree nodes lay within
the source code. The range is represented using a start and an end position,
both are written using zero based row and column positions. For example, the
following S-expression could be a syntax tree result from tree-sitter.

```lisp
(root [0, 0] - [4, 0]
  (leaf [1, 4] - [1, 18])
  (node [3, 4] - [3, 22]
    (leaf [3, 4] - [3, 8]])
    (leaf [3, 9] - [3, 21])))
```

// TODO ref https://tree-sitter.github.io/tree-sitter/using-parsers#query-syntax
A query is written with S-expressions and some special syntax for fields,
anonymous nodes, capturing, quantification, alternations, wildcards, anchors and
predicates. Here are some examples to give a short overview.

```lisp
(leaf)
```
Matches every `leaf` node.

```lisp
(node (leaf))
```

Matches every `node` node that has a `leaf` node.

```lisp
(node
  (leaf) @leaf-one
  (leaf)) @leaf-two
```

Matches every `node` that has two `leaf` nodes and captures the leaf nodes in `leaf-one` and `leaf-two`.

```lisp
(node
  [
    (leaf)
    (node)
  ])
```
Matches every `node` that has either a `leaf` node children or a `node` node
children.

```lisp
(node (_ (leaf)))
```

Matches every `node` that has a child with a child that is a `leaf` node.

== Incremental change example <did_change_example>

Imagine a text document with the content below.

```owl-ms
Ontology: <http://www.co-ode.org/ontologies/pizza>

Class: pizza:Margherita
    Annotations:
        rdfs:label "Margherita"@en
```

Upon the language server getting a request with the `textDocuement/didChange` message
from @did_change, the language server's model of the document is updated.

```json
{
  textDocument: <the identifier of the text file (like a URL)>,
  contentChanges: [
    {
      range: {
        start: { line: 3, character: 14 },
        end: { line: 3, character: 24 } // end position is exclusive
      },
      text: "Napoletana",
    },
    {
      range: {
        start: { line: 5, character: 21 },
        end: { line: 5, character: 35 } // end position is exclusive
      },
      text: "Napoletana",
    }
  ]
}
```

Applying this change will result in the following text document.

```owl-ms
Ontology: <http://www.co-ode.org/ontologies/pizza>

Class: pizza:Napoletana
    Annotations:
        rdfs:label "Napoletana"@en
```

== Evaluation form <evaluation_form>

#let rating(a, b) = grid(
  columns: (auto, auto, auto, auto, auto, auto, auto), gutter: 5mm, [], [1], [2], [3], [4], [5], [],
  //
  a, [#circle(radius: 0.4em)], [#circle(radius: 0.4em)], [#circle(radius: 0.4em)], [#circle(radius: 0.4em)], [#circle(radius: 0.4em)], b,
)

The following form was given to people for evaluation purposes. It starts with a
heading section then some background questions and a main part which ends with
comments. Parts in brackets stand for images that are comparable with the images
in this thesis.

=== Heading section

*Disclaimer*: This evaluation will be used in the bachelor thesis "Design and
development of an OWL 2 manchester syntax language server" by Janek Winkler.
Your submission will be anonymous. No personal data is involved. You will not be
identifiable by your answerers.

*Requirements*: This form evaluates the usability of the owl-ms-language-server
with an editor. Information on how to download, install and configure the
language server can be found on the Github Repository. Start testing the
language server and then come back and fill out this evaluation form. You will
need a code editor for this and Visual Studio Code is recommendet.

*Some files for testing*: pizza.omn (Try using the pizza Veneziana) minimal.omn
(This is a super small subset of the open energy ontology)

*Explanation of terms using example pictures*: Some questions show pictures for
terms that are relevent and need explanation. They are just examples.

*Finished trying out the languge server?* Please continue to the next section of
this form and share your experience.

=== Background questions
#block[
  #set list(marker: circle(radius: 0.4em))

  This section contains questions about your background with ontologies.

  *How do you work normaly with ontologies?*
  - Protégé
  - TopBraid Composer
  - Text Editor
  - I dont work with ontologies
  - other ...

  *How long have you been using the language server?*
  - I have never used the language server
  - ~ 10min
  - ~ 30min
  - ~ 1h
  - ~ 5h
  - >5h
]

=== Main section

This next section has questions about your experience with the language server.
The lower the number, the worse the experience. Higher numbers indicate better
experience.
`worse<----------- 1 -- 2 -- 3 -- 4 -- 5 ------------> better`

*How easy was the the installation process?*
#rating([too complex], [very easy])

*How was your experience regarding the performance of the language server?*
#rating([too slow], [fast enough])

*How well could you achieve your goals with a language server?*
#rating([poor], [very good])

*How was your experience in general?*
#rating([poor], [very good])

Hover Information is the information that is shown, when you hover source code
like IRI's. This example shows the hover info of the "pizza:NamedPizza" IRI.
[example image of a hover]

*How useful did you find the Hover Information?*
#rating([useless], [very useful])

Syntax Error Diagnostics are shown when invalid syntax is written. In this
example they are "????????" (question marks) with a red underline. [example
image of syntax errors]

*How useful did you find the Syntax Error Diagnostics?*
#rating([useless], [very useful])

Inlay Hinting quickly show labels. This example shows 4 of them. They are
readonly texts behind an IRI that is a full URL and show the underlying label.
In this example they are "emission factor", "emission", "biogas power unit" and "belongs
to module". [example image of inlay hints]

*How useful did you find the Inlay Hinting?*
#rating([useless], [very useful])

Auto Completion. In this example "pizz" triggers a list of auto completion
items. [example image of auto completion]

*How useful did you find the Auto Completion?*
#rating([useless], [very useful])

*Did you encounter any bugs or unexpected behavior?*

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

*What features is this tool missing in your opinion?*

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

*Can you imagine working with the language server instead of the tool you are
using now?*
#rating([not at all], [very well])

*Do you have any additional comments?*

\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
