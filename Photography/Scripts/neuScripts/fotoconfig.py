__author__ = "Tuan T. Pham"

"""
FileName: `fotoconfig.py`

Parse the `info.ini` for images

The file has the following format:

[GeneralInfo]
Title: This is the title of the whole photoset
Description: More details about the wholeset but still a one-liner

[Image]
; This is the total number of images
Total: 10

[Image_n]
FileName: MyPhoto.jpg
Title: Untitled
Description: One line descriptive description
"""

from ConfigParser import ConfigParser
import sys

class FotoInfo():
    FileName = None
    Title = None
    Description = None

    def __init__(self, config = None, sectName = None):
        if config != None and sectName != None:
            self.FileName = config.get(sectName, 'FileName')
            self.Title= config.get(sectName, 'Title')
            self.Description = config.get(sectName, 'Description')

    def __repr__(self):
        return "FileName=%s\tTitle=%s\tDescription=%s" % (self.FileName, self.Title, self.Description)

class FotoSetInfo():
    ConfigFile = None
    FotoSetDesc = None
    FotoSetTitle = None
    FotoNumber = 0
    FotoInfoArray = []

    """
    Read the `info.ini` file, parse it into array of FotoInfo objects
    """
    def __init__(self, configFile = None):
        config = ConfigParser()
        config.read(configFile)
        self.ConfigFile = configFile
        self.FotoSetDesc = config.get('GeneralInfo', 'Description')
        self.FotoSetTitle= config.get('GeneralInfo', 'Title')
        self.FotoNumber = config.getint('Image','Total')

        for i in range(self.FotoNumber):
            imageInfo = FotoInfo(config, 'Image_'+str(i))
            self.FotoInfoArray.append([imageInfo])

    def __repr__(self):
        return "ConfigFile=%s\tFotoSetDesc=%s\tFotoSetTitle=%s\tFotoNumber=%d"\
        % (self.ConfigFile, self.FotoSetDesc, self.FotoSetTitle, self.FotoNumber)

    def toStr(self):
        print self
        for i in range(len(self.FotoInfoArray)):
            print self.FotoInfoArray[i]

def DumpFile(argv):
    print 'config file = ' + argv[0]
    fotoSetInfo =  FotoSetInfo(argv[0])
    fotoSetInfo.toStr()

"""
Self test, just parse input file
"""
if __name__ == '__main__':
    DumpFile(sys.argv[1:])
