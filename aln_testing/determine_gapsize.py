import commands

def move_files(ko,wt,outdir):
    """move island score files to own dir"""
    get_score_files = "ls | grep scoreisland"
    commands.getoutput("mkdir {0}".format(outdir))
    commands.getoutput("mkdir {0}/{1}".format(outdir,wt))
    commands.getoutput("mkdir {0}/{1}".format(outdir,ko))

    score_files = commands.getoutput(get_score_files)
    for sfile in score_files.split("\n"):
        if ko in sfile:
            commands.getoutput("mv {0} to {1}/{2}/".format(sfile,outdir,ko))
        if wt in sfile:
            commands.getoutput("mv {0} to {1}/{2}/".format(sfile,outdir,wt))
 

def get_group(ko,wt,window_size):
    """for many gap sizes run sicer on sample data to plot gaps need to run this script in the dir you want file"""
    for gap in range(0,6):
        gap_size = gap * window_size
        ##TODO is pvalue too high or too low papers recommend otherwise
        sicer_cmd = "sh /usr/local/bin/SICER_V1.1/SICER/SICER-df-rb.sh {0} {1} 10000 {2} 0.1 0.001".format(ko,wt,gap_size)
        commands.getoutput(sicer_cmd)

def main(ko,wt,outdir,window_size=200):
    get_group(ko,wt,window_size)
    move_files(ko,wt,outdir)



if __name__ == "__main__":
    import optparse
    parser = optparse.OptionParser("usage: %prog [options] ")
    parser.add_option("--ko", dest="ko", help="ko file")
    parser.add_option("--wt", dest="wt", help="wt file")
    parser.add_option("-w", dest="window_size", help="window size", type='int', default=200)
    parser.add_option("-o", dest="outdir", help="location of outdir you want made")

    (options, _) = parser.parse_args()
    if not (options.ko and options.wt and options.outdir):
        sys.exit(parser.print_help())

    main(options.ko, options.wt,options.outdir,options.window_size)

