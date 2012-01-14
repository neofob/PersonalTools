#!/usr/bin/perl
# author: Tuan T. Pham
# I wrote this tool to do some histogram of my weblog or any debug log
# Example: to find out the frequency of different requests from bingbot
# $ grep bingbot weblog.log | awk '{print $7}' | sort > bingbot.txt
# countBin.pl bingbot.txt > bingCount.txt
# The output of file "bingCount.txt" will be something like this
# /CDE/Spring06/CDE-Spring06-09.html	1
# /excursions/Autumn04/Autumn04-09-BW.html	1
# /excursions/Germany/d6/index.html	1
# /fav/Cascades-2002-02.html	2
# /robots.txt	46
# Then I can plot them nicely in OpenOffice Calc

$inputFile=@ARGV[0];

open (INPUT_FILE,"$inputFile")
|| die "Failed to open $inputFile\n";

$lastFreq=1;
$lastBin=<INPUT_FILE>;
chomp $lastBin;

while ($line=<INPUT_FILE>)
{
  chomp $line;
  if ($line eq $lastBin)
  {
    $lastFreq++;
  }
  else
  {
    print "$lastBin\t$lastFreq\n";
    $lastFreq=1;
    $lastBin=$line;
  }
}

print "$lastBin\t$lastFreq\n";

close (INPUT_FILE);
