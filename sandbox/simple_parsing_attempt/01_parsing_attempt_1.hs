{-# LANGUAGE OverloadedStrings #-}
-- Ici on montre juste comment fonction le type Cursor
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

main :: IO ()
main = do
    let findingAidCursor = fromDocument (parseText_ def xml)
    -- findingAidCursor représente l'arborescence de façon abstraite 
    -- ou plutot : une position navigable dans cet arbre : c'est CURSOR
    print findingAidCursor
