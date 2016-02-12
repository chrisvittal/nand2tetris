

def decode(infile, outfile):
    '''Runs through the .asm file creating the hack machine code while
    writing to the destination file.
    '''
    while 1:
        more, line = has_more_commands(infile)
        if more:

        else:
            outfile.close()
            return

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



infilename = #put filename here
infile = open(infilename)
outfile = open(get_outfile_name(infilename), 'w')
decode(infile)
