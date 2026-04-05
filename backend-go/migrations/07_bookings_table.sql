-- +goose Up
CREATE TABLE bookings (
    id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    game_id INTEGER NOT NULL REFERENCES board_games(id) ON DELETE CASCADE,
    booked_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, game_id)
);

-- +goose Down
DROP TABLE bookings;