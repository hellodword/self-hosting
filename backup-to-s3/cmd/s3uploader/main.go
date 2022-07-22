package main

import (
	"backup-to-s3/common"
	"context"
	"errors"
	"flag"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/service/s3"
	"os"
	"time"
)

func main() {
	prefix := flag.String("prefix", "", "")
	key := flag.String("key", "", "")
	filePath := flag.String("path", "", "")
	timeout := flag.Int("timeout", 120, "")
	flag.Parse()

	err := uploadFile(*prefix, *key, *filePath, *timeout)
	if err != nil {
		panic(err)
	}

	os.Exit(0)
}

func uploadFile(prefix, key, filePath string, timeout int) error {
	s3Endpoint := os.Getenv(prefix + "S3_ENDPOINT")
	if s3Endpoint == "" {
		return errors.New(prefix + "S3_ENDPOINT")
	}
	s3Region := os.Getenv(prefix + "S3_REGION")
	if s3Region == "" {
		return errors.New(prefix + "S3_REGION")
	}
	s3AccessKey := os.Getenv(prefix + "S3_ACCESS_KEY")
	if s3AccessKey == "" {
		return errors.New(prefix + "S3_ACCESS_KEY")
	}
	s3SecretKey := os.Getenv(prefix + "S3_SECRET_KEY")
	if s3SecretKey == "" {
		return errors.New(prefix + "S3_SECRET_KEY")
	}
	s3Bucket := os.Getenv(prefix + "S3_BUCKET")
	if s3Bucket == "" {
		return errors.New(prefix + "S3_BUCKET")
	}

	svc := common.NewS3(s3Endpoint, s3Region, s3AccessKey, s3SecretKey)

	f, err := os.Open(filePath)
	if err != nil {
		return err
	}

	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(timeout)*time.Second)
	defer cancel()
	_, err = svc.PutObjectWithContext(ctx,
		&s3.PutObjectInput{
			Bucket: aws.String(s3Bucket),
			Key:    aws.String(key),
			Body:   f,
		})
	if err != nil {
		return err
	}
	return nil
}
