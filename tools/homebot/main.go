package main

import (
	"context"
	"flag"
	"log/slog"
	"os"
	"os/signal"
)

var (
	level = new(slog.LevelVar)
)

func parseFlags() {
	b := flag.Bool("debug", false, "enable debug mode")
	flag.Parse()

	if *b {
		level.Set(slog.LevelDebug)
		Config.DebugMode = true
	}

}

func main() {
	h := slog.NewJSONHandler(os.Stdout, &slog.HandlerOptions{Level: level})
	slog.SetDefault(slog.New(h))

	parseFlags()

	err := parseConfig()
	if err != nil {
		slog.Error("Could not parse config", "error", err)
		return
	}

	ctx, cancel := context.WithCancel(context.Background())

	sigCh := make(chan os.Signal, 1)
	signal.Notify(sigCh, os.Interrupt)

	go func() {
		<-sigCh
		cancel()
	}()

	bot := NewBot()
	if err = bot.Run(ctx); err != nil {
		slog.Error("Exiting with error")
	}
}
