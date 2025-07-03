output "ec2_public_ip"{
    value = aws_instance.notifier_instance.public_ip
}

output "s3_bucket_name"{
    value = aws_s3_bucket.backup_bucket.bucket
}