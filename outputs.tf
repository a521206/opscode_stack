output "public_ip" {
  value = "${aws_opsworks_instance.cluster01-1.public_ip}"
}