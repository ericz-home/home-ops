package main

import (
	"io"
	"os"
	"strings"
)

type cfg struct {
	DebugMode bool

	DiscordToken       string
	HomeAssistantToken string
	HomeAssistantURL   string
}

var Config cfg

func readEnvPath(env string) (string, error) {
	path := os.Getenv(env)

	f, err := os.Open(path)
	if err != nil {
		return "", err
	}
	b, err := io.ReadAll(f)
	if err != nil {
		return "", err
	}

	return strings.TrimSpace(string(b)), nil
}

func parseConfig() error {
	discordToken, err := readEnvPath("DISCORD_TOKEN_PATH")
	if err != nil {
		return err
	}

	haToken, err := readEnvPath("HOME_ASSISTANT_TOKEN_PATH")
	if err != nil {
		return err
	}

	haURL := os.Getenv("HOME_ASSISTANT_URL")

	Config.DiscordToken = discordToken
	Config.HomeAssistantToken = haToken
	Config.HomeAssistantURL = haURL
	return nil
}
