## 1. L’idée générale

Un `Cursor` est une **position dans un arbre XML**, accompagnée des informations nécessaires pour se déplacer dans cet arbre.

Imagine ce document :

```xml
<ead>
  <eadheader>
    <eadid>FR-AD75-1234</eadid>
    <titleproper>Archives de Jean Dupont</titleproper>
  </eadheader>
</ead>
```

On peut le représenter comme un arbre :

```text
ead
└── eadheader
    ├── eadid
    │   └── "FR-AD75-1234"
    └── titleproper
        └── "Archives de Jean Dupont"
```

Un curseur peut être positionné sur n’importe lequel de ces nœuds :

```text
ead
└── eadheader       ← curseur ici
    ├── eadid
    └── titleproper
```

À partir de cette position, on peut demander :

* quels sont mes enfants ?
* quel est mon parent ?
* quels sont mes frères et sœurs ?
* quels descendants correspondent à un certain nom ?
* quel texte contient ce nœud ?

`Text.XML.Cursor` fournit ainsi un parcours bidirectionnel du DOM, avec une syntaxe inspirée de XPath. ([hackage.haskell.org][1])

---

# 2. Du texte XML au `Cursor`

Dans ton programme, il y a trois représentations successives :

```haskell
xml :: LazyText.Text
```

C’est seulement du texte :

```text
"<ead>...</ead>"
```

Ensuite :

```haskell
document :: Document
document =
  parseText_ def xml
```

`parseText_` analyse le texte et construit un arbre XML en mémoire, appelé DOM :

```text
texte XML
    ↓ parseText_
Document
```

Enfin :

```haskell
cursor :: Cursor
cursor =
  fromDocument document
```

`fromDocument` place un curseur au sommet du document :

```text
Document
    ↓ fromDocument
Cursor
```

Le curseur initial se trouve sur un nœud représentant le document entier, légèrement au-dessus de l’élément racine `<ead>`.

Conceptuellement :

```text
Document                   ← curseur initial
└── ead
    └── eadheader
        ├── eadid
        └── titleproper
```

C’est important pour comprendre pourquoi la première navigation peut parfois devoir sélectionner `<ead>` et parfois directement ses enfants, selon le comportement de l’axe employé et la structure examinée.

---

# 3. Un `Cursor` n’est pas seulement un élément XML

Un curseur peut pointer vers différents types de nœuds :

* un élément ;
* du texte ;
* un commentaire ;
* une instruction de traitement ;
* le nœud racine du document.

Par exemple :

```xml
<eadid>FR-AD75-1234</eadid>
```

contient au moins deux nœuds conceptuels :

```text
Element : eadid
└── Text : "FR-AD75-1234"
```

Quand le curseur est sur `eadid`, il pointe sur l’élément :

```text
eadid                 ← Cursor
└── "FR-AD75-1234"
```

Quand on applique `content`, on extrait le texte contenu dans ce nœud.

---

# 4. La notion d’`Axis`

Dans `Text.XML.Cursor`, une opération de navigation est appelée un **axe**.

Son type est essentiellement :

```haskell
type Axis = Cursor -> [Cursor]
```

Autrement dit, un axe :

1. reçoit un curseur ;
2. cherche des nœuds à partir de cette position ;
3. renvoie zéro, un ou plusieurs curseurs.

Par exemple, un axe qui sélectionne les enfants pourrait recevoir :

```text
eadheader
```

et renvoyer :

```text
[eadid, titleproper]
```

Le résultat est une liste parce qu’une recherche XML peut trouver plusieurs nœuds.

Cela explique pourquoi cette expression :

```haskell
cursor $/ element name
```

produit une liste de curseurs :

```haskell
[Cursor]
```

et non un seul `Cursor`.

---

# 5. `element` est un filtre

Prenons :

```haskell
element
  (Name "eadheader" (Just eadNamespace) Nothing)
```

Cette expression construit un axe qui conserve les éléments ayant ce nom.

Le type simplifié est :

```haskell
element :: Name -> Axis
```

Puisque :

```haskell
type Axis = Cursor -> [Cursor]
```

on peut lire ce type comme :

```haskell
element :: Name -> Cursor -> [Cursor]
```

Il faut donc fournir :

1. le nom recherché ;
2. un curseur à partir duquel effectuer la sélection.

Les opérateurs comme `$/` se chargent de transmettre le curseur.

---

# 6. Le type `Name`

Un nom XML n’est pas seulement une chaîne de caractères.

Voici sa structure :

```haskell
Name
  { nameLocalName :: Text
  , nameNamespace :: Maybe Text
  , namePrefix :: Maybe Text
  }
```

Pour :

```xml
<eadheader xmlns="urn:isbn:1-931666-22-9">
```

le nom est approximativement :

```haskell
Name
  { nameLocalName = "eadheader"
  , nameNamespace = Just "urn:isbn:1-931666-22-9"
  , namePrefix = Nothing
  }
```

Le nom local est :

```text
eadheader
```

Le namespace est :

```text
urn:isbn:1-931666-22-9
```

Il est donc pratique d’écrire :

```haskell
eadElement :: Text -> Axis
eadElement localName =
  element
    (Name localName (Just eadNamespace) Nothing)
```

Puis :

```haskell
eadElement "eadheader"
```

représente l’axe :

> Sélectionner un élément appelé `eadheader` appartenant au namespace EAD.

---

# 7. Comprendre `$/`

L’opérateur `$/` applique un axe aux **enfants directs** d’un curseur.

Son utilisation ressemble à :

```haskell
cursor $/ axe
```

On peut le lire ainsi :

> Depuis ce curseur, descends d’un niveau, puis applique cet axe.

Prenons l’arbre :

```text
ead
└── eadheader
    ├── eadid
    └── titleproper
```

Supposons que le curseur soit sur `ead` :

```text
ead                 ← curseur
└── eadheader
```

Cette expression :

```haskell
cursor $/ eadElement "eadheader"
```

renvoie :

```text
[eadheader]
```

Mais :

```haskell
cursor $/ eadElement "eadid"
```

renvoie :

```text
[]
```

Pourquoi ? Parce que `eadid` n’est pas un enfant direct de `ead`. C’est un petit-enfant :

```text
ead
└── eadheader
    └── eadid
```

Il faut donc deux étapes :

```haskell
cursor
  $/ eadElement "eadheader"
  &/ eadElement "eadid"
```

---

# 8. Comprendre `&/`

Après une première sélection, nous possédons généralement une liste :

```haskell
[Cursor]
```

Par exemple :

```haskell
cursor $/ eadElement "eadheader"
```

donne potentiellement :

```haskell
[header1, header2]
```

L’opérateur `&/` poursuit la navigation depuis **chaque curseur de cette liste**.

```haskell
headers &/ eadElement "eadid"
```

signifie :

> Pour chaque en-tête trouvé, cherche ses enfants `eadid`, puis rassemble tous les résultats.

Prenons deux en-têtes fictifs :

```text
header1
└── eadid "A"

header2
└── eadid "B"
```

L’expression :

```haskell
[header1, header2] &/ eadElement "eadid"
```

donnera :

```haskell
[eadidA, eadidB]
```

`&/` effectue donc une sorte de combinaison :

```haskell
concatMap
```

Une intuition approximative serait :

```haskell
cursors &/ axis =
  concatMap axisSurLesEnfants cursors
```

Ce n’est pas sa définition exacte, mais c’est une bonne représentation mentale.

---

# 9. Pourquoi utiliser `$/` puis `&/` ?

Dans ton expression :

```haskell
cursor
  $/ eadElement "eadheader"
  &/ eadElement "eadid"
  &/ content
```

les types évoluent ainsi.

Au départ :

```haskell
cursor :: Cursor
```

Après :

```haskell
cursor $/ eadElement "eadheader"
```

nous obtenons :

```haskell
[Cursor]
```

Comme nous avons maintenant une liste, nous utilisons `&/` :

```haskell
cursor
  $/ eadElement "eadheader"
  &/ eadElement "eadid"
```

Le résultat reste :

```haskell
[Cursor]
```

Enfin :

```haskell
&/ content
```

extrait le texte et produit :

```haskell
[Text]
```

On peut visualiser la transformation :

```text
Cursor
  ↓ $/ eadElement "eadheader"
[Cursor]
  ↓ &/ eadElement "eadid"
[Cursor]
  ↓ &/ content
[Text]
```

---

# 10. Attention : `content` est un axe particulier

`content` ne renvoie pas des curseurs. Il renvoie du texte.

Son type est conceptuellement :

```haskell
content :: Cursor -> [Text]
```

Ce type ressemble à un `Axis`, mais le résultat n’est pas `[Cursor]`.

C’est pour cela que `&/` est plus général qu’un simple opérateur réservé aux curseurs. Il permet d’appliquer une fonction aux nœuds sélectionnés et d’aplatir les résultats.

Avec :

```xml
<eadid>FR-AD75-1234</eadid>
```

si le curseur pointe sur `<eadid>`, alors :

```haskell
content eadIdCursor
```

renvoie :

```haskell
["FR-AD75-1234"]
```

---

# 11. Lecture complète de ton expression

Voici ton expression :

```haskell
identifiers =
  cursor
    $/ element (Name "eadheader" (Just eadNamespace) Nothing)
    &/ element (Name "eadid" (Just eadNamespace) Nothing)
    &/ content
```

Lis-la de gauche à droite.

### Départ

```haskell
cursor
```

Nous sommes sur le curseur du document.

### Première étape

```haskell
$/ element (Name "eadheader" ...)
```

Cherche parmi les enfants pertinents du curseur les éléments `eadheader`.

Résultat :

```haskell
[Cursor]
```

Chaque curseur de cette liste pointe sur un `<eadheader>`.

### Deuxième étape

```haskell
&/ element (Name "eadid" ...)
```

Pour chaque `<eadheader>`, cherche ses enfants `<eadid>`.

Résultat :

```haskell
[Cursor]
```

Chaque curseur pointe maintenant sur un `<eadid>`.

### Troisième étape

```haskell
&/ content
```

Pour chaque `<eadid>`, récupère son contenu textuel.

Résultat :

```haskell
[Text]
```

Donc :

```haskell
identifiers :: [Text]
```

et la valeur obtenue est :

```haskell
["FR-AD75-1234"]
```

---

# 12. Pourquoi le résultat est-il une liste ?

Même si ton document ne contient qu’un seul `eadid`, la bibliothèque ne peut pas le supposer.

Ce XML est possible :

```xml
<eadheader>
  <eadid>A</eadid>
  <eadid>B</eadid>
</eadheader>
```

La même requête renverrait :

```haskell
["A", "B"]
```

Une sélection XML peut donc produire :

```haskell
[]          -- aucun résultat
[value]     -- un résultat
[a, b, c]   -- plusieurs résultats
```

C’est ensuite ton modèle métier qui décide si :

* zéro élément est autorisé ;
* exactement un élément est attendu ;
* plusieurs éléments sont autorisés.

Par exemple :

```haskell
requiredChildText :: Cursor -> Text -> Maybe Text
requiredChildText parent localName =
  first
    (parent $/ eadElement localName &/ content)
```

Cette fonction décide de conserver seulement le premier résultat.

---

# 13. Le lien entre `[Text]` et `Maybe Text`

La requête XML produit :

```haskell
[Text]
```

Mais ton modèle demande :

```haskell
eadIdentifier :: Text
```

Il faut donc décider quoi faire avec la liste.

Ta fonction :

```haskell
first :: [a] -> Maybe a
first [] =
  Nothing

first (value : _) =
  Just value
```

transforme :

```haskell
[]
```

en :

```haskell
Nothing
```

et :

```haskell
["FR-AD75-1234"]
```

en :

```haskell
Just "FR-AD75-1234"
```

La chaîne complète devient donc :

```text
Cursor
  ↓ requête
[Text]
  ↓ first
Maybe Text
  ↓ notation do
Text
  ↓ constructeur
EADHeader
```

---

# 14. Une limite de `first`

Avec :

```haskell
first (value : _) = Just value
```

ce résultat :

```haskell
["A", "B"]
```

devient simplement :

```haskell
Just "A"
```

La seconde valeur est silencieusement ignorée.

Or ton modèle pourrait exiger **exactement un** identifiant. Il est alors préférable d’écrire :

```haskell
exactlyOne :: [a] -> Maybe a
exactlyOne [value] =
  Just value

exactlyOne _ =
  Nothing
```

Ainsi :

```haskell
exactlyOne []
```

donne :

```haskell
Nothing
```

```haskell
exactlyOne ["A"]
```

donne :

```haskell
Just "A"
```

```haskell
exactlyOne ["A", "B"]
```

donne aussi :

```haskell
Nothing
```

La fonction métier devient :

```haskell
requiredChildText :: Cursor -> Text -> Maybe Text
requiredChildText parent localName =
  exactlyOne
    (parent $/ eadElement localName &/ content)
```

Cela exprime mieux la contrainte :

> Il doit exister exactement un enfant de ce nom contenant du texte.

---

# 15. Les principales directions de navigation

Le curseur est bidirectionnel : il ne sert pas uniquement à descendre. ([hackage.haskell.org][1])

Les axes courants permettent notamment de naviguer vers :

```haskell
child
```

les enfants directs ;

```haskell
descendant
```

tous les descendants ;

```haskell
parent
```

le parent ;

```haskell
ancestor
```

tous les ancêtres ;

```haskell
precedingSibling
followingSibling
```

les frères et sœurs situés avant ou après.

Considérons :

```text
ead
└── eadheader
    ├── eadid
    └── titleproper
```

Depuis `eadheader` :

```text
child
```

peut atteindre :

```text
eadid
titleproper
```

Depuis `eadid` :

```text
parent
```

peut atteindre :

```text
eadheader
```

Depuis `eadid` :

```text
followingSibling
```

peut atteindre :

```text
titleproper
```

Depuis `titleproper` :

```text
ancestor
```

peut atteindre notamment :

```text
eadheader
ead
```

Cette possibilité de revenir vers les parents est l’une des différences entre un simple nœud XML et un curseur.

---

# 16. Enfant direct ou descendant

Cette distinction correspond à peu près à celle entre `/` et `//` en XPath.

Avec cet arbre :

```text
ead
└── archdesc
    └── did
        └── unitid
```

Une recherche parmi les enfants directs de `ead` ne trouvera pas `unitid` :

```haskell
eadCursor $/ eadElement "unitid"
```

Résultat :

```haskell
[]
```

Parce que `unitid` se trouve plusieurs niveaux plus bas.

Pour chercher dans toute la profondeur de l’arbre, on utilise un axe de descendants, combiné à un filtre approprié.

L’intention est alors :

```text
Depuis ead
└── cherche à n’importe quelle profondeur
    └── un élément unitid
```

Il faut toutefois employer les recherches profondes avec prudence : elles peuvent trouver un élément portant le bon nom mais situé dans une partie inattendue du document.

Pour construire un modèle métier strict, les chemins par enfants directs sont souvent préférables :

```haskell
ead
  → archdesc
  → did
  → unitid
```

Ils vérifient indirectement la structure attendue.

---

# 17. Attributs et curseurs

Prenons :

```xml
<eadid countrycode="FR">FR-AD75-1234</eadid>
```

Le curseur est positionné sur l’élément `eadid`.

Pour récupérer son texte :

```haskell
eadIdCursor $/ content
```

ou selon la composition utilisée :

```haskell
[eadIdCursor] &/ content
```

Pour récupérer un attribut, on emploie un filtre comme `attribute` avec son `Name`.

Conceptuellement :

```haskell
attribute "countrycode" eadIdCursor
```

produit :

```haskell
["FR"]
```

Les attributs ne sont donc pas nécessairement manipulés comme des curseurs indépendants : ils sont généralement extraits depuis le curseur de l’élément qui les porte.

---

# 18. `Cursor` et modèle métier ont des rôles différents

Le `Cursor` appartient à la couche XML :

```haskell
Cursor
```

Il connaît :

* les éléments ;
* les namespaces ;
* les attributs ;
* les parents ;
* les enfants ;
* les nœuds textuels.

Le modèle métier appartient à ton application :

```haskell
data EADHeader =
  EADHeader
    { eadIdentifier :: EADIdentifier
    , eadTitle :: EADTitle
    }
```

Il connaît :

* un identifiant EAD ;
* un titre ;
* les règles que tu souhaites imposer.

Il ne devrait pas connaître :

* `Cursor` ;
* `Name` ;
* XPath ;
* les namespaces ;
* la manière dont le document était encodé.

La fonction de parsing constitue la frontière :

```haskell
parseEADHeader :: Cursor -> Maybe EADHeader
```

À gauche :

```text
monde XML
```

À droite :

```text
monde métier
```

---

# 19. Relire `parseEADHeader`

```haskell
parseEADHeader :: Cursor -> Maybe EADHeader
parseEADHeader headerCursor = do
  identifierText <-
    requiredChildText headerCursor "eadid"

  titleText <-
    requiredChildText headerCursor "titleproper"

  pure
    EADHeader
      { eadIdentifier = EADIdentifier identifierText
      , eadTitle = EADTitle titleText
      }
```

Le paramètre :

```haskell
headerCursor :: Cursor
```

doit être positionné sur :

```xml
<eadheader>
```

Puis :

```haskell
requiredChildText headerCursor "eadid"
```

fait cette navigation :

```text
eadheader          ← départ
└── eadid          ← sélection
    └── texte      ← extraction
```

Le résultat est :

```haskell
Maybe Text
```

La notation `do` retire le `Just` si la recherche réussit, ou interrompt la construction si elle échoue.

Enfin, le texte brut est enveloppé dans un type métier :

```haskell
EADIdentifier identifierText
```

---

# 20. Une analogie avec un explorateur de fichiers

On peut comparer un curseur XML à la position actuelle dans un terminal.

Avec :

```text
/
└── ead
    └── eadheader
        ├── eadid
        └── titleproper
```

Le curseur représente le répertoire courant :

```text
/ead/eadheader
```

Une navigation vers les enfants ressemble à :

```text
ls
```

Une sélection :

```haskell
eadElement "eadid"
```

ressemble à :

```text
chercher le fichier nommé eadid
```

L’opérateur `$/` ressemble à :

```text
descendre depuis la position actuelle
```

Le parent ressemble à :

```text
cd ..
```

La différence est que les opérations produisent généralement une **liste de nouvelles positions**, parce qu’une requête peut trouver plusieurs nœuds.

---

# 21. Résumé des types

Les types les plus importants sont :

```haskell
fromDocument :: Document -> Cursor
```

Transforme le document en point de départ navigable.

```haskell
type Axis = Cursor -> [Cursor]
```

Une opération de navigation produit zéro ou plusieurs positions.

```haskell
element :: Name -> Axis
```

Sélectionne les éléments correspondant à un nom XML.

```haskell
content :: Cursor -> [Text]
```

Extrait le contenu textuel depuis une position.

Et l’expression :

```haskell
cursor
  $/ eadElement "eadheader"
  &/ eadElement "eadid"
  &/ content
```

se lit :

```text
Depuis le curseur initial,
  sélectionne les enfants eadheader,
  puis pour chacun sélectionne ses enfants eadid,
  puis pour chacun récupère son texte.
```

Son type final est :

```haskell
[Text]
```

Le point essentiel est donc :

> Un `Cursor` n’est pas une requête XPath ni ton modèle métier. C’est une position navigable dans l’arbre XML. Les axes produisent de nouvelles positions, et les opérateurs permettent d’enchaîner ces déplacements.

[1]: https://hackage.haskell.org/package/xml-conduit?utm_source=chatgpt.com "xml-conduit: Pure-Haskell utilities for dealing with XML with the conduit package."
