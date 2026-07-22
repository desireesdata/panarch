module Main where

import System.Environment (getArgs)
import System.Exit (exitFailure, exitSuccess)
import Text.XML.HXT.Core

validateDTD :: FilePath -> IO Bool
validateDTD xmlPath = do
  statuses <-
    runX $
      readDocument
        [ withValidate yes
        , withCheckNamespaces yes
        , withWarnings yes
        , withInputEncoding utf8
        ]
        xmlPath
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
    [xmlPath] -> do
      valid <- validateDTD xmlPath

      if valid
        then do
          putStrLn "Document XML valide."
          exitSuccess
        else do
          putStrLn "Document XML invalide."
          exitFailure

    _ -> do
      putStrLn "Usage : runghc validator.hs document.xml"
      exitFailure