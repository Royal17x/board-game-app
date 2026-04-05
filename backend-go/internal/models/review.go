package models

import "time"

type Review struct {
	Id        int       `json:"id"`
	GameId    int       `json:"game_id"`
	UserId    int       `json:"user_id"`
	Username  string    `json:"username"`
	Text      string    `json:"text" binding:"required"`
	CreatedAt time.Time `json:"created_at"`
}
