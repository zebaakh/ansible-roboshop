#!/bin/bash

NAMES=$@
IMAGE_ID=ami-0d4949a5a5686445c
SECURITY_GROUP_ID=sg-0d09274b7b3d19419
# DOMAIN_NAME=joindevops.online
# HOSTED_ZONE_ID=Z06112601XX8DKA9TU7T7

# Improvement: Use a function to create an EC2 instance
create_ec2_instance() {
    local INSTANCE_TYPE=""
    local SERVICE_NAME=$1

    # Set instance type based on service name
    if [[ $SERVICE_NAME == "mongodb" || $SERVICE_NAME == "mysql" ]]; then
        INSTANCE_TYPE="t3.medium"
    else
        INSTANCE_TYPE="t2.micro"
    fi

    echo "Creating $SERVICE_NAME instance"
    local IP_ADDRESS=$(aws ec2 run-instances --image-id $IMAGE_ID \
                        --instance-type $INSTANCE_TYPE \
                        --security-group-ids $SECURITY_GROUP_ID \
                        --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$SERVICE_NAME}]" \
                        | jq -r '.Instances[0].PrivateIpAddress')
    
    echo "Created $SERVICE_NAME instance: $IP_ADDRESS"
    # update_route53_record $SERVICE_NAME $IP_ADDRESS
}
# # Function to update Route 53 record
# update_route53_record() {
#     local SERVICE_NAME=$1
#     local IP_ADDRESS=$2

#     echo "Updating Route 53 record for $SERVICE_NAME"
#     aws route53 change-resource-record-sets --hosted-zone-id $HOSTED_ZONE_ID --change-batch '
#     {
#         "Changes": [{
#             "Action": "CREATE",
#             "ResourceRecordSet": {
#                 "Name": "'$SERVICE_NAME.$DOMAIN_NAME'",
#                 "Type": "A",
#                 "TTL": 300,
#                 "ResourceRecords": [{"Value": "'$IP_ADDRESS'"}]
#             }
#         }]
#     }
#     '
# }
# Loop through service names and create EC2 instances
for SERVICE_NAME in "$@"; do
    create_ec2_instance $SERVICE_NAME
done
