{-# LANGUAGE OverloadedStrings #-}
-- L'idée ici est de montrer qu'on peut non seulement lire les valeurs du XML mais les "mouler" dans une représentation typée intermédiaire (AST)
module Main where

import Data.Text (Text)
import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor
  ( Cursor
  , content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

-- On simule l'entrée XML avec du Lazy Text
xml :: LT.Text
xml =
  "<ead>\
  \  <titleproper>Inventaire du Fonds Ducoeur</titleproper>\
  \  <author>Verlaine</author>\
  \</ead>"

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

main :: IO ()
main = do
    let findingAidCursor = fromDocument (parseText_ def xml)
    print (parsingFindingAid findingAidCursor)
