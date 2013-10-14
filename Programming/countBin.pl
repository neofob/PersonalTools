#!/usr/bin/perl
# Someone else wrote a good tool 'utiq' that has an option '-c', so this script 
# is another one bycicle :)
# Example: to find out the frequency of different requests from bingbot
# $ grep bingbot weblog.log | awk '{print $7}' | sort | uniq -c > bingCount.txt
# The output of file "bingCount.txt" will be something like this
# /CDE/Spring06/CDE-Spring06-09.html	1
# /excursions/Autumn04/Autumn04-09-BW.html	1
# /excursions/Germany/d6/index.html	1
# /fav/Cascades-2002-02.html	2
# /robots.txt	46
# Then I can plot them nicely in OpenOffice Calc
