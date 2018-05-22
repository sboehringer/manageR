# Purpose

Perl script to manage parallel installs of different R versions.

# Install

```
git clone https://github.com/sboehringer/manageR
cd manageR
mkdir -p ~/bin
ln -s `pwd`/manageR.pl ~/bin
echo 'export PERL5LIB=$PERL5LIB:'`pwd` >> ~/.bashrc
# optional if bin not already in path
echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
manageR.pl --help
```

Check your ```.bashrc``` as it might exit early and the added lines should be moved up.
