{-# LANGUAGE OverloadedStrings #-}

import Data.Char (isAlphaNum)
import Data.Set (Set)
import qualified Data.Set as Set
import Data.Text (Text)
import qualified Data.Text as T

-- Normalise le texte :
--   - passage en minuscules
--   - ponctuation remplacée par des espaces
--   - espaces multiples supprimés
normalize :: Text -> Text
normalize =
  T.unwords
    . T.words
    . T.map normalizeCharacter
    . T.toCaseFold
  where
    normalizeCharacter character
      | isAlphaNum character = character
      | otherwise = ' '

-- Produit les trigrammes d'un texte.
--
-- "verlaine"
-- devient :
-- {"ver", "erl", "rla", "lai", "ain", "ine"}
trigrams :: Text -> Set Text
trigrams text =
  Set.fromList
    [ T.take 3 (T.drop index normalized)
    | index <- [0 .. T.length normalized - 3]
    ]
  where
    normalized = normalize text

jaccardSimilarity :: Text -> Text -> Double
jaccardSimilarity left right
  | Set.null union = 1
  | otherwise =
      fromIntegral (Set.size intersection)
        / fromIntegral (Set.size union)
  where
    leftTrigrams = trigrams left
    rightTrigrams = trigrams right

    intersection =
      Set.intersection leftTrigrams rightTrigrams

    union =
      Set.union leftTrigrams rightTrigrams

main :: IO ()
main = do
  let first =
        "Jugements civils; manquant 1857"

      second =
        "Jugements civils"

      third =
        "Jugements civils de simple police"

  print (jaccardSimilarity first second)
  print (jaccardSimilarity first third)