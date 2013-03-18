class UsersController < ApplicationController
  def index
    queue = TorqueBox::Messaging::Queue.lookup '/queues/kvizer-ci/test'
    cache = TorqueBox::Infinispan::Cache.new(:name => 'treasure', :persist => '/data/treasure')

    str = "start messages: #{queue.count_messages} users: #{User.count} cache: #{cache.get('time').inspect}<br/>"

    begin
      TorqueBox.transaction do
        User.create :name => 'asd'
        queue.publish 'asd'
        cache.put 'time', Time.now

        #str << "before rollback messages: #{queue.count_messages} users: #{User.count} cache: #{cache.get('time').inspect}<br/>"

        raise 'rollback'
      end
    rescue => e
      p e
    end

    str << "end messages: #{queue.count_messages} users: #{User.count} cache: #{cache.get('time').inspect}<br/>"

    cache.clear
    User.delete_all
    queue.remove_messages

    render :text => str
  end
end
