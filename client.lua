vRPwantedC = {}
Tunnel.bindInterface("vRP_wanted",vRPwantedC)
Proxy.addInterface("vRP_wanted",vRPwantedC)
vRP = Proxy.getInterface("vRP")
vRPSwanted = Tunnel.getInterface("vRP_wanted","vRP_wanted")

--am baut 5 beri si am zis sa pun asta pe net 