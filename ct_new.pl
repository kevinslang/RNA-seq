#!/usr/bin/perl

$gff_file = $ARGV[0];
$alignRead_file = $ARGV[1];
my $allcounts =0;

open(GFF2TXT,$gff_file) || die("Could not open gff2 file!");
  my @gffs;
  my $m = 0;

  while(<GFF2TXT>){
   chomp;
   push @gffs, $_;
  }
  close(GFF2TXT);

  open(ALIGNREADS,$alignRead_file) || die("Could not open reads file!");
  my @reads;
  while(<ALIGNREADS>){
   chomp;
   push @reads, $_;
  }
  close(ALIGNREADS);

  my $gffsize = @gffs;
  #my $m=0;
  my $rdsize = @reads-1;
  my $x = 1;

  for($i=0;$i<$gffsize;$i++){
    @gfs = split("\t",$gffs[$i]);
    $gfbb = $gfs[3];
    $gfee = $gfs[4];
    $len = $gfee-$gfbb;
    my $num = 0;
    $inexon = 1;
    my $gfb =0;
    my $gfe =0;
    # my $x=0;

    while($inexon == 1){
     @readline = split("\t",$reads[$m]);
     $rd = $readline[1];
     $ps = $readline[3];
#print "ps: "."$ps\n";
#print "rd: "."$rd\t";
#print "gfbb: "."$gfbb\t";
#print "gfee: "."$gfee\n";

     if($ps eq "+"){
        $gfb = $gfbb;
        $gfe = $gfee-35;
        }
     elsif($ps eq "-"){
        $gfb = $gfbb;
        $gfe = $gfee+35;
       }
     if($rd >= $gfb && $rd <= $gfe){
           $num++;
       }
     elsif($rd > $gfe || $x >= $rdsize){   ## the two files must be sorted
      #print "gfe = ".$gfe."\n";
      $ids = $gffs[$i];
      @idss = split("GeneID:",$ids);
      $gid = $idss[1];
      @gis = split(";",$gid);
      $gi = $gis[0];
      $am = $num/$len;
      $ampl = $am*70;
      $rpkm = $num/(($len/1000)*($rdsize/1000000));
      print $gi."\t".$num."\t"."$len"."\t"."$rpkm"."\t"."$am"."\t"."$ampl\n";
      #print $gi."\t".$num."\t"."$rpkm"."\t"."$am"."\t"."$ampl\n";
      $allcounts = $allcounts+$num;
      $inexon = 0;
      $am = 0;
      $rpkm = 0;
      $ampl = 0;
      last;
      }
     $x++;
     $m++;
    }#while
  }#for

print "all read counts = ".$allcounts."\n";
#print "gff size: ".$gffsize."\n";
#print "all read  = ".$m."\n";
exit;


