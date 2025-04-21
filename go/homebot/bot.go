package main

import (
	"context"
	"log/slog"

	"github.com/bwmarrin/discordgo"
)

type Bot struct{}

func (b *Bot) Run(ctx context.Context) error {
	discord, err := discordgo.New("Bot " + Config.DiscordToken)
	if err != nil {
		slog.Error("Could not create discord client", "error", err)
		return err
	}

	// add event handler
	discord.AddHandler(b.handleMessage)
	discord.Open()
	defer discord.Close()

	slog.Info("Running homebot...")

	<-ctx.Done()

	slog.Info("Exiting homebot...")
	return nil
}

func (b *Bot) handleMessage(session *discordgo.Session, message *discordgo.MessageCreate) {
	/* prevent bot responding to its own message
	this is achived by looking into the message author id
	if message.author.id is same as bot.author.id then just return
	*/
	if message.Author.ID == session.State.User.ID {
		return
	}

	slog.Debug("received event", "event", "messageCreate", "message", message)

	session.ChannelMessageSend(message.ChannelID, "I received your message")
}
