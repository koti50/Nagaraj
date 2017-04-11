#/bin/bash
###############################################################
#              Arcee  RVI FIO configuration file              #
#              nagaraja.gowder.malatesha@hpe.com              #
#              Date:  1/20/2017                               #            
###############################################################
# setting up the configuration file for running the fio on differnt fan speed 
rm -f FIO_BW_SEQ_WRITE_1MB
cp -f fio_bw.TXT FIO_BW_SEQ_WRITE_1MB
OSdrive=`cat /proc/partitions | grep -e sd.1 -e sd..1  /proc/partitions | awk '{print$4}'`
#echo $OSdrive
OSdrv=`echo $OSdrive | tr -d '0123456789'`
#echo $OSdrv
Serial=`hdparm -I /dev/sd* | grep -i "Serial Number" | awk '{print$3}'`
sdlist=`hdparm -I /dev/sd* | grep -i "/dev/" | cut -d '/' -f3 |tr -d ':0123456789'`
HDD_Sernum=(${Serial// /})
HDD_Sdd=(${sdlist// /})
len_sdd=${#HDD_Sdd[@]}
#echo $len_sdd
#echo $sdlist

for ((i=0;i <= $len_sdd; i++)); do

	if [ "$OSdrv" == "${HDD_Sdd[$i]}" ]
	then
		continue 
	fi
	echo -e "${HDD_Sdd[i]}  :  ${HDD_Sernum[i]}" >> sdlist.TXT
done

drive_ST=$(./lsscsi | grep -i "ST")
drive_HGST=$(./lsscsi | grep -i "HGST")

if [ "$drive_ST" != "" ]
then
  	echo "SGT DRIVES DETECTED"
	drive_type="ST"

elif [ "$drive_HGST"i != "" ]
then 
	echo "HGST DRIVES DETECTED"
	drive_type="HGST"
else
	echo "NO HGST or ST  DRIVES DETECTED"
	drive_type="NOTYPE"
	
fi

if [ $drive_type == "ST" ]
then
	drives=`./lsscsi | grep ST | awk '{print$6}'`

elif [ $drive_type == "HGST" ]
then 
	drives=`./lsscsi | grep  HGST | awk '{print$6}'`
fi

echo "     " >> FIO_BW_SEQ_WRITE_1MB
echo "     " >> FIO_BW_SEQ_WRITE_1MB
echo "     " >> FIO_BW_SEQ_WRITE_1MB

for driv in $drives
do
	job=`echo $driv | cut -d '/' -f 3`
	if [ "$OSdrv" == "$job"  ]
	then
		continue 
        fi
	echo "[job$job]" >> FIO_BW_SEQ_WRITE_1MB	
	echo "filename=$driv" >> FIO_BW_SEQ_WRITE_1MB
	echo "  " >> FIO_BW_SEQ_WRITE_1MB
done
	echo "; --end job file --" >> FIO_BW_SEQ_WRITE_1MB
