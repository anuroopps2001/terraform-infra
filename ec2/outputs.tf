/* #for outputs of count meta arguement
output "ec2_public_ip_address" {
  value = aws_instance.my_instance[*].public_ip #to get output of 2 or more ec2 instances because the count=2 in main.tf
}
output "ec2_ami_value" {
  value = aws_instance.my_instance.ami  #to get the output of exact one resource
}
output "ec2_root_disK_size" {
  value = aws_instance.my_instance[*].root_block_device[0]
} */



# output block when using "for each" meta arguement
output "ec2_public_ip_address" {
  value = [
    for every_instance in aws_instance.my_instance : every_instance.public_ip
  ]
}

output "ec2_root_disK_size" {
  value = [
    for every_root_block_device in aws_instance.my_instance : every_root_block_device.root_block_device[0]
  ]
}