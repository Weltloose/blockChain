package model

import (
	"bufio"
	"fmt"
	"io"
	"os"
	"os/exec"
)

func InterateWithChain(args []string) (bool, string) {

	cmd := exec.Command("./model/python_sdk/interateWithChain.py", args...)
	stdout, err := cmd.StdoutPipe()
	stderr, err := cmd.StderrPipe()
	go func() {
		io.Copy(os.Stderr, stderr)
		io.Copy(os.Stdout, stdout)
	}()
	if err != nil {
		fmt.Println(err)
		return false, ""
	}
	if err := cmd.Start(); err != nil {
		fmt.Println(err)
		return false, ""
	}
	r := bufio.NewReader(stdout)
	opt, _, err := r.ReadLine()
	print("res: ", string(opt))
	if err := cmd.Wait(); err != nil {
		fmt.Println(err)
		return false, ""
	}
	if string(opt) == "error" {
		return false, ""
	} else {
		return true, string(opt)
	}
}
