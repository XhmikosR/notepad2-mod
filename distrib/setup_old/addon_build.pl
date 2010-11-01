use strict;
use File::Copy;


################################################################################
#
# Customizable section
#
################################################################################


my($SHORT_NAME) = 'np2setup';
my($USE_LITE) = 0;
my($VERSION_SOURCE) = 'version.h';

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


sub get_version_string # in( $source_path ), out( $version_string )
{
	my($source_path) = @_;

	my($buffer);

	open(my $handle, '<', $source_path) or return('');
	binmode($handle);
	read($handle, $buffer, -s $handle);
	close($handle);

	if ($buffer =~ /\s(\d+,\d+(?:,\d+){0,2})\s/s)
	{
		$buffer = $1;
		$buffer =~ s/,/./sg;
		return($buffer);
	}
	else
	{
		return('');
	}
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
		get_version_string($VERSION_SOURCE),
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
