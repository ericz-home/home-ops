package main

import (
	"io"
	"os"
)

type cfg struct {
	DiscordToken       string
	HomeAssistantToken string
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

	return string(b), nil
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

	Config.DiscordToken = discordToken
	Config.HomeAssistantToken = haToken
	return nil
}
