# Panarch

Panarch is a pandoc-inspired educational project designed for converting archival data.
blabla

## Converting Archival Data : the way of AST

Structured archival data can be found in various formats (CSV, XML/EAD, JSON, etc.) and will be converted into other formats (RiC, clean XML/EAD, etc.). One good way to achieve this is to create a semantic and intermediate representation (AST) to make it easier to apply transformations with domain constraints. 

Blabla why haskell is a good langague for THIS case (Schematron is an orthogonal validator : good but its adds a layer of complexity to the data pipeline). Here we would like to manipulate data structures from a semantic point of view, which is usefull for identifying problems. "Parse don't validate", arise errors properly (XSLT is bad for this, i think !) etc, etc.

Limitations : NLP features, friction.

