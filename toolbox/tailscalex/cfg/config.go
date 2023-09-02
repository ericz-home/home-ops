package cfg

import (
	"fmt"
	"os"
	"path"
)

type OAuthClientConfig struct {
	ClientID     string
	ClientSecret string

	TokenFile string
}

var OAuth OAuthClientConfig

func Load() error {
	clientID := os.Getenv("TS_API_CLIENT_ID")
	clientSecret := os.Getenv("TS_API_CLIENT_SECRET")
	if clientID == "" || clientSecret == "" {
		return fmt.Errorf("must provide Tailscale OAuth Client Credentials")
	}

	tokenFile := os.Getenv("TS_TOKEN_FILE")
	if tokenFile == "" {
		home, err := os.UserHomeDir()
		if err != nil {
			return fmt.Errorf("Could not find home dir. %w", err)
		}
		tokenFile = path.Join(home, ".tailscalex", "token")

		err = os.MkdirAll(path.Dir(tokenFile), 0750)
		if err != nil {
			return err
		}
	}

	OAuth = OAuthClientConfig{
		ClientID:     clientID,
		ClientSecret: clientSecret,
		TokenFile:    tokenFile,
	}

	return nil
}
