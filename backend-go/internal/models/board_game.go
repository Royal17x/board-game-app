package models

import "time"

type BoardGame struct {
	Id          int       `json:"id"`
	Title       string    `json:"title" binding:"required"`
	Description string    `json:"description" binding:"required"`
	ImageUrl    string    `json:"image_url"`
	CreatedAt   time.Time `json:"created_at"`
}
