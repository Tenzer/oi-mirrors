#!/usr/bin/env python

import filecmp
import os
import shutil
import sys

if len(sys.argv) != 3:
    print 'Exactly two arguments are expected: <source> <destination>'
    sys.exit(1)
else:
    source = sys.argv[1].rstrip('/')
    destination = sys.argv[2].rstrip('/')

    if os.path.basename(source) != 'file':
        print 'The source path is expected to point to a "file" directory'
        sys.exit(1)

    if not os.path.exists(source) or not os.path.exists(destination):
        print 'One or both of the provided paths does not exist'
        sys.exit(1)

    if not os.path.isdir(source) or not os.path.isdir(destination):
        print 'The provided paths should point to directories'
        sys.exit(1)


for i in range(0, 256):
    hex = '%0.2x' % (i)
    source_hex = os.path.join(source, hex)
    print 'Working on %s:' % (hex),

    if not os.path.isdir(source_hex):
        print 'Directory missing from the source'
        continue

    files = os.listdir(source_hex)
    (match, mismatch, errors) = filecmp.cmpfiles(source_hex, destination, files)  # Compares file mode, size and mtime
    print '%i OK, %i mismatches, %i missing' % (len(match), len(mismatch), len(errors)),
    sys.stdout.flush()

    if mismatch:
        for f in mismatch:
            sf = os.path.join(source_hex, f)
            df = os.path.join(destination, f)

            os.remove(df)
            shutil.copy2(sf, df)

        print '- Mismatches done',
        sys.stdout.flush()

    if errors:
        for f in errors:
            sf = os.path.join(source_hex, f)
            df = os.path.join(destination, f)

            # Source file exists, destination file doesn't exist
            if os.path.exists(sf) and not os.path.exists(df):
                shutil.copy2(sf, df)
            # Source file doesn't exist, destination file exists
            elif not os.path.exists(sf) and os.path.exists(df):
                os.remove(df)
            else:
                print '- %s could not be compared' % (f),
                sys.stdout.flush()

        print '- Missing files done',
        sys.stdout.flush()

    print
