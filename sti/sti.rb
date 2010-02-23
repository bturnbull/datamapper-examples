require 'sqlite3'
require 'dm-core'

DataMapper.setup(:default, 'sqlite3://:memory:')

## simple sti
class Foo
  include DataMapper::Resource

  property :id,   Serial
  property :name, String
  property :type, Discriminator
end

class Bar < Foo
  property :place, String
end

DataMapper.auto_migrate!
Foo.new(:name => 'Frank').save
Bar.new(:name => 'George', :place => 'LA').save
Foo.all
# => [#<Foo @id=1 @name="Frank" @type=Foo>,
#     #<Bar @id=2 @name="George" @type=Bar @place=<not loaded>>]
bar = Foo.first(:name => "George")
# => #<Bar @id=2 @name="George" @type=Bar @place=<not loaded>>
bar.place
# => "LA"
bar
# => #<Bar @id=2 @name="George" @type=Bar @place="LA">
Bar.all
# => [#<Bar @id=2 @name="George" @type=Bar @place="LA">]



