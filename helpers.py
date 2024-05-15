import sys,csv

command = sys.argv[1]

def splitfile(f, name, offset, writelen):
    outfile = open(name, "wb")
    f.seek(offset)
    outfile.write(f.read(writelen))
    outfile.close()
    print(name)

def patch_inplace(f, offset, obj):
    f.seek(offset)
    f.write(obj)
    flen = f.tell() - offset
    return flen

def do_thing(thing):
    image_file = sys.argv[2]
    locations_file = sys.argv[3]
    infile = open(image_file, "rb" if (thing == 'unpack') else "r+b")
    with open(locations_file) as csvfile:
        reader = csv.reader(csvfile)
        for entry in reader:
            [extension, offset, length, lenloc, crcloc] = entry
            name = ("%s.%s" % (offset, extension))
            offset=int(offset,0)
            length=int(length,0)
            if (thing == 'unpack'):
                splitfile(infile, name, offset, length)
            else:
                print("packing: %s" % (name))
                packfile = open(name, "rb")
                flen = patch_inplace(infile, offset, packfile.read())
                if lenloc:
                    lenbytes=flen.to_bytes(byteorder="little", signed=False, length=4)
                    patch_inplace(infile, int(lenloc,0), lenbytes)
                if crcloc:
                    if extension == 'gz':
                        # copy crc footer from bottom of gz file to the top
                        packfile.seek(flen - 4)
                        crc_footer = packfile.read(4)
                        patch_inplace(infile, int(crcloc,0), crc_footer)
                    else:
                        print("not implemented")
                packfile.close()
    infile.close()

if command == 'patchlogo':
    infile=open('sample2.bin', 'rb+')
    infile.seek(0x3cccc2)
    infile.write(bytes(1596))
    infile.close()

if command == 'unpack':
    do_thing('unpack')
elif command == 'pack':
    do_thing('pack')
