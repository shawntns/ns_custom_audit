#!/bin/bash
# Author: xxu@tenable.com
# Usage: sh eval-approval.sh <1st-RequestID> <2st-RequestID> ... <last-RequestID>
echo "I. Who will be responsible to approve this EVAL request?"
names='Coco Jason Rocky Shawn'
PS3="Select SE's name: "
select name in $names; do
  if [ $name == 'Coco' ];then
    email=xquan@tenable.com
  elif [[ $name == 'Jason' ]]; then
    email=jfan@tenable.com
  elif [[ $name == 'Rocky' ]]; then
    email=lyang@tenable.com
  else
    email=xxu@tenable.com
  fi
  echo "[$name $email]\t\n"
  break
done

echo "II. How many Agents?"
numbers='128 512 1024 2048'
PS3="Select the number: "
select agents in $numbers; do
  echo "[$agents]\t\n"
  break
done

echo "III. How many copies of license?"
read qty

if [[ $qty -eq 1 ]]; then
  curl -s "https://www.tenable.com/products/nessus/nessus-agents/evaluate" \
  --data "first_name=foo&last_name=bar&email=$email&phone=%2B8618616335761&job_role=APAC+SE&company=Tenable&product_size=$agents&type=nessus_mgr&country=US&state=LA&zip=71201&submit=Register" \
  --compressed  > /dev/null && echo "The NM EVAL license has been applied." || echo "Network Error?" && exit 1
else
  for i in `seq $qty`; do
    curl -s "https://www.tenable.com/products/nessus/nessus-agents/evaluate" \
    --data "first_name=foo&last_name=bar&email=$email&phone=%2B8618616335761&job_role=APAC+SE&company=Tenable&product_size=$agents&type=nessus_mgr&country=US&state=LA&zip=71201&submit=Register" \
    --compressed  > /dev/null && echo "The No.$i of total $qty EVAL license has been applied." || echo "Network Error?"
    sleep 4
  done
fi
echo Bye!
