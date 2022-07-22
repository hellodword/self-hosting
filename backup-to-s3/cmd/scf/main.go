package main

import (
	"context"
	"fmt"
	"github.com/pkg/errors"
	"github.com/tencentyun/scf-go-lib/cloudfunction"
	"os/exec"
)

func execCommand(command string) error {
	output, err := exec.Command("bash", "-c",
		fmt.Sprintf("%s 2>&1", command),
	).Output()

	if err != nil {
		err = errors.Wrap(err, "output "+string(output))
	}
	return err
}

func backup() error {
	{
		err := execCommand("bash ./bitwarden-cfs.sh")
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
