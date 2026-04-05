package storage

import (
	"backend-for-flutter/internal/models"
	"context"
	"errors"
)

func (r *PostgresRepo) CreateBooking(userId, gameId int) (models.Booking, error) {
	var count int
	err := r.db.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM bookings WHERE user_id=$1 AND game_id=$2`,
		userId, gameId,
	).Scan(&count)
	if err != nil {
		return models.Booking{}, err
	}
	if count > 0 {
		return models.Booking{}, errors.New("already booked")
	}

	var booking models.Booking
	query := `
		INSERT INTO bookings (user_id, game_id)
		VALUES ($1, $2)
		RETURNING id, user_id, game_id, booked_at`
	err = r.db.QueryRow(context.Background(), query, userId, gameId).
		Scan(&booking.Id, &booking.UserId, &booking.GameId, &booking.BookedAt)
	return booking, err
}

func (r *PostgresRepo) GetBookingsByUser(userId int) ([]models.Booking, error) {
	bookings := make([]models.Booking, 0)
	query := `
		SELECT b.id, b.user_id, b.game_id, bg.title, b.booked_at
		FROM bookings b
		JOIN board_games bg ON bg.id = b.game_id
		WHERE b.user_id = $1
		ORDER BY b.booked_at DESC`
	rows, err := r.db.Query(context.Background(), query, userId)
	if err != nil {
		return bookings, err
	}
	defer rows.Close()
	for rows.Next() {
		var booking models.Booking
		if err := rows.Scan(&booking.Id, &booking.UserId, &booking.GameId, &booking.GameTitle, &booking.BookedAt); err != nil {
			return bookings, err
		}
		bookings = append(bookings, booking)
	}
	return bookings, nil
}

func (r *PostgresRepo) DeleteBooking(userId, bookingId int) error {
	result, err := r.db.Exec(context.Background(),
		`DELETE FROM bookings WHERE id=$1 AND user_id=$2`,
		bookingId, userId,
	)
	if err != nil {
		return err
	}
	if result.RowsAffected() == 0 {
		return errors.New("already booked")
	}
	return nil
}
