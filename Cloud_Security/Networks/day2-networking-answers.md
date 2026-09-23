# Day 2 — Networking for Cloud Security — Lab Answers

Exported: 2026-08-18T16:13:46.477255+00:00
Progress: 10/10 challenges answered
Day marked complete: No

---

## [01] Interface Recon (RECON).

**Objective:** Identify your machine's network interface and local IP address.

**Commands used:**
```
ip addr
```

**Task:** Run the command above in your terminal. Find your primary network interface name (e.g. eth0, wlan0) and its assigned local IP address.

**My answer:**

etho 172.20.144.246/21

---

## [02] DNS Resolution (RECON)

**Objective:** See DNS convert a domain name into an IP address.

**Commands used:**
```
nslookup google.com
```

**Task:** Run the command above. Note the IP address(es) returned. Then explain: what job does DNS do for a cloud service like AWS Route 53?

**My answer:**

Non-authoritative answer:
Name:   google.com
Address: 142.250.134.139.
Name:   google.com
Address: 142.250.134.101
Name:   google.com
Address: 142.250.134.102.
Name:   google.com
Address: 142.250.134.138
Name:   google.com
Address: 142.250.134.113
Name:   google.com
Address: 142.250.134.100
Name:   google.com
Address: 2404:6800:4000:1006::8a
Name:   google.com
Address: 64:ff9b::8efb:dc6e
Name:   google.com
Address: 2404:6800:4000:1006::64
Name:   google.com
Address: 2404:6800:4000:1006::65
Name:   google.com
Address: 2404:6800:4000:1006::8a.

---

## [03] HTTPS Handshake Check (RECON)

**Objective:** Inspect HTTP response headers over HTTPS (port 443).

**Commands used:**
```
curl -I https://google.com
```

**Task:** Run the command above. Report the HTTP status code and the 'server' header if present. What does HTTPS traffic tell you about what's happening on port 443?

**My answer:**

HTTP/2 301
 and headers x-frame-options: SAMEORIGIN and x-xss-protection: 0
https encrypts the data before it's sent, so port 443 traffic can't be read even if intercepted, unlike plain http

---

## [04] Path Trace (RECON)

**Objective:** See the network hops your traffic takes to reach a destination.

**Commands used:**
```
traceroute google.com
```
```
sudo apt install traceroute   # if missing
```

**Task:** Run traceroute against google.com. Report roughly how many hops your traffic passed through before reaching the destination.

**My answer:**

2 hops:  1  LAPTOP-C88IQ160.mshome.net (172.20.144.1)  1.900 ms  1.332 ms  1.189 ms
 2  10.170.65.180 (10.170.65.180)  6.911 ms  6.723 ms  6.618 ms.

---

## [05] Port Watch (RECON)

**Objective:** Find which ports your own machine is listening on

**Commands used:**
```
ss -tulnp
```
```
netstat -tulnp   # fallback if ss unavailable
```

**Task:** Run the command above. List at least two listening ports/services you find, and for each, note whether it's TCP or UDP.

**My answer:**

udp   UNCONN   10.255.255.254:53   0.0.0.0:*
tcp   LISTEN   10.255.255.254:53   0.0.0.0:*

---

## [06] TCP vs UDP (CONCEPT)

**Objective:** Understand the core tradeoff between the two main transport protocols

**Task:** No command for this one. In your own words, explain the core difference between TCP and UDP, and give one real example of when a cloud application would use each.

**My answer:**

tcp is like gided gateway to data packet(transmission control protocol) and udp is user datagram protocol which is no guided path for data packets flow tcp is more secure than udp and udp is faster tcp example: google and banking websites and udp is for gaming

---

## [07] Port 22 Exposure (CONCEPT)

**Objective:** Understand why SSH exposure is a classic cloud misconfiguration.

**Task:** Explain in your own words why leaving port 22 (SSH) open to 0.0.0.0/0 (the entire internet) on an AWS EC2 instance is dangerous, and what you'd do instead to secure it.

**My answer:**

so ssh when its left open lots of people or bots scan for the port and try to access the ssh by finding vernubilitieds dos or bruite force, i would restrict the security groups to allow them only from my own ip so that apart from my local network no one can access it and use ssm so that that ssh port 22 no need to be open at all

---

## [08] Security Group vs NACL (CONCEPT)

**Objective:** Distinguish AWS's two firewall layers.

**Task:** Explain the difference between an AWS Security Group and a Network ACL (NACL) — specifically: stateful vs stateless, and instance-level vs subnet-level.

**My answer:**

in stateful if an inbound rule allows the flow of traffic it automatically configures the outboard rule regardless the outboards rules and in the stateless it is manually checked the traffic flow so both are required to monitor and configure

---

## [09] NAT Gateway Logic (CONCEPT)

**Objective:** Understand outbound-only internet access for private resources.

**Task:** Explain why a private-subnet resource (e.g. a database) would need a NAT Gateway to reach the internet for things like updates, but should never be given a public IP directly.

**My answer:**

because it lacks a public ip address and so it points to the nat gateway instead of internet gateway

---

## [10] DNS in Cloud Security (CONCEPT)

**Objective:** See DNS as an attack surface, not just a lookup service.

**Task:** Explain one way DNS can be abused or attacked (e.g. DNS hijacking, subdomain takeover, cache poisoning), and why this matters specifically for cloud-hosted apps.

**My answer:**

usually a company uses a third part dns routing and when uh update the server or change the dns routing uh will have to clear the dns track in the third party and if we dont do that the attacker can hijack and take the old dns and which may lead to a subdomain takeover

---
