#import "template.typ": *

#show: project.with(
  title: "Design and development of an OWL 2 manchester syntax language server",
  authors: ((name: "Janek Winkler", email: "janek.winkler@st.ovgu.de"),),
  date: "December 6, 2023",
  topleft: [
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

// What is a langauge server

== The Research Objective

// How to design and implement an efficient language server for the owl language

== The Structure of the Thesis

// first explain what the work i am doing is and

= Related work

= Background

In this chapter i will explain programs libraries frameworks and techniques that
are important to this work. You can skip the parts that you know about. We start
with the ontology language this language server will support.

== What is Owl, Owl 2 and Owl 2 manchester syntax

w3.org defines the following way:

The OWL 2 Web Ontology Language, informally OWL 2, is an ontology language for
the Semantic Web with formally defined meaning. OWL 2 ontologies provide
classes, properties, individuals, and data values and are stored as Semantic Web
documents. OWL 2 ontologies can be used along with information written in RDF,
and OWL 2 ontologies themselves are primarily exchanged as RDF documents. The
OWL 2 Document Overview describes the overall state of OWL 2, and should be read
before other OWL 2 documents.

// TODO copied from https://www.w3.org/TR/2012/REC-owl2-syntax-20121211/

== How IDE's work

IDE's use syntax trees to deliver language smarts to the programmer. The problem
with IDE's is that they are focused on specific languages or platforms. They are
usually slow due to not using incremental parsing. This means on every keystroke
the IDE is parsing the whole file. This can take 100 milliseconds or longer,
getting slower with larger files. This delay can be felt by programmers while
typing. @loopTreesitterNewParsing

== What is a language server
// https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html 4:05

== What makes a parser a GLR parser
@langDeterministicTechniquesEfficient1974
//TODO paper Deterministic Techniques for Efficient Non-Deterministic Parsers DOI:10.1007/3-540-06841-4_65

== What is tree sitter

Tree-sitter is a parser generator and query tool for incremental parsing. It
builds a deterministic parser for a given grammar that can parse a source file
into a syntax tree and update that syntax tree efficiently. It aims to be
general enough for any programming language, fast enough for text editors to act
upon every keystroke, robust enough to recover from previus syntax errors and
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

= Implementation

This chapter will explain what was implemented and how it was done. I will also
show why I choose the tools that I did, what alternatives are and when to use
those.

- incremental parsing
- industry standart
- rust bindings

//TODO Why Tree Sitter

=== Writing the grammar

// i used the owl reference and replaced the complicated parts
// i wrote tests to check that the parsing is correct

=== Using the generated parser

== Relevent parts of the LSP specification
=== `TextDocumentSyncKind::INCREMENTAL`
=== `did_open`
=== `did_change`

How to remove iris and diagnostics that dont matter any more and how to only
check the relevant nodes after that

=== `hover`
=== `inlay_hint`
=== TODO diagnostics

== Used data structures
=== Rope

== Optimizations
=== Rust Async with Tokio
=== LS State vs. on promise tree query

== How, why and what i tested
//TODO why i tested

=== Query testes in tree sitter
=== Unit tests in rust
=== E2E tests using a LSP client

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
#heading(outlined: false, numbering: none)[Acknowledgments]

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
