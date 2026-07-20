

newtype Structure = 
    Structure String
    deriving(Show)

newtype Html =
    Html String
    deriving(Show)

el :: String -> String -> String
el tag content = 
    "<" <> tag <> ">" <> content <> "</" <> tag <> ">"

h1 :: String -> Structure
h1 = Structure . el "h1"

p :: String -> Structure
p = Structure . el "p"

append_ :: Structure -> Structure -> Structure
append_ (Structure elementGo) (Structure here) =
    Structure (elementGo <> here)

structureToString :: Structure -> String
structureToString (Structure str) = str

render :: Html -> String
render (Html str) = str

main :: IO ()
main = do
    print "hello"