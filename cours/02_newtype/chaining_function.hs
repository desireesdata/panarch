
newtype Structure = 
    Structure String
    deriving(Show)

getStringFromStructure :: Structure -> String
getStringFromStructure (Structure str) = str

el :: String -> String -> String
el tag content =
    "<" <> tag <> ">" <> content <> "</" <> tag <> ">"

p_ :: String -> Structure
p_ = Structure . el "p"

main :: IO ()
main = do
    putStrLn $ getStringFromStructure $ p_ "hello"