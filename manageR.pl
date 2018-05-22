#!/usr/bin/perl
#
#Mon Mar 24 10:43:52 2014

use TempFileNames;
use Data::Dumper;

# default options
$main::d = { 'repository' => 'http://cran.r-project.org/src/base/',
	'fileTemplate' => 'R-$MAJOR/R-$VERSION.tar.gz', 'workingDir' => '~/tmp/Rinstall',
	download => 1
};
# options
$main::o = [ '+install=s', '+activate=s', '+deactivate', 'repository=s', 'download!' ];
$main::usage = '';
$main::helpText = <<HELP_TEXT.$TempFileNames::GeneralHelp;
	Examples:
	manageR.pl --install=3.0.3
	manageR.pl --no-download --install=3.0.3
	manageR.pl --activate=3.0.3
	manageR.pl --deactivate

HELP_TEXT

sub install { my ($o) = @_;
	Log(Dumper($o), 5);
	my $version = $o->{install};
	my ($major, $minor, $path) = ($version =~ m{(\d+)\.(\d+)\.(.*)}so);
	my $url = mergeDictToString( { '$MAJOR' => $major, '$VERSION' => $version},
		"$o->{repository}/$o->{fileTemplate}");
	Log("Fetching from: $url", 3);
	my $to = mergeDictToString({ '~' => $ENV{HOME} }, $o->{workingDir});
	Log("Fetching to: $to", 4);
	Mkpath($to, 4);
	my $toQ = qs($to);
	my $urlS = splitPathDict($url);
	my $file = mergeDictToString( { '$MAJOR' => $major, '$VERSION' => $version}, "$o->{fileTemplate}");
	my ($base) = ($file =~ m{([^/]*).tar.gz}so);
	System("cd $toQ ; wget $url", 4) if ($o->{download});

	# export RVERSION=R-2.15.3
	# export RVERSION=R-3.0.1
	# export RVERSIONNUM=`echo $RVERSION| cut -d'-' -f 2`
	# cd $HOME/tmp/foreign
	# umask -S u=rwx,g=rwx,o=rwx ; tar xzf ~/Downloads/$RVERSION.tar.gz ; cd $RVERSION ; ./configure --enable-R-shlib --with-tcltk ; make -j8
	# umask -S u=rwx,g=rwx,o=rwx ; sudo make install rhome=/usr/local/lib64/$RVERSION
	# umask -S u=rwx,g=rwx,o=rwx ; sudo cp /usr/local/bin/R /usr/local/bin/R-$RVERSIONNUM ; sudo cp /usr/local/bin/Rscript /usr/local/bin/Rscript-$RVERSIONNUM

	System("umask -S u=rwx,g=rwx,o=rwx ; cd $toQ ; tar xzf $base.tar.gz ; cd $base ; ./configure --enable-R-shlib --with-tcltk --prefix=$ENV{HOME} ; make -j4", 4) if (1);
	System("umask -S u=rwx,g=rwx,o=rwx ; cd $toQ/$base ; make install rhome=$ENV{HOME}/lib64/$base", 3) if (1);
	System("umask -S u=rwx,g=rwx,o=rwx ; cp ~/bin/R ~/bin/R-$version ; cp ~/bin/Rscript ~/bin/Rscript-$version", 3);
}

sub activate { my ($o) = @_;
	my $version = $o->{activate};

	if (!-e "$ENV{HOME}/bin/R-$version") {
		Log("Requested R version $version is not installed. Consider installing it with 'manage.R --install=$version'", 2);
		exit(100);
	}
	System("umask -S u=rwx,g=rwx,o=rwx ; cp ~/bin/R-$version ~/bin/R  ; cp ~/bin/Rscript-$version ~/bin/Rscript", 4);
	Log("R version: $version activated.", 2);
}

sub deactivate { my ($o) = @_;
	if (!-e "$ENV{HOME}/bin/R") {
		Log("No R version is currently activated in the home directory. Consider installing or activating a version first.", 2);
		exit(100);
	}
	System("rm ~/bin/R  ; cp ~/bin/Rscript", 4);
	Log("R version in home directory deactivated.", 2);
}

#main $#ARGV @ARGV %ENV
	initLog(3);
	my $c = StartStandardScript($main::d, $main::o, triggerPrefix => '');
exit(0);
