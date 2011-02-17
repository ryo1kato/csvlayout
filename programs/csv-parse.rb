# CSV -- module for generating/parsing CSV data.

# $Id$

# This module is copyrighted free software by NAKAMURA, Hiroshi.
# You can redistribute it and/or modify it under the same term as Ruby.

module CSV

public
  class ColData
    attr( :data, true )		# Datum as string.
    attr( :isNull, true )	# Is this datum null?

    def ==( rhs )
      ( @data == rhs.data ) and ( @isNull == rhs.isNull )
    end

    def initialize( data = "", isNull = true )
      @data = data
      @isNull = isNull
    end
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
  def CSV.parse( buf )
    myIdx = 0
    resType = :DT_COLSEP
    cols = Array.new()
    begin
      while ( resType.equal?( :DT_COLSEP ))
	aCol = ColData.new()
	resType, myIdx = parseBody( buf, myIdx, aCol )
	cols.push( aCol.isNull ? nil : aCol.data )
	break unless resType.equal?( :DT_BODY )
	resType, myIdx = parseSeparator( buf, myIdx )
      end
    rescue IllegalFormatError
      raise
      return []
    end
    cols
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
  def CSV.create( cols )
    return "" if ( cols.size == 0 )
    resType = :DT_COLSEP
    resStr = ""
    idx = 0
    while true
      col = if ( cols[ idx ] == nil )
	  ColData.new( '', true )
	else
	  ColData.new( cols[ idx ].to_s, false )
	end
      createBody( col, resStr )
      idx += 1
      break if ( idx == cols.size )
      createSeparator( :DT_COLSEP, resStr )
    end
    resStr
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
  def CSV.parseLine( buf, idx, colDataArray )
    nofCol = 0
    myIdx = idx
    resType = :DT_COLSEP
    begin
      while ( resType.equal?( :DT_COLSEP ))
	aCol = ColData.new()
	resType, myIdx = parseBody( buf, myIdx, aCol )
	colDataArray.push( aCol )
	break unless resType.equal?( :DT_BODY )
	nofCol += 1
	resType, myIdx = parseSeparator( buf, myIdx )
      end
    rescue IllegalFormatError
      return 0, 0
    end
    return 0, 0 unless resType.equal?( :DT_ROWSEP )
    return nofCol, myIdx	# num of parsed column, parsed chars.
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
  def CSV.createLine( colDataArray, cols, resStr )
    return if ( colDataArray.size == 0 )
    resType = :DT_COLSEP
    idx = 0
    createBody( colDataArray[ idx ], resStr )
    idx += 1
    while (( idx < cols ) && ( idx != colDataArray.size ))
      createSeparator( :DT_COLSEP, resStr )
      createBody( colDataArray[ idx ], resStr )
      idx += 1
    end
    if ( idx == cols )
      createSeparator( :DT_ROWSEP, resStr )
    else
      createSeparator( :DT_COLSEP, resStr )
    end
    idx
  end

private
  class IllegalFormatError < Exception; end

  # state for parsing 1 datum.
  # :DT_FAIL
  # :DT_BODY = 1
  # :DT_COLSEP = 2
  # :DT_ROWSEP = 3
  # :DT_CANCELED = 4

  # state for parsing 1 char.
  # :ST_START = 0
  # :ST_DATA = 1
  # :ST_QUOTE = 2
  # :ST_END = 3

  def CSV.parseBody( buf, idx, aCol )
    myIdx = idx
    quoted = false
    cr = false
    aCol.isNull = false	unless buf.empty? 
    state = :ST_START
    while (( c = buf[myIdx] ) && !state.equal?( :ST_END ))
      if ( c == ?, )
	if ( state.equal?( :ST_START ))
	  aCol.isNull = true
	  myIdx -= 1
	  state = :ST_END
	elsif ( state.equal?( :ST_DATA ))
	  if ( cr )
	    aCol.data << "\r"
	    cr = false
	  end
	  if ( !quoted )
	    myIdx -= 1
	    state = :ST_END
	  else
	    aCol.data << c.chr
	  end
	elsif ( state.equal?( :ST_QUOTE ))
	  raise IllegalFormatError.new() if ( cr )
	  myIdx -= 1
	  state = :ST_END
	else
	  raise IllegalFormatError.new()
	end
      elsif ( c == ?" )
	if ( state.equal?( :ST_START ))
	  quoted = true
	  state = :ST_DATA
	elsif ( state.equal?( :ST_DATA ))
	  if ( cr )
	    aCol.data << "\r"
	    cr = false
	  end
	  if ( quoted )
	    state = :ST_QUOTE
	  else
	    raise IllegalFormatError.new()
	  end
	elsif ( state.equal?( :ST_QUOTE ))
	  raise IllegalFormatError.new() if ( cr )
	  aCol.data << c.chr
	  state = :ST_DATA
	else
	  raise IllegalFormatError.new()
	end
      elsif ( c == ?\r )
	state = :ST_DATA if ( state.equal?( :ST_START ))
	cr = true
      elsif ( c == ?\n )
	if ( state.equal?( :ST_START ) || state.equal?( :ST_DATA ))
	  if ( cr )
	    if ( quoted )
	      aCol.data << "\r\n"
	      state = :ST_DATA
	    else
	      myIdx -= 2
	      state = :ST_END
	    end
	    cr = false
	  else
	    aCol.data << c.chr
	    state = :ST_DATA
	  end
	elsif ( state.equal?( :ST_QUOTE ))
	  if ( cr )
	    myIdx -= 2
	    state = :ST_END
	    cr = false
	  else
	    raise IllegalFormatError.new()
	  end
	else
	  raise IllegalFormatError.new()
	end
      else
	if ( state.equal?( :ST_START ) || state.equal?( :ST_DATA ))
	  if ( cr )
	    aCol.data << "\r"
	    cr = false
	  end
	  aCol.data << c.chr
	  state = :ST_DATA
	elsif ( state.equal?( :ST_QUOTE ))
	  raise IllegalFormatError.new()
	else
	  raise IllegalFormatError.new()
	end
      end
      myIdx += 1
    end
    if ( state.equal?( :ST_END ))
      return :DT_BODY, myIdx
    else
      return :DT_CANCELED, idx
    end
  end

  def CSV.parseSeparator( buf, idx )
    myIdx = idx
    resType = :DT_FAIL
    if ( buf[myIdx] == ?, )
      myIdx += 1
      resType = :DT_COLSEP
    elsif (( buf[myIdx] == ?\r ) && ( buf[myIdx + 1] == ?\n ))
      myIdx += 2
      resType = :DT_ROWSEP
    else
      raise IllegalFormatError.new()
    end
    return resType, myIdx
  end

  def CSV.createBody( colData, resStr )
    addData = colData.data.dup
    if ( !colData.isNull )
      if ( addData.gsub!( '"', '""' ) || ( addData =~ /[,\"]/ ) ||
	  ( addData =~ /\r\n/ ) || ( colData.data.empty? ))
	resStr << '"' << addData << '"'
      else
	resStr << addData
      end
    end
  end

  def CSV.createSeparator( type, resStr )
    case type
    when :DT_COLSEP
      resStr << ','
    when :DT_ROWSEP
      resStr << "\r\n"
    else
      raise RuntimeError.new( 'not reached.' )
    end
  end
end
