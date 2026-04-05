package models

import "time"

type Booking struct {
	Id        int       `json:"id"`
	UserId    int       `json:"user_id"`
	GameId    int       `json:"game_id"`
	GameTitle string    `json:"game_title"`
	BookedAt  time.Time `json:"booked_at"`
}
