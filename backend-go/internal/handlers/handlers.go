package handlers

import (
	"backend-for-flutter/internal/models"
	"backend-for-flutter/internal/storage"
	"net/http"
	"time"

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
	id, err := u.userRepo.CreateUser(input.Username, input.Password)
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, models.User{
		Id:        id,
		Username:  input.Username,
		CreatedAt: time.Now(),
	})
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
	c.JSON(http.StatusOK, models.User{
		Id:        user.Id,
		Username:  user.Username,
		CreatedAt: user.CreatedAt,
	})
}
