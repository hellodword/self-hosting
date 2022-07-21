package main

import (
	"errors"
	"flag"
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
	"os"
)

func main() {
	prefix := flag.String("prefix", "", "")
	key := flag.String("key", "", "")
	filePath := flag.String("path", "", "")
	flag.Parse()

	err := uploadFile(*prefix, *key, *filePath)
	if err != nil {
		panic(err)
	}

	os.Exit(0)
}

func uploadFile(prefix, key, filePath string) error {
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

	svc := NewS3(s3Endpoint, s3Region, s3AccessKey, s3SecretKey)

	f, err := os.Open(filePath)
	if err != nil {
		return err
	}

	_, err = svc.PutObject(&s3.PutObjectInput{
		Bucket: aws.String(s3Bucket),
		Key:    aws.String(key),
		Body:   f,
	})
	if err != nil {
		return err
	}
	return nil
}

func NewS3(s3Endpoint, s3Region, s3AccessKey, s3SecretKey string) *s3.S3 {
	defaultResolver := endpoints.DefaultResolver()
	s3CustomResolverFn := func(service, region string, optFns ...func(*endpoints.Options)) (endpoints.ResolvedEndpoint, error) {
		if service == "s3" {
			return endpoints.ResolvedEndpoint{
				URL:           s3Endpoint,
				SigningRegion: s3Region,
			}, nil
		}

		return defaultResolver.EndpointFor(service, region, optFns...)
	}

	sess := session.Must(session.NewSession(&aws.Config{
		EndpointResolver: endpoints.ResolverFunc(s3CustomResolverFn),
		Credentials:      credentials.NewStaticCredentials(s3AccessKey, s3SecretKey, ""),
	}))
	svc := s3.New(sess)
	return svc
}
