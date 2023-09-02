package cmd

import (
	"context"
	"fmt"
	"os"

	"github.com/spf13/cobra"

	"ericz-home/toolbox/tailscalex/cfg"
	"ericz-home/toolbox/tailscalex/tailscale"
)

var rootCmd = &cobra.Command{
	Use:   "tailscalex [command]",
	Short: "tailscalex contains extensions to the tailscale cli",
	Long:  `Extended CLI commands for use with tailscale CLI`,
}

func init() {
	cobra.OnInitialize(onInit)

	rootCmd.AddCommand(keysCmd)
	// rootCmd.AddCommand(dnsCmd)
}

func Execute() error {
	return rootCmd.ExecuteContext(context.TODO())
}

func exit(err error) {
	fmt.Fprintf(os.Stderr, "ERROR: %s", err)
	os.Exit(1)
}

func onInit() {
	if err := cfg.Load(); err != nil {
		exit(err)
	}

	if err := tailscale.Init(context.TODO()); err != nil {
		exit(err)
	}
}
