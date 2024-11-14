// #import "template.typ": *
#import "@preview/cetz:0.2.2": canvas, draw, tree
#import "../template/template.typ": todo, section, parcio-table, j-table, empty-page

// #show: project.with(
//   title: "Design and development of an OWL 2 manchester syntax language server", authors: ((name: "Janek Winkler", email: "janek.winkler@st.ovgu.de"),), date: "December 6, 2023", topleft: [
//     Otto-von-Guericke-University Magdeburg \
//     Faculty of Computer Science\
//     Research Group Theoretical Computer Science
//   ],
// )

// Pintoria setup

// #heading(outlined: false, numbering: none)[Abstract]

// #pagebreak()

// #outline(indent: auto, fill: repeat(" . "))

// #pagebreak()

= Introduction

Modern society is constantly evolving, and software plays an integral role in
our daily lives. This ongoing change leads to new use cases and shifting
requirements for modern software. To meet these demands, developers are
continually tasked with adding new features or modifying existing ones, which
results in larger and more complex codebases. As complexity grows, programming
errors become inevitable, potentially leading to undesirable behaviors. Testing
is a common method developers use to identify errors and unintended behaviors.
Extensive test suites are run during development to evaluate a component's
behavior under various inputs and conditions. While testing can reveal many
errors, it cannot guarantee the absence of all defects or ensure the overall
correctness of the program. As noted by Beyer and Lemberger in "Software
Verification: Testing vs. Model Checking"#todo[hier muss ref hin] , formal
verification should complement testing to provide a more robust assurance of
program correctness. Formal verification requires a specification of the desired
behavior, which the verification tool then uses to check if the program meets
these requirements. If a property is violated, the verification tool may produce
a warning, detailing the cause. This allows developers to trace the problem,
correct the issue, and re-verify the program. This process is deeply embedded
into the field of computer science.

*The problem* that is thesis will address is the current lack of text tooling
for the OWL community. A first step towards a solution to this problem is a new
text tool for the human-readable variant "OWL 2 Mancherster
Syntax"@OWLWebOntologya of the OWL language family.

*The goal* of this thesis is to make the OWL Manchester Syntax in text form more
accessible to developers by integrating it into their workflows via an
Integrated Development Environment (IDE) plugin. By implementing the
functionality as a Language Server Protocol (LSP) server named "owl-ms-languge-server"
and an LSP client plugin for Visual Studio Code named "vscode-owl-ms", the tool
can be easily adapted for use in other IDEs. This integration allows the
owl-ms-language-server to be run directly from within the IDE, with results
displayed in the editor. The language server will provide diagnostics, hover,
semantic tokens and jump to definition features. A small qualitative user study
will show whether the implementation is able to keep up with the users
expectations in a synthetic scenario. It should be fast enough and feature rich
to work with. The scenario can not be a real-world one, because the chosen
language does not have an established text based workflow yet.

*The research question* this thesis will answer while documenting which data
structures, tech stacks and packages are best suited, and the performance
characteristics of them is: "How to develop a language server for a known
lanugage that satifies the user in need for features while not slowing him
down?".

// #show figure.where(kind: "RQ"): it => box(width: 100%)[
//   #it.body
// ]

// #figure(
//   kind: "RQ", supplement: "RQ", numbering: "1",
// )[
//   #grid(
//     columns: (auto, auto), gutter: 2pt, [*RQ 1:*], [How to develop a language server for a known lanugage that satifies the user in
//       need for features while not slowing him down?],
//   )
// ]<rq_1>

// #figure(
//   kind: "RQ", supplement: "RQ", numbering: "1",
// )[
//   *RQ 2:* How does a text editor with a language server compare to a specialised
//   editor.
// ]<rq_2>

This implementation is specific to the OWL language. The grammar covers the
complete Manchester Syntax but without extensions and limits in dependent
syntaxes like RFC-3629@rfc-3629. In addition, only a small subset of possible
language features is implemented, because of time constrains. It is not my goal
to create a full OWL language server tool that covers every use case. For that
reason a prioritized list with LSP features guided the implementation order.

1. Document Synchronization
2. Diagnostics (Just syntax)
3. Semantic Tokens (Just syntax highlighting)
4. Inlay hints (For resolving IRI's)
5. Hover
6. Go to definition
7. Auto-completion (Keywords and IRI's)
8. Document symbols
9. Rename
10. Go to references

Working with multiple files or workspaces as well as the following features and
there "work done progress" variation where explicitly not planned. The features
Go to declaration, go to type definition, go to implementation, incoming calls,
outgoing calls, super-types, subtypes, document highlight (Highlights text that
corresponds to text under the cursor), document link (All links in a document),
document link resolve (How to resolve a link), code lens, folding range,
selection range, semantic tokens, inline value, moniker, workspace diagnostic,
signature help, document color, color presentation, formatting, on type
formatting, linked editing range (Ranges that have the same content) and Symbol
(Project-wide symbol search) where not planned.

== Structure of the Thesis

// first explain what the work i am doing is and

After the introduction and related work chapters, the thesis begins with
background information about OWL2, the manchester syntax, IDE's and language
servers in the @background. This wide background is followed by detailed
information about my implementation of a language server in @implementation.
What my decisions where and why. It involves translating a grammar, creating a
language server crate/package and a plugin example for Visual Studio Code.
@analysis is about testing the created program by running grammar tests,
integration tests and benchmarks. Then analyzing and evaluating the results in
the categories of speed, correctness in @benchmarks and usability in
@evaluation.

The implementation is not part of this document. It can be found in varous
Github repositories. This is also the case for this typst document.

- Bachelor thesis typst document\
  https://github.com/janekx21/bachelor-thesis

  - Distributed PDF (main.pdf)\
    https://github.com/janekx21/bachelor-thesis/releases

- Parser generator (tree sitter grammar)\
  https://github.com/janekx21/tree-sitter-owl-ms

- langauge server (rust crate/package)\
  https://github.com/janekx21/owl-ms-language-server

- Visual Studio Code plugin (npm package)
  https://github.com/janekx21/vscode-owl-ms

  - Distributed via Open VSX Marketplace\
    https://open-vsx.org/extension/JanekWinkler/vscode-owl-ms

  - Distributed via VisualStudio Marketplace\
    https://marketplace.visualstudio.com/items?itemName=JanekWinkler.vscode-owl-ms

= Related work <chapter:related_work>

The goal of this work is to implement a simple language server with a
corresponding Visual Studio Code plugin. There are countless language servers
that precede this work, but most of them do not have a publication that belongs
to them. A list of language servers can be found on the page great
https://langserver.org/. Nevertheless, there are some papers about writing a
language server, and here are two of them.

In the work "A Language Server and IDE Plugin for
CPAchecker"@leimeisterLanguageServerIDE by Adrian Leimeister a language server
is built for the already existing tool
"CPAchecker". The server is written in Java to be able to talk directly to
CPAchecker. In this case, CPAchecker is even integrated as a library and is only
started directly via the Java class. The server also has an integration with "VerifierCloud",
an online service for verification. To run the CPAchecker, a configuration must
be specified, which caused some difficulties because the library did not make
certain methods publicly available. The stdio logging was also redirected to the
language server via "logMessage" notifications. This is necessary because
language servers communicate with the client via stdio. For communication via
the LSP, the language server uses the LSP4J library, a Java implementation of
the LSP. This provides an interface that implements the class "CPAchekerLSP".
The language server takes the document that was sent via "didSave", analyzes it
using the CPAchecker and sends back a "publishDiagnostics" notification. The
whole thing can also be verified via the cloud when configured. The eclipse
plugin is based on the generic languge client LSP4E. It is installed via an
update site. The plugin is built automatically via Apache Maven and Eclipse
Tycho. Due to conflicts between the OSGi manifest and Maven manifest, a
workaround had to be implemented. The work used an online survey of potential
users as an evaluation. After an installation and configuration guide, the
participants were asked to follow a basic usage scenario and then try out the
tool themselves. The questionnaire mainly contained questions about the
installation and configuration process, general usage and presentation of the
results. Improvements were then implemented. The work concludes with suggestions
for improvements to other IDEs, more flexible configuration, improved
presentation and the addition of a debug adapter. In comparison, the
CPAcheckerLSP and the owl-ms-language-server are similar. Both implement a
language server and both integrate into an IDE with simple plugins. Technically,
of course, the projects are very different, but the two approaches to source
code analysis are particularly contrasting. While the OWL language server only
processes syntax and provides e.g. goto's by means of the syntax tree, the
CPAchecker language server uses a complete diagnostic tool in the background.
This makes it more powerful in diagnostics but weaker in the other LSP features.
It also lacks incremental parsing.

In the paper by Yannik Sander entitled "Design and Implementation of the
Language Server Protocol for the Nickel
Language"@sanderDesignImplementationLanguage, CPAcheckerLSP is categorized as an "interface
to an existing tool". The work is an excellent source that gives a fantastic
introduction to the topic as well as a rough overview of other work. In
subsection 3.2 you will find some language servers that have been categorized.
At this point I would like to highlight this as a brilliant secondary source.
The thesis also deals with the implementation of a nickel language server. Like
the language server itself, this is written in rust, which facilitates
integration by allowing parts of the language analysis to be reused. The
disadvantage, however, is that the implemented language server will not support
incremental parsing because the existing components on which it is based do not
support this feature. The paper discusses a lazy and an eager approach that
comes close to [ref needed]. Basically, the author comes to the same conclusion
that “Ahead of time analysis” (eager) is more responsive than lazy after a
direct lookup. But the Nickel language server should also be
language-independent. To achieve this, it introduces an abstraction, the
“Linearizer” trait. It is the interface between Nickel and the language server,
which converts source code into the representation called Linearization. The
approach is not comparable with traditional analysis of abstract syntax trees,
as used by the owl-ms-language-server. The Nickel language server is implemented
using the “lsp-server” rust crate/package. This also works as usual via a
“didOpen” notification and a subsequent “diagnostics” push notification. The
linearization is cached for each file. This information is also used if the file
is being edited and is in an invalid state. Furthermore, the LSP implements the
server commands hover, jump to reference, show reference, completion and
document symbols using the same linearization. This server also has a usability
evaluation. It was carried out in a workshop with a survey. There is also a
performance evaluation. Part of this is also an analysis of different LSP
requests.

= Background <background>

In this chapter I will explain programs, libraries, frameworks and techniques
that are important to this work. You can skip parts that you are familiar with.
We start with the ontology language this language server will support. Then we
go over how IDE's used to work and what modern text editors do different.
Afterwards I will say something about tree sitter, the parser generator that was
used.

== Owl 2 Manchester Syntax

// TODO What it OWL 1

To understand what OWL 2, the second version of the OWL language, is, let's hear
from the authors of this semantic web language.

#quote(
  block: true, attribution: [w3.org #cite(<OWLWebOntologya>, supplement: [abstract])],
)[The OWL 2 Web Ontology Language, informally OWL 2, is an ontology language for
  the Semantic Web with formally defined meaning. OWL 2 ontologies provide
  classes, properties, individuals, and data values and are stored as Semantic Web
  documents. OWL 2 ontologies can be used along with information written in RDF,
  and OWL 2 ontologies themselves are primarily exchanged as RDF documents.]

This work concentrates on a specific syntax of the OWL language. The so-called
Manchester Syntax. Let's hear from the authors of that syntax what it's all
about.

// TODO why owl2 not owl1
#quote(
  block: true, attribution: [w3.org #cite(<OWLWebOntologya>, supplement: [chapter 1 introduction])],
)[
  The Manchester OWL syntax is a user-friendly syntax for OWL 2 descriptions, but
  it can also be used to write entire OWL 2 ontologies. The original version of
  the Manchester OWL syntax was created for OWL 1 [...]. The Manchester syntax is
  used in Protégé 4 and TopBraid Composer®, particularly for entering and
  displaying descriptions associated with classes. Some tools (e.g., Protégé 4)
  extend the syntax to allow even more compact presentation in some situations
  (e.g., for explanation) or to replace IRIs by label values [...].

  The Manchester OWL syntax gathers together information about names in a
  frame-like manner, as opposed to RDF/XML, the functional-style syntax for OWL 2,
  and the XML syntax for OWL 2. It is thus closer to the abstract syntax for OWL
  1, than the above syntaxes for OWL 2. Nevertheless, parsing the Manchester OWL
  syntax into the OWL 2 structural specification is quite easy, as it is easy to
  identify the axioms inside each frame.

  As the Manchester syntax is frame-based, it cannot directly handle all OWL 2
  ontologies. However, there is a simple transform that will take any OWL 2
  ontology that does not overload between object, data, and annotation properties
  or between classes and datatypes into a form that can be written in the
  Manchester syntax.
]

== IDE's

#figure(
  caption: [The problem: "The Matrix"],
)[
  #j-table(
    columns: (auto, auto, auto, auto, auto), table.header([], [Go], [Java], [TypeScript], [...]),
    // ---------------------
    [Emacs], [], [], [], [],
    // ---------------------
    [Vim], [], [], [], [],
    // ---------------------
    [VSCode], [], [], [], [],
    // ---------------------
    [...], [], [], [], [],
  )
]

#figure(
  caption: [The solution: language server and clients],
)[
  #grid(
    columns: 2, gutter: 2mm, j-table(
      columns: (auto), table.header([*Server*]), [Go], [Java], [TypeScript], [...],
    ), j-table(
      columns: (auto), table.header([*Client*]), [Emacs], [Vim], [VSCode], [...],
    ),
  )
]

IDE's use syntax trees to deliver language smarts to the programmer. The problem
with IDE's is that they are focused on specific languages or platforms. They are
usually slow due to not using incremental parsing. This means on every keystroke
the IDE is parsing the whole file. This can take 100 milliseconds or longer,
getting slower with larger files. This delay can be felt by programmers while
typing. @loopTreesitterNewParsing

== Language Server
// https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html 4:05

#lorem(100)

== Tree Sitter

Tree-sitter is a parser generator and query tool for incremental parsing. It
builds a deterministic parser for a given grammar that can parse a source file
into a syntax tree and update that syntax tree efficiently. It aims to be
general enough for any programming language, fast enough for text editors to act
upon every keystroke, robust enough to recover from previous syntax errors and
dependency free, meaning that the resulting runtime library can be embedded or
bundled with any application. @TreesitterIntroduction

It originated from Max Brunsfeld and was build at GitHub with c and c++ and is
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

== GLR parser

GLR parsers (generalized left-to-right rightmost derivation parser) are more
general LR Parsers that handle non-deterministic or unambiguous grammars.
Deterministic LR parsers #cite(<ahoTheoryParsingTranslation1972>, supplement: [chapter 4]) have
been well studied and optimized, yielding very efficient parsers. But they are
limited to a subset of grammars that are not unambiguous. GLR parsers do not
produce non-deterministic automata in the theoretical sense, rather they produce
an algorithm simulating them. Keeping track of all possible states in parallel.
Backtracking on the other hand is extremely in efficient. Parallel parsers #cite(<ahoTheoryParsingTranslation1972>, supplement: [chapter 4.1 and 4.2]) on
the other hand produce in the worse case a time complexity of $O(n^3)$, like
random grammars. But on a large class of grammars they are linear in time. This
makes them extremely useful for design and research, because of the otherwise
grammatical constrains that LR parsing comes with
@ironsExperienceExtensibleLanguage1970
#cite(<langDeterministicTechniquesEfficient1974>, supplement: [introduction]).

// TOOD (Context free grammars als wort einbauen)

// secondary source @langDeterministicTechniquesEfficient1974

// TODO mehr schriebe
// TODO sekundärquelle durch primärquelle ersetzten

//TODO paper Deterministic Techniques for Efficient Non-Deterministic Parsers DOI:10.1007/3-540-06841-4_65

= Implementation <implementation>

This chapter will explain what was implemented and how it was done. I will also
show why I choose the tools that I did, what alternatives exist and when to use
those.

== Parsing

A language server needs a good parser and when there is no incremental error
recovering parser it needs to be build. The parser generator chosen for this
language server is tree sitter.

=== Why Tree Sitter

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
languages. I chose rust. The programming language could offer me the safety,
speed and comfort needed. Some notable alternatives are typescript and c++. I
choose rust over typescript, because of performance. Rust compiles to native
machine code and runs without a garbage collector while typescript first gets
transpiled into javascript and then would run on a "virtual machine" like
javascript engine - e.g. V8. Modern javascript engines are fast enough and this
language server could be ported. One other benefit of typescript is the fact
that it can be packaged into a Visual Studion Code plugin.// TODO is it possible to do the same thing using a rust binary?
I will try the same thing using a rust binary.// TODO
C++ on the other hand is very fast but lacks the safety and comfort. This is not
a strict requirement, and it would be a viable implementation language for this
language server.// More about that in @rust_over_cpp.
But the rust bindings, cargo package manager and memory safety are excellent and
guaranteed an efficient implementation. The Chromium project had found that
roughly 70% of serious security bugs are memory safety problems @MemorySafety.
The usage of Rust rules out the entire class of bugs for safe rust applications.
In hindsight, it was a good choice and I recommend rust for writing language
servers.

// TODO reference rust book, typescript and c++ stuff

I came across tree sitter when I was researching what my own text editor uses
for its syntax highlighting. It turned out that the editor Helix also uses tree
sitter. Just like GitHub.// TODO Reference for this?
It is popular and the standardized syntax tree representation and grammar files
make it ideal.

// Alternatives
Initially I wanted to work with Haskell and use the parser from spechub's Hets,
but it uses parsec and is sadly not an incremental parser. Also, it has no error
recovery functionality that would be sufficient for text editors. There are
similar reasons to not use the owlapi for parsing.

//TODO besserer satz als Nobody would like to have a completely red underlined document in case of a syntax error in
//line one.

I then read about the Happy parser generator, witch Haskell uses, and Alex the
tool for generating lexical analyzers. But the complexity of these tools put me
off, and I also didn't know how to connect the different libraries with one
another.

The Protégé project uses the parser of the owlapi which does not do error
recovering or incremental paring.// TODO ref owl api
The package responsible for parsing in the owlapi is `org.semanticweb.owlapi.manchestersyntax.parser`.

// TODO more alternavies

For these reasons I ended up writing a custom parser. The next chapter will show
how this was done.

=== Tree Sitter Grammar

Staring with the official reference of the OWL2 manchester syntax
@OWLWebOntologya, I transformed the rules into tree sitter rules, replacing the
rules with the corresponding tree sitter ones. For example, I rewrote the
following rule from

```bnf
ontologyDocument ::=  { prefixDeclaration } ontology
```

into

```js
ontology_document: $ => seq(repeat($.prefix_declaration), $.ontology),
```

Tree sitter rules are always read from the `$` object and named in snake_case.
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
are hidden because they add substantial depth and noise to the syntax tree.// TODO reference https://tree-sitter.github.io/tree-sitter/creating-parsers#hiding-rules
While using the written grammar in a later step of the implementation it was
obvious that hiding each supertype node did increase the complexity of the
queries, because while querying for a supertype each subtype must be named,
instead of just one named supertype. The transformations where done using the
following table for reference. Each construct has a rule in the original
reference and in the new tree sitter grammar.

// #show table.cell: it => {
//   if it.x == 0 or it.y == 0 {
//     strong(it)
//   } else {
//     set table.cell(stroke: black)
//   }
// }
// #set table.cell(stroke: black)
// #set table(stroke: (x, y) =>{
//   let s = (left: black, right: black, top: black, bottom: black)
//   if x == 0 { s = s + (left: none) }
//   if y == 0 { s = s + (top: none) }
//   if x == -1 { s = s + (right: none) }
//   if y == -1 { s = s + (bottom: none) }
//   s
// })
// #show table.c

#j-table(
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

In a second step the rules where transformed from typical BNF constructs into
more readable tree sitter rules. These transformations are shown in the
following table.

#j-table(
  columns: (2fr, 3fr, 3fr), table.header([*Construct*], [*OWL BNF*], [*tree sitter grammar*]),
  // ---------------------
  [separated by comma], [```<NT> { ',' <NT> }```], [```js sep1(<NT>, ',')```],
  // ---------------------
  [separated by "or"], [```<NT> { 'o' <NT> }```], [```js sep1(<NT>, 'o')```],
  // ---------------------
  [one or more], [```<NT> ',' <NT>List```], [```js repeat1(<NT>)```],
  // ---------------------
  [annotated list], [```[a] <NT> { ',' [a] <NT> }```], [```js annotated_list(a, <NT>)```],
)<js_transfromations>

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

There are limits on how precise your parse should be. The IRI rfc3987
format@rfc-3987 is part of the OWL2-MS specification but not simple in any way.
Some specification for the IRI was skiped and put in some regexs that worked for
the test data but not necessarily for all ontology documents. This had to be
done because, for example the IRI specification, defines many small
non-terminals. It would be time-consuming and impractical to write that grammar
in full just to get some small benefit in syntax errors.

Tests where wrote to see if the grammar and the resulting parser would produce
the correct syntax tree for the given source code. This is done with tree
sitters CLI. More about tree sitter query testing in @query-tests.

The grammar had to be changed while developing and after writing large parts of
the language server, containing many queries. This was of course time-consuming,
as all queries in the language server had to be adapted for the new grammar.
Unfortunately, there is no type checking or other tool support inside the
original tree sitter. Everything is based on magic strings. There is a tool
called rust sitter@HydroprojectRustsitter2024 that does type checking and
creates a generated rust data structure for a given grammar, but it has
limitations like no incremental parsing support and was hence not suitable,
because this feature was one of the reasons why tree sitter was chosen.

=== Using the generated parser

There are a number of uses for the generated parser. The simplest is syntax
highlighting. Because the language server was developed with helix, a tree
sitter focused editor, in mind, the syntax highlighting uses tree sitter
queries. They use a modified version of the s-expression syntax and look
something like this.

```scm
; highlights.scm

"func" @keyword
"return" @keyword
(type_identifier) @type
(int_literal) @number
(function_declaration name: (identifier) @function)```

The file contains multiple queries that each have a specially named captures.
These arbitrary highlight names map to colors inside the editor theme. Some
common highlight names are `keyword`, `function`, `type`, `property`, and `string` but
this is editor dependent. This language server uses `punctuation.bracket`, `punctuation.delimiter`, `keyword`, `operator`, `string`, `number`, `constant.buildin`, `variable` and `variable.buildin`.

Queries can also be used to extend the functionality of a text editor by
supplying useful syntactic information. The grammar can provide text objects,
indentations and other editor specific queries. The following queries are for
folding in the owl-ms grammar.
```scm
[
  (ontology)
  (class_frame)
  (datatype_frame)
  (object_property_frame)
  (data_property_frame)
  (annotation_property_frame)
  (individual_frame)
  (misc)

  (sub_class_of)
  (equivalent_to)
  (disjoint_with)
  (disjoint_union_of)
  (has_key)
] @fold
```

They define which nodes are foldable. In this case it's when frames or
properties of frames start. The same query, replacing `fold` with `indent` and `extend` captures,
is used for indents.

While developing the language server the grammar had to change, because the
queries where getting more and more complicated. Changing the grammar is
time-consuming because the language server depends on it. All relevant queries
have to be adapted and unfortunately there is no good static analysis for this.

// === Why use rust and not c or c++ <rust_over_cpp>

// // TODO
// - memory safety
// - pointers
// - compile time
// - ease of use
// - arithmetic type system

// https://www.educative.io/blog/rust-vs-cpp#compare

The grammar distribution works through the GitHub repository
https://github.com/janekx21/tree-sitter-owl-ms. It contains an NPM package,
queries and bindings. The queries are for folds, highlights and indents; the
bindings are for node and rust. The latter defines a crate/package which the
language server imports as a submodule and uses as a local dependency.

== LSP specification and Rust implementation

// TODO who defines the specification
Microsoft defines the LSP specification (Version 3.17) on a GitHub page./* TODO reference LSP specification */ The
page contains the used base protocol and its RPC methods using typescript types.
The @lsp_lifecycle shows a typical LSP lifecycle.

#figure(
  caption: [An overview of the LSP lifecycle], kind: image,
)[
```pintora
sequenceDiagram
  @param noteMargin 20
  Client->>Server: Start the Server
  activate Server
  @start_note left of Server
  The client creates a sub process and opens a stdio pipe
  for communication. The following communication is via json-rpc.
  @end_note
  Client->>+Server: initialize(params: InitializeParam)
  Server-->>-Client: result: InitilizeResult
  Client->>Server: initialized(params: InitializedParams)
  Client->>Server: textDocument/didOpen(params: DidOpenTextDocumentParams)
  Server->>Client: textDocument/publishDiagnostics(params: PublishDiagnosticsParams)
  == Using the Language Server ==
  Client->>Server: textDocument/didClose(params: DidCloseTextDocumentParams)
  Client->>+Server: shutdown()
  Server-->>-Client: result: null
  Client-xServer: exit()
  deactivate Server
```
// TODO ref springer buch
]<lsp_lifecycle>

Not all LSP features can be listed here because many require more than one RPC
call or are not relevant for this language server. That said, let us begin with
the start of the language server. The client creates a sub process of the LSP
server executable using the executables path and arguments. Some language
servers use the `--stdio` command line argument to indicate that the
communication will be done via the stdin and stdout pipes. The
owl-ms-language-server uses the stdio pipes by default and does not support
sockets. When a message needs to be sent between server and client, they just
write into the stdio pipe. The client uses stdin the server uses stdout. Hey
communicate using a simple protocol called json-rpc. The so-called base protocol
consists of a header part and a content part.

```
Content-Length: ...\r\n
\r\n
{
  "jsonrpc": "2.0",
  "id": 1,
  "method": "textDocument/completion",
  "params": {
    ...
  }
}
```

The `method` string and `params` object contain the data that is used for all
language smarts. It is used for requests, responses and notifications. However,
the client should not expect a reply to a message. These are only remote
procedure calls, not classic endpoints as we know them from servers.

// TODO maybe errors, notification, progress and cancelation

// TODO reference https://microsoft.github.io/language-server-protocol/specifications/lsp/3.17/specification/

The first thing that happens in the communication after starting the language
server is that the client sends an in initialize request to the server. This
contains meta information, who the client is, etc. But the most important thing
is the client capabilities. Not every editor supports all LSP features. It must
therefore be clarified here which features are relevant for the server. For the
time being, all other messages are prohibited, or it must not be guaranteed that
a response will be sent. The server responds with the initialize result, which
also contains the server capabilities. Not every language server supports all
features, so it must be communicated at this point which features the client can
use. The client then sends an initialized notification to the server. Now the
server and client are ready to start working. The handshake is complete. A
communication ends preferably with a shutdown request from the client. After an
empty response from the server, the client sends a final exit notification and
this concludes the communication.

// TODO maybe dynamic client capabilities, set trace, log trace

The good thing is that we can leave out all these technical details when
building a language server, because packages provide these functions. In the
case of this server, the used rust crate/package is called "tower-lsp". Just
supply a trait implementation for your server state and that's it. A minimal
code example that creates an empty language server can be found in
@code:minimal-server.

#figure(
  caption: "Minimal language server in rust via tower-lsp crate/package",
)[
```rust
struct Backend {
    // Put your state here
}
#[tower_lsp::async_trait]
impl LanguageServer for Backend {
    // Put your functions here
}
#[tokio::main]
async fn main() {
    let (service, socket) = LspService::new(|client| Backend {
        // Init your state here
    });

    let stdin = tokio::io::stdin();
    let stdout = tokio::io::stdout();
    Server::new(stdin, stdout, socket).serve(service).await;
}```
]<code:minimal-server>

The next chapters will contain single language server protocol requests and
notifications. The chapters always start with a description, contain the
typescript interface and the tower-lsp functions, followed by an in depth
explanation and an example image. The next big point is synchronizing our
document. The following chapters will deal with this, followed by documentation,
diagnostics, hints and auto-completion.

== Text Document Synchronization

The language server protocol defines how a document is sent from the client to
the server. The server does not open the file itself. It just gets the contents
and can request other files from the client. In ensures that the client can
operate safely separated from the server. This makes it even possible to run the
server on a separate host or even another operating system. The language server
has no need for an internet connection, file system, random generator or time.
It just needs a stable RPC connection to the client. This connection can be a
network socket, file socket or in most cases just stdio.

=== The `TextDocumentSyncKind` <sync_kind_incremental>

According to the specification, the text document can be synchronized in two
ways. In the first type is `Full`; the entire document is always sent. The
second type is `Incemental`; only changes in the content of a document are sent.
It must be remembered here that an ontology file can become very large. The file
I am working with, `oeo-full.omn`, is about 2 megabytes in size. When deciding
whether to synchronize the entire document or just the changed parts,
incremental changes should be preferred. Only sending changes is fewer data and
the server gets information where content changed for free and without diffing
anything. This is very useful for incremental parsing and updating diagnostics,
because it reduces the search space.

The content changes are sent in small snippets. Each snippet has a range and
content. If something is added to the document, for example, the start and end
of the range are the same and the content contains what has been added. If you
remove something, the content is empty and the range indicates where it is
deleted. If something is replaced, there is a range and a content that contains
the replacement. Marginal amounts of data are transferred in most cases (single
character insertion or deletion), compared to a full document. This is faster
than transferring the entire document. You can find an example in
@did_change_example.

=== `textDocument/didOpen` Notification<section:did_open>

Now let's explore our first language server endpoint. The simplest one after to
the initialization. The notification is sent from the client to the server to
inform the language server, that a new text document was opened on the client.
The parameter contains the text document. Those documents are identified by a
URI (Unified Resource Identifier). They are just strings and in most cases start
with the file protocol like `file:///home/janek/project/readme.md`. The format
is specified by rfc3986, which is the same format that OWL uses.

```ts
interface DidOpenTextDocumentParams {
  textDocument: TextDocumentItem;
}

interface TextDocumentItem {
  uri: DocumentUri; // just a string
  languageId: string; // "owl-ms" in this case
  version: integer; // 0 in this case
  text: string;
}```

The `textDocument/didOpen` endpoint is handled in the rust language server as a
method of a `LanguageServer` trait called `did_open`. This trait is implemented
for the struct `Backend`, which contains the whole state of the language server.

```rust
struct Backend {
    client: Client,
    parser: Mutex<Parser>,
    document_map: DashMap<Url, Document>, // DashMap is an async hash map
    // ...
}

struct Document {
    tree: Tree,
    rope: Rope,
    version: i32,
    iri_info_map: DashMap<Iri, IriInfo>,
    diagnostics: Vec<Diagnostic>,
}

#[tower_lsp::async_trait] // traits can not be async by default
impl LanguageServer for Backend {
    // ...
    async fn did_open(&self, params: DidOpenTextDocumentParams) {
        // Parse the document (locking the Mutex) from borrowed params.text_document.text
        // Create rope from params.text_document.text
        // Insert document into self.document_map
        // Create diagnostics from the parse
        // Extract and save information from the parse (eg. used for gotodefinition)
        // Send diagnostics to client
        // ...
     }
    // ...
}
```

The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/c39761487c920dcaf65720947ab8e2345e2bec1f/src/main.rs#L236",
)[owl-ms-language-server/src/main.rs\#L236].

This method does not return anything; it is a Notification and only there for
our language server to register that a file has been opened. The language server
then parses the file and creates a rope data structure. It also creates
diagnostics and sends them to the client. The interesting thing here is that
rust's borrow checker shows exactly where it is likely that a copy of the data
is done and where not. For example, the parsing happens on the original
buffer/document, while the creation of the rope consumes the original. Then the
rope and the tree are moved into the document map. This also consumes them, so
it is a move, not a copy.

=== `textDocument/didChange` Notification <did_change>

#figure(
  caption: [A typical text document update lifecycle], kind: image,
)[
```pintora
sequenceDiagram
  @param noteMargin 20
  Client->>Server: textDocument/didChange(params: ChangeOpenTextDocumentParams)
  @start_note left of Server
  Update the internal server state
  and generate new diagnostics
  @end_note
  Server->>Client: textDocument/publishDiagnostics(params: PublishDiagnosticsParams)
```
// TODO ref springer buch
]

This notification is sent from the client to the server to inform the language
server about changes in a text document. Its parameter contains the text
document identification and the content changes made to the document. The
version should increase after each change. The content changes are ranges with
texts. They work as explained in @sync_kind_incremental.

```ts
interface DidChangeTextDocumentParams {
  textDocument: VersionedTextDocumentIdentifier; // URI and version
  contentChanges: TextDocumentContentChangeEvent[];
}
export type TextDocumentContentChangeEvent = {
  range: Range;
  text: string;
}
```

The first thing that happens is that the server retrieves the document from its
model using the URI from the parameter. Then the rope and the old syntax tree
are modified. The rope then contains the same text document as the client. The
old syntax tree moves its node positions. A reparsing does not yet take place,
but the process is necessary so that the old, unmodified nodes later fit into
the new positions. Incidentally, the syntax tree does not save any text. It only
contains the nodes. To get the text from the nodes, you still need a rope that
fits the tree. The old syntax tree (with the new node positions) and the new
rope can then generate a new syntax tree using reparsing. The IRI map and
diagnostics are then adapted and published. This is done by first removing the
entries that overlap the changed positions and then generating and inserting new
information in these positions (prune and extend). If the number of changes
exceeds a threshold value, IRI map and diagnostics are completely removed and
regenerated. I don't know if this is really necessary. You can find an example
in @did_change_example.

```rust
// inside impl LanguageServer
async fn did_change(&self, params: DidChangeTextDocumentParams) {
    // Get the document from self.document_map
    // Update the documents rope and syntax tree with the changes
    // Parse using the old tree with changed ranges (incremental parse)
    if use_full_replace {
      // Do a full replace instead of incremental when worth
    }
    // Prune and extend iri info map
    // Prune and extend diagnostics
    // Publish diagnostics async
}
```
The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/c39761487c920dcaf65720947ab8e2345e2bec1f/src/main.rs#L273",
)[owl-ms-language-server/src/main.rs\#L273].

=== `textDocument/didClose` Notification <did_close>

This notification is sent from the client to the server when a text document got
closed on the client.

```rust
// inside impl LanguageServer
async fn did_close(&self, params: DidCloseTextDocumentParams) {
    self.document_map.remove(&params.text_document.uri);
}
```
The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/c39761487c920dcaf65720947ab8e2345e2bec1f/src/main.rs#L421",
)[owl-ms-language-server/src/main.rs\#L421].

== `textDocument/semanticTokens/full` Request

This request is sent from the client to the server to resolve all semantic token
in a text document. The parameter contains the URI of the file and the result
contains a list of semantic tokens. The language server protocol does not define
how syntax highlighting is done. Most editor do the highlighting with regular
expressions, some use tree sitter queries. Visual Studio Code uses TextMate
grammars.// TOOD ref https://code.visualstudio.com/api/language-extensions/syntax-highlight-guide
IntelliJ IDEA uses TextAttributeKeys2.// TODO ref https://plugins.jetbrains.com/docs/intellij/syntax-highlighting-and-error-highlighting.html
Helix uses the tree sitter queries of `highlights.scm`, a common syntax
highlighting file that a grammar optionally can define.// TODO ref https://docs.helix-editor.com/guides/adding_languages.html
But the language server protocol defines how semantic tokens can be resolved.
This is similar to syntax highlighting with a big advantage. Semantic tokens can
capture language specific semantic meaning that regular expression can not
(nearly impossible, but certainly unfeasible).// TODO ref https://link.springer.com/content/pdf/10.1007/978-1-4842-7792-8.pdf

That said, the owl-ms-language-server uses semantic tokens for syntax
highlighting.
// TODO write more?

```rust
// inside impl LanguageServer
async fn semantic_tokens_full(&self, params: SemanticTokensParams) -> Result<Option<SemanticTokensResult>> {
    // Get the document from self.document_map
    // Load the highlights query from the tree_sitter_owl_ms crate
    // Query the whole text document
    // Convert each match into a semantic token, using the capture name as the token type
    // Sort the tokens
    // Convert the token ranges from absolute to relative
    // Return the tokens
}
```
The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/c39761487c920dcaf65720947ab8e2345e2bec1f/src/main.rs#L695",
)[owl-ms-language-server/src/main.rs\#L695].

#figure(
  grid(
    columns: 2, row-gutter: 2mm, column-gutter: 1mm, image("assets/screenshot_vscode_just_opened-1.svg"), image("assets/screenshot_vscode_just_opened.svg"), "a) without the owl-ms plugin", "b) with the owl-ms plugin",
  ), caption: [
    Visual Studio Code (editor-container) after opening the pizza ontology
  ],
)

== `textDocument/hover` Request

This request is sent from the client to the server to request hover information
at a given text document position. The parameter contains the text document
identifier and a position inside this document. While the result contains the
hover content in a markup format and the range that the hover applies to.

```ts
export interface HoverParams extends TextDocumentPositionParams,
  WorkDoneProgressParams {
}

interface TextDocumentPositionParams {
  textDocument: TextDocumentIdentifier;
  position: Position;
}

export interface Hover {
  contents: MarkedString | MarkedString[] | MarkupContent;
  range?: Range;
}```

In the language server implementation this request is processed by the `hover` function.

```rust
// inside impl LanguageServer
async fn hover(&self, params: HoverParams) -> Result<Option<Hover>> {
    // Get the document from self.document_map
    // Find deepest named node in the document at the position of the parameter
    // Generate node info of that node
    //     This is done by checking the node kind
    //     The fallback case returns the node kind
    // Return that info
}
```
The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/510858a58f24dd251f33013a9623e20975f25daa/src/main.rs#L435",
)[owl-ms-language-server/src/main.rs\#L435].

The hover function first fetches the document from the document map. It is
populated by the `textDocument/didOpen` notification that can be found in
@section:did_open. All requests that fetch a document from the document map can
fail if the document is not available, resulting in an error response. After the
document, and thus also the parsed tree, the rope and the IRI info map, have
been retrieved, the lowest named node under the requested position will be found
in the tree. A tree walk is performed for this purpose. It creates a cursor at
the tree root. Using a loop, the cursor is moved recursively along the tree
until a leaf node is found. The cursor is then moved up (parent nodes) the tree
again in a loop until a named node is found. This node is returned and used for
the hover information. A distinction is now made between different types of
nodes. When an IRI is hovered, each annotation must be retrieved from the IRI
info map in order to display it in a meaningful way. The title of the hover info
for example is the resolved `rdfs:label` value. The implementation does not do
much more here, but it could also fetch all kinds of other information from the
ontology. When a frame is hovered, the same information is returned as for the
frame's IRI. All other node kinds will return a generic result that contains the
node kind. The result can be seen in @image:hover. The figure also shows a
slight imperfection. When designing the IRI info map, no attention was paid to
the fact that an annotation can be used more than once. Here, for example, the `rdfs:label` is
specified with different languages. However, only one is displayed. In this
case, it is Polish, which is not useful for every user. In the future, such
preferences should be adjustable.

#figure(
  image("assets/screenshot_vscode_hover.svg", width: 100%), caption: [
  Visual Studio Code (editor-container) with the owl-ms plugin after hovering the `pizza:NamedPizza`
  IRI
  ],
)<image:hover>

== `textDocument/publishDiagnostics` Push Notification

This push notification is sent from the server to the client to push a new set
of diagnostics.

```ts
interface PublishDiagnosticsParams {
  uri: DocumentUri;
  version?: integer;
  diagnostics: Diagnostic[];
}


export interface Diagnostic {
  range: Range;
  severity?: DiagnosticSeverity; // used just a static 1 = Error
  source?: string; // used just a static "owl-language-server"
  message: string;
  // ... some other properties that where not used
}

export type DiagnosticSeverity = 1 | 2 | 3 | 4;
```

The language server sends this notification whenever the diagnostics change,
event if they are removed completely. This is done in the `textDocument/didOpen` Notification
(found in @section:did_open) and the `textDocument/didChange` Notification
(found in @did_change). They are generated using a `gen_diagnostics` function
that takes a syntax tree node on which to generate them. On the first opening of
a file this node is the root of the syntax tree. All further changes search for
this node by finding the highest node that overlaps with the change range.
Diagnostics are cached and are only changed when something in their range
changes in the document. For this reason, the server must also have all
diagnostics available for every open document.

#figure(
  caption: [Part of the `did_open` function that prunes and extends diagnostics],
)[
```rust
// Do this for an updated document and a changed range (so we got document and range)

// Remove old diagnostics
document
    .diagnostics
    .retain(|d| !range_overlaps(&d.range.into(), range));

// Find the node that needs new diagnostics
let mut cursor = document.tree.walk();
while range_exclusive_inside(range, &cursor.node().range().into()) {
    if cursor.goto_first_child_for_point(range.start.into()).is_none() {
        break;
    }
}
cursor.goto_parent();
let node_that_has_change = cursor.node();
drop(cursor);

// Generate those diagnostics
let additional_diagnostics = gen_diagnostics(&node_that_has_change)
    .into_iter()
    // Because the node could include unchanged diagnostics we need to remove those to
    // not add duplicates
    .filter(|d| range_overlaps(&d.range.into(), range));

// Add the new diagnostics back in
document.diagnostics.extend(additional_diagnostics);
```
]<code:diagnostics_prune_and_extend>

The @code:diagnostics_prune_and_extend shows how the `did_change` function first
removes all old diagnostics for a change range and then inserts newly generated
ones. The more complex `gen_diagnostics` function takes a changed node and
generates diagnostics for cust that node.

#figure(caption: [`gen_diagnostics` function with complex tree walk])[
```rust
fn gen_diagnostics(node: &Node) -> Vec<Diagnostic> {
    let mut cursor = node.walk();
    let mut diagnostics = Vec::<Diagnostic>::new();

    loop {
        let node = cursor.node();
        if node.is_error() {
            // Root has no parents so use itself
            let parent_kind = node.parent().unwrap_or(node).kind();

            // Push a diagnostic using static node type lookup
            // for valid children of parent

            while !cursor.goto_next_sibling() {
                if !cursor.goto_parent() {
                    return diagnostics;
                }
            }
        } else if node.has_error() {
            let has_child = cursor.goto_first_child();
            if !has_child {
                while !cursor.goto_next_sibling() {
                    if !cursor.goto_parent() {
                        return diagnostics;
                    }
                }
            }
        } else {
            while !cursor.goto_next_sibling() {
                if !cursor.goto_parent() {
                    return diagnostics;
                }
            }
        }
    }
}
```
]<code:gen_diagnostics>

The `gen_diagnostics` function seen in @code:gen_diagnostics is not a recursive
tree walk but rather uses a loop. It works by walking the tree with a cursor.
The cursor moves along the siblings and to the parent, when the node does not
contain errors. Otherwise, it moves into the first child and along the siblings.
When it encounters a node that is an error node directly, a diagnostic is pushed
into the returned vector. The message of the diagnostic is based on the parent
node of the error. Using a static node type lookup, the possible child nodes can
be found. Sadly tree-sitter does not directly deliver the information of
possible nodes and therefore the message will not be correct all the time.
Future developments could improve this message greatly.

Static node types are created by tree-sitter and are stored in a simple JSON
file called `src/node-types.json`. The language server loads them lazy and
deserializes them using the popular "serde" crate/package. The result is put
into a dash map for quick lookup when generating diagnostics. The file contains
every node type and the children of that node.

#figure(
  caption: [A portion of the `node-types.json` file showing the `class_iri` node kind],
)[
```json
...
  {
    "type": "class_iri",
    "named": true,
    "fields": {},
    "children": {
      "multiple": false,
      "required": true,
      "types": [
        {
          "type": "abbreviated_iri",
          "named": true
        },
        {
          "type": "full_iri",
          "named": true
        },
        {
          "type": "simple_iri",
          "named": true
        }
      ]
    }
  },
...
```
]

#figure(
  image("assets/screenshot_vscode_diagnostics_1.svg", width: 100%), caption: [
    Syntax error example
  ],
)<image:errors>

In the example case, that is shown in @image:errors, the syntax error resulting
from the invalid "????????" part is shown. The message is generated from the
parent node. In this case it is "Object Propery Frame", found after "inside".
The lookup into the node types returned the possible children and displays them
in the diagnostics after
"expected". Because tree-sitter does do error recovery, it is possible to show
every syntax error in a file. Clients can show every error (Called "Problems" in
@image:multiple_errors) in a source code file. The language server does not show
errors other than syntax errors like semantic ones. A future version could
improve diagnostics and show a more complex errors. This could be done by using
the OWL Api or maybe a OWL solver application.

#figure(
  image("assets/screenshot_vscode_diagnostics_2.svg", width: 100%), caption: [
    Syntax error example with overview overview of all problems in a file
  ],
)<image:multiple_errors>

== `textDocument/inlayHint` Request

This request is sent from the client to the server to request inlay hints in a
range of a specific text document. The parameter contains the text document
identifier and a range. This range is typically the view box into a opend file
from the client.

```ts
export interface InlayHintParams extends WorkDoneProgressParams {
  textDocument: TextDocumentIdentifier;
  range: Range;
}

export interface InlayHint {
  position: Position;
  label: string | InlayHintLabelPart[]; // this LS uses string
  paddingLeft?: boolean;
  paddingRight?: boolean;
  // ... some other properties that where not used
}
```

The inlay hints are the feature that makes `*.omn` files, with numbers used as
identification in the IRI's, tolerable for text editors. It enriches the view of
the source code with human-readable information by retrieving the so-called
"rdfs:label" from the annotations contained in the document and displaying it
next to the IRI. In the @image:inlay_hints example, it can be seen that the
class for emissions does not use a human-readable IRI. Instead, it is a number
that is incremented for each frame. In OWL ontologies, it is up to the author to
decide which IRI to use and they many use these automatically generated ones to
facilitate subsequent renaming. However, this makes it very difficult to read
such documents. The reader would have to look up each IRI and the language
server in this tool takes care of this lookup. For example, the IRI that ends
with "OEO_00000147" is provided with an inlay hint that displays the
"rdfs:label", i.e. "emission". However, the owl-ms-language-server only
implements a very rudimentary variant. In the future, additional information
from other `*.omn` files or even external OWL ontologies could be taken into
account.

```rust
async fn inlay_hint(&self, params: InlayHintParams) -> Result<Option<Vec<InlayHint>>> {
    // Get the document from self.document_map
    // Query all IRI's but restrict the query to the range in params.range
    // For each found match do a lockup into the documents iri_info_map
    //    Generate an inlay hint for the retrieved info (this uses the rdfs:label annotation)
    // Return the transformed inlay hints
}
  ```
The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/c39761487c920dcaf65720947ab8e2345e2bec1f/src/main.rs#L459",
)[owl-ms-language-server/src/main.rs\#L459].

#figure(
  image("assets/screenshot_vscode_inlay_hints.svg", width: 100%), caption: [
    Highlighted inlay hints in a small omn file
  ],
)<image:inlay_hints>

== `textDocument/completion` Request

This request is sent from the client to the server to request completion items
under the cursor of a specific text document. The parameter contains the text
document identifier and position. The completion items are presented in the user
interface as a list of possible completions.

```ts
// The completion Response is just a CompletionItem[]

export interface CompletionItem {
  label: string;
  // ... huge number of unsed properties
}
```

The completion function takes the document and searches for the deepest node at
the cursor position in the syntax tree and creates a cursor there. As long as
the node is an error, the cursor goes to the parent. To get the possible
keywords, the function now uses the node type DashMap to look up the current
node. If found, the possible child nodes are collected here. This is very
similar to diagnostics, where the same procedure is used to genreate a syntax
error message. Here, the possible nodes become a completion item by turning the
node kind into a keyword. There is done in a large lookup function called `node_type_to_keyword(tipe: &str) -> Option(String)` (Unfortunately, `type` is
a reserved keyword, so `tipe` is used here instead). When writing the grammar,
it was not yet clear that it should have a separate rule for each keyword, so
unfortunately not all keywords can be used here. This problem must be solved in
the next version of the grammar.The list of possible IRIs is created based on
the previously found parent node. If this node is a `simple_iri`, an IRI
containing the item text is searched for in the `iri_info_map`. Afterward, it
was noticed that this is not sufficient. On the one hand, it should also be
possible to complete other types of IRIs. On the other hand, the `iri_info_map` is
not equipped with all IRIs from the file. That is why this type of completion
does not always work. At the end, the two lists are merged. This works because `simple_iri` has
no child node in the node types.

```rust
async fn completion(&self, params: CompletionParams) -> Result<Option<CompletionResponse>> {
    // Get the document from self.document_map
    // Find node under cursor
    // Generate keyword list that can be applied
    //     This also works with node types like diagnostics
    //     Note that this is missing some keywords because of limitations in the grammar
    // Generate a list of IRIs that can be inserted
    // Combine lists and return the completions items
}
```
The source code of that function can be found in this rust file
#link(
  "https://github.com/janekx21/owl-ms-language-server/blob/c39761487c920dcaf65720947ab8e2345e2bec1f/src/main.rs#L626",
)[owl-ms-language-server/src/main.rs\#L626].

#figure(
  image("assets/screenshot_vscode_completion_keyword.svg", width: 100%), caption: [
  Completion list items of keywords after typing `Ann`
  ],
)

#figure(
  image("assets/screenshot_vscode_completion_iri.svg", width: 100%), caption: [
  Completion list items of simple IRIS after typing `pizz`
  ],
)

== Used data structures
#todo(inline: true)[TODO schreiben]
#lorem(50)

=== Rope

Strings are traditionally fixed length arrays of characters with or without
additional space for expansion. These data structures are occasionally
appropriate, but common operations do not scale on these. Performance should
largely not be impacted by long strings. Strings that are a continues array of
characters violate these requirements. Any copy of strings allocates large
chunks of memory. Character insertion and deletion or any operation that shifts
the characters will result in a copy and would make any text editor intolerably
slow. In order to obtain acceptable performance, special purpose data structures
are needed to represent these strings. Ropes make that practical, because it
allows the concatenation of strings to be efficient in both space and time by
sharing data structure of results with its arguments. This is done by a tree in
witch each node represents the concatenation of all child nodes left-to-right.
Leaf nodes consist of flat strings, thus the tree represents the concatenation
of all its leaf nodes. @rope_quick_brow_fox shows an example with the string "The
quick brown fox". @boehmRopesAlternativeStrings1995

#figure(
  caption: "Rope representation of \"The quick brown fox\"",
)[
#set align(center)
#let data = ([concat], ([concat], [`"The qui"`], [`"ck brown"`]), ([`" fox"`]))
#canvas(
  {
    import draw: *

    set-style(
      content: (padding: .2), fill: rgb("#f5f5f5"), line: (fill: gray.lighten(60%), stroke: gray.lighten(60%)),
    )

    tree.tree(
      data, spread: 4, grow: 1.5, draw-node: (node, ..) => {
        content(
          (), box(par(node.content), fill: rgb("#f5f5f5"), inset: 8pt, radius: 4pt),
        )
      }, draw-edge: (from, to, ..) => {
        line((a: from, number: .8, b: to), (a: to, number: .8, b: from))
      }, name: "tree",
    )
    // Draw a "custom" connection between two nodes
    // let (a, b) = ("tree.0-0-1", "tree.0-1-0",)
    // line((a, .6, b), (b, .6, a), mark: (end: ">", start: ">"))
  },
)
]<rope_quick_brow_fox>

The advantage of ropes is that parts of the string can be changed quickly. Both
additions and deletions are in $O(log n)$ and therefore much faster than
monolithic string arrays. The disadvantage of such a data structure is the
reading of sections (report i to j). Here the time complexity is comparable to
the monolithic string array plus the time of the rope tree traversal. Reporting
a string slice is in $O(j + log n)$. In addition to that a rope needs more
overall space and time for managing that a traditional string array. But arrays
also need huge amounts of memory for copying operations.
@boehmRopesAlternativeStrings1995

#j-table(
  columns: (auto, auto, auto), table.header([*Operation*], [*Rope*], [*String*]),
  // ---------------------
  [Insert], [$O(log n)$], [$O(n)$],
  // ---------------------
  [Delete], [$O(log n)$], [$O(n)$],
  // ---------------------
  [Report(i, j)], [$O(j + log n)$], [$O(j)$],
)

=== DashMap

DashMap@wejdenstalXacrimonDashmap is an implementation of a concurrent
associative array/hashmap in Rust. I use DashMap with the document map and with
the iri info map. It is an alternative to a rust hash map (`std::collections::HashMap`)
which has a read write mutex (`RwLock<HashMap<K, V>>`). From the api it is very
similar with the difference that it uses async/await syntax and can work in
parallel. DashMap is very fast as the benchmarks of
conc-map-bench@wejdenstalXacrimonConcmapbench2024 show.

== Optimizations

The owl-ms-language-server rust crate/package includes many optimizations. This
section will list the used optimizations, explain why they are needed and
mention alternatives. Parser grammar, Visual Studio Code plugin and other parts
of the language server did not contain any optimizations. It is unknown if there
is a possibility to optimize the grammar and reduce parsing time. The Visual
Studio Code plugin is very light and there is only one obvious optimization.
Using the build in syntax highlighting instead of the semantic token feature of
the language server.

// TODO explain the further sub sections

=== Rust Async with Tokio <tokio>

In general, language servers are asynchronous in nature. Beginning with the
client-server architecture and extending into the internal structure. For that
reason the whole server is set up in a way to not rely on synchronicity. The
incremental document synchronization uses a versioned sub class of the text
document identifier containing a URI and a version.

```ts
interface TextDocumentIdentifier {
  uri: DocumentUri;
}

interface VersionedTextDocumentIdentifier extends TextDocumentIdentifier {
  version: integer;
}
```

The version will increment on each change. The order does not matter, provided
no change notification is dropped. An ideal language server and client should
buffer out of order requests. The language server protocol defines another
useful concept named "work done progress". It is a generic notification that
communicates the progress of longer asynchronous tasks using a start, report and
end messages. This feature was considered but in the end, not needed for the
owl-ms-language-server.

For all of these asynchronous features the language server uses
tokio@TokioAsynchronousRust. It is an asynchronous runtime for rust and needed,
because rust does not come with any. Tokio is very fast and natively build with
rust. Tokio is also scalable by being build upon the async/await language
feature of rust, witch itself is scalable. In the case of this language server,
Tokio uses green threads on a multithreaded runtime. It would be possible to use
synchronous requests for a language server. But the server would block incoming
requests and would therefore become useless. For example a client that requests
a hover info and a document change at the in quick succession would corrupt the
server state, because the server would drop the document change when it's
blocked by the hover request. In an ideal world, one server could handle many
clients simultaneously. With the Tokio runtime and the rust async/await support,
it was really easy to add async support.

=== Language server state vs. on promise tree query

The owl-ms-language-server has some obvious internal state like all opened
documents. Some state is not that obvious and this sections discusses one of
them. @code:backend contains the complete backend model; witch is more or less
the servers whole state. It contains the connected client (just one), the reused
parser, the opened documents and a setting for which position encoding to use
(some editors don't suppot UTF-8).

#figure(caption: "Backend model of the language server")[
```rust
struct Backend {
    client: Client,
    parser: Mutex<Parser>,
    document_map: DashMap<Url, Document>,
    position_encoding: Mutex<PositionEncodingKind>,
}
```
]<code:backend>

Let's take a look at a document to see what state it stores. The model of the
document can be found in @code:document. It contains the syntax tree (no source
code, just nodes), a rope of the text (wich the syntax tree uses to fetch the
source code), an incrementing version, current diagnostics and a very odd `iri_info_map`.
The diagnostics and the IRI informations can be generated from the tree and rope
and are therefore repeated information in other words data redundancy.

#figure(caption: "Document model of the language server")[
```rust
struct Document {
    tree: Tree,
    rope: Rope,
    version: i32,
    iri_info_map: DashMap<Iri, IriInfo>,
    diagnostics: Vec<Diagnostic>,
}
```
]<code:document>

The question that came up while developing is: "Should all document data come
from just the tree or can you cache some information?". I used the additional
state alternative, because retrieving distributed information like IRI info will
cause a tree query to traverse the whole document/workspace. Caching on the
other hand has the implication of constantly updating the state. The
disadvantage, it's more likely to be bugged than an ad hoc query.

= Analysis <analysis>
#todo(inline: true)[TODO schreiben]
#lorem(50)

== Automated Testing

The language server uses two kinds of automated testing. The first one is
testing the grammar using input source code and expected syntax tree output. The
second testing kind used where integration tests in rust. They focus more on
integration between tree-sitter and the language server, testing like a client
would connect and asserting a result. It is also possible to do end-to-end
testing using Visual Studio Code, but this was sparred here for time reasons.

The tests should run when pushing to the repository in GitHub by using
GitHub-Actions. Merging or deploying a version should only be done when every
automated test succeeds.

=== Query tests in tree sitter <query-tests>

The tree-sitter-owl2-manchester-syntax repository, that contains the tree sitter
grammar that is used by the language server, has its own tests. They can be
found in the `test/corpus/*.txt` files and are executed by running `npm test`.

Each test entry takes the form of a test name, text and expected tree. The
following test is a simple example of a typical `*.omn` file beginning.

```
======================
Class Frame SubClassOf
======================

Ontology:
  Class: Person
    SubClassOf: owl:Thing

-------------------------------------

(source_file
  (ontology
    (class_frame
      (class_iri (simple_iri))
      (sub_class_of
        (description
          (class_iri (abbreviated_iri)))))))
```

Each entry in a test file starts with a line with just `=` (equal sign)
characters followed by a name followed by a line with just `=` (equal sign)
characters. Then the input source code followed by a line with only `-` (dash)
characters. Then the expected output tree as an S-expression. Take a look at
@how_to_read_s_expression on how to read them. This expression ignores
whitespace and does only show named nodes.

These grammar tests are very important. They document and verify the API.
Running them after a grammar change verifies that everything still parses
correctly. But when changing the grammar the tests don't line up anymore and
also need to be changed. Each visible node and each permutation of language
constructs should have a corresponding test to increase the test coverage. When
multiple people work on a tree sitter grammar, the tests give the reader a good
understanding of what inputs produce what outputs, the "edges" of a language.
Tree sitter also supports testing syntax highlighting, but this project does not
use it.

=== Integration tests in rust
#todo(inline: true)[TODO schreiben]
#lorem(100)

== Benchmarks <benchmarks>
There are two kinds of speed measurements. The first kind is cargo benchmarks
using criterion. The second kind is runtime logs of real operations. The runtime
logs is a kind of profiling and are only intended to show that the editor can
also operate in real time with a real client and files. No benchmarks for end to
end operations are necessary yet, as the language server remains nice and fast
even with large files. Only the required main memory is a bit too big for
massive ontology files. It has not yet been possible to determine why this is
the case. In the future, this is a part of the language server that could be
improved, because ontologies can become very large. The following section deals
with how the benchmarks are set up. Some code is shown and explained. The
section after that is about the results of the benchmarks.

=== Experimental Setup

#figure(
  caption: [Rust benchmark "ontology_size_bench"],
)[
```rust
fn ontology_size_bench(c: &mut Criterion) {
    let mut group = c.benchmark_group("ontology_size_bench");
    for size in (1..40).map(|i| i * 100) {
        group.throughput(Throughput::Elements(size as u64));
        group.bench_with_input(BenchmarkId::from_parameter(size), &size, |b, &size| {
            b.iter_batched_ref(
                || {
                    let mut source_code = "Ontology: <http://foo.bar>".to_string();
                    source_code.push_str(
                        "Class: <http://foo.bar/0> Annotations: rdfs:label \"Fizz\" "
                            .repeat(size)
                            .as_str(),
                    );

                    let mut parser = Parser::new();
                    parser.set_language(language()).unwrap();
                    (source_code.to_string(), parser)
                },
                |(source, parser)| parse_helper(source, parser),
                criterion::BatchSize::SmallInput,
            )
        });
    }
    group.finish();
}

fn parse_helper(source_code: &String, parser: &mut Parser) {
    parser.reset();
    parser.parse(source_code, None).unwrap();
}
```
]<code:benchmark_ontology_size>

As can be seen in the @code:benchmark_ontology_size, a temporary ontology is
created in the “ontology_size_bench”, which is variable in size from 100 to 4000
class frames and named input size (elements). Each benchmark is given a name. In
this case ontology_size_bench/\<number of class frames\>. Each benchmark is run
for at least 60 seconds to obtain at least 100 samples. The number of iterations
can therefore be very high. Up to 30 thousand for fast benchmarks. For some
benchmarks, it is also possible that 100 samples cannot be taken because it
would take longer than 60 seconds. In this case, the length of the benchmarks is
increased. This can be over 100 seconds for some.

The second benchmark from @code:ontology_change_bench is similar. It also
creates a temporary ontology with a variable size named input size (elements)
that is the number of class frames in the ontology that will be parsed. However,
the benchmark performs the parsing in advance and then measures the time
required for a change. In this case, no change is even made at all.

#figure(
  caption: [Rust benchmark "ontology_change_bench"],
)[
```rust
fn ontology_change_bench(c: &mut Criterion) {
    let mut group = c.benchmark_group("ontology_change_bench");
    for size in (1..40).map(|i| i * 1000) {
        group.throughput(Throughput::Elements(size as u64));
        group.bench_with_input(BenchmarkId::from_parameter(size), &size, |b, &size| {
            b.iter_batched_ref(
                || {
                    let mut source_code = "Ontology: <http://foo.bar>\n".to_string();
                    source_code.push_str(
                        "Class: <http://foo.bar/0>\nAnnotations: rdfs:label \"Fizz\"\n"
                            .repeat(size)
                            .as_str(),
                    );

                    let mut parser = Parser::new();
                    parser.set_language(language()).unwrap();
                    let mut old_tree = parser.parse(source_code.clone(), None).unwrap();
                    (source_code.to_string(), parser, old_tree)
                },
                |(source, parser, old_tree)| re_parse_helper(source, parser, old_tree),
                criterion::BatchSize::SmallInput,
            )
        });
    }
    group.finish();
}

fn re_parse_helper(source_code: &String, parser: &mut Parser, old_tree: &Tree) {
    parser.parse(source_code, Some(old_tree)).unwrap();
}
```
]<code:ontology_change_bench>

It's expected that an incremental parser only parses the changed sections and
delivers a $O(1)$ runtime complexity on an unchanged source, but the results
suggest otherwise. This benchmark came to be, because the profiling showd ood
timings in small changes.

=== Results

The results show two things. Normal parsing is complex in the runtime of $O(n)$.
This was basically to be expected, because parsing requires iterating over all
characters at least once. Nevertheless, it is good to see that the parser is
roughly in the best possible runtime complexity. The second result shows that
incremental parsing is also in $O(n)$. Here I would have expected the runtime
complexity to be lower. Nevertheless, incremental parsing is significantly
faster than blind parsing. A five to tenfold acceleration is to be expected.

#figure(caption: [Results of the "ontology_size_bench" benchmark])[
  #image("assets/benchmark_lines.svg")
]<image:ontology_size_bench>

#figure(caption: [Results of the "ontology_change_bench" benchmark])[
  #image("assets/benchmark_change_lines.svg")
]<image:ontology_size_bench>

== Evaluation of the usability <evaluation>

=== Experimental Setup
#todo(inline: true)[TODO schreiben]
#lorem(100)

=== Results
#todo(inline: true)[TODO schreiben]
#lorem(100)
//TODO who are the users
//TODO describe the usability
//TODO is the LSP fast enough

= Conclusion

// TODO
- It was hard to track each syntax thing like keywords and rules.
- Changing the grammar has a large impact.

#todo(inline: true)[TODO schreiben]
#lorem(100)

== Performance
#todo(inline: true)[TODO schreiben]
#lorem(100)

== Future Work
#todo(inline: true)[TODO schreiben]
#lorem(100)

- Mono Repo for easy releases
- More features (see list in repo)
- More tests (of queries for example)
- Fetching external ontolgies
- Create class code action when class iri is not found

// = Appendix

// #heading(outlined: false, numbering: none)[Acknowledgments]

// #bibliography("lib.bib", style: "ieee")

/*
 Notes:

 Possible Features:
 - Auto completion with label
 - Goto definition of keywords inside the lsp directory

 Warum hast du so etwas gebaut, was wären Alternativen gewesen und warum hast du sie nicht genutzt.

 - Am Anfrang, Fragestellung: Kann man damit flüssig arbeiten
 - Am Ende, Frage beantworten

 */
#empty-page
#bibliography("../lib.bib")
