# Panarch

Panarch is a pandoc-inspired educational project designed for converting archival data and cleaning dirty XML/EAD 2.0.
blabla

> in progress...

## Converting Archival Data : the AST approach

Structured archival data can be found in various formats (CSV, XML/EAD, JSON, etc.) and will be converted into other formats (RiC, clean XML/EAD, etc.). One good way to achieve this is to create a semantic and intermediate representation (AST) to make it easier to apply transformations with domain constraints. 

Blabla why haskell is a good langague for THIS case (Schematron is an orthogonal validator : good but its adds a layer of complexity to the data pipeline). Here we would like to manipulate data structures from a semantic point of view, which is usefull for identifying problems. "Parse don't validate", arise errors properly (XSLT is bad for this, i think !) etc, etc.

Limitations : NLP features, friction.

## Features

> in progress... These are just ambitions, currently...

- XML/GAIA (french archival information system)
    -- -> clean XML/EAD 2.0
    -- -> JSON
    -- -> CSV
- dirty XML/EAD 2.0
    -- -> clean XML/EAD 2.0
    -- -> clean XML/EAD 4.0
    -- -> CSV
    -- -> JSON
- XML/EAD 
    -- -> RiC (we can hope...)

> Note GAIA is becoming Advance Archive... I hope its XML will be close to real EAD  

### Structural normalization
Blabla ISAD G

### Content normalization
Blabla ponctuation, lowcase, etc.

## Organization

- cours: experiments for understanding the Haskell basics (in French only)
- utils: utilities for applying XSLT and validating schemas
- sandbox: a folder where i'm just testing things


## Install

### Binaries
blabla
- Windows 11 and Ubuntu 24.04

### Compiling
blabla
Moins risqué mais plus technique !

#### Dependances

```
cabal update
cabal install --lib xml-conduit
cabal install --lib xml
cabal install --lib hxt hxt-xslt
```

## Using Panarch

```
some command... in progress (:
```