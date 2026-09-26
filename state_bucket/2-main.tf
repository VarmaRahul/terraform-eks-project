resource "aws_s3_bucket" "state_bucket" {
  bucket = "terraform-state-vrahul-mumbai"

  tags = {
    Name        = "terraform-state-vrahul-mumbai"
    Environment = "shared"
  }
}

# ---------------------------------------------------------
# Versioning
# ---------------------------------------------------------

#resource "aws_s3_bucket_versioning" "state_bucket" {
#  bucket = aws_s3_bucket.state_bucket.id
#
#  versioning_configuration {
#    status = "Disabled"
#  }
#}

# ---------------------------------------------------------
# Block Public Access
# ---------------------------------------------------------

resource "aws_s3_bucket_public_access_block" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# ---------------------------------------------------------
# Server-Side Encryption
# ---------------------------------------------------------

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# ---------------------------------------------------------
# Enforce HTTPS / TLS
# ---------------------------------------------------------

resource "aws_s3_bucket_policy" "state_bucket" {
  bucket = aws_s3_bucket.state_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid       = "DenyInsecureTransport"
        Effect    = "Deny"
        Principal = "*"

        Action = "s3:*"

        Resource = [
          aws_s3_bucket.state_bucket.arn,
          "${aws_s3_bucket.state_bucket.arn}/*"
        ]

        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}