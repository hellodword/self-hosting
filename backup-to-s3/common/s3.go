package common

import (
	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/endpoints"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

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
