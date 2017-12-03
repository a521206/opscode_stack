# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# DEPLOY OpsCode
# This template deploys OpsCode stack
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

provider "aws" {
  region = "ap-south-1"
}

# ------------------------------------------------------------------------------
# CONFIGURE OUR AWS STACK
# ------------------------------------------------------------------------------

resource "aws_opsworks_stack" "test-stack" {
  name                          = "awesome-stack"
  region                        = "ap-south-1"
  default_os                    = "Amazon Linux 2017.09"
  default_ssh_key_name          = "TerraformDemo"
  configuration_manager_name    = "Chef"
  configuration_manager_version = "11.10"

  use_custom_cookbooks          = true
  custom_cookbooks_source{
    type                        = "git"
    url                         = "https://github.com/a521206/opsworks_cookbook_demo.git"
  }

  manage_berkshelf              = false

  service_role_arn              = "arn:aws:iam::771987116335:role/aws-opsworks-service-role"
  default_instance_profile_arn  = "arn:aws:iam::771987116335:instance-profile/aws-opsworks-ec2-role"
  default_availability_zone     = "ap-south-1a"

   

  use_opsworks_security_groups  = true

  tags {
    Name                        = "terraform-stack-demo"
  }

}

resource "aws_opsworks_custom_layer" "custlayer" {
  name                          = "awesome-custom-layer"
  short_name                    = "awesome-layer"
  stack_id                      = "${aws_opsworks_stack.test-stack.id}"
 
  # network
  auto_assign_elastic_ips = false
  auto_assign_public_ips  = true
  drain_elb_on_shutdown   = true

  # chef
  custom_setup_recipes     = []
  custom_configure_recipes = []
  custom_deploy_recipes    = []
  custom_undeploy_recipes  = []
  custom_shutdown_recipes  = []}

# aws opsworks create-instance --stack-id "a5e392d5-4d3d-4907-9f97-223c49a6f15e" --layer-ids "03e69f92-35d0-4645-826f-82dba29c92b4" --instance-type t2.micro --hostname cluster01-1

resource "aws_opsworks_instance" "cluster01-1" {
    count                       = 1
    availability_zone           = "ap-south-1a"
    stack_id                    = "${aws_opsworks_stack.test-stack.id}"
    layer_ids                   = ["${aws_opsworks_custom_layer.custlayer.id}"]
    os                          = "Amazon Linux 2017.09"
    instance_type               = "t2.micro"
    state                       = "running"
    root_device_type            = "ebs"
}

resource "aws_opsworks_permission" "stack_permission" {
  allow_ssh  = true
  allow_sudo = true
  # level      = "manage"
  # "arn:aws:iam::771987116335:user/awsdemo"
  user_arn   = "arn:aws:iam::771987116335:user/awsdemo"
  stack_id   = "${aws_opsworks_stack.test-stack.id}"
}