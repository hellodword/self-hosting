package main

import (
	"context"
	"fmt"
	"github.com/pkg/errors"
	"github.com/tencentyun/scf-go-lib/cloudfunction"
	"os/exec"
	"path/filepath"
	"time"
)

func verifyEnv() error {
	return nil
}

func uploadFile(prefix, key, filePath string) error {
	output, err := exec.Command("bash", "-c",
		fmt.Sprintf(`./s3uploader -prefix "%s" -key "%s" -path "%s" 2>&1`,
			prefix,
			key,
			filePath),
	).Output()

	if err != nil {
		err = errors.Wrap(err, "output "+string(output))
	}
	return err
}

func backup() error {
	baseDir := "/tmp"

	{
		if err := verifyEnv(); err != nil {
			return err
		}
	}

	tarFilename := fmt.Sprintf(
		"bitwarden-%s.tar.gz",
		time.Now().Format("20060102150405"),
	)
	tarFilepath := filepath.Join(baseDir, tarFilename)

	// tar
	{
		if _, err := exec.Command("bash", "-c",
			fmt.Sprintf("tar cvfP %s --exclude='/mnt/sends/*' --exclude='/mnt/attachments/*' --exclude='/mnt/icon_cache/*' --exclude='/mnt/tmp/*' --exclude='/mnt/sends' --exclude='/mnt/attachments' --exclude='/mnt/icon_cache' --exclude='/mnt/tmp' /mnt",
				tarFilepath,
			)).Output(); err != nil {
			return err
		}
	}

	// cos
	{
		err := uploadFile("COS_", fmt.Sprintf("bitwarden/%s", tarFilename), tarFilepath)
		if err != nil {
			return err
		}
	}

	// aws
	{
		err := uploadFile("AWS_", fmt.Sprintf("bitwarden/%s", tarFilename), tarFilepath)
		if err != nil {
			return err
		}
	}

	// oss
	{
		err := uploadFile("OSS_", fmt.Sprintf("bitwarden/%s", tarFilename), tarFilepath)
		if err != nil {
			return err
		}
	}

	return nil
}

type DefineEvent struct {
	// test event define
	Key1 string `json:"key1"`
	Key2 string `json:"key2"`
}

func hello(ctx context.Context, event DefineEvent) (string, error) {
	if err := backup(); err != nil {
		return "", err
	}

	return fmt.Sprintf("%s %s", event.Key1, event.Key2), nil
}

func main() {
	// Make the handler available for Remote Procedure Call by Cloud Function
	cloudfunction.Start(hello)
}
