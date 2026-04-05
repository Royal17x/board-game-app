package storage

import (
	"backend-for-flutter/internal/models"
	"context"
	"errors"
)

func (r *PostgresRepo) GetAllGames() ([]models.BoardGame, error) {
	games := make([]models.BoardGame, 0)
	query := `SELECT id, title, description, image_url, created_at FROM board_games ORDER BY id`
	rows, err := r.db.Query(context.Background(), query)
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

func (r *PostgresRepo) CreateGame(title, description, imageUrl string) (models.BoardGame, error) {
	var game models.BoardGame
	query := `
		INSERT INTO board_games (title, description, image_url)
		VALUES ($1, $2, $3)
		RETURNING id, title, description, image_url, created_at`
	err := r.db.QueryRow(context.Background(), query, title, description, imageUrl).
		Scan(&game.Id, &game.Title, &game.Description, &game.ImageUrl, &game.CreatedAt)
	return game, err
}

func (r *PostgresRepo) DeleteGame(id int) error {
	query := `DELETE FROM board_games WHERE id = $1`
	result, err := r.db.Exec(context.Background(), query, id)
	if err != nil {
		return err
	}
	if result.RowsAffected() == 0 {
		return errors.New("game not found")
	}
	return nil
}
