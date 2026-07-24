{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Text (Text)
import qualified Data.Text.IO as TIO
import qualified Text.XML as XML
import Text.XML.Cursor
    ( Cursor
    , checkName
    , content
    , laxElement
    , fromDocument
    , node
    , ($//)
    , (&/)
    )

data FindingAid = FindingAid
    {
          findingAidTitle     :: Text
        , findingAidId        :: Text
    }
    deriving (Show)

parseFindingAid :: Cursor -> FindingAid
parseFindingAid cursor =
    FindingAid
        { findingAidTitle =
            head
                ( cursor
                    $// laxElement "archdesc"
                    &/ laxElement "did"
                    &/ laxElement "unittitle"
                    &/ content
                )
        , findingAidId =
            head
                ( cursor
                    $// laxElement "titleproper"
                    &/ content
                )
        }
    

settingsXml = XML.def { XML.psRetainNamespaces = False }

main :: IO ()
main = do 
    document <- XML.readFile settingsXml "justice_dirty_ead.xml"
    print (parseFindingAid (fromDocument document))