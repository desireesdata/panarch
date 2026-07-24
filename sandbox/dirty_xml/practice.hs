{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.IO as TIO
import qualified Text.XML as XML
import Text.XML.Cursor
    ( Cursor
    , checkName
    , content
    , fromDocument
    , node
    , ($//)
    , (&/)
    )



main :: IO ()
main = do 
    document <- XML.readFile XML.def "justice_dirty_ead.xml"
    print document