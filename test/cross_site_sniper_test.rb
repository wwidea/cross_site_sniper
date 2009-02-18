require 'test/unit'
require 'rubygems'
gem 'activerecord', '>= 2.3.0'
require 'active_record'
require 'erb'
require "#{File.dirname(__FILE__)}/../init"

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :dbfile => ":memory:")

class CrossSiteSniperTest < Test::Unit::TestCase
  # Replace this with your real tests.
  def setup
    setup_db
    @hunter = SnipeHunter.create(:name => '<b>One</b>', :title => '<b>One Title</b>', :description => '<b>One Description</b>',:age => 42)
    @snipe = Snipe.create(:species => '<b>Fitch</b>', :genus => '<b>Abercrombie</b>', :snipe_hunter => @hunter)
    @leprechaun = Leprechaun.create(:name => '<b>Clover McGillicuty</b>')
  end
  
  def teardown; teardown_db; end
  
  def hunter; @hunter; end
  def snipe; @snipe; end
  def leprechaun; @leprechaun; end
    
  def test_basics
    assert_equal('&lt;b&gt;One&lt;/b&gt;',hunter.name)
    assert_equal('&lt;b&gt;One&lt;/b&gt;',hunter.name_with_html_escaping)
    assert_equal('<b>One</b>',hunter.name_without_html_escaping)
    assert_equal('<b>One</b>',hunter[:name])
    
    assert_equal('<b>One Title</b>',hunter.title)
    assert_equal(false,hunter.respond_to?('title_with_html_escaping'))
    assert_equal(false,hunter.respond_to?('title_without_html_escaping'))
    
    assert_equal('&lt;b&gt;One&lt;/b&gt;(42)',hunter.name_and_age)
    assert_equal('<b>One</b>(42)',hunter.name_and_age_without_html_escaping)
    
    assert_equal('<b>Overriden</b>',hunter.description)
    assert_equal(false,hunter.respond_to?('description_with_html_escaping'))
    assert_equal(false,hunter.respond_to?('description_without_html_escaping'))
    assert_equal('<b>One Description</b>',hunter[:description])
    
    assert_equal(42,hunter.age)
    assert_equal(false,hunter.respond_to?('age_with_html_escaping'))
    assert_equal(false,hunter.respond_to?('age_without_html_escaping'))
    
    assert_equal('&lt;b&gt;Fitch&lt;/b&gt;',snipe.species)
    assert_equal('<b>Abercrombie</b>',snipe.genus)
    
    assert_equal('&lt;b&gt;Fitch&lt;/b&gt;',hunter.first_snipe_species)
    assert_equal('<b>Fitch</b>',hunter.first_snipe_species_without_html_escaping)
    
    assert_equal('<b>Clover McGillicuty</b>',leprechaun.name)
  end
end

class SnipeHunter < ActiveRecord::Base
  has_many :snipes
  #make title unescaped
  html_escape :except => :title
  
  #make description unescaped
  def description; '<b>Overriden</b>'; end
  
  def name_and_age; "#{name}(#{age})"; end
  
  def first_snipe_species; snipes.first.species; end
end

class Snipe < ActiveRecord::Base
  belongs_to :snipe_hunter
  #only escape species
  html_escape :only => :species
end

class Leprechaun < ActiveRecord::Base
  #completely disable xss protection on this model
  html_escape :none
end

def setup_db
  #Supress annoying Schema creation output when tests run
  old_stdout = $stdout
  $stdout = StringIO.new
  
  ActiveRecord::Schema.define(:version => 1) do
    create_table :snipe_hunters do |t|
      t.column :name, :string
      t.column :title, :string
      t.column :description, :text
      t.column :age, :integer      
      t.column :updated_at, :datetime
    end
    
    create_table :snipes do |t|
      t.column :snipe_hunter_id, :integer
      t.column :species, :string
      t.column :genus, :string
    end
    
    create_table :leprechauns do |t|
      t.column :name, :string
    end
  end
  
  #Re-enable stdout
  $stdout = old_stdout
end

def teardown_db
  ActiveRecord::Base.connection.tables.each do |table|
    ActiveRecord::Base.connection.drop_table(table)
  end
end