def create_symbols():
    symbol_dict = {'R{}'.format(x): '{:016b}'.format(x) for x in range(0,16)}
    predefineds = [('SP', 0), ('LCL', 1), ('ARG', 2), ('THIS', 3),
                   ('THAT', 4), ('SCREEN', 16384), ('KBD', 24576)]
    for x in predefineds:
        symbol_dict[x[0]] = '{:016b}'.format(x[1])
    return symbol_dict

def get_labels(infile, symbol):
    '''Runs thrught the .asm file getting the L_COMMANDs
    and assigning the appropriate numbers to them'''

def decode(infile, outfile, dicts):
    '''Runs through the .asm file creating the hack machine code while
    writing to the destination file.
    '''
    add_used = 16
    while 1:
        more, line = has_more_commands(infile)
        if more:
            newline = parse_line(line)
            if get_command_type(newline) == 'a': #True if A_COMMAND
                output, add_used = decode_A_COMMAND(newline,
                                                    dicts['symbol'],
                                                    add_used)
            elif get_command_type(newline) == 'l': #True if L_COMMAND
                0 == 0
            else: #True if C_COMMAND or not a command.
                output = decode_C_COMMAND(newline,
                                          dicts['comp'],
                                          dicts['dest'],
                                          dicts['jump'])
            if output != None:
                outfile.write(output + '\n')
        else:
            outfile.close()
            return

def decode_A_COMMAND(line, symbol, add_used):
    try:
        adr = int(line[1:])
        return '{:016b}'.format(adr), add_used
    except:
        if line[1:] in symbol:
            return symbol[line[1:]], add_used
        else:
            symbol[line[1:]] = '{:016b}'.format(add_used)
            return symbol[line[1:]], add_used + 1

def parse_line(line):
    line = line.replace(' ', '')
    comment, endline = line.find('//'), line.find('\n')
    if comment >= 0:
        line = line[:comment]
    elif endline >= 0:
        line = line[:endline]
    return line

def parse_C(line):
    parsed_C = []
    eqpos, semipos = line.find('='), line.find(';')
    parsed_C.append(get_comp(line, eqpos, semipos))
    parsed_C.append(get_dest(line, eqpos))
    parsed_C.append(get_jump(line, semipos))
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

def get_command_type(line):
    if line == '':
        return 'c'
    elif line[0] == '@':
        return 'a'
    elif line[0] == '(':
        return 'l'
    else:
        return 'c'

# These are the inital dictionaries used for translation
# of the hack assembly into hack machine code.
symbol_dict = create_symbols()
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
dictionaries = {'symbol': symbol_dict,
                'comp':   comp_dict,
                'dest':   dest_dict,
                'jump':   jump_dict}


# Runs assembler. main, as it were

infilename = input()
infile = open(infilename)
outfile = open(get_outfile_name(infilename), 'w')

get_labels(infile, dictionaries['symbol'])

decode(infile, outfile, dictionaries)
