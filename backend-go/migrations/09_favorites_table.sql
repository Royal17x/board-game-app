-- +goose Up
CREATE TABLE favorites (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id INTEGER NOT NULL REFERENCES board_games(id) ON DELETE CASCADE,
    UNIQUE(user_id, game_id)
);

-- +goose Down
DROP TABLE favorites;