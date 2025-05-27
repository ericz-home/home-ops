package tailscale

import (
	"context"
	"encoding/json"
	"errors"
	"io"
	"io/fs"
	"os"
	"time"

	"github.com/tailscale/tailscale-client-go/tailscale"
	"golang.org/x/oauth2"
	"golang.org/x/oauth2/clientcredentials"

	"ericz-home/toolbox/tailscalex/cfg"
)

const (
	TAILNET = "ericz-home.org.github"
	TAG     = "tag:lab"
)

var OAUTH_SCOPES = []string{"devices", "dns"}

var ts *tailscale.Client

func Init(ctx context.Context) error {
	token, err := getToken(ctx)
	if err != nil {
		return err
	}

	client, err := tailscale.NewClient(token.AccessToken, TAILNET)
	if err != nil {
		return err
	}

	ts = client
	return nil
}

type KeyFilter func(tailscale.Key) bool

func KeyExpiresWithin(d time.Duration) KeyFilter {
	return func(k tailscale.Key) bool {
		return time.Until(k.Expires) <= d
	}
}

func ListKeys(ctx context.Context, filters ...KeyFilter) ([]tailscale.Key, error) {
	keys, err := ts.Keys(ctx)
	if err != nil {
		return nil, err
	}

	tmp := keys[:0]
	for _, k := range keys {
		key, err := ts.GetKey(ctx, k.ID)
		if err != nil {
			return nil, err
		}

		keep := true
		for _, f := range filters {
			if !f(key) {
				keep = false
				break
			}
		}
		if !keep {
			continue
		}

		tmp = append(tmp, key)
	}

	return tmp, nil
}

func CreateKey(ctx context.Context, description string) (tailscale.Key, error) {
	caps := tailscale.KeyCapabilities{}
	caps.Devices.Create.Reusable = true
	caps.Devices.Create.Ephemeral = true
	caps.Devices.Create.Preauthorized = true
	caps.Devices.Create.Tags = []string{TAG}

	return ts.CreateKey(ctx,
		caps,
		tailscale.WithKeyExpiry(30*24*time.Hour),
		tailscale.WithKeyDescription(description),
	)
}

func DeleteKey(ctx context.Context, id string) error {
	return ts.DeleteKey(ctx, id)
}

func getToken(ctx context.Context) (*oauth2.Token, error) {
	f, err := os.Open(cfg.OAuth.TokenFile)
	if err != nil {
		if !errors.Is(err, fs.ErrNotExist) {
			return nil, err
		}

		return writeToken(ctx)
	}

	token, err := readToken(f)
	if err != nil {
		return nil, err
	}

	// only reuse token if within 10 minutes from expiry
	if time.Until(token.Expiry) > 10*time.Minute {
		return token, nil
	}

	return writeToken(ctx)
}

func readToken(r io.Reader) (*oauth2.Token, error) {
	b, err := io.ReadAll(r)
	if err != nil {
		return nil, err
	}

	var token oauth2.Token
	err = json.Unmarshal(b, &token)
	if err != nil {
		return nil, err
	}

	return &token, nil
}

func writeToken(ctx context.Context) (*oauth2.Token, error) {
	c := clientcredentials.Config{
		ClientID:     cfg.OAuth.ClientID,
		ClientSecret: cfg.OAuth.ClientSecret,
		TokenURL:     "https://api.tailscale.com/api/v2/oauth/token",
		Scopes:       OAUTH_SCOPES,
	}

	token, err := c.Token(ctx)
	if err != nil {
		return nil, err
	}

	b, err := json.Marshal(token)
	if err != nil {
		return nil, err
	}

	f, err := os.Create(cfg.OAuth.TokenFile)
	if err != nil {
		return nil, err
	}

	_, err = f.Write(b)
	if err != nil {
		return nil, err
	}

	return token, nil
}
