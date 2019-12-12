package main

import (
	"github.com/Weltloose/blockChain/router"
)

func main() {
	server := router.CreateServer()
	server.Run()
}
