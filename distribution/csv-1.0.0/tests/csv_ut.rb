require 'runit/testcase'
require 'runit/cui/testrunner'

$:.push( '../lib' )

require 'csv.rb'

class TestCSV < RUNIT::TestCase

  public

  def setup
    @simpleCSVData = {
      [ nil ] => '',
      [ '' ] => '""',
      [ 'foo' ] => 'foo',
      [ 'foo', 'bar' ] => 'foo,bar',
      [ 'foo', '"bar"', 'baz' ] => 'foo,"""bar""",baz',
      [ 'foo', 'foo,bar', 'baz' ] => 'foo,"foo,bar",baz',
      [ 'foo', '""', 'baz' ] => 'foo,"""""",baz',
      [ 'foo', '', 'baz' ] => 'foo,"",baz',
      [ 'foo', nil, 'baz' ] => 'foo,,baz',
      [ 'foo', "\r", 'baz' ] => "foo,\r,baz",
      [ 'foo', "\n", 'baz' ] => "foo,\n,baz",
      [ 'foo', "\r\n", 'baz' ] => "foo,\"\r\n\",baz",
      [ 'foo', "\r.\n", 'baz' ] => "foo,\r.\n,baz",
      [ 'foo', "\r\n\n", 'baz' ] => "foo,\"\r\n\n\",baz",
      [ 'foo', '"', 'baz' ] => 'foo,"""",baz',
    }

    @fullCSVData = {
      [ d( '', true ) ] => '',
      [ d( '' ) ] => '""',
      [ d( 'foo' ) ] => 'foo',
      [ d( 'foo' ), d( 'bar' ) ] => 'foo,bar',
      [ d( 'foo' ), d( '"bar"' ), d( 'baz' ) ] => 'foo,"""bar""",baz',
      [ d( 'foo' ), d( 'foo,bar' ), d( 'baz' ) ] => 'foo,"foo,bar",baz',
      [ d( 'foo' ), d( '""' ), d( 'baz' ) ] => 'foo,"""""",baz',
      [ d( 'foo' ), d( '' ), d( 'baz' ) ] => 'foo,"",baz',
      [ d( 'foo' ), d( '', true ), d( 'baz' ) ] => 'foo,,baz',
      [ d( 'foo' ), d( "\r" ), d( 'baz' ) ] => "foo,\r,baz",
      [ d( 'foo' ), d( "\n" ), d( 'baz' ) ] => "foo,\n,baz",
      [ d( 'foo' ), d( "\r\n" ), d( 'baz' ) ] => "foo,\"\r\n\",baz",
      [ d( 'foo' ), d( "\r.\n" ), d( 'baz' ) ] => "foo,\r.\n,baz",
      [ d( 'foo' ), d( "\r\n\n" ), d( 'baz' ) ] => "foo,\"\r\n\n\",baz",
      [ d( 'foo' ), d( '"' ), d( 'baz' ) ] => 'foo,"""",baz',
    }
  end

  def d( data, isNull = false )
    CSV::ColData.new( data, isNull )
  end

  def teardown
    # Nothing to do.
  end

  # NAME
  #   CSV::create
  #
  # SYNOPSIS
  #   str = CSV::create( cols )
  #
  # ARGS
  #   cols: 'Array' of columns data('String') to be converted to CSV string.
  #
  # RETURNS
  #   str: 'String' of generated CSV data.
  #
  # DESCRIPTION
  #   Create a line from columns data.
  #   
  def test_s_create
    assert_equal( '', CSV.create( [] ))
    @simpleCSVData.each do | col, str |
      buf = CSV.create( col )
      assert_equal( str, buf )
    end
  end

  # NAME
  #   CSV::createLine
  #
  # SYNOPSIS
  #   idx = CSV::createLine( colDataArray, cols, resStr )
  #
  # ARGS
  #   colDataArray: 'Array' of 'CSV::ColData' to be converted to CSV string.
  #   cols: num of cols in A line.
  #   resStr: 'String' for created string buffer.
  #
  # RETURNS
  #   idx: num of converted columns.
  #
  # DESCRIPTION
  #   Convert A line from columns data to string.
  #   
  def test_s_createLine
    @fullCSVData.each do | col, str |
      buf = ''
      CSV.createLine( col, col.size, buf )
      assert_equal( str + "\r\n", buf )
    end

    buf = ''
    toBe = ''
    @fullCSVData.each do | col, str |
      CSV.createLine( col, col.size, buf )
      toBe << str << "\r\n"
    end
    assert_equal( toBe, buf )
  end

  # NAME
  #   CSV::parse
  #
  # SYNOPSIS
  #   cols = CSV::parse( buf )
  #
  # ARGS
  #   buf: 'String' to be parsed.
  #
  # RETURNS
  #   cols: 'Array' of parsed columns('String').
  #
  # DESCRIPTION
  #   Parse a line from string.
  #   
  def test_s_parse
    @simpleCSVData.each do | col, str |
      buf = CSV.parse( str )
      assert_equal( col.size, buf.size )
      assert_equal( col, buf )
    end
  end

  # NAME
  #   CSV::parseLine
  #
  # SYNOPSIS
  #   col, idx = CSV::parseLine( buf, idx, colDataArray )
  #
  # ARGS
  #   buf: 'String' to be parsed.
  #   idx: index of parsing location of `buf'.
  #   colDataArray: 'Array' for parsed columns buffer.
  #
  # RETURNS
  #   col: num of parsed columns.
  #   idx: index of next parsing location of `buf'.
  #
  # DESCRIPTION
  #   Parse A line from string.
  #   
  def test_s_parseLine
    @fullCSVData.each do | col, str |
      buf = []
      CSV.parseLine( str, 0, buf )
      assert_equal( col.size, buf.size )
      assert_equal( col, buf )
    end

    buf = []
    toBe = []
    @fullCSVData.each do | col, str |
      CSV.parseLine( str, 0, buf )
      toBe.concat( col )
    end
    assert_equal( toBe.size, buf.size )
    assert_equal( toBe, buf )
  end

  # sample data
  #
  #  1      2       3         4       5        6      7    8
  # +------+-------+---------+-------+--------+------+----+------+
  # | foo  | "foo" | foo,bar | ""    |(empty) |(null)| \r | \r\n |
  # +------+-------+---------+-------+--------+------+----+------+
  # | NaHi | "Na"  | Na,Hi   | \r.\n | \r\n\n | "    | \n | \r\n |
  # +------+-------+---------+-------+--------+------+----+------+
  #
  def test_s_parseAndCreate
    colSize = 8
    csvStr = "foo,!!!foo!!!,!foo,bar!,!!!!!!,!!,,\r,!\r\n!\r\nNaHi,!!!Na!!!,!Na,Hi!,\r.\n,!\r\n\n!,!!!!,\n,!\r\n!\r\n".gsub!( '!', '"' )

    myStr = csvStr.dup
    res1 = []; res2 = []
    idx = 0
    col, idx = CSV::parseLine( myStr, 0, res1 )
    col, idx = CSV::parseLine( myStr, idx, res2 )

    myStr = ''
    col = CSV::createLine( res1, colSize, myStr )
    col = CSV::createLine( res2, colSize, myStr )
    assert_equal( myStr, csvStr )
  end
end

if $0 == __FILE__
  testrunner = RUNIT::CUI::TestRunner.new
  if ARGV.size == 0
    suite = TestCSV.suite
  else
    suite = RUNIT::TestSuite.new
    ARGV.each do |testmethod|
      suite.add_test(TestCSV.new(testmethod))
    end
  end
  testrunner.run(suite)
end
