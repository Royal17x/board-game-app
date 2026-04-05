package middleware

import (
	"backend-for-flutter/internal/storage"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
)

func AdminOnly(repo *storage.PostgresRepo) gin.HandlerFunc {
	return func(c *gin.Context) {
		userIdStr := c.GetHeader("X-User-Id")
		if userIdStr == "" {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "unauthorized"})
			return
		}
		userId, err := strconv.Atoi(userIdStr)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "invalid user id"})
			return
		}
		user, err := repo.GetUserById(userId)
		if err != nil {
			c.AbortWithStatusJSON(http.StatusUnauthorized, gin.H{"error": "user not found"})
			return
		}
		if user.Role != "admin" {
			c.AbortWithStatusJSON(http.StatusForbidden, gin.H{"error": "forbidden: admins only"})
			return
		}
		c.Next()
	}
}
