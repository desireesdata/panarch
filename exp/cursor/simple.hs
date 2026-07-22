{-# LANGUAGE OverloadedStrings #-}

module Main where

import qualified Data.Text.Lazy as LT
import Text.XML (def, parseText_)
import Text.XML.Cursor (Cursor, fromDocument)

xml :: LT.Text
xml =
  "<book>\
  \  <title>Haskell simple</title>\
  \</book>"

main :: IO ()
main = do
  let document =
        parseText_ def xml

      cursor :: Cursor
      cursor =
        fromDocument document

  print cursor