Ces utilitaires pour effectuer des validations DTD + application XSLT ont été vibecodées, n'étant pas vraiment l'apanage de la modélisation métier proprement dite.

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