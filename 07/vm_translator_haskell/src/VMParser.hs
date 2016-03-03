module VMParser (Command(..), parseCommand, dropComms, parseCommands) where

data Command = C_ARITHMETIC String
             | C_PUSH String Int
             | C_POP String Int
             | C_LABEL String
             | C_GOTO String
             | C_IF String
             | C_FUNCTION String Int
             | C_RETURN
             | C_CALL String Int
    deriving (Eq, Show)

parseCommand :: [String] -> Command
parseCommand (x:xs)
    | x == "push"     = C_PUSH y (read z :: Int)
    | x == "pop"      = C_POP y (read z :: Int)
    | x == "label"    = C_LABEL y
    | x == "goto"     = C_GOTO y
    | x == "if-goto"  = C_IF y
    | x == "function" = C_FUNCTION y (read z :: Int)
    | x == "call"     = C_CALL y (read z :: Int)
    | x == "return"   = C_RETURN
    | otherwise       = C_ARITHMETIC x
    where go [x]   = (x,x)
          go [x,y] = (x,y)
          (y,z)    = go xs

dropComms :: String -> [String]
-- Gets rid of comments, newlines, whitespace
-- Puts each command in it's own list entry
dropComms = words . takeWhile (\x -> x/='\n' && x/='/')

parseCommands :: String -> [Command]
parseCommands =
    map parseCommand . filter (/=[]) . map dropComms . lines

tst = "push constant 3030 // pointer, this, and that segments."
tst2 = "push constant 3030 \n// pointer, this, and that segments."

-- Lines -> map (words . takewhile) -> filter empty

simadd = "// This file is part of www.nand2tetris.org\n// and the book \"The Elements of Computing Systems\"\n// by Nisan and Schocken, MIT Press.\n// File name: projects/07/StackArithmetic/StackTest/StackTest.vm\n\n// Executes a sequence of arithmetic and logical operations\n// on the stack. \npush constant 17\npush constant 17\neq\npush constant 17\npush constant 16\neq\npush constant 16\npush constant 17\neq\npush constant 892\npush constant 891\nlt\npush constant 891\npush constant 892\nlt\npush constant 891\npush constant 891\nlt\npush constant 32767\npush constant 32766\ngt\npush constant 32766\npush constant 32767\ngt\npush constant 32766\npush constant 32766\ngt\npush constant 57\npush constant 31\npush constant 53\nadd\npush constant 112\nsub\nneg\nand\npush constant 82\nor\nnot\n"

tt = "this is \
      \a string"
