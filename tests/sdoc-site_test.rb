require "test_helper"
require "rack/test"
require "#{File.dirname(__FILE__)}/../sdoc-site.rb"
require "sdoc_site/builds"
require "sdoc_site/automation"

set :environment, :test

class SDocSiteTest < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Sinatra::Application
  end
  
  def test_should_redirect_to_closest_simple_minor
    stub_builds_list %w(ruby-v1.8.2 ruby-v1.9.2), [] do
      get '/doc/ruby-v1.8.1/'
      assert last_response.redirect?
      assert last_response.location.include?('ruby-v1.8.2')
    end
  end
  
  def test_should_404_if_build_allready_exists
    stub_builds_list %w(ruby-v1.8.2 ruby-v1.9.2), [] do
      get '/doc/ruby-v1.8.2/unexistent'
      assert_equal 404, last_response.status
    end
  end
  
  def test_should_404_if_build_does_not_exist
    stub_builds_list %w(ruby-v1.8.2 ruby-v1.9.2), [] do
      get '/doc/something-v1.8.2/unexistent'
      assert_equal 404, last_response.status
    end
  end
  
  def test_should_redirect_to_max_named_version
    stub_builds_list %w(ruby-v1.8.2 ruby-v1.9RC2), [] do
      get '/doc/ruby/'
      assert last_response.redirect?, 'should redirect'
      assert last_response.location.include?('ruby-v1.9RC2'), 'shoud redirect to latest version'
    end
  end
  
  def test_should_404_if_name_not_exists
    stub_builds_list %w(ruby-v1.8.2 ruby-v1.9RC2), [] do
      get '/doc/someting/'
      assert_equal 404, last_response.status
    end
  end
  
  def test_should_redirect_to_closest_available_merged
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), [] do
      get '/doc/ruby-v1.8_rails-v2.2.1/'
      assert last_response.redirect?, 'should redirect'
      assert last_response.location.include?('rails-v2.2.2_ruby-v1.8'), 'shoud redirect to latest version'
    end
  end
  
  def test_should_404_if_merged_minors_do_not_match
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), [] do
      get '/doc/ruby-v1.8_rails-v2.3.1/'
      assert_equal 404, last_response.status
    end
  end
  
  def test_should_404_if_merged_build_cant_be_made
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), [] do
      get '/doc/ruby-v1.8_something-v2.2.1/'
      assert_equal 404, last_response.status
    end
  end
  
  def test_should_404_if_exact_same_merged_build_exists
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), %w(ruby-v1.8_rails-v2.2.1) do
      get '/doc/ruby-v1.8_rails-v2.2.1/'
      assert_equal 404, last_response.status
    end
  end
  
  def test_should_redirect_to_max_merged_named_version
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), [] do
      get '/doc/ruby_rails/'
      assert last_response.redirect?, 'should redirect'
      assert last_response.location.include?('rails-v2.2.2_ruby-v1.9'), 'shoud redirect to latest version'
    end
  end
  
  def test_should_show_building_page_if_merged_build_is_locked
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), [] do
      SDocSite::Locks.any_instance.stubs(:locked?).returns(true)
      get '/doc/ruby-v1.8_rails-v2.2.2/'
      assert last_response.ok?
    end
  end
  
  def test_should_merge_if_builds_available
    stub_builds_list %w(ruby-v1.8 ruby-v1.9 rails-v2.2.2), [] do
      SDocSite::Locks.any_instance.stubs(:locked?).returns(false)
      SDocSite::Locks.any_instance.expects(:lock)
      SDocSite::Automation.any_instance.expects(:merge_builds).returns(true)
      SDocSite::Automation.any_instance.expects(:generate_index).returns(true)
      get '/doc/rails-v2.2.2_ruby-v1.8/'
      assert last_response.redirect?
    end
  end
  
  def stub_builds_list simple_dirs, merged_dirs, &block
    SDocSite::Builds::List.any_instance.stubs(:simple_builds_dirs).returns(simple_dirs)
    SDocSite::Builds::List.any_instance.stubs(:merged_builds_dirs).returns(merged_dirs)
    yield
  end
  
end
