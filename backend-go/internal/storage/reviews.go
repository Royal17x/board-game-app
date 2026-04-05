package storage

import (
	"backend-for-flutter/internal/models"
	"context"
	"errors"
)

func (r *PostgresRepo) GetReviewsByGame(gameId int) ([]models.Review, error) {
	reviews := make([]models.Review, 0)
	query := `
		SELECT r.id, r.game_id, r.user_id, u.username, r.text, r.created_at
		FROM reviews r
		JOIN users u ON u.id = r.user_id
		WHERE r.game_id = $1
		ORDER BY r.created_at DESC`
	rows, err := r.db.Query(context.Background(), query, gameId)
	if err != nil {
		return reviews, err
	}
	defer rows.Close()
	for rows.Next() {
		var rv models.Review
		if err := rows.Scan(&rv.Id, &rv.GameId, &rv.UserId, &rv.Username, &rv.Text, &rv.CreatedAt); err != nil {
			return reviews, err
		}
		reviews = append(reviews, rv)
	}
	return reviews, nil
}

func (r *PostgresRepo) CreateReview(gameId, userId int, text string) (models.Review, error) {
	var count int
	checkQuery := `SELECT COUNT(*) FROM reviews WHERE user_id = $1 AND game_id = $2`
	if err := r.db.QueryRow(context.Background(), checkQuery, userId, gameId).Scan(&count); err != nil {
		return models.Review{}, err
	}
	if count >= 1 {
		return models.Review{}, errors.New("reviews limit reached")
	}

	var rv models.Review
	query := `
		INSERT INTO reviews (game_id, user_id, text)
		VALUES ($1, $2, $3)
		RETURNING id, game_id, user_id, text, created_at`
	err := r.db.QueryRow(context.Background(), query, gameId, userId, text).
		Scan(&rv.Id, &rv.GameId, &rv.UserId, &rv.Text, &rv.CreatedAt)
	return rv, err
}
