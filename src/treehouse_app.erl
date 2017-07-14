-module(treehouse_app).
-behaviour(application).

-export([start/2]).
-export([stop/1]).

start(_Type, _Args) ->
    application:ensure_all_started(econfig),
    econfig:register_config(forest, ["/etc/spawn.conf"], [autoreload]),
    econfig:subscribe(forest),
    Port = econfig:get_integer(forest, "engine", "port"),
    Dispatch = cowboy_router:compile([
        {'_', [
            {"/units/", units_handler, []},
            {"/schemes/", schemes_handler, []},
            {"/structures/", structures_handler, []}  
        ]}
    ]),
    {ok, _} = cowboy:start_clear(http_listener,
        [{port, Port}],
        #{env => #{dispatch => Dispatch}}
    ),
    {ok, _} = sub_bind:start_link(),
    treehouse_sup:start_link().

stop(_State) ->
    ok.