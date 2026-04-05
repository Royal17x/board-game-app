-- +goose Up
CREATE TABLE board_games (
    id SERIAL PRIMARY KEY,
    title TEXT NOT NULL,
    description TEXT NOT NULL,
    image_url TEXT NOT NULL DEFAULT '',
    created_at TIMESTAMP DEFAULT NOW()
);

-- +goose Down
DROP TABLE board_games;