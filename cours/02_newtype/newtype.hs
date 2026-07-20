newtype Ead = Ead String

newtype Structure = 
    Structure String
    deriving (Show)

getStructureString::Structure -> String
getStructureString struct =
    case struct of
        Structure str -> str

-- équivaut à :
getStructureString2::Structure -> String
getStructureString2 (Structure str) = str