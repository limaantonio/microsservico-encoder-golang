package services_test

import (
	"fullcycle-video-encoder/application/repositories"
	"fullcycle-video-encoder/application/services"
	"fullcycle-video-encoder/domain"
	"fullcycle-video-encoder/framework/database"
	"log"
	"testing"
	"time"

	godotenv "github.com/joho/godotenv"
	uuid "github.com/satori/go.uuid"
	"github.com/stretchr/testify/require"
)

func init() {
	err := godotenv.Load("../../.env")
	if err != nil {
		log.Fatalf("Error loading .env file")
	}
}

func prepare() (*domain.Video, repositories.VideoRepositoryDb) {
	db := database.NewDbTest()
	defer db.Close()

	video := domain.NewVideo()
	video.ID = uuid.NewV4().String()
	video.Filepath = "Motivacional.mp4"
	video.CreatedAt = time.Now()

	repo := repositories.VideoRepositoryDb{Db: db}
	repo.Insert(video)

	return video, repo

}

func TestVideoServiceDownload(t *testing.T) {
	video, repo := prepare()
	videoService := services.NewVideoService()
	videoService.Video = video
	videoService.VideoRepository = repo

	err := videoService.Download("encoder-bucket001")
	require.Nil(t, err)

	err = videoService.Fragment()
	require.Nil(t, err)

}