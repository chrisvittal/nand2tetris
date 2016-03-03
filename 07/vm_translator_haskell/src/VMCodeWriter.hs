module VMCodeWriter where

import VMParser

translate :: Int -> [Command] -> String
-- Master function for turning list of commands, keeping track of commands
-- translated so that conditionals and others can be uniquely identified
translate n cs = concat (go n cs)
    where go _ [] = []
          go n (x:xs) = trans n x : go (n+1) xs

trans :: Int -> Command -> String
trans n c = case c of
    (C_ARITHMETIC _) -> transArith n c
    (C_PUSH _ _)     -> transPushPop c
    (C_POP  _ _)     -> transPushPop c
    _                -> undefined

transArith :: Int -> Command -> String
transArith n (C_ARITHMETIC s)
    | s == "add" =
        "@SP\nAM=M-1\nD=M\n@SP\nA=M-1\nM=M+D\n"
    | s == "sub" =
        "@SP\nAM=M-1\nD=M\n@SP\nA=M-1\nM=M-D\n"
    | s == "neg" =
        "@SP\nA=M-1\nM=-M\n"
    | s == "eq"  =
        "@SP\nAM=M-1\nD=M\nA=A-1\nD=D-M\n@EQ.TRUE."++ show n ++
        "\nD; JEQ\n@SP\nA=M-1\nM=0\n@EQ.END." ++ show n ++
        "\n0; JMP\n(EQ.TRUE." ++ show n ++")\n@SP\nA=M-1\nM=-1\n(EQ.END."
        ++ show n ++")\n"
    | s == "gt"  =
        "@SP\nAM=M-1\nD=M\nA=A-1\nD=M-D\n@GT.TRUE."++ show n ++
        "\nD; JGT\n@SP\nA=M-1\nM=0\n@GT.END." ++ show n ++
        "\n0; JMP\n(GT.TRUE."
        ++ show n ++")\n@SP\nA=M-1\nM=-1\n(GT.END."++ show n ++")\n"
    | s == "lt"  =
        "@SP\nAM=M-1\nD=M\nA=A-1\nD=M-D\n@LT.TRUE."++ show n ++
        "\nD; JLT\n@SP\nA=M-1\nM=0\n@LT.END."++ show n ++"\n0; JMP\n(LT.TRUE."
        ++ show n ++")\n@SP\nA=M-1\nM=-1\n(LT.END."++ show n ++")\n"
    | s == "and" =
        "@SP\nAM=M-1\nD=M\n@SP\nA=M-1\nM=D&M\n"
    | s == "or"  =
        "@SP\nAM=M-1\nD=M\n@SP\nA=M-1\nM=D|M\n"
    | s == "not" =
        "@SP\nA=M-1\nM=!M\n"

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
        "@SP\nAM = M-1\nD=M\n@" ++ show (16+ind) ++"\nM=D\n"
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
        "@SP\nAM = M-1\nD=M\n@" ++ show (5+ind) ++"\nM=D\n"
    | otherwise = error "Invalid Syntax"
