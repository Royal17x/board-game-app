package handlers

import (
	"backend-for-flutter/internal/storage"
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

type BookingHandler struct {
	repo *storage.PostgresRepo
}

func NewBookingHandler(repo *storage.PostgresRepo) *BookingHandler {
	return &BookingHandler{repo: repo}
}

func (h *BookingHandler) CreateBooking(c *gin.Context) {
	var input struct {
		UserId int `json:"user_id" binding:"required"`
		GameId int `json:"game_id" binding:"required"`
	}
	if err := c.ShouldBindJSON(&input); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": err.Error()})
		return
	}
	booking, err := h.repo.CreateBooking(input.UserId, input.GameId)
	if err != nil {
		if err == errors.New("already booked") {
			c.JSON(http.StatusConflict, gin.H{"error": "Игра уже забронирована"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusCreated, booking)
}

func (h *BookingHandler) GetBookings(c *gin.Context) {
	userIdStr := c.Query("user_id")
	userId, err := strconv.Atoi(userIdStr)
	if err != nil || userId == 0 {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user_id"})
		return
	}
	bookings, err := h.repo.GetBookingsByUser(userId)
	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, bookings)
}

func (h *BookingHandler) DeleteBooking(c *gin.Context) {
	bookingId, err := strconv.Atoi(c.Param("id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid booking id"})
		return
	}
	userId, err := strconv.Atoi(c.Query("user_id"))
	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{"error": "invalid user_id"})
		return
	}
	if err := h.repo.DeleteBooking(userId, bookingId); err != nil {
		if err == errors.New("already booked") {
			c.JSON(http.StatusNotFound, gin.H{"error": "booking not found"})
			return
		}
		c.JSON(http.StatusInternalServerError, gin.H{"error": err.Error()})
		return
	}
	c.JSON(http.StatusOK, gin.H{"deleted_id": bookingId})
}
