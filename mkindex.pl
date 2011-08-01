#!/usr/bin/perl
#---------------------oOo-------------------------
# Filename: mkindex.pl
# Usage: ./mkindex.pl [-][t|r|c] filename1.jpg filename2.tif
# the output will be filename1.jpg filename2.jpg
# index.html, filename1.html and filename2.html will be generated
# Coder: Tuan Trung Pham
# Last update: June 24, 2002	1st release
# 		12/31/02	added -t, -r
# 		01/03/02	improved parsing -t -r
#		01/04/02	added sharpen, unsharp mask, and beginning year for (c)
#		01/05/03	fixed parsing the title w/ html tags
#		04/05/03	fixed invalidate html tags
#		05/18/04	removed profiles so that old IEs can display images
#		06/13/06	added website URL
#		03/31/08	added Previous and Next link


# -t="myfile.info"
# filename\ttitle description
#....
# -r dont need to resize the input files, just generate html files
# -c=yyyy begining year for (c) => (c)yyyy-currentYear

# Requirements:
# 1) convert ( from ImageMagick Studio package)
# 2) perl
# 3) decent OS (*ix)
# 4) a lot of image files (tif, jpg, png....)

# Wish list:
# 1.caption info (the next row after title and (c))
# 2.recursive directory
# 3.copy right tag (check out JWZ's code)

$Site="http://photo.neofob.org";
$NAME="Tuan Pham";		# put your darn name here
$IndexFile="";
$Title="";
@FILENAME,@TITLE, $inputFile;		# filename and title array
%Table;

main();

#--------------------------oOo---------------------------
# the job is done mainly by this subroutine => main()
sub main
{
	my $Body,$LastFile,$AFile,$NextFile,$OutFile,$ThumbNail,$CurrentFile;
	my $i=0;

	my @A_PARA;
	my $t=0,$r=0;

	my $bYear="";

	$LastFile="./index.html";
	$NextFile="./index.html";
	mkdir "tn" unless ( -e tn );	# creates the directory for thumbnails
	
	# parse -t and -r
	while ($i<3)
	{
		@A_PARA=split("=",@ARGV[0]);	# parse the first argument

		for (@A_PARA[0])
		{
		/-t/ and do
			{
				$t=1;
				$inputFile=@A_PARA[1];
				makeHashTable();
				shift(@ARGV);
			};
		/-r/ and do
			{
				$r=1;
				shift(@ARGV);
			};
		/-c/ and do
			{
				$bYear=@A_PARA[1];
				shift(@ARGV);
			};
		} # for
	
		$i++;
	} # while

	$i=0;
	makeHeader();
	$Body="<table cellpadding=\"0\" cellspacing=\"5\" border=\"0\" align=\"center\" bgcolor=\"#8F8F8F\">"."\n";
	while ($AFile=shift(@ARGV))
	{
		if ( -e $AFile )	# resize one file
		{
			$CurrentFile=$AFile;
			$OutFile=$CurrentFile;
			$OutFile=~s/\.[^\.]+/\.jpg/;
			if ( -e @ARGV[0] )
			{
				$NextFile=@ARGV[0];
				$NextFile=~s/\.[^.]+/\.html/;
			}
			else
			{
				$NextFile="./index.html";
			}
			# I wonder if this is faster than using system()
			if ( $r==0)
			{
				print "Processing \"$CurrentFile\"...\n";
				`convert -resize 2048x2048 -scale 960x960 -bordercolor "#FDFDFD" -border 1x1 \\
				-bordercolor "#000000" -border 3x3 \\
				-flip -flop -bordercolor "#F8E5AF" -border 5x5 -raise 5x5 \\
				-flop -flip -bordercolor "#000000" -border 15x15 \\
				-scale 1024x1024 -sharpen 1x1 -unsharp 0.12x0.25 -quality 95 +profile \"*\" \\
				$CurrentFile $OutFile`;
			
			}

			$ThumbNail="tn-".$OutFile;
			`convert -scale 150x150 +profile \"*\" $OutFile tn/$ThumbNail`;	# make thumbnail

			# need to solve the -c smoother
			# make html file this file
			print "$OutFile\t$LastFile\t$NextFile\n";
			if ($t==0)
			{
				`mkphoto.pl -c=$bYear $OutFile $LastFile $NextFile`;
			}
			else
			{
				`mkphoto.pl -c=$bYear -t=\"$Table{$AFile}\" $OutFile $LastFile $NextFile`;
			}
			
			# add it to index.html
			if ($i==0)
			{
				$Body=$Body."\t<tr valign=\"bottom\" align=\"center\">\n";
			}
			else
			{
				if ( ($i%4)==0 )	# new line
				{	# there is a broken </tr> for the first row (fixed!)
					$Body=$Body."\t</tr>\n\t<tr valign=\"bottom\" align=\"center\">\n";
				}
			}
			$i++;
			$CurrentFile=~s/\.[^\.]+/\.html/;	# removes the extension
			$Body=$Body.
			"\t <td>\n".
			"\t\t<a HREF=\"$CurrentFile\">".
			"<img SRC=\"tn/$ThumbNail\" VSPACE=4 ALT=\"$CurrentFile\"></a>\n".
			"\t </td>\n";
			$LastFile=$CurrentFile;
		}
		else
		{
			print STDERR "Broken arrow! Broken arrow! \"$NextFile\" doesnt exist!\n";
		}
	} # while loop
	# wrap up the tail
	$Body=$Body."\t</tr>\n".
		"</table>\n";
	my $Year=`date | awk '{print \$6}'`;	# get the current year
	$IndexFile=$IndexFile.$Body."\n\n".
		"</td></tr>\n".
		"</table>\n".

		# make a notice for silly web surfers
		"<br><br>\n".
		"\t<center><font size=\"+1\" color=\"\#FAFAFA\">\n".
		"\t\t<b>Click on the thumbnail to see that photo (the largest dimension is 1024 pixels)</b>\n".
		"\t</font></center>".
		"<br><br>\n".

		"<!-- Make a horizontal line -->\n".	# make a horizontal line
		"<table width=\"80%\" bgcolor=\"#00DD00\" border=\"0\" cellspacing=\"0\" align=\"center\">\n".
		"\t<tr>\n".
		"\t<td width=\"100%\" bgcolor=\"#00DD00\">\n".
		"\t</td>\n".
		"\t</tr>\n".
		"</table>\n".
		"<br>\n".
		
		# (c)
		"<!-- Copy right note -->\n".
		"<table width=\"80%\" bgcolor=\"#8F8F8F\" border=\"0\" cellpadding=\"0\"\n".
		"cellspacing=\"0\" align=\"center\">\n".
		"\t<tr>\n".
		"\t<td align=\"left\">\n".
		"\t\t<font size=\"-1\" color=\"\#FAFAFA\">\n";
	if ("" eq $bYear)
	{
		$IndexFile.="\t\t&copy;$Year $NAME<br>\n";
	}
	else
	{
		$IndexFile.="\t\t&copy;$bYear-$Year $NAME<br>\n";
	}
		$IndexFile.="\t\tAny unauthorized use of these photos will be prosecuted to full extent of the\n".
		"current complicated Federal Copyright Laws.\n".
		"\t\t</font>\n".
		"\t</td>".
		"\t</tr>".
		"\t<tr><td align=\"center\"><a href=\"$Site\">Home</a></td></tr>".
		"</table>".
		"<p><center>\n ".
		"<a href=\"http://validator.w3.org/check?uri=referer\"><img src=\"http://www.w3.org/Icons/valid-html401-blue\"".
		" alt=\"Valid HTML 4.01 Transitional\" height=\"31\" width=\"88\"></a>".
		"</center>\n".
		"</body>\n".
		"</html>";
	if ( open (INDEX,"> index.html") )
	{
		#print STDERR "$Body\n";
		print "Generating index.html ...\n";
		print INDEX $IndexFile;
		close(INDEX);
	}
	else
	{
		print STDERR "Can't create index.html file\n";
	}
	
}

#-------------------------oOo--------------------------
# makeHeader()
# generate the the header for index.html
sub makeHeader
{
	$MyDate=localtime();
	$IndexFile="<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">\n".
		"<html>\n".
		"<head>\n".
		"<meta http-equiv=\"content-type\" content=\n\"text/html; charset=UTF-8\">\n".
		"<title>$Title</title>\n".
		"</head>\n\n".
		"<body BGCOLOR=\"#8F8F8F\" TEXT=\"#00FF00\" LINK=\"#00DDAA\" VLINK=\"#AADD00\" ALINK=\"#00FF00\">\n".
		"<!-- End of Header -->\n".
		"<!-- Generated on $MyDate by Tuan Pham -->\n\n".
		"<br>\n\n".
		"<table align=\"center\">\n".
		"<tr><td>\n";
}

#-------------------------oOo--------------------------
# makeHashTable()
# how to pass a hashtable?
sub makeHashTable
{
	# parse the title
	open (INPUT_FILE,"$inputFile")	# default is open(INPUT_FILE,"< $inputFile") readonly
	|| die "Jebus! Can't read $inputFile\n fsck?";

	$Title=<INPUT_FILE>;		# read the first line as the title for the index.html
	chomp $Title;			# clean it

	while ($line=<INPUT_FILE>)	# parse the filename and titles
	{
		chomp $line;		# clean it!
		@temp_list=split("\t",$line);	# split it into filename and title
		$Table{@temp_list[0]}=@temp_list[1];	# associate the filename to the title
	}

	close (INPUT_FILE);
}

#------------------oOo----------------
