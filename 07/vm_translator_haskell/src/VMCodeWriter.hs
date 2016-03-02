module VMCodeWriter where

import VMParser

translate :: Int -> [Command] -> [String]
-- Master function for turning list of commands, keeping track of commands
-- translated so that conditionals and others can be uniquely identified
translate n [] = []
translate n (x:xs) = trans n x : translate (n+1) xs

trans :: Int -> Command -> String
trans n c = case c of
    (C_ARITHMETIC _) -> transArith n c
    (C_PUSH _ _)     -> transPushPop c
    (C_POP  _ _)     -> transPushPop c

transArith :: Int -> Command -> String
transArith n (C_ARITHMETIC s)
    | s == "add" =
        "@SP\nM=M-1\nA=M\nD=M\n@SP\nM=M-1\nA=M\nM=M+D\n@SP\nM=M+1\n"
    | s == "sub" =
        "@SP\nM=M-1\nA=M\nD=M\n@SP\nM=M-1\nA=M\nM=D-M\n@SP\nM=M+1\n"
    | s == "neg" =
        "@SP\nM=M-1\nA=M\nM=-M\n@SP\nM=M+1\n"
    | s == "eq"  = undefined
    | s == "gt"  = undefined
    | s == "lt"  = undefined
    | s == "and" =
        "@SP\nM=M-1\nA=M\nD=M\n@SP\nM=M-1\nA=M\nM=D&M\n@SP\nM=M+1\n"
    | s == "or"  =
        "@SP\nM=M-1\nA=M\nD=M\n@SP\nM=M-1\nA=M\nM=D|M\n@SP\nM=M+1\n"
    | s == "not" =
        "@SP\nM=M-1\nA=M\nM=!M\n@SP\nM=M+1\n"

transPushPop :: Command -> String
transPushPop (C_PUSH loc ind)
    | loc == "argument" =
        "@ARG\nD=M\n@" ++ show ind ++
        "\nA=D+A\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "local"    =
        "@LCL\nD=M\n@" ++ show ind ++
        "\nA=D+A\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "static"   =
        "@" ++ show (16+ind) ++ "\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "constant" =
        "@" ++ show ind ++ "\nD=A\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "this"     =
        "@THIS\nD=M\n@" ++ show ind ++
        "\nA=D+A\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "that"     =
        "@THAT\nD=M\n@" ++ show ind ++
        "\nA=D+A\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "pointer" && ind == 0 =
        "@THIS\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "pointer" && ind == 1 =
        "@THAT\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | loc == "temp"     =
        "@" ++ show (5+ind) ++ "\nD=M\n@SP\nA=M\nM=D\n@SP\nM=M+1\n"
    | otherwise = error "Invalid Syntax"
transPushPop (C_POP  loc ind)
    | loc == "argument" =
        "@ARG\nD=M\n@" ++ show ind ++
        "\nD=D+A\n@R13\nM=D\n@SP\nAM=M-1\nD=M\n@R13\nA=M\nM=D\n"
    | loc == "local"    =
        "@LCL\nD=M\n@" ++ show ind ++
        "\nD=D+A\n@R13\nM=D\n@SP\nAM=M-1\nD=M\n@R13\nA=M\nM=D\n"
    | loc == "static"   =
        "@SP\nAM = M-1\nD=M\n@" ++ show (16+ind) ++"\nM=D"
    | loc == "this"     =
        "@THIS\nD=M\n@" ++ show ind ++
        "\nD=D+A\n@R13\nM=D\n@SP\nAM=M-1\nD=M\n@R13\nA=M\nM=D\n"
    | loc == "that"     =
        "@THAT\nD=M\n@" ++ show ind ++
        "\nD=D+A\n@R13\nM=D\n@SP\nAM=M-1\nD=M\n@R13\nA=M\nM=D\n"
    | loc == "pointer" && ind == 0 =
        "@SP\nAM = M-1\nD=M\n@THIS\nM=D\n"
    | loc == "pointer" && ind == 1 =
        "@SP\nAM = M-1\nD=M\n@THAT\nM=D\n"
    | loc == "temp"     =
        "@SP\nAM = M-1\nD=M\n@" ++ show (5+ind) ++"\nM=D"
    | otherwise = error "Invalid Syntax"
