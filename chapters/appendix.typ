#import "@preview/cetz:0.2.2": canvas, draw, tree

#counter(heading).update(0)
#set heading(numbering: "A.1")
#set figure(numbering: n => numbering("A.1", counter(heading).get().first(), n))

#heading(supplement: "Appendix")[Appendix]<appendix>

== How to read S-expressions <how_to_read_s_expression>

Symbolic expressions are expressions inside tree structures. They were invented
and used for lisp languages, where they are data structures and source code.
Tree sitter uses them, with some extended syntax, to display syntax trees and
for queries. An S-expression is either an atom like `x` or an S-expression of
the form `(x y)`. A long list would be written as `(a (b (c (d NIL))))`, where `NIL` is
a special end of list atom, but tree sitter unrolls those lists into `(a b c d)`.

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

Tree sitter uses a range syntax to show where the syntax tree nodes lay within
the source code. The range is represented using a start and an end position,
both are written using zero based row and column positions. For example, the
following S-expression could be a syntax tree result from tree sitter.

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
