
main = putStrLn myEad

wrapEad content =
  "<ead>" <> content <> "</ead>"

myEad = wrapEad "hello !"
