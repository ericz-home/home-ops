package main

import (
	"log/slog"
	"net"
	"sync"

	"github.com/hashicorp/mdns"
	"github.com/holoplot/go-avahi"
	"github.com/miekg/dns"
)

type Zones struct {
	zones []*mdns.MDNSService
	lock  sync.RWMutex
}

func NewZones() *Zones {
	return &Zones{
		zones: make([]*mdns.MDNSService, 0, 10),
	}
}

func (z *Zones) Records(q dns.Question) []dns.RR {
	z.lock.RLock()
	defer z.lock.RUnlock()

	ans := []dns.RR{}
	for _, s := range z.zones {
		ans = append(ans, s.Records(q)...)
	}

	return ans
}

func (z *Zones) Publish(svc avahi.Service) {
	ip := net.ParseIP(svc.Address)
	if ip == nil {
		slog.Error("Failed to parse ip", "addr", svc.Address, "host", svc.Host, "name", svc.Name)
		return
	}

	txt := []string{}
	for _, b := range svc.Txt {
		txt = append(txt, string(b))
	}

	s, err := mdns.NewMDNSService(
		svc.Name,
		svc.Type,
		// convert to fqdn
		svc.Domain+".",
		svc.Host+".",
		int(svc.Port),
		[]net.IP{ip},
		txt,
	)
	if err != nil {
		slog.Error("Failed to create mdns service", "error", err, "addr", svc.Address, "host", svc.Host, "name", svc.Name)
		return
	}

	z.lock.Lock()
	z.zones = append(z.zones, s)
	z.lock.Unlock()
}

func (z *Zones) Unpublish(svc avahi.Service) {
	z.lock.Lock()
	defer z.lock.Unlock()

	n := 0
	for _, s := range z.zones {
		// ignores checking IP because we don't have ipv6
		if s.Instance == svc.Name && s.Service == svc.Type {
			continue
		}
		z.zones[n] = s
		n++
	}
	z.zones = z.zones[:n]
}
