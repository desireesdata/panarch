
main :: IO () =
  putStrLn myEad

el :: String -> String -> String
el tag content =
  "<" <> tag <> ">" <> content <> "</" <> tag <> ">"

ead :: String -> String
ead = el "ead"

eadheader :: String -> String
eadheader = el "eadheader"

archdesc :: String -> String
archdesc = el "archdesc"

c :: String -> String
c = el "c"

makeEad :: String -> String -> String
makeEad headerContent archdescContent =
  ead (eadheader headerContent <> archdesc archdescContent)

myEad :: String =
  makeEad "titre du fonds"
  (c "contenu archivistique" <> c "autre contenu")
