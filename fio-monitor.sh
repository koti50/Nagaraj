#/bin/sh
# version 3J - 03/14/2015
# added timestamp, specify options in LSIutil, added "loop" variable
# modified for Juarez manual FIO run

serial=`dmidecode|grep "Serial Number"|head -1|awk '{print $3}'`
echo "Serial Number: " $serial
start=`date +"%m%d-%H%M"`
BASEDIR="/home/dropbox/xp/FIO"
LOGDIR="$BASEDIR/$serial-$start"
DMESGLOGFILE="dmesg-$serial.log"
mkdir $LOGDIR
cd $LOGDIR
echo `pwd` 
# loop=24 means collecting data for 12 hours
loop=47
#loop=3

touch iostat-$serial.log phy-$serial.log $DMESGLOGFILE

echo "========== old dmesg ==========" 
echo "clear dmesg" 
dmesg -c 
echo "fio process" 
ps -ef | grep -i fio 
echo "========== begin fresh `date` ==========" 

#echo "Phy error counts before collecting data" >> phy-$serial.log
#$BASEDIR/lsiutil.x86_64 -p 1 -a 20,12,0,0,0 >> phy-$serial.log
#echo "clear Phy error counts" >> phy-$serial.log
#$BASEDIR/lsiutil.x86_64 -p 1 -a 20,13,0,0,0 >> phy-$serial.log
#echo "=======================================================" >> phy-$serial.log

#echo "getting FW/BIOS version"
#$BASEDIR/lsiutil.x86_64 -p 1 -a 1,0,0 >> phy-$serial.log

#echo "getting link speed"
#echo "
#1
#64


#0
#0" > phy-exp
#$BASEDIR/lsiutil.x86_64 < phy-exp >> phy-$serial.log

i=1
while [ $i -le $loop ]
do
   echo $i
   date 
##   iostat -ztxm 5 3 >> iostat-$serial.log
   iostat -ztxm 15 4 >> iostat-$serial.log

#   echo " "  >> phy-$serial.log
#   echo "========== `date` " >> phy-$serial.log
#   $BASEDIR/lsiutil.x86_64 -p 1 -a 20,12,0,0,0 >> phy-$serial.log 

   if [ $i -lt $loop ]; then
 ##     sleep 15
      sleep 1800
   else
      echo "done"
   fi
   i=`expr $i + 1`
done

dmesg >> $DMESGLOGFILE
echo "========== end `date` ==========" 
ps -eo pid,cmd,etime | grep fio

