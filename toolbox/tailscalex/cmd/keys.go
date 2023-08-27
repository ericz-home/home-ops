package cmd

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	"github.com/spf13/cobra"

	"ericz-home/toolbox/tailscalex/tailscale"
)

var keysCmd = &cobra.Command{
	Use:   "keys [command]",
	Short: "manage tailscale auth keys",
	Long:  `Provides CLI commands for managing tailscale auth keys`,
}

var createCmd = &cobra.Command{
	Use:   "create [description]",
	Short: "create new auth key",
	Long:  `Create a tailscale auth key with default settings`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return runCreate(cmd.Context(), args[0])
	},
}

var deleteCmd = &cobra.Command{
	Use:   "delete [id]",
	Short: "delete new auth key",
	Long:  `Delete a tailscale auth key by key ID`,
	Args:  cobra.ExactArgs(1),
	RunE: func(cmd *cobra.Command, args []string) error {
		return tailscale.DeleteKey(cmd.Context(), args[0])
	},
}

var listCmd = &cobra.Command{
	Use:   "list",
	Short: "list auth keys",
	Long:  `List tailscale auth keys with select filters`,
	Args:  cobra.NoArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		return runList(cmd.Context())
	},
}

var (
	within time.Duration
)

func init() {
	listCmd.Flags().DurationVar(&within, "expires-within", 0, "filter keys that expire within specified duration")

	keysCmd.AddCommand(createCmd)
	keysCmd.AddCommand(deleteCmd)
	keysCmd.AddCommand(listCmd)
}

func runList(ctx context.Context) error {
	var filters []tailscale.KeyFilter
	if within != 0 {
		filters = append(filters, tailscale.KeyExpiresWithin(within))
	}

	keys, err := tailscale.ListKeys(ctx, filters...)
	if err != nil {
		return err
	}

	for _, key := range keys {
		fmt.Printf("%s|%s\n", key.ID, key.Description)
	}

	return nil
}

func runCreate(ctx context.Context, description string) error {
	key, err := tailscale.CreateKey(ctx, description)
	if err != nil {
		return err
	}

	b, err := json.Marshal(key)
	if err != nil {
		return err
	}

	fmt.Println(string(b))
	return nil
}
