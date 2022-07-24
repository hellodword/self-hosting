package main

import (
	"backup-to-s3/common"
	"flag"
	"fmt"
	"net/http"
	"sync"
)

func main() {
	script := flag.String("script", "", "")
	flag.Parse()
	if *script == "" {
		panic("flag script")
	}

	var wg sync.WaitGroup
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		wg.Add(1)
		go func() {
			defer wg.Done()
			fmt.Println(r.RemoteAddr, *script)
			output, err := common.ExecCommand(fmt.Sprintf("bash %s 2>&1", *script))
			fmt.Println(output, err)
		}()

		w.WriteHeader(http.StatusOK)
	})

	http.ListenAndServe("0.0.0.0:8000", nil)
	wg.Wait()
}
