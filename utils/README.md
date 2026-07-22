Ces utilitaires pour effectuer des validations DTD + application XSLT ont été vibecodées, n'étant pas vraiment l'apanage de la modélisation métier proprement dite (c'est juste un aspect technique, pratico-pratique). Car l'idée est juste d'avoir des fonctions qui gère 1) "valider DTD" et 2) "appliquer XSLT". 

D'autres fonctions seront sans doute vibecodées pour réduire les dépendances (Levenstein, Simhash, etc.) pour compenser la friction haskellienne.

```
cabal update
cabal install --lib xml
cabal install --lib hxt hxt-xslt
```

> En chantier, nonobstant

```
runghc validator.hs ead.xml
runghc apply_xslt.hs test.xsl ead.xml resultat.xml
```