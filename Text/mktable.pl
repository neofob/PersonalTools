#!/usr/bin/perl

##################################################################################
# Filename: mktable.pl
# Description: Take input from STDIN and "parse" into fields in html format to STDOUT
# Coder: Tuan Trung Pham
# Last Updated: 10/04/02	(removed unnecessary cellspacing and stuff)
# Usage: mktable.pl < news.info > news.html
#
#################################################################################

$IndexFile;		# output file
$AssType;

main();			# call the main function
sub main()
{
	my $Body;
	$AssType=<STDIN>;	# read in the assignment type
	chomp $AssType;		# chop off the \n char
	makeHeader();		# make the html header
	$Body="<table width=\"100%\" cellpadding=\"1\" cellspacing=\"1\" border=\"1\"".
		" align=\"center\">"."\n".
		"<tbody>"."\n";

##############################################################
# Begin of the while loop to "parse" line
# Date	EventDescription	Photographer(s)	EventDate	DueDate
# 10%	45%			25%		10%		10%

	# print the headr for this table
	
	$Body=$Body."\n  <tr>\n";			# creates a new table row

	# print the cell for Assigned Date
	$Body=$Body."\t<th width=\"10%\">\n";
	$Body=$Body."\tAssigned Date\n\t</th>\n";

		
	# print the cell for EventDescription
	$Body=$Body."\t<th width=\"45%\">\n";
	$Body=$Body."\tEvent Description\n\t</th>\n";

	
	# print the cell for Photographer(s)
	$Body=$Body."\t<th width=\"25%\">\n";
	$Body=$Body."\tPhotographer(s)\n\t</th>\n";

	# print the cell for EventDate
	$Body=$Body."\t<th width=\"10%\">\n";
	$Body=$Body."\tEvent Date\n\t</th>\n";

	# print the cell for DueDate
	$Body=$Body."\t<th width=\"10%\">\n";
	$Body=$Body."\tDue Date\n\t</th>\n";

	# close this row
	$Body=$Body."  </tr>\n\n";
	
	while ($line=<STDIN>)
	{
		chomp $line;			# delete the last \n char
		@line_=split(/\t/,$line);	# "split" into fields seperated by \t
		$length=@line_;			# get the length of @line array
		
		# print 5 cells for one row
		
		$Body=$Body."  <tr>\n";			# creates a new table row

		# print the cell for Assigned Date
		$Body=$Body."\t<td align=\"center\" width=\"10%\">\n";
		$Body=$Body."\t@line_[0]\n\t</td>\n";

		# print the cell for EventDescription
		$Body=$Body."\t<td width=\"45%\">\n";
		$Body=$Body."\t$line_[1]\n\t</td>\n";
	
		# print the cell for Photographer(s)
		$Body=$Body."\t<td width=\"25%\">\n";
		$Body=$Body."\t$line_[2]\n\t</td>\n";
		
		# print the cell for EventDate
		$Body=$Body."\t<td width=\"10%\">\n";
		$Body=$Body."\t$line_[3]\n\t</td>\n";

		# print the cell for DueDate
		$Body=$Body."\t<td width=\"10%\">\n";
		$Body=$Body."\t$line_[4]\n\t</td>\n";

		# close this row
		$Body=$Body."  </tr>\n\n";
	}

	# close the table
	$Body=$Body."</tbody>\n</table>\n\n";

	$IndexFile=$IndexFile.$Body;
	$IndexFile=$IndexFile."</body>\n</html>\n";

	print $IndexFile;
#	if ( open (INDEX, ""))
#	{
#	}
#	else
#	{
#		print STDERR "Can't create the damn html file\n";
#		print STDERR "WTF?\n";
#	}

} # end of main()


#------------------oOo----------------
# makeHeader()
# generate the the header for index.html
sub makeHeader
{
	$MyDate=localtime();
	$IndexFile="<html>\n".
		" <head>\n".
		"  <title>$AssType</title>\n".
		" </head>\n".
		"<body BGCOLOR=\"#8F8F8F\" TEXT=\"#FAFAFA\">\n".
		"<!-- End of Header -->\n".
		"<!--\n".
		" Generated on $MyDate by Tuan Pham \n".
		" Perl source code is available upon request\n".
		"-->\n\n".
		"<br>\n".
		"<font size=\"+3\"><center>$AssType</center></font>\n".
		"<br><br>\n\n";
		
		#"<div ALIGN=\"CENTER\">\n".
		#"<nobr>\n";
}

#-------------------------oOo--------------------------
# End of this script
