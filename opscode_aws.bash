#!/bin/bash

region=ap-south-1
os_type='Amazon Linux 2017.09'

export AWS_DEFAULT_REGION="${region}"

stack_name="test_stack"

service_role_arn="arn:aws:iam::771987116335:role/aws-opsworks-service-role"
instance_profile_arn="arn:aws:iam::771987116335:instance-profile/aws-opsworks-ec2-role"

stack_id=$(aws opsworks create-stack --name ${stack_name} --chef-configuration ManageBerkshelf=false --configuration-manager '{"Name":"Chef","Version":"11.10"}' --stack-region ${region} --service-role-arn ${service_role_arn} --default-instance-profile-arn ${instance_profile_arn} | jq -r '.StackId')

layer_id=$( aws opsworks create-layer --region ${region} --stack-id ${stack_id} --type custom --name awesome-custom-layer --shortname awesome-layer | jq -r '.LayerId')

aws opsworks --region ${region} create-instance --stack-id ${stack_id} --layer-ids ${layer_id} --instance-type 't2.micro' --os "${os_type}" --root-device-type 'ebs'