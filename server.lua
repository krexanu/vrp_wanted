--[[
	kk kk  rrrr   eeeee   xx   xx
	kkk    rr rr  ee       xx xx
	k	   rr rr  eeeee      x
	kkk	   rrr	  ee       xx xx
	kk kk  rr rr  eeeee   xx   xx
]]

local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")


vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP","vRP_wanted")
vRPCwanted = Tunnel.getInterface("vRP_wanted","vRP_wanted")

vRPwanted = {}
Tunnel.bindInterface("vRP_wanted",vRPwanted)
Proxy.addInterface("vRP_wanted",vRPwanted)

local sql = [[
    UPDATE
        vrp_users
    SET
        wanted = CASE WHEN wanted > 0 THEN wanted - 1 END
]]

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(600000)
        MySQL.Async.execute(sql,{}, function(data)end)
    end
end)

local function ch_wantedadd(player,choice)
	local user_id = vRP.getUserId({player})
	vRP.prompt({player,"Player ID:","",function(player, id)
		id = tonumber(id)
		if id == nil or id == "" or id <=0 then
			vRPclient.notify(player,{"Pune un ID valid","error"})
		else
			vRP.prompt({player,"Wanted level: ( ( 1-6 ) )","",function(player, wanted)
				wanted = tonumber(wanted)
				if wanted == nil or wanted == "" or wanted < 1 or wanted > 6 then
					vRPclient.notify(player,{"Pune un wanted level corect","error"})
				else
					vRP.prompt({player,"Motiv: ( ( Maxim 30 de caractere ) )","",function(player, cautatpentru)
						cautatpentru = tostring(cautatpentru)
						if cautatpentru == nil or cautatpentru == "" then
							vRPclient.notify(player,{"Pune un motiv corect","error"})
						else
							if string.len(cautatpentru) <= 30 then
								MySQL.Async.execute("UPDATE vrp_users SET wanted = @wanted, cautatpentru = @cautatpentru WHERE id = @id",{["@id"] = id,['@wanted'] = wanted,["@cautatpentru"] = cautatpentru}, function(data)end)
							else
								vRPclient.notify(player,{"Maxim 30 de caractere","error"})
							end
						end
					end})
				end
			end})
		end
	end})
end

local function ch_scoatejucatoru(player,targetid)
	local user_id = vRP.getUserId({player})
	if user_id~=nil then
		vRP.prompt({player,"Player ID:","",function(player, id)
			id = tonumber(id)
			if id == nil or id == "" or id <=0 or id == user_id then
				vRPclient.notify(player,{"ID invalid","error"})
			else
				MySQL.Async.execute("UPDATE vrp_users SET wanted = @wanted id = @id",{["@id"] = targetid,['@wanted'] = 0}, function(data)end)
			end
		end})
	end
end

local function ch_wantedlist(player,choice)
	local user_id = vRP.getUserId({player})
	SetTimeout(400, function()
		vRP.buildMenu({"Lista Wanted", {player = player}, function(menu2)
			menu2.name = "Lista Wanted"
			menu2.css={top="75px",header_color="rgba(200,0,0,0.75)"}
			menu2.onclose = function(player) vRP.openMainMenu({player}) end
			local user_id = vRP.getUserId({player})
			vRP.openMenu({player,menu2})
			MySQL.Async.fetchAll('SELECT `wanted`,`cautatpentru`, `id` FROM `vrp_users` WHERE `wanted` != 0', {}, function(rows)
				for i,v in pairs(rows) do
					cautat = v.wanted
					id = v.id
					cautatpentru = v.cautatpentru
					MySQL.Async.fetchAll('SELECT * FROM vrp_user_identities WHERE user_id = @id', {["@id"] = id}, function(rows)
						for pula,pizda in pairs(rows) do
							name = tostring(pizda.name)
							pname = tostring(pizda.firstname)
							targetid = tonumber(pizda.user_id)
							menu2["ID: "..targetid] = {ch_wantedaddd, "Nume Prenume: <font color='yellow'>"..pname.." " ..name.."<font color='white'><br>Wanted Level: <font color='green'>"..cautat.."<font color='white'><br>Motiv: <font color='red'>"..cautatpentru.."</font>"}
							vRP.openMenu({player,menu2})
						end
					end)
				end
			end)
		end})
	end)
end

vRP.registerMenuBuilder({"police", function(add, data)
	local user_id = vRP.getUserId({data.player})
	if user_id ~= nil then
		local choices = {}
		if(vRP.hasGroup({user_id, "cop"}))then
			choices["Wanted"] = {function(player,choice)
				vRP.buildMenu({"Wanted", {player = player}, function(menu)
					menu.name = "Wanted"
					menu.css={top="75px",header_color="rgba(235,0,0,0.75)"}
					menu.onclose = function(player) vRP.openMainMenu({player}) end

					menu["Add Wanted"] = {ch_wantedadd,"Add some wanted level."}
					menu["Wanted List"] = {ch_wantedlist,"See people that are wanted."}
					menu["Scoate Wanted"] = {ch_scoatejucatoru,"Scoate wantedu unui jucator."}

					vRP.openMenu({player, menu})
				end})
			end, "Wanted"}
		end
		add(choices)
	end
end})
