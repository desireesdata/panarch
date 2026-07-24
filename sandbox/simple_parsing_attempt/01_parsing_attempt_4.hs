{-# LANGUAGE OverloadedStrings #-}
-- L'idée ici est de montrer qu'on peut faire un moteur de rendu XML -> parsing typé -> rendu XML ou autre
-- puissant avec un mini DSL, à faire ultérieurement
-- ET AVEC un vrai fichier XML sans namespace
module Main where

import Data.Text (Text)
import qualified Data.Text.IO as TIO
import qualified Data.Text.Lazy as LT
import qualified Text.XML as XML
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( Cursor
  , content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

data FindingAid = FindingAid 
    {
        findingAidTitle :: Text,
        findingAidAuthor :: Text
    }
    deriving Show


-- bon on suppose que tout va bien dans le meilleur des mondes
parsingFindingAid :: Cursor -> FindingAid 
parsingFindingAid cursor = 
    FindingAid title author
    where 
        title = 
            head (cursor $/ element "titleproper" &/ content)
        author =
            head (cursor $/ element "author" &/ content)

-- évidemment, c'est du xml jouet...
renderEad4 :: FindingAid -> Text
renderEad4 ir =
    "<ead4>\n"
    <> "<titreEad4>" <> findingAidTitle ir <> "</titreEad4>" <> "\n"
    <> "<auteurEad4>" <> findingAidAuthor ir <> "</auteurEad4>" <> "\n"
    <> "</ead4>"

main :: IO ()
main = do
    xml <- XML.readFile XML.def "01_parsing_attempt_4_input.xml"
    let findingAidCursor = fromDocument xml
    let findingAid = parsingFindingAid findingAidCursor
    TIO.writeFile
        "01_parsing_attempt_4_output.xml"
        (renderEad4 findingAid)
