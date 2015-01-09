#!/usr/bin/perl

$file = $ARGV[0];

open(TXT,$file) || die("Could not open gff2 file!");
my @lines;
$line = <TXT>;

  while($line){

   @lines = split("\t", $line);
   if($lines[2] =~ m/CDS/){
     print $line;
    }
   $line = <TXT>;
  }

