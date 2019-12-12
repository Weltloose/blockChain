package controller

import (
	"github.com/Weltloose/blockChain/model"
	"github.com/gin-gonic/gin"
)

func GenerateAccount(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	ok, opt := model.InterateWithChain([]string{"generateAccount", username, password})
	c.JSON(200, gin.H{
		"success": ok,
		"opt":     opt,
	})
}

func InDebt(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	ok, opt := model.InterateWithChain([]string{username, password, "inDebt"})
	c.JSON(200, gin.H{
		"success": ok,
		"debt":    opt,
	})
}

func AddDownStreamCompany(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	name := c.PostForm("name")
	ok, opt := model.InterateWithChain([]string{username, password, "AddDownStreamCompany", name})
	c.JSON(200, gin.H{
		"success": ok,
		"compID":  opt,
	})
}

func SignAndIssue(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	to := c.PostForm("to")
	amount := c.PostForm("amount")
	debtTime := c.PostForm("debtTime")
	ok, _ := model.InterateWithChain([]string{username, password, "SignAndIssue", to, amount, debtTime})
	c.JSON(200, gin.H{
		"success": ok,
	})
}

func GetRight(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	owner := c.PostForm("owner")
	debtTime := c.PostForm("debtTime")
	ok, opt := model.InterateWithChain([]string{username, password, "GetRight", owner, debtTime})
	c.JSON(200, gin.H{
		"success": ok,
		"owned":   opt,
	})
}

func TransferRight(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	fromm := c.PostForm("fromm")
	to := c.PostForm("to")
	amount := c.PostForm("amount")
	debtTime := c.PostForm("debtTime")
	ok, opt := model.InterateWithChain([]string{username, password, "TransferRight", fromm, to, amount, debtTime})
	if ok && opt == "0" {
		c.JSON(200, gin.H{
			"success": ok,
		})
	} else {
		c.JSON(200, gin.H{
			"success": false,
			"left":    opt,
		})
	}
}

func GetFinance(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	fromm := c.PostForm("fromm")
	ok, opt := model.InterateWithChain([]string{username, password, "GetFinance", fromm})
	c.JSON(200, gin.H{
		"success": ok,
		"finance": opt,
	})
}

func BankCheckFinance(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	fromm := c.PostForm("fromm")
	ok, _ := model.InterateWithChain([]string{username, password, "BankCheckFinance", fromm})
	c.JSON(200, gin.H{
		"success": ok,
	})
}

func CompanyAddFinance(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	fromm := c.PostForm("fromm")
	amount := c.PostForm("amount")
	ok, _ := model.InterateWithChain([]string{username, password, "CompanyAddFinance", fromm, amount})
	c.JSON(200, gin.H{
		"success": ok,
	})
}

func CompanyPayFinance(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	fromm := c.PostForm("fromm")
	amount := c.PostForm("amount")
	ok, _ := model.InterateWithChain([]string{username, password, "CompanyPayFinance", fromm, amount})
	c.JSON(200, gin.H{
		"success": ok,
	})
}

func ConfirmPaied(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	to := c.PostForm("to")
	ok, _ := model.InterateWithChain([]string{username, password, "ConfirmPaied", to})
	c.JSON(200, gin.H{
		"success": ok,
	})
}

func GetUnpaied(c *gin.Context) {
	username := c.PostForm("username")
	password := c.PostForm("password")
	ok, opt := model.InterateWithChain([]string{username, password, "GetUnpaied"})
	c.JSON(200, gin.H{
		"success": ok,
		"opt":     opt,
	})
}
