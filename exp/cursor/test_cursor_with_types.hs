{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.Lazy as LazyText
import Text.XML
  ( Name(..)
  , def
  , parseText_
  )
import Text.XML.Cursor
  ( Axis
  , Cursor
  , content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

eadNamespace :: Text
eadNamespace =
  "urn:isbn:1-931666-22-9"

xml :: LazyText.Text
xml =
  "<ead xmlns=\"urn:isbn:1-931666-22-9\">\
  \  <eadheader>\
  \    <eadid>FR-AD75-1234</eadid>\
  \    <titleproper>Archives de Jean Dupont</titleproper>\
  \  </eadheader>\
  \</ead>"

-- Modèle métier

data EADDocument =
  EADDocument
    { eadHeader :: EADHeader
    }
  deriving (Show)

data EADHeader =
  EADHeader
    { eadIdentifier :: Text
    , eadTitle :: Text
    }
  deriving (Show)

-- Fonctions de navigation XML

eadElement :: Text -> Axis
eadElement localName =
  element
    (Name localName (Just eadNamespace) Nothing)

first :: [a] -> Maybe a
first [] =
  Nothing

first (value : _) =
  Just value

requiredChildText :: Cursor -> Text -> Maybe Text
requiredChildText parent localName =
  first
    ( parent
        $/ eadElement localName
        &/ content
    )

-- Conversion XML vers modèle métier

parseEADHeader :: Cursor -> Maybe EADHeader
parseEADHeader headerCursor = do
  identifier <-
    requiredChildText headerCursor "eadid"

  title <-
    requiredChildText headerCursor "titleproper"

  pure
    EADHeader
      { eadIdentifier = identifier
      , eadTitle = title
      }

parseEADDocument :: Cursor -> Maybe EADDocument
parseEADDocument documentCursor = do
  headerCursor <-
    first
      (documentCursor $/ eadElement "eadheader")

  header <-
    parseEADHeader headerCursor

  pure
    EADDocument
      { eadHeader = header
      }

main :: IO ()
main = do
  let xmlDocument =
        parseText_ def xml

      documentCursor =
        fromDocument xmlDocument

  case parseEADDocument documentCursor of
    Nothing ->
      putStrLn
        "Le document ne respecte pas la structure EAD attendue"

    Just eadDocument ->
      print eadDocument