module Main where

import Data.Char (isSpace)
import Data.List (intercalate)
import Text.XML.Light
  ( CData(..)
  , Content(..)
  , Element
  , QName(..)
  , elContent
  , findChild
  , parseXMLDoc
  )

eadNamespace :: String
eadNamespace = "urn:isbn:1-931666-22-9"

xml :: String
xml =
  "<ead xmlns=\"urn:isbn:1-931666-22-9\">\
  \  <eadheader>\
  \    <eadid>FR-AD75-1234</ead:eadid>\
  \    <titleproper>Archives de Jean Dupont</ead:titleproper>\
  \  <eadheader>\
  \</ead>"

qualifiedName :: String -> String -> QName
qualifiedName namespace localName =
  QName
    { qName = localName
    , qURI = Just namespace
    , qPrefix = Nothing
    }

optionalChildNS :: Element -> String -> String -> Maybe Element
optionalChildNS parent namespace localName =
  findChild (qualifiedName namespace localName) parent

innerText :: Element -> String
innerText =
  intercalate " " . filter (not . null) . textNodes
  where
    textNodes :: Element -> [String]
    textNodes element =
      concatMap contentText (elContent element)

    contentText :: Content -> [String]
    contentText (Text cdata) =
      let value = trim (cdData cdata)
       in [value | not (null value)]

    contentText (Elem child) =
      textNodes child

    contentText _ =
      []

    trim :: String -> String
    trim =
      reverse . dropWhile isSpace . reverse . dropWhile isSpace

content :: Maybe Element -> String
content Nothing =
  "Élément absent"

content (Just node) =
  innerText node

main :: IO ()
main =
  case parseXMLDoc xml of
    Nothing ->
      putStrLn "XML invalide"

    Just document -> do
      let header =
            optionalChildNS
              document
              eadNamespace
              "eadheader"

      putStrLn ("Contenu : " ++ content header)