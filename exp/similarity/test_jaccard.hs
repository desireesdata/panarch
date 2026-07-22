{-# LANGUAGE OverloadedStrings #-}

import Data.Char (isAlphaNum)
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Text (Text)
import qualified Data.Text as T

tokenize :: Text -> Set Text
tokenize =
  Set.fromList
    . T.words
    . T.map normalizeCharacter
    . T.toCaseFold
  where
    normalizeCharacter character
      | isAlphaNum character = character
      | otherwise = ' '

jaccardSimilarity :: Text -> Text -> Double
jaccardSimilarity left right =
  if Set.null union
    then 1
    else
      fromIntegral (Set.size intersection)
        / fromIntegral (Set.size union)
  where
    leftWords = tokenize left
    rightWords = tokenize right

    intersection =
      Set.intersection leftWords rightWords

    union =
      Set.union leftWords rightWords

main :: IO ()
main = do
  let first =
        "Element répétitif un peu pareil"

      second =
        "Element répétitif un peu différent"

      third =
        "Pas du tout la même chose"

  print (jaccardSimilarity first second)
  print (jaccardSimilarity first third)