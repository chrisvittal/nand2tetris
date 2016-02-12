# These are the inital dictionaries used for translation
# of the hack assembly into hack machine code.
symbol_dict = {'R{}'.format(x): x for x in range(0,16)}
comp_dict = {'0'  : '0101010', '1'  : '0111111',
             '-1' : '0111010', 'D'  : '0001100',
             'A'  : '0110000', 'M'  : '1110000',
             '!D' : '0001101', '!A' : '0110001',
             '!M' : '1110001', 'D+1': '0011111',
             'A+1': '0110111', '1+D': '0011111',
             '1+A': '0110111', 'M+1': '1110111',
             '1+M': '1110111', 'D-1': '0001110',
             'A-1': '0110010', 'M-1': '1110010',
             'D+A': '0000010', 'A+D': '0000010',
             'D+M': '1000010', 'M+D': '1000010',
             'D-A': '0010011', 'D-M': '1010011',
             'A-D': '0000111', 'M-D': '1000111',
             'D&A': '0000000', 'A&D': '0000000',
             'D&M': '1000000', 'M&D': '1000000',
             'D|A': '0010101', 'A|D': '0010101',
             'D|M': '1010101', 'M|D': '1010101'}
dest_dict = {''   : '000', 'M'  : '001',
             'D'  : '010', 'MD' : '011',
             'DM' : '011', 'A'  : '100',
             'AM' : '101', 'MA' : '101',
             'AD' : '110', 'DA' : '110',
             'AMD': '111', 'ADM': '111',
             'DAM': '111', 'DMA': '111',
             'MAD': '111', 'MDA': '111'}
jump_dict = {''   : '000', 'JGT': '001',
             'JEQ': '010', 'JGE': '011',
             'JLT': '100', 'JNE': '101',
             'JLE': '110', 'JMP': '111'}

def decode(infile, outfile):
    '''Runs through the .asm file creating the hack machine code while
    writing to the destination file.
    '''
    while 1:
        more, line = has_more_commands(infile)
        if more:
            # do stuff
            if get_command_type(line): #True if A_COMMAND or L_COMMAND
                # do stuff
            else: #True if C_COMMAND
                decode_C_COMMAND(line)
        else:
            outfile.close()
            return

def parse_C(line):
    newline = line.replace(' ', '')
    parsed_C = []
    comment, endline = newline.find('//'), newline.find('\n')
    if comment >= 0:
        newline = newline[:comment]
    elif endline >= 0:
        newline = newline[:endline]
    eqpos, semipos = newline.find('='), newline.find(';')
    parsed_C.append(get_comp(newline, eqpos, semipos))
    parsed_C.append(get_dest(newline, eqpos))
    parsed_C.append(get_jump(newline, semipos))
    return parsed_C

def get_comp(line, eqpos, semipos):
    if eqpos == -1 and semipos == -1:
        return line
    elif eqpos == -1:
        return line[:semipos]
    elif semipos == -1:
        return line[eqpos+1:]
    else:
        return line[eqpos+1:semipos]

def get_dest(line, eqpos):
    if eqpos == -1:
        return ''
    else:
        return line[:eqpos]

def get_jump(line, semipos):
    if semipos == -1:
        return ''
    else:
        return line[semipos+1:]

def decode_C_COMMAND(line, cd, dd, jd):
    cinst = parse_C(line)
    if cinst == ['','','']: return None
    compbin = cd[cinst[0]]
    destbin = dd[cinst[1]]
    jumpbin = jd[cinst[2]]
    return '111' + compbin + destbin + jumpbin

def has_more_commands(infile):
    '''functions as both the hasMoreCommands and advance functions
    as described in the hack assembler API'''
    line = infile.readline()
    if line != '':
        return True, line
    else: return False, line

def get_outfile_name(infilename):
    period = infilename.find('.')
    return infilename[:period] + '.hack'


# Runs assembler

infilename = input()
infile = open(infilename)
outfile = open(get_outfile_name(infilename), 'w')

decode(infile, outfile, symbol_dict)
