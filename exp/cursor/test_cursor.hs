{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.Lazy as LazyText
import Text.XML
import Text.XML.Cursor

eadNamespace :: Text
eadNamespace =
  "urn:isbn:1-931666-22-9"

xml :: Text
xml =
  "<ead xmlns=\"urn:isbn:1-931666-22-9\">\
  \  <eadheader>\
  \    <eadid>FR-AD75-1234</eadid>\
  \    <titleproper>Archives de Jean Dupont</titleproper>\
  \  </eadheader>\
  \</ead>"

main :: IO ()
main = do
  let document =
        parseText_ def (LazyText.fromStrict xml)

      cursor =
        fromDocument document

      identifiers =
        cursor
          $/ element (Name "eadheader" (Just eadNamespace) Nothing)
          &/ element (Name "eadid" (Just eadNamespace) Nothing)
          &/ content

  print identifiers