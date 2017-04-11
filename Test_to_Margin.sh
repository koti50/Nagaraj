####################################################################
#                                                                 # 
####################################################################
#/bin/bash
Product=`ipmitool fru | grep -i "Product Name" | tail -1 | awk '{print$4}'`
#echo $Product


if [ "$Product" ==  "CL3100" ]
then
	echo -e " Setting up the configuration file \n"
	bash ./drive_setup.sh
	echo -e " RVI test is starting with Fan speed 30%PWM , 42%PWM and 100PWM \n"	
	bash ./CL3100_12HDD_RVI_FIO.sh
	echo -e  "Test Completed set Fan speed to default \n"
	bash ./arcee_setfantoautoPWM.sh
	echo "***************************************************"
	echo -e "Display the drive and Block writes in KB/s  ***\n"
	echo "***************************************************"
	bash ./CL3100_Parse_test_result.sh
	#rm -f *.txt
fi
