
main = putStrLn (wrapEad "hello !")

wrapEad content =
  "<ead>" <> content <> "</ead>"
