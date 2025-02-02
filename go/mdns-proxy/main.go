package main

import (
	"context"
	"fmt"
	"log"
	"log/slog"
	"net"
	"os"
	"os/signal"
	"sync"
	"syscall"

	"github.com/flix-tech/k8s-mdns/mdns"
	"github.com/godbus/dbus/v5"
	"github.com/holoplot/go-avahi"
)

type typeEvent struct {
	svcType avahi.ServiceType
	add     bool
}

type svcEvent struct {
	svc avahi.Service
	add bool
}

func main() {
	ctx, cancel := context.WithCancel(context.Background())
	catchSignals(cancel)

	server := newAvahiServer()

	var wg sync.WaitGroup
	svcCh := ListenForServices(&wg, server)
	typesCh := ListenForServiceTypes(ctx, &wg, svcCh, server)

	Run(ctx, typesCh, server)

	close(svcCh)
	close(typesCh)

	slog.Info("Waiting for goroutines to exit")
	wg.Wait()
	slog.Info("Exiting")
}

func Run(ctx context.Context, ch chan<- typeEvent, server *avahi.Server) {
	// Create a ServiceTypeBrowser to listen for all service types
	stb, err := server.ServiceTypeBrowserNew(avahi.InterfaceUnspec, avahi.ProtoInet, "local", 0)
	if err != nil {
		log.Fatalf("Failed to create ServiceTypeBrowser: %v", err)
	}

	for {
		select {
		case svcType := <-stb.AddChannel:
			slog.Info("ADD new service type", "serviceType", svcType)
			ch <- typeEvent{
				svcType,
				true,
			}
		case svcType := <-stb.RemoveChannel:
			slog.Info("REMOVE service type", "serviceType", svcType)
			ch <- typeEvent{
				svcType,
				false,
			}
		case <-ctx.Done():
			slog.Info("Stopping main loop...")
			server.ServiceTypeBrowserFree(stb)
			return
		}
	}
}

func ListenForServiceTypes(ctx context.Context, wg *sync.WaitGroup, svcCh chan<- svcEvent, server *avahi.Server) chan<- typeEvent {
	ch := make(chan typeEvent, 10)

	wg.Add(1)
	go func() {
		defer wg.Done()

		var svcwg sync.WaitGroup
		svcBrowsers := map[avahi.ServiceType]*avahi.ServiceBrowser{}

		for t := range ch {
			if t.add {
				if _, ok := svcBrowsers[t.svcType]; ok {
					slog.Info("ignoring already seen service type", "serviceType", t.svcType)
					continue
				}

				browser, err := server.ServiceBrowserNew(avahi.InterfaceUnspec, avahi.ProtoInet, t.svcType.Type, t.svcType.Domain, 0)
				if err != nil {
					slog.Error("Failed to create ServiceBrowser", "error", err)
				}
				svcBrowsers[t.svcType] = browser

				svcwg.Add(1)
				go func() {
					defer svcwg.Done()
					for {
						select {
						case s := <-browser.AddChannel:
							slog.Info("ADD new service", "service", s)
							svcCh <- svcEvent{s, true}
						case s := <-browser.RemoveChannel:
							slog.Info("REMOVE service", "service", s)
							svcCh <- svcEvent{s, false}
						case <-ctx.Done():
							return
						}
					}
				}()
				slog.Info("Browsing services for new service type", "serviceType", t.svcType)
			} else {
				b, ok := svcBrowsers[t.svcType]
				if !ok {
					continue
				}

				server.ServiceBrowserFree(b)
				delete(svcBrowsers, t.svcType)
			}
		}

		for t, b := range svcBrowsers {
			slog.Info("Closing service browser", "serviceType", t)
			server.ServiceBrowserFree(b)
		}

		slog.Info("Waiting for service browsers to stop...")
		svcwg.Wait()
	}()

	return ch
}

func ListenForServices(wg *sync.WaitGroup, server *avahi.Server) chan<- svcEvent {
	ch := make(chan svcEvent)

	wg.Add(1)
	go func() {
		defer wg.Done()
		for op := range ch {
			if op.add {
				slog.Info("ADD service", "service", op.svc)
			} else {
				slog.Info("REMOVE service", "service", op.svc)
			}

			service, err := server.ResolveService(op.svc.Interface, op.svc.Protocol, op.svc.Name,
				op.svc.Type, op.svc.Domain, avahi.ProtoUnspec, 0)
			if err != nil {
				slog.Error("Error resolving service", "error", err, "service", op.svc)
				continue
			}
			slog.Info("RESOLVED service", "addr", service.Address, "service", service)

			if op.add {
				publish(service.Host, service.Address)
			} else {
				unpublish(service.Host, service.Address)
			}
		}
	}()

	return ch
}

func unpublish(host string, addr string) {
	for _, r := range records(host, addr) {
		err := mdns.UnPublish(r)
		if err != nil {
			slog.Error("Failed to unpublish record", "host", host, "ip", addr, "error", err)
		}
	}
}

func publish(host string, addr string) {
	for _, r := range records(host, addr) {
		err := mdns.Publish(r)
		if err != nil {
			slog.Error("Failed to publish record", "host", host, "ip", addr, "error", err)
		}
	}
}

func records(host string, addr string) []string {
	ip := net.ParseIP(addr)
	if ip == nil {
		slog.Error("Failed to parse ip", "addr", addr, "host", host)
		return nil
	}

	reverseIp := net.IPv4(ip[15], ip[14], ip[13], ip[12])
	records := []string{
		fmt.Sprintf("%s. 120 IN A %s", host, ip),
		fmt.Sprintf("%s.in-addr.arpa. 120 IN PTR %s.", reverseIp, host),
	}

	return records
}

func newAvahiServer() *avahi.Server {
	conn, err := dbus.SystemBus()
	if err != nil {
		log.Fatalf("Cannot get system bus: %v", err)
	}

	// Connect to the Avahi server
	server, err := avahi.ServerNew(conn)
	if err != nil {
		log.Fatalf("Failed to connect to Avahi: %v", err)
	}

	log.Println("Connected to Avahi")

	return server
}

func catchSignals(cancel context.CancelFunc) {
	// Create a channel to receive OS signals
	signalCh := make(chan os.Signal, 1)

	// Notify the signalChan on receiving SIGINT or SIGTERM
	signal.Notify(signalCh, syscall.SIGINT, syscall.SIGTERM)

	// Start a goroutine to handle the signal and send a done signal
	go func() {
		// Wait for a signal to be received
		sig := <-signalCh
		slog.Info("Received signal", "signal", sig)

		// Send done signal when a signal is received
		cancel()
	}()
}
