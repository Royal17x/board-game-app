package storage

import "errors"

var (
	ErrNotFound      = errors.New("not found")
	ErrAlreadyBooked = errors.New("already booked")
	ErrReviewLimit   = errors.New("review limit reached")
)
