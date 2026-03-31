package main

import (
	"backend-for-flutter/internal/config"
	"backend-for-flutter/internal/handlers"
	"backend-for-flutter/internal/storage"
	"context"
	"log"
	"net/http"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/jackc/pgx/v5/pgxpool"
)

func main() {
	r := gin.Default()
	dsn, err := config.LoadConfig()
	if err != nil {
		log.Print(err)
		panic(err)
	}

	pool, err := pgxpool.New(context.Background(), dsn)
	if err != nil {
		panic(err)
	}
	if err := pool.Ping(context.Background()); err != nil {
		panic(err)
	}
	usersRepo := storage.NewPostgresRepo(pool)
	userHandler := handlers.NewUserHandler(usersRepo)

	r.POST("/register", userHandler.RegisterUser)
	r.POST("/login", userHandler.LoginUser)

	serv := http.Server{
		Handler: r,
		Addr:    ":8080",
	}
	go func() {
		log.Print("Server started")
		if err := serv.ListenAndServe(); err != http.ErrServerClosed {
			log.Print(err)
			panic(err)
		}
	}()
	sigChan := make(chan os.Signal, 1)
	signal.Notify(sigChan, syscall.SIGINT, syscall.SIGTERM)
	<-sigChan
	log.Print("Shutting down...")
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	serv.Shutdown(ctx)
	log.Print("Server stopped")
	cancel()
}
