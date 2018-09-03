use Mix.Releases.Config,
    # This sets the default release built by `mix release`
    default_release: :default,
    # This sets the default environment used by `mix release`
    default_environment: :dev

# For a full list of config options for both releases
# and environments, visit https://hexdocs.pm/distillery/configuration.html


# You may define one or more environments in this file,
# an environment's settings will override those of a release
# when building in that environment, this combination of release
# and environment configuration is called a profile

environment :dev do
  set dev_mode: true
  set include_erts: false
  set cookie: :"!VhD=[9:QZJ(ED}0:aC{]Pj8@U3/w=Y)*yD}DfN*%URg(tPZ38xljm.x|,?nL,U7"
end

environment :prod do
  set include_erts: true
  set include_src: false
  set cookie: :"Lg)xc$C4Xz(%LIO7k9EL`HJ90UE|8EJ(TCJog|4Hk0,QjPZ?1ES@(s9;6H1@2tH9"
end

# You may define one or more releases in this file.
# If you have not set a default release, or selected one
# when running `mix release`, the first release in the file
# will be used by default

release :smoodle do
  set version: current_version(:smoodle)
end

