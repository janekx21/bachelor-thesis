#import "template.typ": *

#show: project.with(
  title: "Design and development of an OWL 2 manchester syntax language server",
  authors: ((name: "Janek Winkler", email: "janek.winkler@st.ovgu.de"),),
  date: "December 6, 2023",
)

= Abstract
As the number of code editors and programming languages rises, language servers,
which communicate with the editor to provide language-specific smarts, are
getting more relevant. Traditionally this hard work hat been repeated for each
editor as each editor api was different. This can be avoided with a standard.
The _de facto_ standart to realize editing support for languages is the language
server protocol (LSP). This work implements a LSP compatible language server for
the OWL 2 manchester syntax/notation (OMN) using the incremental parser
generator treesitter. It provides language features like auto complete, go to
definition and inlay hints, wich are critical in large OMN files, as it would be
tedious and error prone without a graphical editor. We also evaluated the
practical relevance of the LSP.

= Intoduction

== Owl
== GLR parser
@langDeterministicTechniquesEfficient1974
//TODO paper Deterministic Techniques for Efficient Non-Deterministic Parsers DOI:10.1007/3-540-06841-4_65

= Related work
= Implementation

== What is tree sitter

Tree-sitter is a parser generator and query tool for incremental parsing. It
builds a determenistic parser for a given grammar that can parse a source file
into a syntax tree and update that syntax tree efficiently. It aims to be
general enough for any programming language, fast enough for text editors to act
uppon every keystroke, robust enough to recover from previus syntax errors and
dependency free, meaning that the resulting runtime libary can be embedded or
bundled with any application. @TreesitterIntroduction

It originated from Max Brunsfeld and was build at github with c and c++ and is
designed to be used in applications like atom, light text editors that need
plugins to become as usefull as an IDE. Its core functionality is to parse many
different programming languages into a coherent syntax trees that all have the
same interface. The incremental parsing is "super fast" and needs very little
memory, because it shares nodes with the previus version of the syntax tree.
This makes is possible to parse on every keystroke and run parsers in paralel.
Another important feature is the error recovery. Tree-sitter can, unlike other
common parsers that error out on parsing fails, find the start and end of a
wrong syntax snipped, by "inspecting" the code. @loopTreesitterNewParsing

All these features make it extremly usefull for parsing code that is constantly
modified and contains syntactical errors, like source code, written inside code
editors.

== How IDE's work
IDE's use syntax trees to deliver language smarts to the programmer. The problem
with IDE's is that they are focused on specific languages or platforms. They are
usualy slow due to not using incremental parsing. This means on every keystroke
the IDE is parsing the whole file. This can take 100 milli seconds or longer,
getting slower with larger files. This delay can be felt by programmers while
typing. @loopTreesitterNewParsing

== What is a language server
// https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html 4:05

//TODO Why Tree Sitter
=== Writing a grammar
=== Using the parser

== Relevent parts of the LSP specificationjge
=== TextDocumentSyncKind::INCREMENTAL
=== did_open
=== did_change
=== hover
=== inlay_hint

== Used data structures
=== Rope

== How, why and what i tested
//TODO why i tested

=== Query testes in tree sitter
=== Unit tests in rust
=== E2E tests using a LSP client

= Analysis
== Benchmarks
== Usability
//TODO who are the users
//TODO describe the usability
//TODO is the LSP fast enough

= Conclusion

#bibliography("lib.bib", style: "ieee")

/*
Notes:

Possible Features:
-  Auto completion with label
-  Goto definition of keywords inside the lsp directory

Warum hast du so etwas gebaut, was wären Alternativen gewesen und warum hast du sie nicht genutzt.

- Am Anfrang, Fragestellung: Kann man damit flüssig arbeiten
- Am Ende, Frage beantworten

*/
