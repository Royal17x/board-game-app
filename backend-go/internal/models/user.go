package models

import "time"

type User struct {
	Id        int       `json:"id"`
	Username  string    `json:"username" binding:"required"`
	Password  string    `json:"password,omitempty"`
	Role      string    `json:"role"`
	CreatedAt time.Time `json:"created_at"`
}
