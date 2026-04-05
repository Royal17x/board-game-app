package handlers

import (
	"backend-for-flutter/internal/storage"
	"net/http"

	"github.com/gin-gonic/gin"
)

type UserHandler struct {
	userRepo *storage.PostgresRepo
}

func NewUserHandler(userRepo *storage.PostgresRepo) *UserHandler {
	return &UserHandler{
		userRepo: userRepo,
	}
}
func (u *UserHandler) RegisterUser(c *gin.Context) {
	type RegisterUserRequest struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	input := RegisterUserRequest{}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	// всегда client
	user, err := u.userRepo.CreateUser(input.Username, input.Password, "client")
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, user)
}

func (u *UserHandler) LoginUser(c *gin.Context) {
	type LoginUserRequest struct {
		Username string `json:"username" binding:"required"`
		Password string `json:"password" binding:"required"`
	}
	input := LoginUserRequest{}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid credentials"})
		return
	}
	user, err := u.userRepo.GetUserByLogin(input.Username)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid credentials"})
		return
	}
	if input.Password != user.Password {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid credentials"})
		return
	}
	user.Password = ""
	c.JSON(http.StatusOK, user)
}
