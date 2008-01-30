require 'test/unit'

require 'rubygems'
gem 'activerecord', '>= 2.0.2'
require 'active_record'
require 'erb'

require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class CrossSiteSniperTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def setup
    setup_db
    @hunter = SnipeHunter.create(:name => '<b>One</b>', :description => '<b>One Description</b>',:age => 42)
  end
  def teardown; teardown_db; end
  
  def hunter; @hunter; end
    
  def test_basics
    assert_equal('&lt;b&gt;One&lt;/b&gt;',hunter.name)
    assert_equal('&lt;b&gt;One&lt;/b&gt;',hunter.name_with_html_escaping)
    assert_equal('<b>One</b>',hunter.name_without_html_escaping)
    assert_equal('<b>One</b>',hunter[:name])
  end
end

class SnipeHunter < ActiveRecord::Base; end
  
def setup_db
  ActiveRecord::Schema.define(:version => 1) do
    create_table :snipe_hunters do |t|
      t.column :name, :string
      t.column :description, :text
      t.column :age, :integer      
      t.column :updated_at, :datetime
    end
  end
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end