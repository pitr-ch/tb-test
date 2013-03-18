
TorqueBox.configure do
  ruby do
    version '1.9'
    #compile_mode 'jit'
    debug false
    interactive true
    #profile_api false
  end

  web do
    rackup 'lib/config.ru'
    context '/ci'
    static 'public'
    #host "www.host-one.com"
  end

  queue '/queues/kvizer-ci/test'
end