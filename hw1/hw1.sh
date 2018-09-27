rm -f /tmp/sahw1.tmp
uname -a >> /tmp/sahw1.tmp
date >> /tmp/sahw1.tmp 
id >> /tmp/sahw1.tmp
service sshd status >> /tmp/sahw1.tmp
zfs list >> /tmp/sahw1.tmp
mail -s '[SAHW1] 0416045' sahw1@nasa.cs.nctu.edu.tw < /tmp/sahw1.tmp
mail -s '[SAHW1] 0416045' j6256448@gmail.com < /tmp/sahw1.tmp
