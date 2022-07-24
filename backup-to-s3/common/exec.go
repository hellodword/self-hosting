package common

import (
	"github.com/pkg/errors"
	"os/exec"
)

func ExecCommand(command string) (string, error) {
	output, err := exec.Command("bash", "-c",
		command,
	).Output()

	if err != nil {
		err = errors.Wrap(err, "output "+string(output))
	}
	return string(output), err
}
