#!/usr/bin/perl

($hour,$day,$month,$year) = (localtime)[2,3,4,5];

$yyyy=$year+1900;
    $mm=sprintf("%02d",$month+1);
    $dd=sprintf("%02d",$day);

print "--------------  Local time --------\n";
print "year is : $yyyy\n";
print "month is:$mm\n";
print "day is  :$dd\n";
print "hour is :$hour\n";

($hour,$day,$month,$year) = (gmtime)[2,3,4,5];
$yyyy=$year+1900;
    $mm=sprintf("%02d",$month+1);
    $dd=sprintf("%02d",$day);
print "--------------  GMT time --------\n";
print "year is : $yyyy\n";
print "month is:$mm\n";
print "day is  :$dd\n";
print "hour is :$hour\n";

exit
