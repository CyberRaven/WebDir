clear 
#!/bin/bash



# ANSI escape codes for colors
GREEN="\e[1;32m"
YELLOW="\e[1;33m"
WHITE="\e[1;37m"
CYAN="\e[1;36m"
RED="\e[0;31m"
PURPLE="\e[35m"
NC="\e[0m"

# Regular Expression for URL validation
regex='^(http:\/\/www\.|https:\/\/www\.|http:\/\/|https:\/\/)?[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?'

# report configuration 
REPORT_DIR='reports'
INFO_file=info_urls.txt
OK_file=ok_urls.txt
REDIRECT_file=redirect_urls.txt
unauthenticate=unauthenticate_urls.txt
unauthorize=unauthorize_urls.txt
SERVER_E_file=ser_err_urls.txt
else_file=else_urls.txt

# Display the logo
figlet WebDir

if [ ! -d 'reports' ]; then
  mkdir $REPORT_DIR
fi

printf "\n\n\n$RED"
printf "Made by: CyberRaven$NC\t\tPublished: $CYAN 2021 $NC\n\n\n$YELLOW WebDir is a bash script for finding common interesting files stored inside a website $NC\n\n===============================================================================\n\n\n"

printf "\n\nPlease Enter a website URL: "

read -r website

raw_website=$(echo $website | awk -F:// '{print $2}' | sed 's/\///g' ) 

time_now=$(date "+%Y_%m_%d_%H_%M_%S")


mkdir $REPORT_DIR/$raw_website\_$time_now
touch $REPORT_DIR/$raw_website\_$time_now/$INFO_file
touch $REPORT_DIR/$raw_website\_$time_now/$OK_file
touch $REPORT_DIR/$raw_website\_$time_now/$REDIRECT_file
touch $REPORT_DIR/$raw_website\_$time_now/$unauthenticate
touch $REPORT_DIR/$raw_website\_$time_now/$unauthorize
touch $REPORT_DIR/$raw_website\_$time_now/$SERVER_E_file
touch $REPORT_DIR/$raw_website\_$time_now/$else_file

if [[ $website =~ $regex ]] 
then 
    printf "$YELLOW\n[~]$NC WebDir Trying to reach to %s \n" $website 
    #check connection
    #if [ CheckConnection ]; then
    #if [ ConnectionChecker ]; then
     # printf "$CYAN[~]$NC WebDir reached to $website"
    #else
      #echo "[!] WebDir didn't reached to $website. Check Your connection "
     # exit 
    #fi

    if ping -c 1 $raw_website &> /dev/null
    then
      printf "$CYAN[~]$NC WebDir reached to $website"
    else
      printf "\n$RED[!] WebDir didn't reached to $website. Check URL or Check Your connection$NC \n\n"
      exit
    fi

else
    printf "\n$RED[!] Invalid URL $NC\n"
    echo "e.g: https://example.com or https://www.example.com"
    exit
fi



payload_file="payloads/default_payload.txt"


para_counter=$(echo $website | egrep -o '[a-zA-Z]+=' | wc -l ) 

for i in $(seq 1 1 $para_counter)
do
  params_copy=$(echo $website | egrep -o '[a-zA-Z]+=' | awk "FNR == $i { print } " | sed 's/=//')
  printf "[ $i ] = $RED $params_copy $NC\n"  
done


payloads_counter=$(cat $payload_file | wc -l )


printf "\n\n[~] WebDir found $RED $payloads_counter $NC payloads inside $CYAN $payload_file $NC file\n\n"

printf "\n\n$PURPLE[INFO]$NC WebDir will automatically save URLs inside $YELLOW reports\<website_date_time> $NC folder"

printf "\n\n$CYAN[~]$NC WebDir Start Attacking: \n\n"

printf "\n=====================================================================================\nProgress\t\tTime\t\tStatus Code\t\tFULL URL WITH PAYLOAD\t\t\t\t\n=====================================================================================\n\n"

count_lost=0

for i in $(seq 1 1 $payloads_counter) 
do
  function CurlRequest () {

    #if [ CheckConnection ] ; then

    if ping -c 1 $raw_website &> /dev/null
    then
     
      url=$(echo $website | cut -d '?' -f 1,3)

      fetech_payload=$(cat $payload_file | awk "FNR == $i {print}")

       # encode url
       encode_payload=$(echo $fetech_payload | sed 's/</%3C/g; s/>/%3E/g; s/\s/%20/g; s/=/%3D/g; s/\"/%22/g' )
  
      url=$url/$encode_payload
  
      time=$(date | awk '{print $5}')
  
      curl_action=$(curl -I -s $url &)

      if curl -I -s > .check_status $url 
      then
        status_code=$(echo $curl_action | head -n 1 | awk '{print $2}' )  
        status_code_s=$(echo $curl_action | head -n 1 | awk '{print $2}' | cut -b 1)
      else
        printf "$RED[!] Curl Failed to request $NC $YELLOW payload number [$i]$NC\n" &2
        continue
      fi
  
      printf "[ $i | $payloads_counter ]\t\t"
      printf "[$YELLOW$time$NC]\t"
 
      if [ $status_code_s -eq 1 ]; then
        printf "[$CYAN$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$INFO_file

      elif [ $status_code_s -eq 2 ]; then
        printf "[$GREEN$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$OK_file

      elif [ $status_code_s -eq 3 ]; then
        printf "[$YELLOW$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$REDIRECT_file

      elif [ $status_code_s -eq 4 ] && [ $status_code -eq 404 ] || [ $status_code -eq 400 ]; then
        printf "[$RED$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$else_file

      elif [ $status_code_s -eq 4 ] && [ $status_code -eq 401 ]; then #unauthenticated 
        printf "[$CYAN$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$unauthenticate
    
      elif [ $status_code_s -eq 4 ] && [ $status_code -eq 403 ]; then #unauthorized 
        printf "[$CYAN$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$unauthorize

      elif [ $status_code_s -eq 4 ] && [ $status_code -ne 404 ] && [ $status_code_s -ne 400 ]; then
        printf "[$YELLOW$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$else_file

      elif [ $status_code_s -eq 5 ]; then
        printf "[$WHITE$status_code$NC]" 
        echo $url >> $REPORT_DIR/$raw_website\_$time_now/$SERVER_E_file

      else
        printf "[UNEXPECTED CONDITION]"
      fi 

      printf "\t\t\t$PURPLE" 
      echo  -n "$url"
      printf "$NC\n"
      
    else
      echo "[!] WebDir Stopped .. because target no more reachable! "
      count_lost=$((count_lost + 1))
      if [ $count_lost -gt 5 ]; then
        echo "[!] WebDir Quit .. target not reachable for 5 times in a row"
        exit 
      fi

    fi
  } 

 CurlRequest

done 

echo $raw_website

printf "\n\n\n\n$CYAN[~]$NC WebDir Finished\n\n$PURPLE[INFO]$NC You can find the report inside $YELLOW reports/<website_date_name> $NC folder\n\n"



