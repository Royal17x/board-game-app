package storage

import (
	"backend-for-flutter/internal/models"
	"context"
)

func (r *PostgresRepo) GetFavoritesByUser(userId int) ([]models.BoardGame, error) {
	games := make([]models.BoardGame, 0)
	query := `
		SELECT bg.id, bg.title, bg.description, bg.image_url, bg.created_at
		FROM favorites f
		JOIN board_games bg ON bg.id = f.game_id
		WHERE f.user_id = $1
		ORDER BY f.id DESC`
	rows, err := r.db.Query(context.Background(), query, userId)
	if err != nil {
		return games, err
	}
	defer rows.Close()
	for rows.Next() {
		var game models.BoardGame
		if err := rows.Scan(&game.Id, &game.Title, &game.Description, &game.ImageUrl, &game.CreatedAt); err != nil {
			return games, err
		}
		games = append(games, game)
	}
	return games, nil
}

func (r *PostgresRepo) AddFavorite(userId, gameId int) error {
	_, err := r.db.Exec(context.Background(),
		`INSERT INTO favorites (user_id, game_id) VALUES ($1, $2) ON CONFLICT DO NOTHING`,
		userId, gameId,
	)
	return err
}

func (r *PostgresRepo) RemoveFavorite(userId, gameId int) error {
	_, err := r.db.Exec(context.Background(),
		`DELETE FROM favorites WHERE user_id=$1 AND game_id=$2`,
		userId, gameId,
	)
	return err
}

func (r *PostgresRepo) IsFavorite(userId, gameId int) (bool, error) {
	var count int
	err := r.db.QueryRow(context.Background(),
		`SELECT COUNT(*) FROM favorites WHERE user_id=$1 AND game_id=$2`,
		userId, gameId,
	).Scan(&count)
	return count > 0, err
}
