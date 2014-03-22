#!/usr/bin/perl
#

# code taken from:
# http://tex.stackexchange.com/questions/83663/utility-to-strip-comments-from-latex-source

use strict 'vars';
&MAIN(@ARGV);
sub MAIN {
   my ($filehandle) = @_;

   open FILE, "<$filehandle";
   my @doc = <FILE>;
   close FILE;

   &removeComments(\@doc);

   foreach my $line ( @doc ){
      print $line;
    }

   return 1;
}

sub removeComments {
   my ($docarray) = @_;

   my $isCommentEnvironment  = "no";
   my $isVerbatimEnvironment = "no";

   my @newdoc;

   foreach my $line ( @{$docarray} ){
      $isVerbatimEnvironment = "yes" if ( $line =~ /^\\begin{verbatim}/ );
      $isCommentEnvironment  = "yes" if ( $line =~ /^\\begin{comment}/ );
      if ( ($isVerbatimEnvironment eq "no") && ($isCommentEnvironment eq "no") ){
     next if ($line =~ /^%/);
     ## Temporarily replace "%" that you want to keep with a dummy string
     ## that does not appear elsewhere in your document.  Then, remove remainder
     ## of lines that still contain "%".
     if ( $line =~ /\\%/){
        $line =~ s/\\%/TMP::PERCENT/g;
        $line =~ s/\s*%.+//;
        $line =~ s/TMP::PERCENT/\\%/g;
      } else {
         $line =~ s/\s*%.+//;
       }
     push @newdoc, $line;
       }
      push @newdoc, $line if ( $isVerbatimEnvironment eq "yes" );

      $isVerbatimEnvironment = "no" if ( $line =~ /^\\end{verbatim}/ );
      $isCommentEnvironment  = "no" if ( $line =~ /^\\end{comment}/ );
    }

   @{$docarray} = @newdoc;
   return 1;
 }  
