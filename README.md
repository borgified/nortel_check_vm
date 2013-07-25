this doesnt actually retrieve your voicemail but it checks whether you have messages waiting (sends out email to let you know)

this is useful because for our older phone system since there's no indication that there are new voicemails on a mailbox that isnt connected directly to a phone.

cvm_always_send.pl is meant to be run once a day (9AM) so that if something goes wrong and causes cvm to silently fail, then we will know.

cvm.pl runs hourly (cron) from 10AM to 6PM and only sends email if there arenew voicemails waiting.
