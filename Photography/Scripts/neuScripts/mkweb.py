__author__ = "Tuan T. Pham"
__version__ = "0.0.1"

"""
    mkweb.py resizes a bunch of big image files to web-friendly size.
    The default settings are stored in $HOME/.config/image/image.cfg
   :copyright: (c) 2014 by Tuan T. Pham
"""

try:
    import ConfigParser as configparser
except ImportError:
    import configparser

import PythonMagick as Magick
import os, sys, glob, string, re

from multiprocessing import Process
import multiprocessing

# Set to True to turn on DEBUG
OUTPUT = False

def DEBUG(arg):
    if OUTPUT:
        print arg

image_defaults = {
    'scale' : '1080x1080',
    'quality' : 95,
    'sharpen' : '1x1',
    'type' : 'JPG',
    'profile' : 'strip',
    'fmatch' : ['*.TIF', '*.tif', '*.JPG'],
}
image_settings = dict()

def parse_config(config_file):
    parser = configparser.ConfigParser()
    parser.read(config_file)

    settings = dict()

    # parsing string
    for entry in ('scale', 'type', 'profile', 'sharpen'):
        try:
            settings[entry] = parser.get('Image', entry)
            DEBUG("%s=%s" % (entry, settings[entry]))
        except configparser.NoOptionError:
            pass
        except configparser.NoSectionError:
            break

    # parsing int
    settings['quality'] = parser.getint('Image', 'quality')

    # parsing file match pattern
    pattern = parser.get('Image', 'fmatch')
    DEBUG(pattern)
    settings['fmatch'] = pattern.split(', ')

    return settings

def LoadConfig(argv):
    print 'config file = ' + argv[0]
    global image_settings
    image_settings = parse_config(argv[0])

    print "image settings:"
    for key in image_settings:
        print "%s = %s" % (key, image_settings[key])

def ProcessDirs(dirs):
    CWD = os.getcwd()
    fileList = []
    for item in dirs:
        os.chdir(item)
        wd = os.getcwd()
        files = []
        for pattern in image_settings['fmatch']:
            files +=glob.glob(pattern)

        for aFile in files:
            fileList += [wd + '/' + aFile]
        os.chdir(CWD)

    # Distribute the big list to all the threads
    thread_no = multiprocessing.cpu_count()
    print "Number of threads = %d" % thread_no
    print "Total files to process = %d" % len(fileList)
    p = []
    pivot = 0
    part_size = len(fileList)/thread_no
    args_array = []
    for i in range(thread_no):
        args_array.append(fileList[pivot:part_size*(i+1)])
        pivot += part_size

    remain = fileList[pivot:]
    for i in range(len(remain)):
        args_array[i].append(remain[i])

    for i in range(thread_no):
        p.append(Process(target=ProcessImage, args=(args_array[i],)))
        p[i].start()

    # The first spawned threads tend to have more work. So we wait
    # for the last threads first because they tend to finish first.
    for i in range(thread_no):
        DEBUG("joining thread %d" % (thread_no-i-1))
        p[thread_no-i-1].join()

    os.chdir(CWD)

def ProcessImage(images):
    DEBUG(images)
    img = Magick.Image()
    radius, sigma = [float(s) for s in image_settings['sharpen'].split('x')]

    for item in images:
        try:
            img.read(item)
        except:
            print >> sys.stderr, 'Fail to open %s' % item
            continue
        img.scale(image_settings['scale'])
        img.sharpen(radius, sigma)
        img.quality(image_settings['quality'])
        if 'strip' == image_settings['profile']:
            img.strip()
        item = string.replace(item, re.search('\.[^\.]+$', item).group(0), '.jpg')
        img.write(item)

"""
Self test, just parse input file for now
"""
if __name__ == '__main__':
    LoadConfig([sys.argv[1]])
    ProcessDirs(sys.argv[2:])
