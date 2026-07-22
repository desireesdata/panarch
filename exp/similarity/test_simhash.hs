{-# LANGUAGE OverloadedStrings #-}

module Main where

import Data.Bits (bit, popCount, testBit, xor)
import Data.Char (isAlphaNum)
import Data.List (foldl')
import Data.Text (Text)
import qualified Data.Text as T
import Data.Word (Word64)
import qualified Text.XML as XML
import Text.XML.Cursor
  ( Cursor
  , content
  , element
  , fromDocument
  , ($/)
  , (&/)
  )

tokenize :: Text -> [Text]
tokenize =
  T.words
    . T.map normalizeCharacter
    . T.toCaseFold
  where
    normalizeCharacter character
      | isAlphaNum character = character
      | otherwise = ' '

hashToken :: Text -> Word64
hashToken =
  T.foldl' step 14695981039346656037
  where
    step hash character =
      (hash `xor` fromIntegral (fromEnum character))
        * 1099511628211

simHash :: Text -> Word64
simHash text =
  foldl' buildBit 0 [0 .. 63]
  where
    hashes =
      map hashToken (tokenize text)

    scoreForBit bitIndex =
      sum
        [ if testBit hash bitIndex
            then 1
            else -1
        | hash <- hashes
        ]

    buildBit fingerprint bitIndex
      | scoreForBit bitIndex > 0 =
          fingerprint `xor` bit bitIndex
      | otherwise =
          fingerprint

hammingDistance :: Word64 -> Word64 -> Int
hammingDistance left right =
  popCount (left `xor` right)

similarPairs :: Int -> [Text] -> [(Text, Text, Int)]
similarPairs threshold texts =
  [ (left, right, distance)
  | (index, left) <- zip [0 :: Int ..] texts
  , right <- drop (index + 1) texts
  , let distance =
          hammingDistance (simHash left) (simHash right)
  , distance <= threshold
  ]

extractCElements :: Cursor -> [Text]
extractCElements cursor =
  cursor $/ element "c" &/ content

main :: IO ()
main = do
  document <- XML.readFile XML.def "entree.xml"

  let cursor =
        fromDocument document

  let cElements =
        extractCElements cursor

  mapM_ print (similarPairs 15 cElements)