package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

func LoadConfig() (string, error) {
	if err := godotenv.Load(); err != nil {
		return "", err
	}
	dsn := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable",
		GetEnv("POSTGRES_USER", ""),
		GetEnv("POSTGRES_PASSWORD", ""),
		GetEnv("POSTGRES_HOST", ""),
		GetEnv("POSTGRES_PORT", ""),
		GetEnv("POSTGRES_DB", ""))
	return dsn, nil
}
func GetEnv(key string, defaultVal string) string {
	if val, ok := os.LookupEnv(key); ok {
		return val
	}
	return defaultVal
}
