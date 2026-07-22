# Panarch

Panarch is a pandoc-inspired educational project designed for converting archival data and cleaning dirty XML/EAD 2.0.
blabla

> in progress...

## References... 

> - https://learn-haskell.blog/
> - https://pandoc.org/
> - https://ica-egad.github.io/RiC-AG/ <-- usefull for thinking about the semantic AST
>   - https://www.ica.org/standards/RiC/RiC-O_1-1.html#FindingAid

## Converting Archival Data : the AST approach

Structured archival data can be found in various formats (CSV, XML/EAD, JSON, etc.) and will be converted into other formats (RiC, clean XML/EAD, etc.). One good way to achieve this is to create a semantic and intermediate representation (AST) to make it easier to apply transformations with domain constraints. 

Blabla why haskell is a good langague for THIS case (Schematron is an orthogonal validator : good but its adds a layer of complexity to the data pipeline). Here we would like to manipulate data structures from a semantic point of view, which is usefull for identifying problems. "Parse don't validate", arise errors properly (XSLT is bad for this, i think !) etc, etc.
Haskell because we want : binary, a functional approach, type safety and abstract syntax tree, etc.

Limitations : NLP features, friction.

### AST (RiC-based semantic model)

In progress... 

> https://www.ica.org/standards/RiC/RiC-O_1-1.html#documentaryFormTypes

```
data Record = Record
  { recordId    :: URI
  , recordTitle :: Text
  , recordForms :: [DocumentaryFormType] -- optionnel donc !
  }

data DocumentaryFormType
  = FindingAid
  | AuthorityRecord
  | IIIFManifest

findingAid :: Record
findingAid =
  Record
    { recordId = URI "https://francearchivesblabla.org/records/42"
    , recordTitle = "Inventaire du fonds Larcher"
    , recordForms = [FindingAid]
    }
```

## Cleaning Dirty EAD

Archival information software (SIA en français ?) can produce dirty XML/EAD : either because of limitations in the design; or because the descriptions are irregular (unittitle in scopecontent etc.)

## Features

> in progress... These are just ambitions, currently...

- XML/GAIA (french archival information system)
    - -> clean XML/EAD 2.0
    - -> JSON
    - -> CSV
    - -> Typst
    - -> LaTex
- dirty XML/EAD 2.0
    - -> clean XML/EAD 2.0
    - -> clean XML/EAD 4.0
    - -> CSV
    - -> JSON
    - -> Typst
    - -> LaTex
- XML/EAD 
    - -> RiC (we can hope...)
- SimplEAD model
    - -> Just a validator ??? for arise errors? 
    - -> XML/EAD 2
    - -> XML/EAD 4

> Note GAIA is becoming Advance Archive... I hope its XML will be close to real EAD  

### Structural normalization
Blabla ISAD G (no repetitions), chronological order, etc.

### Content normalization
Blabla ponctuation, date, lowcase, etc.

## Organization

- cours: experiments for understanding the Haskell basics (in French only)
- utils: utilities for applying XSLT and validating schemas
- sandbox: a folder where i'm just testing things
- exp : generated code and documentation, just for verify feasibility 

## Install

### Binaries
blabla
- Windows 11 and Ubuntu 24.04

### Compiling
blabla
Moins risqué mais plus technique !

### Dependances


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

## AI

The use of AI is here limited to :
- generating documentation (Haskell docs are mysterious)
- verify feasibility with "toy data"
- creating utilities (Levenstein, apply DTD validation...) to reduce friction with Haskell environments and dependancies.