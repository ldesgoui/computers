[
  { addr = "0.0.0.0"; port = 80; }
  { addr = "[::0]"; port = 80; }
  { addr = "[fd4c:a29e:23d9::1]"; port = 9080; ssl = false; proxyProtocol = true; }
  { addr = "0.0.0.0"; port = 443; ssl = true; }
  { addr = "[::0]"; port = 443; ssl = true; }
  { addr = "[fd4c:a29e:23d9::1]"; port = 9443; ssl = true; proxyProtocol = true; }
]

