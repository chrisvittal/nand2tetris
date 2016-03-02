
# The Lists used in decoding the commands.
arithLogi = {"add" : "+", "sub" : "-", "neg" : "-",
             "eq"  : "TO FILL" , "gt"  : "TO FILL" , "lt"  :  "TO FILL",
             "and" : "&", "or"  : "|", "not" : "!"}

def has_more_commands(infile):
    '''functions as both the hasMoreCommands and advance functions
    as described in the VM Translation API'''
    line = infile.readline()
    if line != '':
        return True, line
    else: return False, line

def translate(infile, dicts):
    ''' Runs through a .vm file creating a list of strings with each line
    of assembly code as an entry in the list '''
    asmCommands = []
    while 1:
        more, line = has_more_commands(infile)
        if more:
            newline = parse_line(line)
            cType = get_command_type(newline)


def parse_line(line):
    ''' turns a line into a list of every word in the command
    also removes comments and whitespace'''
    comment, endline = line.find('//'), line.find('\n')
    if comment >= 0:
        line = line[:comment]
    elif endline >= 0:
        line = line[:endline]
    return line.strip().split()
