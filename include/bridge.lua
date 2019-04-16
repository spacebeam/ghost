#!/usr/bin/env luajit
--
-- Bridge between StarCraft 1.16.1 and TorchCraft 1.3
--
local argparse = require("argparse")
local socket = require("socket")
local uuid = require("uuid")
require("torch")
require("sys")
local tc = require("torchcraft")
local utils = require("torchcraft.utils")
-- This are from our custom blackboard
local macro = require("spaceboard.macro")
local meta = require("spaceboard.meta")
local micro = require("spaceboard.micro")

-- Set default float tensor type
torch.setdefaulttensortype('torch.FloatTensor')
-- Debug can take values 0, 1, 2 (from no output to most verbose)
tc.DEBUG = 0
-- Gen random seed
uuid.randomseed(socket.gettime()*10000)
-- Spawn UUID
local spawn_uuid = uuid()
print("Starting bridge 1.3 " .. spawn_uuid)
-- CLI argument parser
local parser = argparse() {
    name = "bridge",
    description = "Bridge between StarCraft 1.16.1 and TorchCraft 1.3",
    epilog = "(luajit prototype)"
}
parser:option("-t --hostname", "Give hostname/ip to VM", "127.0.0.1")
parser:option("-p --port", "Port for TorchCraft", 11111)

-- Bridge system variables
local restarts = -1
-- Skip bwapi frames
local skip_frames = 7
-- Parse your arguments
local args = parser:parse()
local hostname = args['hostname']
local port = args['port'] 

-- Do your main loop 
while restarts < 5 do
    restarts = restarts + 1
    tc:init(hostname, port)
    local loops = 1
    local actions = {}
    local update = tc:connect(port)
    if tc.DEBUG > 1 then
        print('Received init: ', update)
    end
    assert(tc.state.replay == false)
    -- first message to BWAPI's side is setting up variables
    local setup = {
        tc.command(tc.set_speed, 0), tc.command(tc.set_gui, 1),
        tc.command(tc.set_cmd_optim, 1),
    }
    tc:send({table.concat(setup, ':')})
    -- measure execution timer 
    local tm = torch.Timer()
    -- game loop
    while not tc.state.game_ended do
        tm:reset()
        -- receive update from game engine
        update = tc:receive()
        if tc.DEBUG > 1 then
            print('Received update: ', update)
        end
        loops = loops + 1
        
        if tc.state.battle_frame_count % skip_frames == 0 then
            actions = macro.manage_economy(actions, tc)
        elseif tc.state.game_ended then
            break
        else
            -- skip frame do nothing
        end
        -- testing timer
        print('Time elapsed ' .. tm:time().real .. ' seconds')
        -- if debug make some noise!
        if tc.DEBUG > 1 then
            print("Sending actions: " .. actions)
        end
        tc:send({table.concat(actions, ':')})
    end
    tc:close()
    collectgarbage()
    sys.sleep(0.5)
    print("So Long, and Thanks for All the Fish!")
    collectgarbage()
end