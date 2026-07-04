
main :: IO () =
  putStrLn (ead "hello")


el :: String -> String -> String
el tag content =
  "<" <> tag <> ">" <> content <> "</" <> tag <> ">"

ead :: String -> String
ead = el "ead"
