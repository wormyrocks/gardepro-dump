import sys,gzip

image_file = sys.argv[1]

def splitfile(f, extension, offset, writelen):
    name = ("0x%s.%s" % (offset, extension))
    outfile = open(name, "wb")
    f.seek(offset)
    outfile.write(f.read(writelen))
    outfile.close()
    print(name)

def patch_inplace(f, offset, obj):
    f.seek(offset)
    f.write(obj)

infile = open(image_file, "rb")
splitfile(infile, "json", 0x50,     0x181bf)
splitfile(infile, "gz"   , 0x020050, 0x13aa63)
splitfile(infile, "gz"   , 0x1a0050, 0x26bfa1)
splitfile(infile, "jffs2", 0x4a0040, 0x27ecd)
splitfile(infile, "jffs2", 0x670040, 0x1bb69)
infile.close()

