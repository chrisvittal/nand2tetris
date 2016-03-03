module Main where

import VMParser
import VMCodeWriter
import System.Directory
import Control.Monad

-- this writer assumes the windows operating system and file structure
main = do
    inFlName <- getLine
    flExist <- doesFileExist inFlName
    if flExist
        then do
            let outFlName = takeWhile (/='.') inFlName ++ ".asm"
            file <- readFile inFlName
            writeFile outFlName (translate 0 . parseCommands $ file)
    else error "File Not Found"
    return ()
