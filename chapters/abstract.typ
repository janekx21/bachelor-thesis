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