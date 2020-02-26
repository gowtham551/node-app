#/bin/bash
abcd=`aws ec2 describe-instances | grep  "demo2" | awk -F: '{print $2}' | sed 's/"//g' | sed 's/,//g'`
if [[ $abcd -eq "demo2" ]]
then
 echo "instance is there,no need to launch"
else
 aws ec2 run-instances --image-id ami-08cec7c429219e339 --count 1 --instance-type t2.micro --key-name tech  --subnet-id subnet-828ff6f8 --region us-east-2 --tags- value=demo1
# Wait for the instance until the 2/2 checks are passed
while [ $status -lt 2 ]
do
 demo=`aws ec2 describe-instances --filters --image-ids ami-08cec7c429219e339 |  grep InstanceId | head -1 | awk -F: '{print $2}' | sed 's/\ "//g;s/",//g'`

 status=`aws ec2 describe-instance-status --instance-ids  $demo --filters Name="instance-status.reachability,Values=passed" | grep  '"Status": "passed"' | wc -l`
    # add sleep time
done
fi
#describe and run commands

demo=`aws ec2 describe-instances --filters "Name=tag-value,Values=demo1" |  grep PublicDnsName | head -1 | awk -F: '{print $2}' | sed 's/\ "//g;s/",//g'`
ssh -i "tech.pem" ubuntu@$demo 'sudo apt-get update -y'
ssh -i "tech.pem" ubuntu@$demo 'sudo touch f2'
#execute remote machine
ssh -i "tech.pem" ubuntu@$demo
