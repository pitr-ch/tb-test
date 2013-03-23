# Testing TorqueBox distributed transactions with standalone ActiveRecord

JRuby 1.7.2 was used with TorqueBox installed as gem. Using simple test in `web.rb` on url `/ci/test`

    begin
      TorqueBox.transaction do
        User.create :name => 'asd'
        queue.publish 'asd'
        cache.put 'time', Time.now
        raise 'rollback'
      end
    rescue => e
      p e
    end

Message publishing and cache `#put` is rollbacked, DB insert is not. 

