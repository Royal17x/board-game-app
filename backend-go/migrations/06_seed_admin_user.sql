-- +goose Up
-- Админ создан заранее, credentials: admin / admin123
INSERT INTO users (username, password, role)
VALUES ('admin', 'admin123', 'admin');

-- +goose Down
DELETE FROM users WHERE username = 'admin' AND role = 'admin';