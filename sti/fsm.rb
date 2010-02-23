require 'sqlite3'
require 'dm-core'
require 'state_machine'

DataMapper.setup(:default, 'sqlite3://:memory:')

## fsm with sti
class Foo
  include DataMapper::Resource

  property :id,    Serial
  property :name,  String
  property :state, String
  property :type,  Discriminator

  state_machine :initial => :unknown do
    event :start do
      transition :unknown => :working
    end
  end
end

class Bar < Foo

  state_machine :initial => :unknown do
    event :start do   ## can't redefine events
      transition :unknown => :borked
    end

    event :bork do
      transition :working => :borked
    end
    
    event :fix do
      transition :borked => :working
    end
  end

end

DataMapper.auto_migrate!
bar = Bar.create(:name => 'George')
# => [#<Bar @id=1 @name="George" @state="unknown" @type=Bar>]
bar.start
# => true
bar
# => [#<Bar @id=1 @name="George" @state="working" @type=Bar>]
bar.bork
# => true
bar
# => #<Bar @id=1 @name="George" @state="borked" @type=Bar>

class Baz < Bar

  ## can redefine initial state
  state_machine :initial => :borked do
  end

end

baz = Baz.create(:name => 'Sammy')
# => <Baz @id=2 @name="Sammy" @state="borked" @type=Baz>

class Bat < Foo

  ## will inherit initial state
  state_machine do
    event :wha do
      transition :unknown => :borked
    end
  end

end

bat = Bat.create(:name => 'Jerry')
=> #<Bat @id=2 @name="Jerry" @state="unknown" @type=Bat>

