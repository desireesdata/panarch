module Main where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import Text.XML.HXT.Core

validateDTD :: FilePath -> IO Bool
validateDTD filename = do
  statuses <-
    runX $
      readDocument
        [ withValidate yes
        , withWarnings yes
        , withRemoveWS no
        ]
        filename
      >>>
      getErrStatus

  pure $
    case statuses of
      [] -> False
      xs -> maximum xs < c_err

main :: IO ()
main = do
  args <- getArgs

  case args of
    [filename] -> do
      valid <- validateDTD filename

      if valid
        then do
          putStrLn "Document valide selon la DTD."
          exitSuccess
        else do
          putStrLn "Document invalide."
          exitFailure

    _ -> do
      putStrLn "Usage : runghc validate.hs fichier.xml"
      exitFailure