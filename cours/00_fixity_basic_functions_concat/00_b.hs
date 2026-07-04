
main = putStrLn myEad

wrapEad archdesc_ =
  "<ead>" <> archdesc_ <> "</ead>"

eadheader content =
  "<eadheader>" <> content <> "</eadheader>"

archdesc content =
  "<archdesc>" <> content <> "</archdesc>"

makeEad headerContent archdescContent =
  wrapEad (eadheader headerContent <> archdesc archdescContent)

myEad = makeEad "titre" "contenu archivistique"
