package handlers

import (
	"backend-for-flutter/internal/storage"
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type GameHandler struct {
	repo *storage.PostgresRepo
}

func NewGameHandler(repo *storage.PostgresRepo) *GameHandler {
	return &GameHandler{repo: repo}
}

func (h *GameHandler) GetAllGames(c *gin.Context) {
	games, err := h.repo.GetAllGames()
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, games)
}

func (h *GameHandler) CreateGame(c *gin.Context) {
	type CreateGameRequest struct {
		Title       string `json:"title" binding:"required"`
		Description string `json:"description" binding:"required"`
		ImageUrl    string `json:"image_url"`
	}
	input := CreateGameRequest{}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	game, err := h.repo.CreateGame(input.Title, input.Description, input.ImageUrl)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, game)
}

func (h *GameHandler) DeleteGame(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid game id"})
		return
	}
	if err := h.repo.DeleteGame(id); err != nil {
		if err == errors.New("game not found") {
			c.JSON(http.StatusNotFound, gin.H{"error": "game not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"deleted_id": id})
}

func (h *GameHandler) UpdateGame(c *gin.Context) {
	id, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid game id"})
		return
	}
	var input struct {
		Title       string `json:"title" binding:"required"`
		Description string `json:"description" binding:"required"`
		ImageUrl    string `json:"image_url"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	game, err := h.repo.UpdateGame(id, input.Title, input.Description, input.ImageUrl)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, game)
}
