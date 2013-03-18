require 'bundler/setup'

require 'cuba'
require 'active_record'
require 'torquebox'

#require 'torquebox/transactions'
#require 'torquebox/active_record_adapters'


ActiveRecord::Base.establish_connection(
    :adapter  => 'jdbcpostgresql',
    :database => 'kvizer-ci',
    :xa       => true,
    :user     => 'root',
    :host     => 'localhost',
    :encoding => 'utf8'
)

class User < ActiveRecord::Base
end

Cuba.define do

  on get do
    on 'hello' do

      #on ':who' do |who|
      #  res.write "Hello #{who}!"
      #end

      res.write 'Hello world!'
    end

    on root do
      res.redirect 'hello'
    end

    on 'test' do
      queue = TorqueBox::Messaging::Queue.lookup '/queues/kvizer-ci/test'
      cache = TorqueBox::Infinispan::Cache.new(:name => 'treasure', :persist => '/data/treasure')

      res.write "messages: #{queue.count_messages} users: #{User.count} cache: #{cache.get('time').inspect}<br/>"

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

      res.write "messages: #{queue.count_messages} users: #{User.count} cache: #{cache.get('time').inspect}<br/>"

      cache.clear
      User.delete_all
      queue.remove_messages
    end

    on 'pry' do
      binding.pry
    end
  end
end