#!/usr/bin/perl -w
# generate/render ASCII GRAPHICS file (e.g demo.asg) to SVG format Version:1.0
# Author: Jurij Kostasenko , Copyright 2021 , Released under MIT license
###############################################################################
#= INFO:
#= asg2svg.pl -c demo.asg
#= -c     : Auto Scale for SVG Image
#= -b     : no Background
#= -x     : remove spaces at the end, for clean input
#= -s     : sort the SVG file line,polygon,circle,text
#=        #> ./asg2svg.pl -s demo.svg > demo_sort.svg
#= e.g. to get demo.asg run> ./asg2svg.pl -demo 
$mod=$mod1=$mod2=0;
while ($_ = $ARGV[0]) {
        shift(@ARGV);
        if ( /^\-c$/ ) {
                $mod=1;
                next;
        }
        elsif ( /^\-b$/ ) {
                $mod1=1;
                next;
        }
        elsif ( /^\-x$/ ) {
                $mod2=1;
                next;
        }
        elsif ( /^\-s$/ ) {
                system "grep -A8 '<?xml' $ARGV[0] ; grep  'line' $ARGV[0] ; grep 'polygon' $ARGV[0] ; grep 'circle' $ARGV[0] ; grep 'text' $ARGV[0] "; 
                print "</g></svg>\n"; exit 0;
        }
        elsif ( /^\-h$/ ) {
                system "grep -e '^#=' $0 | sed s/#=//"; exit 0;
        }
        elsif ( /^\-demo$/ ) {
                system "grep -e '^#+' $0 | sed s/#+//  > demo.asg ";
                system "$0 -c demo.asg > demo.svg ";
                system "$0 -s demo.svg > demos.svg";
                print STDERR "# NOTE [$0]: Image generated ..: s.  demo.svg & demos.svg"; exit 0 ;
        }
        else {
               if ( $_ =~ /\w+\.asg/ ) {$file = $_ } else {die "# ERROR [$0]: No asg file $_ ?\n# INFO [$0]: $0 -h \n";};
        }
}
if ( ! defined($file) ) {die "# ERROR [$0]: No asg file ?\n# INFO [$0]: $0 -h \n"};

$string_len=0;
$svg_str = ""; # string for the svg
if ($mod2) { # just to help, clean the asg file : use system commands! this option is system dependend (e.g bash shell)
  system "cp $file org_$file ; expand --tabs=4 $file > clean_${file}";
  $command= "sed -i -e :a -e '/^\\n*\$/{\$d;N;ba' -e '}' clean_$file";
  system "$command" ; print STDERR "# NOTE [$0]: remove all tabs & spaces @ the End of File (clean_$file)" ; exit 0;
} # get clean input

open(FILE, "<./$file") or die "# ERROR [$0]: Can't read asg file: \"${file}\" ($!) \n# INFO [$0]: $0 -h \n";

while (<FILE>) {
push(@file_array,$_);
 $string_len = length($_),if (length($_) > $string_len);
}
$string_len--;
close(FILE);
$idCol=0;
$idRow=0;
$x = 10;
$y = 10;
$hlen = 15;  # lentgh of line in X dir ->
$vlen = 15;  # lentgh of line in Y dir |<?
$lwith = 2;
$col_line=" stroke=\"black\" stroke-width=\"$lwith\" ";
$cr_div = 4;
$col_cr=' style="fill:rgb(0,200,60);stroke-width:1;stroke:rgb(0,0,50)" ';
$lines = $#file_array;
$col_txt=' font-family="monospace" fill="Navy" font-weight="bold"  font-size="16.00" ';
$auto_winX=600;
$auto_winY=800;
$autoX=($string_len) * ($hlen + 1);
$autoY=($lines+10) * $vlen;

if ($mod) {
        $auto_winX=$autoX;
        $auto_winY=$autoY;
}
$svg_str .= sprintf <<EOF;
<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
<!DOCTYPE svg PUBLIC "-//W3C//DTD SVG 1.1//EN" "http://www.w3.org/Graphics/SVG/1.1/DTD/svg11.dtd">
<!-- Generated with $0 from ASCII GRAPHICS file: $file -->
<!-- Title: ASCII Graphics SIZE: $auto_winX x $auto_winY ROW,COL: $#file_array , $string_len -->
<!-- Options: -c $mod  -k $mod1 Author: Jurij Kostasenko -->
<svg width="${auto_winX}pt" height="${auto_winY}pt" viewBox="0.00 0.00 ${auto_winX}.00 ${auto_winY}.00" xmlns="http://www.w3.org/2000/svg">
<g id="ASG0" class="ASG2SVG" transform="scale(1 1) rotate(0) translate(6 8)">
EOF
if (!$mod1) { 
$svg_str .= sprintf <<EOF;
<!-- green background as rectangle -->
<rect width="$auto_winX" height="$auto_winY" style="fill:rgb(200,250,200);stroke-width:2;stroke:rgb(0,80,0)" />
EOF
}

for $i ( 0 .. $#file_array ){
        $idRow++;
        $idCol = 1;
        @cln = split(//,$file_array[$i]);
        #if ($i == $#file_array) { &gen_svg(1);}
        #else {&gen_svg(0);}
        {&gen_svg(0);}
}
$svg_str .= sprintf <<EOF;
</g>
</svg>

EOF
print "$svg_str";
if ( $auto_winX < $autoX || $auto_winY < $autoY) {
 print STDERR "# NOTE: your graphics is bigger than normal size \n use -c option : $0 -c $file"
}
exit 0;
###############################################################################
sub gen_line{
my ($xpos1,$ypos1,$xpos2,$ypos2) = @_;
  $svg_str .= sprintf(" <line id=\"r${idRow}_c${idCol}\" x1=\"%d\" y1=\"%d\" x2=\"%d\" y2=\"%d\" $col_line />\n",$xpos1,$ypos1,$xpos2,$ypos2);
  $idCol++;
}
###############################################################################
sub gen_crl{
my ($xpos,$ypos,$rad) = @_;
my $joker = $col_cr;
  $joker = ' style="fill:rgb(200,0,60);stroke-width:1;stroke:rgb(0,0,50)" ', if ( $cln[$i+1] eq "?");
  $svg_str .= sprintf(" <circle id=\"r${idRow}_c${idCol}\" cx=\"%d\" cy=\"%d\" r=\"%d\" $joker />\n",$xpos, $ypos,$rad);
  $idCol++;
}
###############################################################################
sub gen_arr{
my ($xpos,$ypos) = @_;
my $len = 5;
my $joker = "transform=\"rotate(0, $xpos, $ypos) \"";
if ( $cln[$i+1] eq "?") {
  $joker = "transform=\"rotate(90, $xpos, $ypos) \"";
  $ypos = $ypos - $len;
} else {
  $ypos = $ypos - $len;
  $xpos = $xpos + 2*$len;
}
  $svg_str .= sprintf(" <polygon id=\"r${idRow}_c${idCol}\" points=\"%d,%d,%d,%d,%d,%d\" style=\"fill:lime;stroke:green;stroke-width:2\" $joker/>\n",$xpos,$ypos,$xpos+$len,$ypos+$len,$xpos,$ypos+2*$len);
  $idCol++;
}
###############################################################################
sub gen_arl{
my ($xpos,$ypos) = @_;
my $len = 5;
my $joker = "transform=\"rotate(0, $xpos, $ypos) \"";
if ( $cln[$i+1] eq "?") {
  $joker = "transform=\"rotate(90, $xpos, $ypos) \"";
  $ypos = $ypos - $len;
} else {
  $ypos = $ypos - $len;
  $xpos = $xpos - 2*$len;
}
  $svg_str .= sprintf(" <polygon id=\"r${idRow}_c${idCol}\" points=\"%d,%d,%d,%d,%d,%d\" style=\"fill:lime;stroke:green;stroke-width:2\" $joker/>\n",$xpos,$ypos,$xpos-$len,$ypos+$len,$xpos,$ypos+2*$len);
  $idCol++;
}
###############################################################################
sub gen_text{
my ($xpos,$ypos,$text) = @_;
my $len = $hlen;
  $ypos = $ypos + $len/2;
  $svg_str .= sprintf("<text id=\"r${idRow}_c${idCol}\" text-anchor=\"middle\" x=\"%d\"  y=\"%d\" $col_txt >%s</text>\n",$xpos, $ypos,$text);
}
###############################################################################
sub gen_svg{
my ($last_line) = @_;
my $relX = 0;
my $relY = 0;
# $i is global for all sub geg_*
for $i ( 0 .. $#cln ){
  if ($cln[$i] eq "-" ) {
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY);
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "\+" ) {
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY);
    gen_line($x+$relX, $y+$relY,$x+$relX, $y+$relY-$vlen);
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "\." ) {
    $lwith = 1;$col_line=" stroke=\"black\" stroke-width=\"$lwith\" ";
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY);
    $lwith = 2;$col_line=" stroke=\"black\" stroke-width=\"$lwith\" ";
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "=" ) {
    $lwith = 3;$col_line=" stroke=\"blue\" stroke-width=\"$lwith\" ";
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY);
    $lwith = 2;$col_line=" stroke=\"black\" stroke-width=\"$lwith\" ";
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "*" ) {
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY), if ($cln[$i+1] eq "|" || $cln[$i+1] eq "-" || $cln[$i+1] eq ".");
    if ($cln[$i+1] eq "|" ) { gen_crl($x+$relX+($hlen),$y+$relY,$hlen/$cr_div); }
    elsif ($cln[$i-1] eq "|" ) {gen_line($x+$relX-$hlen, $y+$relY,$x+$relX, $y+$relY); gen_crl($x+$relX-($hlen),$y+$relY,$hlen/$cr_div); }
    else { gen_crl($x+$relX,$y+$relY,$hlen/$cr_div); }
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq ">" ) {
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY),if ($cln[$i+1] eq "|" || $cln[$i+1] eq "-" || $cln[$i+1] eq ".");
    gen_arr($x+$relX,$y+$relY);
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "<" ) {
    gen_line($x+$relX-$hlen, $y+$relY,$x+$relX+$hlen, $y+$relY),if ($cln[$i+1] eq "|" || $cln[$i+1] eq "-" || $cln[$i+1] eq ".");
    gen_arl($x+$relX,$y+$relY);
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "\\" ) {
    gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY);
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq "/" ) {
    $relX = $relX + $hlen;
  }
  elsif ($cln[$i] eq ":" ) {
    $lwith = 1;$col_line=" stroke=\"black\" stroke-width=\"$lwith\" ";
    # line Y
    gen_line($x+$relX, $y+$relY,$x+$relX, $y+$relY+$vlen);
    if ($i < ($#cln -1)) { # line X
        if ($cln[$i+1] ne " ") {
          gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY), if ($cln[$i+1] eq "|" || $cln[$i+1] eq "-" || $cln[$i+1] eq "\.");
        }
    }
    $relX = $relX + $hlen;
    $lwith = 2;$col_line=" stroke=\"black\" stroke-width=\"$lwith\" ";
  }
  elsif ($cln[$i] eq "|" ) {
    # line Y
    gen_line($x+$relX, $y+$relY,$x+$relX, $y+$relY+$vlen);
    if ($i < ($#cln -1)) {
        if ($cln[$i+1] ne " ") {
          gen_line($x+$relX, $y+$relY,$x+$relX+$hlen, $y+$relY), if ($cln[$i+1] eq "|" || $cln[$i+1] eq "-" || $cln[$i+1] eq "/");
        }
    }
    $relX = $relX + $hlen;
  }
  else {
    gen_text($x+$relX,$y+$relY,$cln[$i]), if ($cln[$i] =~ /[0-9a-zA-Z_!'"#(){},;%^~]/);
    $relX = $relX + $hlen;  # move x pos
    $idCol++;
  }
 }
 $y += $vlen; # new y pos for the next lines
}
###############################################################################
###############################################################################
#+  DEMO for *asg (ASCII GRAPHICS)
#+ ===============================
#+            |-|          |---|
#+ |---|      |R|          |   |
#+ |ROM|<....>|A|*--------*|CPU|
#+ \-|-/      |M|<-------->|   |
#+   :....:.....           \-|-/
#+   :<-->|   distance       *?
#+    D{t}:<---------------->|
#+        *
#+
#+ |---|   |---|   |---|
#+ |TOP|   |TOP|   |TOP|
#+ \-|-/   \-|-/   \-|-/
#+   >?      <?      >?
#+ |-+-|   |-+-|     <?
#+ |BOT|   |BOT|   |-+-*|
#+ \---/   \-|-/   |BOT |
#+           *     \-|--/
#+                   *?
#+    ||||||
#+ ||||    |
#+ --------/
#+
#+ ||||
#+ ||||  ||||                 |-|-|
#+ ||||  ||||  ||||  |||  ||  |A|B|
#+ \--/  \--/  \--/  \-/  \/  \---/
#+
#+   ABCDEFGH
#+ 7|||||||||
#+ 6|||||||||
#+ 5|||||||||
#+ 4|||||||||
#+ 3|||||||||
#+ 2|||||||||
#+ 1|||||||||
#+ 0|||||||||
#+  \-------/
#+
#+  Char Set
#+ =========
#+ abcdefghijklmnopqrstuvwxyz
#+ ABCDEFGHIJKLMNOPQRSTUVWXYZ
#+ 1234567890 _!'"#(){},;%^~
#+
#+ *?> NOTE remove all TABs from ASG File <
#+
#+     
#+ :: :| :||  ||:|||
#+
#+  t0 t1 t2 t3 t4 t5 t6 t7 t8
#+  .  .  .  .  .  .  .  .  .
#+   : : : : : : : : : : : : :
#+    || || || || || || || ||
#+     \-/\-/\-/\-/\-/\-/\-/\
#+
#+
#+   |-| |-| |-| |-| |-| |-| |
#+     \-/ \-/ \-/ \-/ \-/ \-/
#+
#+
#+   |-| |-| |-| |-| |-| |-| |
#+   | | | | | | | | | | | | |
#+     \-/ \-/ \-/ \-/ \-/ \-/
#+
#+   |-| |-| |-| |-| |-| |-| |
#+   | | | | | | | | | | | | |
#+   | | | | | | | | | | | | |
#+     \-/ \-/ \-/ \-/ \-/ \-/
#+
#+   : : : : : : : : : : : : :
#+
#+         Process Time
#+   |<--------------------->|
#+
#+ SOURCE_CLK 
#+   |---|       |---|
#+   |   |       |   |
#+   |   |       |   |
#+   |   \---:---/   \---:---:
#+
#+ PHASE_CLK 
#+       |---|       |---|
#+       |   |       |   |
#+       |   |       |   |
#+   |---/   \---|---/   \---:
#+
#+ INTERVAL_CLK 
#+           |---|       |---|
#+           |   |       |   |
#+           |   |       |   |
#+   |---|---/   \---|---/   \---|
#+   |                           |
#+   <?                          >?
#+
#+ <? >? *  *? + ->*| -*>| >* >*<*<
#+ 
#+ > < -  .  | |  :  \-   -/ >| |<      10V
#+ <> ><  >> * *?  <<                   *|*
#+                               5V      |
#+   fancy         Vcc          *|*?    s|
#+    box     |    *|*           |     g|*
#+  |*->-*|-->|<----|*-----|*----|*--|->|<?T1
#+  |<:::>|       ----    |-|   |-|  |  *|
#+  |*---*|      C--|-    |R|   |L|  |  d|
#+  \*-|*-/         |     | |   | |  |   |-
#+     <?           *?    \|/   \|/  |   |
#+                         |     |   |  |*
#+                         *?   -+   +->|>?T0
#+                              Vss     *|
#+                                       |
#+                                      -+
#+
#+           char elements
#+   ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#+   _________________________________
#+
#+           line elements
#+  ----------------------------------
#+  ..................................
#+  ==================================
###############################################################################
###############################################################################
