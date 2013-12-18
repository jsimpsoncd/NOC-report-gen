#!/usr/bin/perl
use strict;
use warnings;
use RTF::Writer;
use Getopt::Std;
use Text::CSV;
use Data::Dumper;

#######################################################################################################
#                                Zenoss Image Export Tool with RTF report writer                      #
# This PERL script will export JPEG images of the graphs that you need from Zenoss, and create an     #
# RTF report file containing them.                                                                    #
#                                                                                                     #
# Version 1.1 Jon Simpson, November 2013                                                              #
# Based on http://community.zenoss.org/thread/11871 by Lance Wilson / WebGuy Internet                 #
#   You may freely distribute and modify this script provided original author is credited for his     #
#   contribution to the project.                                                                      #
#                                                                                                     #
# This script requires the PERL Library Getopt::Std, RTF::Writer and GNU's WGET binary to function.   #
#######################################################################################################
my $basedir = './'; # Basedir the the real system directory on the machine running this script where everything is at.
my $logfile = 'last_output.log'; 	# Name of the logfile, leave blank if not needed.

my $server;
my $name;
my $i;
my @pix;
my %options;
my $pix;
my @split;
my $cmdline;
my $resimg;
`bash fetch.sh`;
# First let's get to the correct place to start.
# This is the directory where you want the images to be dumped to.
chdir($basedir);

sub usage() {
print STDERR << "EOF";

Usage: pullImage.cgi -q


Command Line Arguments

  -q	Keep the script quiet! eg. no output.

EOF
exit(0);
}

# Start the Main Program
# ---------------------------------------------------
`python event_report.py`;
# Let's get our arguments if there are any.
# like the shell getopt, "d:" means d takes an argument
getopts("q",\%options) or usage();

if($logfile ne ''){
  # Let's remove the old logfile.
  unlink($logfile);

  # Add a seperator in the Log file for readability.
  open LOGFILE, ">>$logfile" or die "cannot open logfile $logfile for append: $!";
  print LOGFILE "-" x 50 ."\n";
}
#Load all graph ID's into an array.
print "Fetching images.\n";
if($logfile ne ''){
  close LOGFILE;
}

if(!($options{q})){
	print "$i images were fetched successfully.\n";
}
print "Generating rtf.\n";
unlink('dailynoc.rtf');
my $rtf = RTF::Writer->new_to_file("dailynoc.rtf");
$rtf->prolog( 'title' => "NOC Report", 'colors' => [ undef, [0,142,252], [50,200,0]]);
#$rtf->number_pages;
$rtf->paragraph(
	\'\fs40\b\i',  # 20pt, bold, italic
	"Incidents"
);
$rtf->paragraph("* Channels look normal for the day.");

$rtf->paragraph("* SBC Dialogs look normal for the day.");
$rtf->paragraph();
$rtf->paragraph(
	\'\fs40\b\i',  # 20pt, bold, italic
	"Device Utilization"
);
$rtf->paragraph(\'\cf2',"Bit Rate = OK");
$rtf->paragraph(\'\cf2',"CPU % and Load = OK");
$rtf->paragraph(\'\cf2',"Real Memory Usage = OK");
$rtf->paragraph(\'\cf2',"Internet Bandwidth = OK");
$rtf->paragraph(\'\cf2',"PRI Channel Usage = OK");
$rtf->paragraph(\'\cf2',"SBC Active Dialogs = OK");
$rtf->paragraph(\'\cf2',"SBC Data = OK");
$rtf->Page();

$rtf->paragraph(
	\'\fs40\b\i',  # 20pt, bold, italic
	"Portal Health"
);
$rtf->paragraph(
"HTTPD Workers",
$rtf->image( 'filename' => "./tmp/w6httpds.png", ),
);
$rtf->Page();
my $eventstable = RTF::Writer::TableRowDecl->new('widths' => [1500,2000], 'borders' => [1,1,1,1]);
$rtf->row($eventstable, [\'\fs25\b',"Sev"],[\'\fs25\b',"Time"],[\'\fs25\b',"Device"], [\'\fs25\b',"Class"], [\'\fs25\b',"Description"]);
my $file = "./tmp/eggs.csv";
open my $fh, "<", $file or die "$file: $!";

my $csv = Text::CSV->new ({
	binary    => 1, # Allow special character. Always set this
	auto_diag => 1, # Report irregularities immediately
	});
while (my $row = $csv->getline ($fh)) {
	print Dumper($row);
	$resimg = 6 - $row->[0];
	print "./resources/severity-spritef".5-$resimg."-0.png\n";
	$rtf->row($eventstable, [\'\fs15\b',$rtf->image( 'filename' => "./resources/severity-spritef".$resimg."-0.png")], [\'\fs15\b',$row->[1]], [\'\fs15\b',$row->[2]], [\'\fs15\b',$row->[3]], [\'\fs15\b',$row->[4]]);
}
close $fh;
$rtf->Page();
$rtf->paragraph(
	\'\fs40\b\i',  # 20pt, bold, italic
	"Bandwidth"
);
$rtf->paragraph(
"COMCAST",
$rtf->image( 'filename' => "./tmp/Comcast.png", ),
);
$rtf->paragraph(
"INTERNAP",
$rtf->image( 'filename' => "./tmp/INTERNAP.png", ),
);
$rtf->paragraph(
"LEVEL3",
$rtf->image( 'filename' => "./tmp/LEVEL3.png", ),
);
$rtf->paragraph(
"emarc T1",
$rtf->image( 'filename' => "./tmp/emarc.png", ),
);
my $decl = RTF::Writer::TableRowDecl->new('widths' => [1500,2200], 'borders' => [1,1,1,1]);
$rtf->paragraph();
$rtf->row($decl, [\'\fs40\b',"Carrier"],  [\'\fs40\b',"Capacity"],  [\'\fs40\b',"Bursting"]);
$rtf->row($decl, "Comcast", '200 Mbps', 'No Burst');
$rtf->row($decl, "Level 3", '500 Mbps', '1Gbps Burst');
$rtf->row($decl, "InterNAP", '500 Mbps', '1Gbps Burst');
$rtf->paragraph();
$rtf->paragraph(\'\cf2',"CoreDial HQ Voice T1 Utilization = OK");
$rtf->Page();

$rtf->paragraph(
	\'\fs40\b\i',  # 20pt, bold, italic
	"Voice Usage"
);
$rtf->paragraph(
"AGW Channels",
$rtf->image( 'filename' => "./tmp/Channels.png", ),
);
$rtf->paragraph("Channels look normal for the day");
$rtf->paragraph();
$rtf->paragraph(
"OpenSIPS Dialogs",
$rtf->image( 'filename' => "./tmp/Dialogs.png", ),
);
$rtf->paragraph("SBC Dialogs look normal for the day.");
$rtf->Page();

$rtf->paragraph(
	\'\fs40\b\i',  # 20pt, bold, italic
	"API"
);
$rtf->paragraph(
"API Presense Response Times",
$rtf->image( 'filename' => "./tmp/API.png", ),
);
$rtf->paragraph("Channels look normal for the day");
$rtf->close;
print "rtf complete.\n";
`soffice dailynoc.rtf &`;




