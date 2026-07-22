## LANGUAGE (le truc bizarre tout en haut du code)

Avec `OverloadedStrings`, la chaîne écrite entre guillemets peut prendre différents types selon le contexte, notamment String, Text ou LazyText.Text. GHC déduit le type attendu.

(comme quoi y a de l'inférence de type en haskell)

## import Text.XML.Cursor (...)

```
import Text.XML.Cursor
  ( Cursor
  , content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )
```

Le module Text.XML.Cursor contient les outils de navigation dans l’arbre XML. `Cursor` est le type représentant une position navigable dans l’arbre XML.

- `fromDocument` transforme un Document XML en Cursor (fromDocument :: Document -> Cursor).
- `Cursor` est une position permettant de parcourir cet arbre.
- `element` construit un filtre qui sélectionne les éléments XML portant un certain nom.
- `content` extrait le contenu textuel d’un nœud XML

## Text.XML.Cursor 

`import Text.XML (def, parseText_)` permet de transformer le texte XML en Document.

## Text strict et paresseux

Dans ce programme, deux types de texte sont utilisés :

- Text (qui vient de Data.Text)
- LT.Text (qui lui vient de Data.Text.Lazy)

On peut les distinguer ainsi :

```
title :: Text
title = "Haskell"
xml :: LT.Text
xml = "<title>Fonds Gérard Larcher</title>"
```

Le texte strict est souvent utilisé pour de petites valeurs, comme :

- un titre ;
- un nom d’élément ;
- un attribut ;
- un namespace.

Le texte paresseux peut être utilisé pour un document complet.

## Chaine de transformation

En gros :

```
LT.Text
   ↓ parseText_
Document
   ↓ fromDocument
Cursor
```