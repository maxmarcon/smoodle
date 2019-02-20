#!/usr/bin/env bash
# Why this? Because ENV SECRET_KEY_BASE=$(mix phx.gen.secret) does not work
# (the output of a command can't be used to set an environment variable)
export SECRET_KEY_BASE=$(mix phx.gen.secret)
exec $*
