// #import "template.typ": *
#import "@preview/cetz:0.2.2": canvas, draw, tree
#import "../template/template.typ": todo, section, parcio-table, j-table

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
crate and a plugin example for Visual Studio Code. The third big chapter is
about testing the created program by running grammar tests, unit tests,
end-to-end tests and benchmarks. Then analyzing and evaluating the results in
the categories of speed, correctness and usability.

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

// TODO What it OWL 1

#quote(
  block: true, attribution: [w3.org #cite(<OWLWebOntologya>, supplement: [abstract])],
)[The OWL 2 Web Ontology Language, informally OWL 2, is an ontology language for
  the Semantic Web with formally defined meaning. OWL 2 ontologies provide
  classes, properties, individuals, and data values and are stored as Semantic Web
  documents. OWL 2 ontologies can be used along with information written in RDF,
  and OWL 2 ontologies themselves are primarily exchanged as RDF documents.]

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

== How IDE's work

IDE's use syntax trees to deliver language smarts to the programmer. The problem
with IDE's is that they are focused on specific languages or platforms. They are
usually slow due to not using incremental parsing. This means on every keystroke
the IDE is parsing the whole file. This can take 100 milliseconds or longer,
getting slower with larger files. This delay can be felt by programmers while
typing. @loopTreesitterNewParsing

== What is a language server
// https://www.thestrangeloop.com/2018/tree-sitter---a-new-parsing-system-for-programming-tools.html 4:05

#lorem(100)

== What is tree sitter

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

== What makes a parser a GLR parser

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

= Implementation

This chapter will explain what was implemented and how it was done. I will also
show why I choose the tools that I did, what alternatives exist and when to use
those.

== Parsing

A language server needs a good parser and when there is no incremental error
recovering parser it needs to be build. The parser generator chosen for this
language server is tree sitter.

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
guaranteed an efficient implementation. In hindsight, it was a good choice and I
recommend rust for writing language servers.

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

=== Writing the grammar

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
The transformations where done using the following table for reference. Each
construct has a rule in the original reference and in the new tree sitter
grammar.

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

I also, in a second step, transformed typical BNF constructs into more readable
tree sitter rules. These include

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
non-terminals.// TODO write more

// TODO i wrote tests to check that the parsing is correct

I wrote tests to see if my grammar and the resulting parser would produce the
correct syntax tree for the given source code. This is done with tree sitters
CLI. More about tree sitter query testing in @query-tests.

I did have to change the grammar while developing. This was of course
time-consuming, as I had to adapt all queries for the language server.
Unfortunately, there is no type checking or other tool support. Everything is
based on magic strings.

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
bindings are for node and rust. The latter defines a crate which the language
server imports as a submodule and uses as a local dependency.

== Getting started with the LSP specification and its Rust implementation

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
server and client are ready to start working. The handshake is complete.

A communication ends preferably with a shutdown request from the client. After
an empty response from the server, the client sends a final exit notification
and this concludes the communication.

// TODO maybe dynamic client capabilities, set trace, log trace

The good thing is that we can leave out all these technical details when
building a language server, because packages provide these functions. In the
case of this server, the used rust crate is called "tower-lsp".

// TODO ref tower-lsp

The next big point is synchronizing our document. The following chapters will
deal with this, followed by documentation, diagnostics, hints and
auto-completion.

== Text Document Synchronization

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

=== `textDocument/didOpen` Notification

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
=== `textDocument/didClose` Notification <did_close>

This notification is sent from the client to the server when a text document got
closed on the client.

```rust
// inside impl LanguageServer
async fn did_close(&self, params: DidCloseTextDocumentParams) {
    self.document_map.remove(&params.text_document.uri);
}
```

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
// TODO <------------------------------ hier weiter arbeiten

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

#figure(
  image("assets/screenshot_vscode_just_opened.svg", width: 80%), caption: [
    Visual Studio Code (editor-container) with the owl-ms plugin after opening the
    pizza ontology
  ],
)

== `hover`

#figure(
  image("assets/screenshot_vscode_hover.svg", width: 80%), caption: [
  Visual Studio Code (editor-container) with the owl-ms plugin after hovering the `pizza:NamedPizza`
  IRI
  ],
)

#lorem(100)

== `diagnostics`

#figure(
  image("assets/screenshot_vscode_diagnostics_1.svg", width: 80%), caption: [
    TODO
  ],
)

#figure(
  image("assets/screenshot_vscode_diagnostics_2.svg", width: 80%), caption: [
    TODO
  ],
)

// TODO diagnostics with multiple errors

#lorem(100)
#todo(inline: true)[staticly generated]

== `inlay_hint`
#lorem(100)

#todo(inline: true)[screenshot]

== `completions`
#lorem(100)

// TODO how the node kinds are converted into completion items
// TODO how the parent node is queried and used with static nodes

#figure(
  image("assets/screenshot_vscode_completion_iri.svg", width: 80%), caption: [
    TODO
  ],
)

#figure(
  image("assets/screenshot_vscode_completion_keyword.svg", width: 80%), caption: [
    TODO
  ],
)

== Used data structures
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

=== DashMap
#lorem(100)

== Optimizations
#lorem(100)

=== Rust Async with Tokio
#lorem(100)

=== LS State vs. on promise tree query

= Analysis
#lorem(50)

== Automated Testing

#todo(inline: true)[why i tested]
//TODO why i tested
#lorem(100)

=== Query tests in tree sitter <query-tests>
#lorem(100)

=== Unit tests in rust
#lorem(100)

=== E2E tests using a LSP client
#lorem(100)

// TOOD using vscode?

== Benchmarks
#lorem(100)

=== Experimental Setup
#lorem(100)

=== Results
#lorem(100)

== Evaluation of the usability

=== Experimental Setup
#lorem(100)

=== Results
#lorem(100)
//TODO who are the users
//TODO describe the usability
//TODO is the LSP fast enough

= Conclusion

// TODO
- It was hard to track each syntax thing like keywords and rules.
- Changing the grammar has a large impact.

#lorem(100)

== Performance
#lorem(100)

== Future Work
#lorem(100)

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
