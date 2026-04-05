-- +goose Up
CREATE TABLE reviews (
    id SERIAL PRIMARY KEY,
    game_id INTEGER NOT NULL REFERENCES board_games(id) ON DELETE CASCADE,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

CREATE UNIQUE INDEX reviews_user_game_unique ON reviews(user_id, game_id);

-- +goose Down
DROP TABLE reviews;