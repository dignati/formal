{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE NamedFieldPuns #-}
{-# LANGUAGE RecordWildCards #-}
{-# LANGUAGE ViewPatterns #-}
{-# LANGUAGE RankNTypes #-}
{-# LANGUAGE TemplateHaskell #-}
{-# LANGUAGE QuasiQuotes #-}
{-# LANGUAGE OverlappingInstances #-}
{-# LANGUAGE FlexibleContexts #-}

module Formal.Parser (parseFormal, compress) where

import Control.Applicative

import Text.Parsec         hiding ((<|>), State, many, spaces, parse, label)
import Text.Parsec.Indent  hiding (same)

import Formal.Parser.Utils
import Formal.Parser.Statements
import Formal.Parser.AST



-- Parsing 
-- -----------------------------------------------------------------------------
-- A Sonnet program is represented by a set of statements

parseFormal :: String -> Either ParseError Program
parseFormal src = case parse ((comment <|> return "\n") `manyTill` eof) "Cleaning comments" src of 
                    Right x -> parse formalParser "parsing syntax" (concat x)


compress :: String -> String
compress = run var . run null . run fun

    where run x src' = case parse ((try x <|> ((:[]) <$> anyChar)) `manyTill` eof) "Compressing" src' of Right x -> concat x

          var = do string "var"
                   spaces
                   name <- many1 (alphaNum <|> char '_')
                   string ";"
                   spaces
                   string name
                   return $ "var " ++ name

          null = do string "var"
                    spaces
                    name <- many1 (alphaNum <|> char '_')
                    string ";"
                    spaces
                    string name
                    spaces
                    string "="
                    spaces
                    string "null"
                    return $ "var " ++ name  

          pairs = do string "{"
                     inner <- (try pairs <|> ((:[]) <$> anyChar)) `manyTill` string "}"
                     return $ "{" ++ concat inner ++ "}"

          fun = do string "(function()"
                   spaces
                   string "{"
                   spaces
                   string "return"
                   spaces
                   string "(function("
                   name <- many1 (alphaNum <|> char '_')
                   string ")"
                   spaces
                   content <- pairs
                   spaces
                   string ");"
                   spaces
                   string "})()"
                   return $ "(function(" ++ name ++ ")" ++ content ++ ")"
                   
               



formalParser :: Parser Program
formalParser  = Program . concat <$> many (many (string "\n") >> statement) <* eof

    where statement       = whitespace >> withPos statement_types <* many newline
          statement_types = (try type_statement       <?> "Type Definition")
                            <|> (try import_statement <?> "Import Statement")
                            <|> (try module_statement <?> "Module Declaration")
                            <|> (try def_statement    <?> "Symbol Definition")
                            <|> (expression_statement <?> "Assertion")

          def_statement = map DefinitionStatement <$> definition_statement

          import_statement = do string "open"
                                whitespace
                                (:[]) . ImportStatement . Namespace <$> namespace

          module_statement = do string "module"
                                whitespace1
                                name <- Namespace <$> namespace
                                whitespace *> newline
                                spaces *> (indented <|> same)
                                (:[]) . ModuleStatement name . concat 
                                    <$> withPos (many1 ((spaces >> same >> statement)))

          namespace = many1 lower `sepBy1` char '.'

