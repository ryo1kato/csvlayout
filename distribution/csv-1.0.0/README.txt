	CSV module for Ruby
	    Version 0.1

	 NAKAMURA, Hiroshi



- Introduction

  Ruby library to parse or generate data in CSV format.


- Install

  Get an archived file. Extract a file 'csv.rb' from the archived file,
  and copy the file to a suitable directory in $:.


- Usage

  Add
    require 'csv'
  before using.


- What is 'CSV'?

  CSV: Comma Separated Value.
  In http://www.wotsit.org/, CSV is defined as follows.

	<CSV_file> ::= { <CSV_line> }
	<CSV_line> ::= <value> { "," <value> } <spaces_and_tabs> <CRLF>
	<value> ::= <spaces_and_tabs>
	        ( 
	          { <any_text_except_quotas_and_commas_and_smth_else> }
	        | <single_or_double_quote> 
	          <any_text_save_CRLF_with_corresponding_doubled_quotas>
	          <the_same_quote>
	        )
	[...]
	... and there is some problem with this format:
	different database systems have different definitions of the
	term <any_text_except_quotas_and_commas_and_smth_else> :)

  So, I defined CSV format, in my module, as follows. Fortunately, this is
  compatible with Microsoft's Excel(at least Excel '97 or later),
  and other applications like spread-sheets, DB, and so on.

	Record separator: CR + LF
	Field separator: ,(comma)
	Quote data like "..." if contains CR, LF, or ,(comma).
	Convert " -> "" when quoted.

	Field "" means null string. ( ex. some-data,"",some-data )
	Field which has no data means NULL. ( ex. some-data,,some-data )


- Module Functions

  'parse' and 'create' are for easy usage. It supports single line CSV format.
  So, CSV-string which is given to 'parse' does not have to terminated with
  CR + LF. And CSV-string which is given from 'create' does not terminated with
  CR + LF. No distinction of a NULL and an empty string.

  In 'parseLine' and 'createLine', cols data are expressed by 'Array' of
  CSV::ColData. CSV::ColData has two properties 'data' and 'isNull'.
  After 'parseLine', check each 'CSV::ColData#isNull' and get data with
  'CSV::ColData#data'.
  Before 'createLine', set each 'CSV::ColData#data' and 'CSV::ColData#isNull'.

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


- Sample

  require 'csv'

  #  1      2       3         4       5        6      7    8
  # +------+-------+---------+-------+--------+------+----+------+
  # | foo  | "foo" | foo,bar | ""    |(empty) |(null)| \r | \r\n |
  # +------+-------+---------+-------+--------+------+----+------+
  # | NaHi | "Na"  | Na,Hi   | \r.\n | \r\n\n | "    | \n | \r\n |
  # +------+-------+---------+-------+--------+------+----+------+
  ColSize = 8
  CSVStr = "foo,!!!foo!!!,!foo,bar!,!!!!!!,!!,,\r,!\r\n!\r\nNaHi,!!!Na!!!,!Na,Hi
!,\r.\n,!\r\n\n!,!!!!,\n,!\r\n!\r\n".gsub!( '!', '"' )  

  myStr = CSVStr.dup
  puts "...Parsing lines..."
  res1 = []; res2 = []
  idx = 0
  col, idx = CSV::parseLine( myStr, 0, res1 )
  print "#{col} column(s) parsed.\n"
  col, idx = CSV::parseLine( myStr, idx, res2 )
  print "#{col} column(s) parsed.\n"

  puts "Result:"
  res1.each do |col|; p col; end
  res2.each do |col|; p col; end

  puts "\n...Generating lines..."
  myStr = ""
  col = CSV::createLine( res1, ColSize, myStr )
  print "#{col} column(s) generated.\n"
  col = CSV::createLine( res2, ColSize, myStr )
  print "#{col} column(s) generated.\n"
  puts "Result:"
  print myStr


- Copying

  This module is copyrighted free software by NAKAMURA, Hiroshi.
  You can redistribute it and/or modify it under the same term as Ruby.


- Author

  Name: NAKAMURA, Hiroshi
  E-mail: nakahiro@sarion.co.jp
  URL: http://www.jin.gr.jp/~nahi/ (Japanese)


- History

  Jul 31, 1999 - version 0.1
    Initial version.
