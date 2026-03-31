package storage

import (
	"backend-for-flutter/internal/models"
	"context"
	"errors"
	"strings"

	"github.com/jackc/pgx/v5"
	"github.com/jackc/pgx/v5/pgxpool"
)

type PostgresRepo struct {
	db *pgxpool.Pool
}

func NewPostgresRepo(db *pgxpool.Pool) *PostgresRepo {
	return &PostgresRepo{
		db: db,
	}
}

func (r *PostgresRepo) Close() {
	r.db.Close()
}

func (r *PostgresRepo) CreateUser(username, password string) (int, error) {
	var id int
	query := `INSERT INTO users (username, password) VALUES ($1, $2) RETURNING id`
	if err := r.db.QueryRow(context.Background(), query, strings.TrimSpace(username), strings.TrimSpace(password)).Scan(&id); err != nil {
		return 0, err
	}

	return id, nil
}

func (r *PostgresRepo) AllUsers() ([]models.User, error) {
	allUsers := make([]models.User, 0, 10)
	query := `SELECT id, username, password, created_at FROM users`
	rows, err := r.db.Query(context.Background(), query)

	if err != nil {
		return allUsers, err
	}
	defer rows.Close()
	for rows.Next() {
		var user models.User
		if err := rows.Scan(&user.Id, &user.Username, &user.Password, &user.CreatedAt); err != nil {
			return allUsers, err
		}
		allUsers = append(allUsers, user)
	}
	return allUsers, nil
}

func (r *PostgresRepo) DeleteUser(id int) (int, error) {
	query := `DELETE FROM users WHERE id = $1 RETURNING id`
	if err := r.db.QueryRow(context.Background(), query, id).Scan(&id); err != nil {
		return 0, err
	}

	return id, nil
}

func (r *PostgresRepo) GetUserByLogin(username string) (models.User, error) {
	var user models.User
	query := `SELECT id, username, password, created_at FROM users WHERE username = $1`
	if err := r.db.QueryRow(context.Background(), query, strings.TrimSpace(username)).Scan(&user.Id, &user.Username, &user.Password, &user.CreatedAt); err != nil {
		if err == pgx.ErrNoRows {
			return user, errors.New("user not found")
		} else {
			return user, err
		}
	}
	return user, nil
}
