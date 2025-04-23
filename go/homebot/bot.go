package main

import (
	"context"
	"log/slog"
	"strings"

	"github.com/bwmarrin/discordgo"
)

type Bot struct {
	hass *HassClient

	conversationID string
}

func NewBot() *Bot {
	return &Bot{
		NewHass(),
		"",
	}
}

func (b *Bot) Run(ctx context.Context) error {
	discord, err := discordgo.New("Bot " + Config.DiscordToken)
	if err != nil {
		slog.Error("Could not create discord client", "error", err)
		return err
	}

	// add event handler
	discord.AddHandler(b.handleMessage)
	// discord.Identify.Intents =
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

	if strings.ToLower(message.Content) == "start a new conversation" {
		b.conversationID = ""
		session.MessageReactionAdd(message.ChannelID, message.ID, "🔄")
		slog.Info("Restarting conversation ID")
		return
	}

	slog.Debug("received event", "event", "messageCreate", "message", message)

	session.MessageReactionAdd(message.ChannelID, message.ID, "🤖")

	out, err := b.sendToHA(message.Content, b.conversationID)
	if err != nil {
		slog.Warn("error trying to communicate to HomeAssistant", "error", err)
		session.ChannelMessageSend(message.ChannelID, "❌ I received an error while processing your message")
		return
	}

	session.ChannelMessageSend(message.ChannelID, out)
}

func (b *Bot) sendToHA(text, id string) (string, error) {
	cr, ce, err := b.hass.Conversation(text, id)
	if err != nil {
		return "", err
	}

	slog.Debug("received response from HomeAssistant", "responseData", cr, "errorData", ce)

	if ce != nil {
		return ce.Speech, nil
	}

	b.conversationID = cr.ConversationID
	return cr.Speech, nil
}
