{-# LANGUAGE PackageImports #-}

module Main where

import System.Environment (getArgs)
import System.Exit (exitFailure)

import "hxt" Text.XML.HXT.Core

import "hxt-xslt" Text.XML.HXT.XSLT.XsltArrows
  ( CompiledStylesheet
  , xsltApplyStylesheet
  , xsltCompileStylesheet
  )

compileStylesheet
  :: FilePath
  -> IO (Either String CompiledStylesheet)
compileStylesheet stylesheetPath = do
  stylesheets <-
    runX $
      readDocument
        [ withValidate no
        , withCheckNamespaces yes
        , withWarnings yes
        , withInputEncoding utf8
        , withStrictInput yes
        ]
        stylesheetPath
        >>> xsltCompileStylesheet

  pure $
    case stylesheets of
      stylesheet : _ ->
        Right stylesheet

      [] ->
        Left "Impossible de lire ou compiler la feuille XSLT."

transformToFile
  :: CompiledStylesheet
  -> FilePath
  -> FilePath
  -> IO Bool
transformToFile stylesheet xmlPath outputPath = do
  results <-
    runX $
      readDocument
        [ withValidate no
        , withCheckNamespaces yes
        , withWarnings yes
        , withInputEncoding utf8
        , withStrictInput yes
        ]
        xmlPath
        >>> xsltApplyStylesheet stylesheet
        >>> writeDocument
              [ withIndent yes
              , withOutputEncoding utf8
              ]
              outputPath

  pure (not (null results))

main :: IO ()
main = do
  arguments <- getArgs

  case arguments of
    [stylesheetPath, xmlPath, outputPath] -> do
      compiled <- compileStylesheet stylesheetPath

      case compiled of
        Left err -> do
          putStrLn err
          exitFailure

        Right stylesheet -> do
          success <-
            transformToFile stylesheet xmlPath outputPath

          if success
            then
              putStrLn ("Fichier créé en UTF-8 : " ++ outputPath)
            else do
              putStrLn "La transformation ou l’écriture a échoué."
              exitFailure

    _ -> do
      putStrLn $
        "Usage : runghc apply_xslt.hs "
          ++ "feuille.xsl document.xml sortie.xml"

      exitFailure