####################################################################
#                                                                 # 
####################################################################
#/bin/bash
ARCEE30="arcee_30PWM_1M_seqwrite_180s.txt"
ARCEE42="arcee_42PWM_1M_seqwrite_180s.txt"
ARCEE100="arcee_100PWM_1M_seqwrite_180s.txt"
CL3100CSV="CL3100.$(date +%F_%R).csv"
sdlist=`cat sdlist.TXT| awk '{print$3}'`
#echo $sdlist
#echo $CL3100CSV

linenum=`grep -n Starting $ARCEE30 | awk '{print$1}' | tr -d ':Starting'`
devicename=`sed -n $linenum',$p' $ARCEE30 | grep -i "bsd"|awk '{print$1}'|tr -d ':'|cut -c4-`
BlockWrite_30=`sed -n $linenum',$p' $ARCEE30 |grep -i "bw="|awk '{print$3}'|awk -F'=' '{print$2}' | sed -r 's/.{5}$//'`

linenum=`grep -n Starting $ARCEE42 | awk '{print$1}' | tr -d ':Starting'`
BlockWrite_42=`sed -n $linenum',$p' $ARCEE42 |grep -i "bw="|awk '{print$3}'|awk -F'=' '{print$2}' | sed -r 's/.{5}$//'`

linenum=`grep -n Starting $ARCEE100 | awk '{print$1}' | tr -d ':Starting'`
BlockWrite_100=`sed -n $linenum',$p' $ARCEE100 |grep -i "bw="|awk '{print$3}'|awk -F'=' '{print$2}' | sed -r 's/.{5}$//'`
        
#echo $devicename 
#echo $BlockWrite_30
#echo $BlockWrite_42
#echo $BlockWrite_100

array1=(${devicename// /})
array2=(${BlockWrite_30// /})
array3=(${BlockWrite_42// /})
array4=(${BlockWrite_100// /})
sdList=(${sdlist// /})
length=${#array1[@]}

echo "Device: 30%PWM : 42%PWM : 100% PWM : Drive Serial number"
echo "Device,30%PWM,42%PWM,100% PWM,Drive Serial number" > $CL3100CSV
for ((i=0;i < $length;i++)); do
    echo -e "${array1[$i]}   : ${array2[$i]} : ${array3[$i]} : ${array4[$i]}  :  ${sdList[$i]}\n"
    echo "${array1[$i]},${array2[$i]},${array3[$i]},${array4[$i]},${sdList[$i]}" >> $CL3100CSV
done
