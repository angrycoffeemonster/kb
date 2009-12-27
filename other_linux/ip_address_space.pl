#!/usr/bin/perl

# Remember to install package perl-netaddr-ip

use NetAddr::IP;

my $iface = $ARGV[0];

my $ip = `ifconfig $iface | awk 'NR==2 {print\$2}'| awk -F: '{printf \$2}'`;
my $subnet = `ifconfig $iface | awk 'NR==2 {print \$4}'| awk -F: '{printf \$2}'`;

my $ip_addr_space = new NetAddr::IP($ip, $subnet);

my $l = join("\n", @$ip_addr_space);
$l =~ s/\/32//g;
print $l;

