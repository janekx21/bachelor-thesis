#import "template.typ": *
#import "@preview/cetz:0.2.2": canvas, draw, tree

#show: project.with(
  title: "Design and development of an OWL 2 manchester syntax language server", authors: ((name: "Janek Winkler", email: "janek.winkler@st.ovgu.de"),), date: "December 6, 2023", topleft: [
    Otto-von-Guericke-University Magdeburg \
    Faculty of Computer Science\
    Research Group Theoretical Computer Science
  ],
)

#heading(outlined: false, numbering: none)[Abstract]

As the number of code editors and programming languages rises, language servers,
which communicate with the editor to provide language-specific smarts, are
getting more relevant. Traditionally this hard work hat been repeated for each
editor as each editor API was different. This can be avoided with a standard.
The _de facto_ standard to realize editing support for languages is the language
server protocol (LSP). This work implements an LSP compatible language server
for the OWL 2 Manchester syntax/notation (OMN) using the incremental parser
generator tree sitter. It provides language features like auto complete, go to
definition and inlay hints, which are critical in large OMN files, as it would
be tedious and error-prone without a graphical editor. I also evaluated the
practical relevance of the LSP.

#pagebreak()

#outline(indent: auto, fill: repeat(" . "))

#pagebreak()

= Introduction

== The Research Objective

// How to design and implement an efficient language server for the owl language

The aim of my research is to find out how best to implement a language server
for a language that is unknown to the author. Which data structures, techniques
and protocols are best suited, and what are performance characteristics of
different alternatives?

== The Structure of the Thesis

// first explain what the work i am doing is and

The thesis begins with background information about OWL2, the mancherster
syntax, IDE's and language servers. This wide background is followed by detailed
information about my implementation of a language server. What my decisions
where and why. It involves translating a grammar, creating a language server
crate and a plugin example for VSCode. The third big chapter is about testing
the created program by running grammar tests, unit tests, end-to-end tests and
benchmarks. Then analyzing and evaluating the results in the categories of
speed, correctness and usability.

= Related work

#lorem(100)

= Background

In this chapter I will explain programs, libraries, frameworks and techniques
that are important to this work. You can skip parts that you are familiar with.
We start with the ontology language this language server will support. Then we
go over how IDE's used to work and what modern text editors do different.
Afterwards I will say something about tree sitter, the parser generator that was
used.

== What is Owl, Owl 2 and Owl 2 manchester syntax

#quote(
  block: true, attribution: [w3.org],
)[The OWL 2 Web Ontology Language, informally OWL 2, is an ontology language for
  the Semantic Web with formally defined meaning. OWL 2 ontologies provide
  classes, properties, individuals, and data values and are stored as Semantic Web
  documents. OWL 2 ontologies can be used along with information written in RDF,
  and OWL 2 ontologies themselves are primarily exchanged as RDF documents. The
  OWL 2 Document Overview describes the overall state of OWL 2, and should be read
  before other OWL 2 documents.]

// TODO copied from https://www.w3.org/TR/2012/REC-owl2-syntax-20121211/

// TODO why owl2 not owl1
// TODO what is manchester syntax

== How IDE's work

IDE's use syntax trees to deliver language smarts to the programmer. The problem
with IDE's is that they are focused on specific languages or platforms. They are
usually slow due to not using incremental parsing. This means on every keystroke
the IDE is parsing the whole file. This can take 100 milliseconds or longer,
getting slower with larger files. This delay can be felt by programmers while
typing. @loopTreesitterNewParsing

== What is a language server
// https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html 4:05

== What is tree sitter

Tree-sitter is a parser generator and query tool for incremental parsing. It
builds a deterministic parser for a given grammar that can parse a source file
into a syntax tree and update that syntax tree efficiently. It aims to be
general enough for any programming language, fast enough for text editors to act
upon every keystroke, robust enough to recover from previous syntax errors and
dependency free, meaning that the resulting runtime library can be embedded or
bundled with any application. @TreesitterIntroduction

It originated from Max Brunsfeld and was build at github with c and c++ and is
designed to be used in applications like atom, light text editors that need
plugins to become as useful as an IDE. Its core functionality is to parse many
programming languages into a coherent syntax trees that all have the same
interface. The incremental parsing is "superfast" and needs very little memory,
because it shares nodes with the previous version of the syntax tree. This makes
it possible to parse on every keystroke and run parsers in parallel. Another
important feature is the error recovery. Tree-sitter can, unlike other common
parsers that error out on parsing fails, find the start and end of a wrong
syntax snipped, by "inspecting" the code. @loopTreesitterNewParsing

All these features make it extremely useful for parsing code that is constantly
modified and contains syntactical errors, like source code, written inside code
editors.

== What makes a parser a GLR parser
@langDeterministicTechniquesEfficient1974
//TODO paper Deterministic Techniques for Efficient Non-Deterministic Parsers DOI:10.1007/3-540-06841-4_65

= Implementation

This chapter will explain what was implemented and how it was done. I will also
show why I choose the tools that I did, what alternatives exist and when to use
those.

=== Why use tree sitter

I chose three sitter, because it is an incremental parsing library. This is a
must because the OMN files can be very large. Parsing a complete file after only
changing one character wound be inefficient. In some cases unusable. The parser
I build takes about 490ms for the initial parse of a 2M file. The parser then
only needs about 150ms for a changed character in the same file using the
resulting tree of the previous parsing. The next big reason why I chose tree
sitter is the error recovery. In the presence of syntax error the parser can
recover to a valid state and continue parsing with a prior rule. For example the
following OMN file

```omn
Ontology:
    Class: ???????

    Class: other_thing
```
results in the S-expression (See @how_to_read_s_expression for how to read them)

```lisp
(source_file [0, 0] - [4, 0]
  (ontology [0, 0] - [3, 22]
    (ERROR [1, 4] - [1, 18])
    (class_frame [3, 4] - [3, 22]
      (class_iri [3, 11] - [3, 22]
        (simple_iri [3, 11] - [3, 22])))))
```

You can see that the first class frame contains a syntax error. The second class
frame is valid, and the parser can pick up parsing after the erroneous first
frame. Without this error recovery, the source code after a syntax error would
not be checked for errors or would become invalid to. It would be impossible to
show all syntax error in a file.

// Rust bindings
Tree sitter comes with rust bindings but also supports a number of programming
languages. I chose rust and there is no language that could offer me the safety,
speed and comfort it provides. Some notable alternatives are typescript and c++.
I choose rust over typescript, because of performance. Rust compiles to machine
code and runs without a garbage collector while typescript first gets transpiled
into javascript and the program would run on a "virtual machine" like javascript
engine - e.g. V8. Modern javascript engines are fast enough and this language
server could be ported. C++ on the other hand is very fast but lacks the safety
and comfort. This is not a strict requirement, and it would be a viable
implementation language for this language server. More about that in
@rust_over_cpp. But the rust bindings, cargo package manager and memory safety
are excellent and guaranteed an efficient implementation. In hindsight, it was a
good choice and I recommend rust for writing language servers.

// TODO reference rust book, typescript and c++ stuff

I came across tree sitter when I was researching what my own text editor uses
for its syntax highlighting. It turned out that the editor Helix also uses tree
sitter. Just like Github and VSCode do. It is therefore popular and the
standardized syntax tree representation and grammar files make it ideal.

// Alternatives
Initially I wanted to work with Haskell and use the parser from spechub's Hets,
but it uses parsec and is therefore not an incremental parser. Also it has no
error recovery functionality that would be sufficient for text editors. Nobody
would like to have a completely red underlined document in case of a syntax
error in line one.

I then read about the Happy parser generator, witch Haskell uses, and Alex the
tool for generating lexical analyzers. But the complexity of these tools put me
off, and I also didn't know how to connect the different libraries with one
another.

// TODO more alternavies

=== Writing the grammar

Staring with the official reference of the OWL2 manchester syntax, I transformed
the rules into tree sitter rules, replacing the rules with the corresponding
tree sitter ones. For example, I rewrote the following rule from

```bnf
ontologyDocument ::=  { prefixDeclaration } ontology
```

into

```js
ontology_document: $ => seq(repeat($.prefix_declaration), $.ontology),
```

Tree sitter rules are always read from the `$` object and named in snake case.
Some are prefixed with `_`. We call theses "hidden rules". We call rules that
are not prefixed "named rules" and we call terminals symbols, literals and
regular expressions "anonymous rules". For example the rule

```javascript
_frame: $ =>
  choice(
    $.datatype_frame,
    $.class_frame,
    $.object_property_frame,
    $.data_property_frame,
    $.annotation_property_frame,
    $.individual_frame,
    $.misc,
)
```

is a hidden rule, because `_frame` is a supertype of `class_frame`. These rules
are hidden because they add substantial depth and noise to the syntax tree.

// TODO reference https://tree-sitter.github.io/tree-sitter/creating-parsers#hiding-rules

The exact transformations where done as following:

#table(
  columns: (1fr, auto, auto), table.header([*Construct*], [*OWL BNF*], [*tree sitter grammar*]),
  // ---------------------
  [sequence], [```'{' literalList '}'```], [```js seq('{', $.literal_list, '}')```],
  // ---------------------
  [non-terminal symbols], [`ClassExpression`], [```js $.class_expression```],
  // ---------------------
  [terminal symbols], [```'PropertyRange'```], [```js 'PropertyRange'```],
  // ---------------------
  [zero or more], [```{ ClassExpression }```], [```js repeat($.class_exprresion)```],
  // ---------------------
  [zero or one], [```[ ClassExpression ]```], [```js optional($.class_expression)```],
  // ---------------------
  [alternative], [`Assertion | Declaration`], [```js choice($.assertion, $.declaration)```],
  // ---------------------
  [grouping], [```( restriction | atomic )```], [```js choice($.restriction, $.atomic)```],
)

I also, in a second step, transformed typical BNF constructs into more readable
tree sitter rules. These include

#table(
  columns: (2fr, 3fr, 3fr), table.header([*Construct*], [*OWL BNF*], [*tree sitter grammar*]),
  // ---------------------
  [separated by comma], [```<NT> { ',' <NT> }```], [```js sep1(<NT>, ',')```],
  // ---------------------
  [separated by "or"], [```<NT> { 'o' <NT> }```], [```js sep1(<NT>, 'o')```],
  // ---------------------
  [one or more], [```<NT> ',' <NT>List```], [```js repeat1(<NT>)```],
  // ---------------------
  [annotated list], [```[a] <NT> { ',' [a] <NT> }```], [```js annotated_list(a, <NT>)```],
)

Where `<NT>` is a non-terminal and `a` is the non-terminal called `annotations`.
This is used for `<NT>List`, `<NT>2List`, `<NT>AnnotatedList` and every
derivative that replaces `<NT>` with a real non-terminal.

This results in the following example transformation:

```bnf
annotationAnnotatedList ::= [annotations] annotation { ',' [annotations] annotation }
```

will become

```js
annotation_annotated_list: $ => annotated_list($.annotations, $.annotation)
```

// TODO regex and where to stop parsing
There are limits on how precise your parse should be. The IRI rfc3987 format is
part of the OWL2-MS specification but not simple in any way. I skipped some
specification for the IRI and put in some regexs that worked for me but not
necessarily for you. For example the IRI specification defines many small
non-terminals like// TODO write more

// TODO i wrote tests to check that the parsing is correct

I wrote tests to see if my grammar and the resulting parser would produce the
correct syntax tree for the given source code. This is done with tree sitters
CLI. More about tree sitter query testing in @query-tests.

=== Using the generated parser

=== Why use rust and not c or c++ <rust_over_cpp>

// TODO
- memory safety
- pointers
- compile time
- ease of use
- arithmetic type system

// https://www.educative.io/blog/rust-vs-cpp#compare

== Relevant parts of the LSP specification
#lorem(50)
=== `TextDocumentSyncKind::INCREMENTAL`
#lorem(100)
=== `did_open`
#lorem(100)
=== `did_change`

How to remove diagnostics that don't matter any more and how to only check the
relevant nodes after that.

=== `hover`
#lorem(100)
=== `inlay_hint`
#lorem(100)
=== TODO diagnostics
#lorem(100)

== Used data structures
=== Rope
#lorem(100)

== Optimizations
#lorem(100)
=== Rust Async with Tokio
#lorem(100)
=== LS State vs. on promise tree query

== How, why and what i tested
//TODO why i tested

=== Query tests in tree sitter <query-tests>
#lorem(100)
=== Unit tests in rust
#lorem(100)
=== E2E tests using a LSP client
#lorem(100)

= Analysis
== Benchmarks
=== Experimental Setup
=== Results

== Usability
=== Experimental Setup
=== Results
//TODO who are the users
//TODO describe the usability
//TODO is the LSP fast enough

= Conclusion
== Performance
== Future Work

= Appendix

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

#set align(center)
#let data = ([root], ([leaf]), ([node], [leaf], [leaf]))
#canvas(
  {
    import draw: *

    set-style(
      content: (padding: .2), fill: rgb("#f5f5f5"), line: (fill: gray.lighten(60%), stroke: gray.lighten(60%)),
    )

    tree.tree(
      data, spread: 2.5, grow: 1.5, draw-node: (node, ..) => {
        circle((), radius: .45, stroke: none)
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
#set align(top + left)

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

#heading(outlined: false, numbering: none)[Acknowledgments]

#bibliography("lib.bib", style: "ieee")

/*
 Notes:

 Possible Features:
 - Auto completion with label
 - Goto definition of keywords inside the lsp directory

 Warum hast du so etwas gebaut, was wären Alternativen gewesen und warum hast du sie nicht genutzt.

 - Am Anfrang, Fragestellung: Kann man damit flüssig arbeiten
 - Am Ende, Frage beantworten

 */
