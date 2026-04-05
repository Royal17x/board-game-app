package main

import (
	"backend-for-flutter/internal/config"
	"backend-for-flutter/internal/handlers"
	"backend-for-flutter/internal/middleware"
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
		log.Fatal(err)
	}

	pool, err := pgxpool.New(context.Background(), dsn)
	if err != nil {
		log.Fatal(err)

	}
	if err := pool.Ping(context.Background()); err != nil {
		log.Fatal(err)

	}
	repo := storage.NewPostgresRepo(pool)
	userHandler := handlers.NewUserHandler(repo)
	gameHandler := handlers.NewGameHandler(repo)
	reviewHandler := handlers.NewReviewHandler(repo)
	bookingHandler := handlers.NewBookingHandler(repo)
	favoriteHandler := handlers.NewFavoriteHandler(repo)

	// auth
	r.POST("/register", userHandler.RegisterUser)
	r.POST("/login", userHandler.LoginUser)
	// games
	r.GET("/games", gameHandler.GetAllGames)
	// reviews
	r.GET("/games/:id/reviews", reviewHandler.GetReviews)
	r.POST("/games/:id/reviews", reviewHandler.CreateReview)
	// bookings
	r.POST("/bookings", bookingHandler.CreateBooking)
	r.GET("/bookings", bookingHandler.GetBookings)
	r.DELETE("/bookings/:id", bookingHandler.DeleteBooking)
	// favorites
	r.GET("/favorites", favoriteHandler.GetFavorites)
	r.POST("/favorites", favoriteHandler.AddFavorite)
	r.DELETE("/favorites", favoriteHandler.RemoveFavorite)

	admin := r.Group("/")
	admin.Use(middleware.AdminOnly(repo))
	{
		admin.POST("/games", gameHandler.CreateGame)
		admin.DELETE("/games/:id", gameHandler.DeleteGame)
		admin.PUT("/games/:id", gameHandler.UpdateGame)
	}

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
