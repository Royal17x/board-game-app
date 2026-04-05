package handlers

import (
	"backend-for-flutter/internal/storage"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type ReviewHandler struct {
	repo *storage.PostgresRepo
}

func NewReviewHandler(repo *storage.PostgresRepo) *ReviewHandler {
	return &ReviewHandler{repo: repo}
}

func (h *ReviewHandler) GetReviews(c *gin.Context) {
	gameId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid game id"})
		return
	}
	reviews, err := h.repo.GetReviewsByGame(gameId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, reviews)
}

func (h *ReviewHandler) CreateReview(c *gin.Context) {
	gameId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid game id"})
		return
	}

	var input struct {
		UserId int    `json:"user_id" binding:"required"`
		Text   string `json:"text" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}

	review, err := h.repo.CreateReview(gameId, input.UserId, input.Text)
	if err != nil {
		if err == storage.ErrReviewLimit {
			c.JSON(http.StatusTooManyRequests, gin.H{"error": "review was already sent on this game"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, review)
}
