# 1. Créer un curseur

Ce premier programme ne fait qu’analyser le XML et créer un `Cursor`.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor (Cursor, fromDocument)

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell simple</title>\
  \</book>"

main :: IO ()
main = do
  let document =
        parseText_ def xml

      cursor :: Cursor
      cursor =
        fromDocument document

  print cursor
```

La transformation est :

```text
texte XML
   ↓ parseText_
Document
   ↓ fromDocument
Cursor
```

`fromDocument` place le curseur sur l’élément racine du document. Ici, il pointe donc sur `<book>`. ([hackage-content.haskell.org][1])

Le résultat affiché est assez verbeux, parce que `Cursor` est une structure interne. Dans la pratique, on ne l’affiche presque jamais directement : on l’utilise pour naviguer.

---

# 2. Tester le nœud courant avec `$|`

L’opérateur `$|` applique un axe au **curseur courant lui-même**.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( element
  , fromDocument
  , ($|)
  )

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell simple</title>\
  \</book>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      result =
        cursor $| element "book"

  print (length result)
```

Résultat :

```text
1
```

Pourquoi ?

Le curseur pointe déjà sur `<book>` :

```text
book  ← curseur
└── title
```

L’expression :

```haskell
cursor $| element "book"
```

signifie :

> Vérifie si le nœud courant est un élément nommé `book`.

Le résultat est une liste :

```haskell
[Cursor]
```

Ici, la liste contient le curseur courant.

En revanche :

```haskell
cursor $| element "title"
```

renverrait :

```haskell
[]
```

car le nœud courant est `book`, pas `title`.

---

# 3. Sélectionner un enfant avec `$/`

`$/` applique un axe aux **enfants directs** du curseur.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( element
  , fromDocument
  , ($/)
  )

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell simple</title>\
  \  <author>Alice</author>\
  \</book>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      titles =
        cursor $/ element "title"

      authors =
        cursor $/ element "author"

  print (length titles)
  print (length authors)
```

Résultat :

```text
1
1
```

L’arbre est :

```text
book  ← curseur
├── title
└── author
```

Donc :

```haskell
cursor $/ element "title"
```

signifie :

> Parmi les enfants directs de `book`, sélectionne ceux qui s’appellent `title`.

Le résultat est toujours une liste, car il pourrait y avoir plusieurs éléments :

```xml
<book>
  <author>Alice</author>
  <author>Bob</author>
</book>
```

Dans ce cas :

```haskell
cursor $/ element "author"
```

renverrait deux curseurs.

---

# 4. Extraire le texte avec `content`

`content` extrait les nœuds textuels directs d’un élément.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell simple</title>\
  \</book>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      titleTexts =
        cursor
          $/ element "title"
          &/ content

  print titleTexts
```

Résultat :

```text
["Haskell simple"]
```

Lis l’expression de gauche à droite :

```haskell
cursor
  $/ element "title"
  &/ content
```

Première étape :

```haskell
cursor $/ element "title"
```

produit :

```haskell
[Cursor]
```

Chaque curseur pointe vers un `<title>`.

Deuxième étape :

```haskell
&/ content
```

applique `content` à chacun des curseurs trouvés.

Le type final est :

```haskell
[Text]
```

Schématiquement :

```text
Cursor
  ↓ $/ element "title"
[Cursor]
  ↓ &/ content
[Text]
```

---

# 5. Comprendre `&/`

`&/` travaille sur une **liste de curseurs**.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

xml :: LT.Text
xml =
  "<library>\
  \  <book><title>Livre A</title></book>\
  \  <book><title>Livre B</title></book>\
  \</library>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      books =
        cursor $/ element "book"

      titles =
        books
          &/ element "title"
          &/ content

  print titles
```

Résultat :

```text
["Livre A","Livre B"]
```

Après :

```haskell
books =
  cursor $/ element "book"
```

on a conceptuellement :

```haskell
[bookCursorA, bookCursorB]
```

Puis :

```haskell
books &/ element "title"
```

signifie :

> Pour chaque livre, cherche ses enfants `title`, puis rassemble tous les résultats.

C’est proche de :

```haskell
concatMap
```

On peut imaginer :

```haskell
concatMap chercherTitre books
```

Le parcours est :

```text
library
├── book
│   └── title → "Livre A"
└── book
    └── title → "Livre B"
```

---

# 6. Enfant direct contre descendant

`$/` ne descend que d’un niveau.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( content
  , element
  , fromDocument
  , ($/)
  , ($//)
  , (&/)
  )

xml :: LT.Text
xml =
  "<library>\
  \  <section>\
  \    <book>\
  \      <title>Livre profond</title>\
  \    </book>\
  \  </section>\
  \</library>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      directTitles =
        cursor
          $/ element "title"
          &/ content

      descendantTitles =
        cursor
          $// element "title"
          &/ content

  print directTitles
  print descendantTitles
```

Résultat :

```text
[]
["Livre profond"]
```

`title` n’est pas un enfant direct de `library` :

```text
library
└── section
    └── book
        └── title
```

Donc :

```haskell
cursor $/ element "title"
```

ne trouve rien.

En revanche :

```haskell
cursor $// element "title"
```

cherche parmi tous les descendants.

On peut rapprocher les deux formes de XPath :

```text
$/   ≈ /
$//  ≈ //
```

Ce n’est qu’une analogie, mais elle aide à retenir les opérateurs.

---

# 7. Récupérer un attribut

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( attribute
  , element
  , fromDocument
  , ($/)
  , (&|)
  )

xml :: LT.Text
xml =
  "<library>\
  \  <book id=\"b42\">\
  \    <title>Haskell</title>\
  \  </book>\
  \</library>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      bookIds =
        cursor
          $/ element "book"
          &| attribute "id"

  print bookIds
```

Résultat :

```text
["b42"]
```

Ici, `&|` applique la fonction au **nœud courant de chaque résultat**, sans redescendre vers ses enfants.

Après :

```haskell
cursor $/ element "book"
```

le curseur est déjà positionné sur `<book>`.

On veut donc lire l’attribut de ce même nœud :

```haskell
&| attribute "id"
```

Différence pratique :

```haskell
&|  -- applique au nœud courant
&/  -- applique aux enfants
&// -- applique aux descendants
```

Dans `Text.XML.Cursor`, les attributs ne sont pas eux-mêmes traités comme des nœuds `Cursor`; `attribute` extrait directement leur valeur textuelle. ([hackage-content.haskell.org][1])

---

# 8. Revenir au parent

Un curseur connaît son parent.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( element
  , fromDocument
  , parent
  , ($/)
  , (&|)
  )

xml :: LT.Text
xml =
  "<library>\
  \  <book>\
  \    <title>Haskell</title>\
  \  </book>\
  \</library>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      titles =
        cursor
          $/ element "book"
          &/ element "title"

      titleParents =
        titles &| parent

      bookParents =
        titleParents &| parent

  print (length titles)
  print (length titleParents)
  print (length bookParents)
```

Résultat :

```text
1
1
1
```

Les positions successives sont :

```text
title
  ↑ parent
book
  ↑ parent
library
```

C’est une propriété importante du curseur : contrairement à un simple `Node`, il conserve les informations de localisation nécessaires pour remonter dans l’arbre. La documentation décrit cette structure comme un *zipper*. ([hackage-content.haskell.org][1])

---

# 9. Plusieurs résultats

Cet exemple montre pourquoi les sélections renvoient des listes.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

xml :: LT.Text
xml =
  "<book>\
  \  <author>Alice</author>\
  \  <author>Bob</author>\
  \  <author>Charlie</author>\
  \</book>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      authors =
        cursor
          $/ element "author"
          &/ content

  print authors
```

Résultat :

```text
["Alice","Bob","Charlie"]
```

Le type est :

```haskell
authors :: [Text]
```

Une requête peut naturellement produire :

```haskell
[]          -- aucun résultat
["Alice"]   -- un résultat
["Alice", "Bob"] -- plusieurs résultats
```

La bibliothèque ne décide pas si tu en attends exactement un. C’est ton programme qui doit imposer cette règle.

---

# 10. Transformer `[Text]` en `Maybe Text`

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

first :: [a] -> Maybe a
first [] =
  Nothing

first (value : _) =
  Just value

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell</title>\
  \</book>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      titleTexts :: [Text]
      titleTexts =
        cursor
          $/ element "title"
          &/ content

      maybeTitle :: Maybe Text
      maybeTitle =
        first titleTexts

  print titleTexts
  print maybeTitle
```

Résultat :

```text
["Haskell"]
Just "Haskell"
```

La fonction :

```haskell
first :: [a] -> Maybe a
```

exprime :

* une liste vide devient `Nothing` ;
* une liste non vide donne son premier élément.

Cependant, elle ignore silencieusement les résultats supplémentaires.

---

# 11. Exiger exactement un résultat

Cette version est plus stricte.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

exactlyOne :: [a] -> Maybe a
exactlyOne [value] =
  Just value

exactlyOne _ =
  Nothing

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell</title>\
  \</book>"

main :: IO ()
main = do
  let cursor =
        fromDocument (parseText_ def xml)

      titleTexts :: [Text]
      titleTexts =
        cursor
          $/ element "title"
          &/ content

      title =
        exactlyOne titleTexts

  print title
```

Résultat :

```text
Just "Haskell"
```

Les trois cas sont :

```haskell
exactlyOne []
-- Nothing

exactlyOne ["A"]
-- Just "A"

exactlyOne ["A", "B"]
-- Nothing
```

Cette fonction signifie :

> Je considère la recherche valide uniquement si elle produit exactement une valeur.

---

# 12. Construire une petite valeur typée

Ce dernier exemple combine le curseur avec un modèle Haskell minimal.

```haskell
{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( Cursor
  , content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

data Book =
  Book
    { bookTitle :: Text
    , bookAuthor :: Text
    }
  deriving (Show)

exactlyOne :: [a] -> Maybe a
exactlyOne [value] =
  Just value

exactlyOne _ =
  Nothing

requiredText :: Cursor -> Text -> Maybe Text
requiredText parent elementName =
  exactlyOne
    ( parent
        $/ element elementName
        &/ content
    )

parseBook :: Cursor -> Maybe Book
parseBook bookCursor = do
  title <-
    requiredText bookCursor "title"

  author <-
    requiredText bookCursor "author"

  pure
    Book
      { bookTitle = title
      , bookAuthor = author
      }

xml :: LT.Text
xml =
  "<book>\
  \  <title>Apprendre Haskell</title>\
  \  <author>Alice</author>\
  \</book>"

main :: IO ()
main = do
  let bookCursor =
        fromDocument (parseText_ def xml)

  print (parseBook bookCursor)
```

Résultat :

```text
Just (Book {bookTitle = "Apprendre Haskell", bookAuthor = "Alice"})
```

La fonction principale est :

```haskell
parseBook :: Cursor -> Maybe Book
```

Elle transforme :

```text
curseur XML
    ↓
Maybe Book
```

Le `Cursor` sert seulement à naviguer et extraire les textes.

Le type `Book` représente ensuite les données de ton programme :

```haskell
data Book =
  Book
    { bookTitle :: Text
    , bookAuthor :: Text
    }
```

---

## Tableau mental des opérateurs

| Expression         | Point d’application               |                            |
| ------------------ | --------------------------------- | -------------------------- |
| `cursor $          | axis`                             | le curseur lui-même        |
| `cursor $/ axis`   | ses enfants directs               |                            |
| `cursor $// axis`  | ses descendants                   |                            |
| `cursors &         | axis`                             | chaque curseur de la liste |
| `cursors &/ axis`  | les enfants de chaque curseur     |                            |
| `cursors &// axis` | les descendants de chaque curseur |                            |

L’expression la plus courante est :

```haskell
cursor
  $/ element "book"
  &/ element "title"
  &/ content
```

Elle se lit :

> Depuis le curseur initial, sélectionne les enfants `book`, puis leurs enfants `title`, puis leur contenu textuel.

[1]: https://hackage-content.haskell.org/package/xml-conduit-1.10.1.0/docs/src/Text.XML.Cursor.html?utm_source=chatgpt.com "Untitled"
