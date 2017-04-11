#/bin/bash
FANNUM=`cat setfanspeed | grep -i fanspeed|cut -d ':' -f2`
FANSPEED=(${FANNUM//  /})
loopsize=${#FANSPEED[@]}
#echo $loopsize
#echo $FANSPEED

#PWM=30
#PWM_HEX=$(printf '%x' $PWM)

for ((i=0;i < $loopsize; i++))
do	

	PWM=${FANSPEED[i]}
	PWM_HEX=$(printf '%x' $PWM)
	echo $PWM_HEX
	CONFIG1="BROADSIDE_${PWM}_25drives.txt"
	CONFIG2="BROADSIDE_${PWM}_50drives.txt"
	CONFIG3="BROADSIDE_${PWM}_75drives.txt"
	CONFIG4="BROADSIDE_${PWM}_100drives.txt"
	echo "ipmitool -t 0x2a -b 0x00 raw 0x30 0x25 0x$PWM_HEX 0x$PWM_HEX 0x$PWM_HEX 0x$PWM_HEX 0x$PWM_HEX"
	echo "ipmitool sdr type fan | tee -a"
	echo "fio on 1st configuration file" >> $CONFIG1 
	sleep 5
	echo "fio on 2st configuration file" >> $CONFIG2
	sleep 5
	echo "fio on 3st configuration file" >> $CONFIG3
	sleep 5
	echo "fio on 4st configuration file" >> $CONFIG4
	sleep 5

done
	echo "ipmitool -t 0x2a -b 0x00 raw 0x30 0x25 0x00 0x1E 0x1E 0x1E 0x1E 0x1E"
