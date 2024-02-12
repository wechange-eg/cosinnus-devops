# -*- mode: Python -*-
config.define_bool("light")
cfg = config.parse()
light = cfg.get("light", False)

docker_cache_days = 30
docker_cache_minutes = docker_cache_days*24*60
docker_prune_settings(
    disable=False,
    max_age_mins=docker_cache_minutes,
    num_builds=0,
    interval_hrs=1,
    keep_recent=2,
)
update_settings(max_parallel_updates=6)

local(
    'bash -c "{command}"'.format(
        command=" ".join([
            "[[ -z '$(docker network ls | grep wechange-traefik)' ]]",
            "&& docker network create wechange-traefik",
            "|| echo 'wechange-traefik already created'",
        ])
    )
)

composes = [
    "./wechange/traefik.yaml",
    "./wechange/wechange.yaml",
]
if not light:
    composes += [
        "./wechange/rocketchat.yaml",
        "./wechange/nextcloud.yaml",
        "./wechange/etherpad.yaml",
        "./wechange/ethercalc.yaml",
        "./wechange/wordpress.yaml",
    ]
docker_compose(composes)

include("./tilts/Tiltfile.traefik")
include("./tilts/Tiltfile.wechange.frontend")
include("./tilts/Tiltfile.wechange.backend")
if not light:
    include("./tilts/Tiltfile.rocketchat")
    include("./tilts/Tiltfile.nextcloud")
    include("./tilts/Tiltfile.etherpad")
    include("./tilts/Tiltfile.ethercalc")
    include("./tilts/Tiltfile.wordpress")
