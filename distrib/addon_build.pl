use strict;
use File::Copy;


################################################################################
#
# Customizable section
#
################################################################################


my($SHORT_NAME) = 'np2setup';
my($USE_LITE) = 0;
my(@VERSION_SOURCE) = qw(../src/Version.h ../src/Version_rev.h);

my($ENTRIES_TEMPLATE) = q(
	[General]
	Title=Notepad2 (Notepad Replacement)
	Version=%s
	BuildDate=%s

	[EditFile]
	@DESTINATION\SVCPACK.INF,SetupHotfixesToRun,AddProgram

	[AddProgram]
	%s
);


################################################################################
#
# Initialize
#
################################################################################


my($CRLF) = "\x0D\x0A";

my(@ARCHS) = ('x86-32', 'x86-64', 'IA-64');

# Normalize the template
$ENTRIES_TEMPLATE =~ s/(?:^\s+|\s+$|\t|\x0D)//sg;
$ENTRIES_TEMPLATE =~ s/\x0A/$CRLF/sg;
$ENTRIES_TEMPLATE .= $CRLF;


################################################################################
#
# get_version_string()
#
################################################################################


sub get_version_string # in( @source_path ), out( $version_string )
{
	my(@source_path) = @_;
	my(@version) = (4,1,24,0); # default 4.1.24.0
	my(@key) = qw(VERSION_MAJOR VERSION_MINOR VERSION_BUILD VERSION_REV);

	my @contents = ();
	foreach my $filename(@source_path) {
		open(INPUT, "<$filename") || last;  # can't open file then break
		push(@contents,<INPUT>);
		close(INPUT);
	}

	for(my $idx = 0; $idx < @key; $idx++) {
		my $tag = $key[$idx];

		foreach(@contents) {
			if(/#define\s*$tag\s*(\d+)/) {
				$version[$idx] = $1;
				last;
			}
		}
	}

	return join('.', @version);
}


################################################################################
#
# get_date_string()
#
################################################################################


sub get_date_string # in( ), out( $date_string )
{
	my(undef, undef, undef, $mday, $mon, $year, undef, undef, undef) = gmtime();
	return(sprintf('%04d/%02d/%02d', $year + 1900, $mon + 1, $mday));
}


################################################################################
#
# main loop
#
################################################################################


foreach my $arch (@ARCHS)
{
	my($source_dir) = "setup.$arch";
	next unless (-d $source_dir);

	my($dest_file) = "$SHORT_NAME.exe";
	my($source_file, $switch);

	if ($USE_LITE)
	{
		$source_file = 'setuplite.exe';
		$switch = '';
	}
	else
	{
		$source_file = 'setupfull.exe';
		$switch = ' /quiet';
	}

	unless (-d 'addon/svcpack')
	{
		mkdir('addon');
		mkdir('addon/svcpack');
	}

	copy("$source_dir/$source_file", "addon/svcpack/$dest_file");

	my($entries_data) = sprintf(
		$ENTRIES_TEMPLATE,
		get_version_string(@VERSION_SOURCE),
		get_date_string(),
		"$dest_file$switch",
	);

	$entries_data =~ s/\@DESTINATION/I386/  if ($arch eq 'x86-32');
	$entries_data =~ s/\@DESTINATION/AMD64/ if ($arch eq 'x86-64');

	open(my $handle, '>', "addon/entries_$SHORT_NAME.ini") or next;
	binmode($handle);
	print $handle $entries_data;
	close($handle);

	system("addon_7z.cmd $source_dir");
}
