package router

import (
	"net/http"

	"github.com/Weltloose/blockChain/controller"
	"github.com/gin-gonic/gin"
)

func CreateServer() *gin.Engine {
	router := gin.Default()
	router.StaticFS("/public", http.Dir("assets"))
	router.StaticFile("/", "./assets/index.html")
	router.POST("/api/GenerateAccount", controller.GenerateAccount)
	router.POST("/api/InDebt", controller.InDebt)
	router.POST("/api/AddDownStreamCompany", controller.AddDownStreamCompany)
	router.POST("/api/SignAndIssue", controller.SignAndIssue)
	router.POST("/api/GetRight", controller.GetRight)
	router.POST("/api/TransferRight", controller.TransferRight)
	router.POST("/api/GetFinance", controller.GetFinance)
	router.POST("/api/BankCheckFinance", controller.BankCheckFinance)
	router.POST("/api/CompanyAddFinance", controller.CompanyAddFinance)
	router.POST("/api/CompanyPayFinance", controller.CompanyPayFinance)
	router.POST("/api/ConfirmPaied", controller.ConfirmPaied)
	router.POST("/api/GetUnpaied", controller.GetUnpaied)
	return router
}
