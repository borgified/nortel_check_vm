#!/usr/bin/env perl

use warnings;
use strict;
use WWW::Mechanize;

my %nortel = do "/secret/nortel.config";

my $nhost		= $nortel{'nhost'};
my $nuserid		= $nortel{'nuserid'};
my $npassword	= $nortel{'npassword'};
my $toemail		= $nortel{'toemail'};
my $servernotifications		= $nortel{'servernotifications'};

sub main{
	&run;
}

&main;



sub run{

	my $url = "https://$nhost/CallPilotManager";

	$ENV{PERL_LWP_SSL_VERIFY_HOSTNAME} = 0;

	my $mech = WWW::Mechanize->new();
	$mech->get($url);

	$mech->submit_form(
			fields          => {
			UserId        => $nuserid,
			Password        => $npassword,
			}
			);

	my $stuff = $mech->content();
#get to main menu
	$stuff=~/window\.location = \"(.*)\&AppCon=/;

	my $sessionid=$1;
	my $mailboxinfo='&AppCon=_mmRAz8mxmmmmmGmmmmLKa';

	my $newurl="https://$nhost".$sessionid.$mailboxinfo;
	$mech->get($newurl);

	$stuff=$mech->content();

	#COS is a field that determines how many minutes of capacity your mailbox has.

	if($stuff=~/5557(.*)none/){
		my $email="
                                                   -Total- --New-- -Unsent-Out
MB       Type  Directory Name         Ext      COS Msg Min Msg Min Msg Min dial
5557$1none\n";

		my $line=$1;
		$line=~/5557\s+\d+\s+(.*)/;
		my($tmsg,$tmin,$nmsg,$nmin,$umsg,$umin)=split(/\s+/,$1);

		if($nmsg>0){

			open(MAIL, "|/usr/sbin/sendmail -t");

			my $from='nortel_phone_system';
			my $subject="total msg: $tmsg, new msg: $nmsg\n";
			my $to=$toemail;


			print MAIL "To: $to\n";
			print MAIL "From: $from\n";
			print MAIL "Subject: $subject\n\n";
		
			print MAIL $email;
		
			close(MAIL);
		}


	}else{
		open(MAIL, "|/usr/sbin/sendmail -t");

		my $from='nortel_phone_system';
		my $subject="script error, unable to find 5557 mailbox within the NUMERIC MAILBOX INFORMATION REPORT\n";
		my $to=$servernotifications;

		print MAIL "To: $to\n";
		print MAIL "From: $from\n";
		print MAIL "Subject: $subject\n\n";
		
		print MAIL "this script checks for voicemails in the versant support queue\n";
		
		close(MAIL);
	}
}
