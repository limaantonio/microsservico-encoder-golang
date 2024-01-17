package domain_test

import (
	"encoder/domain"
	"testing"
	"time"

	uuid "github.com/satori/go.uuid"
	"github.com/stretchr/testify/require"
)

func TestNewJob(t *testing.T) {
	video := domain.NewVideo()
	video.ID = uuid.NewV4().String()
	video.ResourceID = "abc"
	video.Filepath = "abc"
	video.CreatedAt = time.Now()

	job, err := domain.NewJob("path", "pending", video)

	require.NotNil(t, job)
	require.Nil(t, err)
}
