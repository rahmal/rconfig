#!/usr/bin/env ruby

ROOT_DIR = File.expand_path(File.dirname(__FILE__))

# Loads the rconfig library
$LOAD_PATH << File.join(ROOT_DIR,"..","lib")

# Test environment:
ENV['TIER'] = 'development'
ENV.delete('CONFIG_OVERLAY') # Avoid unintended magic.

# Test dependencies:
require 'test/unit'
require 'fileutils' # FileUtils.touch

# Test target:
require 'rconfig'


class RConfigTest < Test::Unit::TestCase


  def setup

    begin
      RConfig.reload(true)
      RConfig.config_paths = "#{ROOT_DIR}/config_files"
      RConfig.reload = true
      RConfig.allow_reload = true  # default
      RConfig.reload_delay = nil # default
      RConfig.verbose = false # default
    rescue => err
      STDERR.puts err.inspect
      raise err
    end
    super
  end


  def teardown
    super
  end


  def test_basic
    RConfig.set_config_path = "#{ROOT_DIR}/config_files"
    RConfig.verbose = true
    RConfig.reload = true
    RConfig.allow_reload = true
    RConfig.reload_delay = nil # default
    
    assert_equal true, RConfig.test.secure_login
  end


  def test_default
    assert_equal "yo!", RConfig.test.default
  end


  def test_indifferent
    assert h = RConfig.test
    # STDERR.puts "h = #{h.inspect}:#{h.class}"

    assert hstr = h['hash_1']
    assert_kind_of Hash, hstr
    # STDERR.puts "hstr = #{hstr.inspect}:#{hstr.class}"

    assert hsym = h[:hash_1]
    assert hsym.object_id == hstr.object_id
  end


  def test_dot_notation
    assert h = RConfig.test
    assert h = h.hash_1
    assert h.foo
  end


  def test_dot_notation_overrun
    assert_raise NoMethodError do
      RConfig.test.hash_1.foo.a_bridge_too_far
    end
  end


  def test_array_notation
    assert h = RConfig.test[:hash_1]
    assert a = RConfig.test[:array_1]
  end


  def test_function_notation
    assert h = RConfig.test(:hash_1, 'foo')
    assert_equal nil, RConfig.test(:hash_1, 'foo', :too_far)
    assert_equal 'c', RConfig.test(:array_1, 2)
    assert_equal nil, RConfig.test(:array_1, "2")
  end


  def test_immutable
    assert_raise TypeError do
      RConfig.test.hash_1[:foo] = 1
    end
  end


  def test_to_yaml
    assert RConfig.test.to_yaml
  end


  def test_disable_reload
    # Clear out everything.
    RConfig.reload(true)

    # Reload delay
    RConfig.reload_delay = -1
    # RConfig.verbose = true
    RConfig.config_file_loaded = nil

    # Get the name of a config file to touch.
    assert cf1 = RConfig.get_config_files("test")
    assert cf1 = cf1[0][2]
      
    v = nil
    th = nil
    RConfig.disable_reload do 
      # Make sure first access works inside disable reload.
      assert th = RConfig.test
      assert_equal "foo", v = RConfig.test.hash_1.foo
      RConfig.config_file_loaded = nil

      # Get access again and insure that file was not reloaded.
      assert_equal v, RConfig.test.hash_1.foo
      assert th.object_id == RConfig.test.object_id
      assert ! RConfig.config_file_loaded
  
      # STDERR.puts "touching #{cf1.inspect}"
      FileUtils.touch(cf1)

      assert_equal v, RConfig.test.hash_1.foo
      assert th.object_id == RConfig.test.object_id
      assert ! RConfig.config_file_loaded
    end

    # STDERR.puts "reload allowed"
    assert ! RConfig.config_file_loaded
    assert th.object_id != RConfig.test.object_id
    assert_equal v, RConfig.test.hash_1.foo

    assert RConfig.config_file_loaded
    assert_equal v, RConfig.test.hash_1.foo
     

    # Restore reload_delay
    RConfig.reload_delay = false
    RConfig.verbose = false
  end


  def test_hash_merge
    assert_kind_of Array, cf = RConfig.get_config_files("test").select{|x| x[3]}
    STDERR.puts "cf = #{cf.inspect}"
    assert_equal "foo", RConfig.test.hash_1.foo
    assert_equal "baz", RConfig.test.hash_1.bar
    assert_equal "bok", RConfig.test.hash_1.bok
    assert_equal "zzz", RConfig.test.hash_1.zzz
  end


  def test_array
    assert_equal [ 'a', 'b', 'c', 'd' ], RConfig.test.array_1
  end


  def test_index
    assert_kind_of Hash, RConfig.get_config_file(:test)
  end


  def test_config_files
    assert_kind_of Array, cf = RConfig.get_config_files("test").select{|x| x[3]}
    #STDERR.puts "cf = #{cf.inspect}"

    if ENV['CONFIG_OVERLAY']
      assert_equal 3, cf.size
    else
      assert_equal 2, cf.size
    end

    assert_equal 5, cf[0].size
    assert_equal "test", cf[0][0]
    assert_equal "test", cf[0][1]
    assert_equal :yml, cf[0][3]

    assert_equal 5, cf[1].size
    if ENV['CONFIG_OVERLAY'] == 'gb'
      assert_equal "test_gb", cf[1][0]
      assert_equal "test_gb", cf[1][1]

      assert_equal 4, cf[2].size
      assert_equal "test", cf[2][0]
      assert_equal "test_local", cf[2][1]
    else
      assert_equal "test", cf[1][0]
      assert_equal "test_local", cf[1][1]
    end

  end


  def test_config_changed
    RConfig.reload(true)

    cf1 = RConfig.config_files("test")
    cf2 = RConfig.get_config_files("test")
    cf3 = RConfig.config_files("test")

    # Check that _config_files is cached.
    # STDERR.puts "cf1 = #{cf1.object_id.inspect}"
    # STDERR.puts "cf2 = #{cf2.object_id.inspect}"
    assert cf1.object_id != cf2.object_id
    assert cf1.object_id == cf3.object_id

    # STDERR.puts "cf1 = #{cf1.inspect}"
    # STDERR.puts "cf2 = #{cf2.inspect}"
    # Check that config_changed? is false, until touch.
    assert cf1.object_id != cf2.object_id
    assert_equal cf1, cf2
    assert_equal false, RConfig.config_changed?("test")

    # Touch a file.
    FileUtils.touch(cf1[1][2])
    cf2 = RConfig.get_config_files("test")
    assert cf1.object_id != cf2.object_id
    assert ! (cf1 === cf2)
    assert_equal true, RConfig.config_changed?("test")

    # Pull config again.
    RConfig.reload(true)
    cf3 = RConfig.config_files("test")
    cf2 = RConfig.get_config_files("test")
    # STDERR.puts "cf3 = #{cf1.inspect}"
    # STDERR.puts "cf2 = #{cf2.inspect}"
    assert cf1.object_id != cf3.object_id
    assert RConfig.config_files("test")
    assert_equal false, RConfig.config_changed?("test")

    # Pull config again, expect no changes.
    cf4 = RConfig.config_files("test")
    # STDERR.puts "cf3 = #{cf1.inspect}"
    # STDERR.puts "cf2 = #{cf2.inspect}"
    assert cf3.object_id == cf4.object_id
    assert RConfig.config_files("test")
    assert_equal false, RConfig.config_changed?("test")
 
  end


  def test_check_reload_disabled
    RConfig.reload(true)

    assert_kind_of Array, RConfig.config_files('test')
    
    RConfig.reload_disabled = true

    assert_kind_of Array, RConfig.load_config_files('test')

    RConfig.reload_disabled = nil
  end


  def test_on_load_callback
    # STDERR.puts "test_on_load_callback"

    RConfig.reload(true)
    # RConfig.verbose = 1

    cf1 = RConfig.config_files("test")

    assert_equal "foo", RConfig.test.hash_1.foo

    sleep 1

    called_back = 0

    RConfig.on_load(:test) do
      called_back += 1
      # STDERR.puts "on_load #{called_back}"
    end

    assert_equal 1, called_back

    assert_equal "foo", RConfig.test.hash_1.foo

    
    # STDERR.puts "Not expecting config change."
    assert_nil RConfig.check_config_changed
    assert_equal "foo", RConfig.test.hash_1.foo
    assert_equal 1, called_back

    file = cf1[0][2]
    # STDERR.puts "Touching file #{file.inspect}"
    File.chmod(0644, file)
    FileUtils.touch(file)
    File.chmod(0444, file)

    # STDERR.puts "Expect config change."
    assert_not_nil RConfig.check_config_changed
    assert_equal "foo", RConfig.test.hash_1.foo
    assert_equal 2, called_back

    # STDERR.puts "Not expecting config change."
    RConfig.reload(true)
    assert_nil RConfig.check_config_changed
    assert_equal "foo", RConfig.test.hash_1.foo
    assert_equal 2, called_back

    # STDERR.puts "test_on_load_callback: END"
  end


  def test_overlay_by_name
    assert_equal nil,   RConfig.overlay

    assert_equal "foo", RConfig.test.hash_1.foo
    assert_equal "foo", RConfig.test_GB.hash_1.foo

    assert_equal "bok", RConfig.test.hash_1.bok
    assert_equal "GB",  RConfig.test_GB.hash_1.bok

    assert_equal nil,   RConfig.test.hash_1.gb
    assert_equal "GB",  RConfig.test_GB.hash_1.gb
  end


  def test_overlay_change
    begin
      RConfig.overlay = 'gb'
      
      assert_equal "foo", RConfig.test.hash_1.foo
      assert_equal "foo", RConfig.test_GB.hash_1.foo
      assert_equal "foo", RConfig.test_US.hash_1.foo
      
      assert_equal "GB",  RConfig.test.hash_1.bok
      assert_equal "GB",  RConfig.test_GB.hash_1.bok
      assert_equal "US",  RConfig.test_US.hash_1.bok
      
      assert_equal "GB",  RConfig.test.hash_1.gb
      assert_equal "GB",  RConfig.test_GB.hash_1.gb
      assert_equal nil,   RConfig.test_US.hash_1.gb
      
      RConfig.overlay = 'us'
      
      assert_equal "foo", RConfig.test.hash_1.foo
      assert_equal "foo", RConfig.test_GB.hash_1.foo
      assert_equal "foo", RConfig.test_US.hash_1.foo
      
      assert_equal "US", RConfig.test.hash_1.bok
      assert_equal "GB", RConfig.test_GB.hash_1.bok
      assert_equal "US", RConfig.test_US.hash_1.bok
      
      assert_equal  nil,  RConfig.test.hash_1.gb
      assert_equal "GB",  RConfig.test_GB.hash_1.gb
      assert_equal  nil,  RConfig.test_US.hash_1.gb
 
      RConfig.overlay = nil

    ensure
      RConfig.overlay = nil
    end
  end


  # Expand this benchmark to
  # compare with relative minimum performance, for example
  # a loop from 1 to 1000000.
  # Make this test fail if the minimum peformance criteria
  # is not met.
  # -- kurt@cashnetusa.com 2007/06/12
  def test_zzz_benchmark
    n = 10000
    bm = Benchmark.measure do 
      n.times do 
        RConfig.test.hash_1.foo
      end
    end
    puts "\n#{n}.times =>#{bm}\n"
  end

end # class

