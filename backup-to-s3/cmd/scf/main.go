package main

import (
	"context"
	"fmt"
	"github.com/pkg/errors"
	"github.com/tencentyun/scf-go-lib/cloudfunction"
	"net/url"
	"os/exec"
	"time"
)

func execCommand(command string) (string, error) {
	output, err := exec.Command("bash", "-c",
		fmt.Sprintf("%s 2>&1", command),
	).Output()

	if err != nil {
		err = errors.Wrap(err, "output "+string(output))
	}
	return string(output), err
}

func notify(group, title, desp, sound string) (string, error) {
	output, err := execCommand(fmt.Sprintf(`bash ./notify.sh "%s" "%s" "%s" "%s" 2>&1`,
		url.QueryEscape(group),
		url.QueryEscape(title),
		url.QueryEscape(desp),
		url.QueryEscape(sound),
	))
	if err != nil {
		fmt.Println("notify", err)
	}
	return output, err
}

func backup() error {
	{
		_, err := execCommand("bash ./bitwarden-cfs.sh")
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
	t := time.Now()
	if err := backup(); err != nil {
		notify("bw-scf-backup",
			"bw-scf-backup",
			fmt.Sprintf("error %s %d %s", t.Format("2006-01-02 15:04:05"), time.Since(t)/time.Millisecond, err.Error()),
			"newsflash",
		)
		return "", err
	}
	notify("bw-scf-backup",
		"bw-scf-backup",
		fmt.Sprintf("ok %s %d", t.Format("2006-01-02 15:04:05"), time.Since(t)/time.Millisecond),
		"",
	)

	return fmt.Sprintf("ok %s %d", t.Format("2006-01-02 15:04:05"), time.Since(t)/time.Millisecond), nil
}

func main() {
	// Make the handler available for Remote Procedure Call by Cloud Function
	cloudfunction.Start(hello)
}
