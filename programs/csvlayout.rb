#coding:utf-8

=begin
======================== COPYRIGHT ==============================
csvlayout - Tiled label print merge print with LaTeX

Permission of copy and/or modification of this program is granted
under the term of GPL (GNU General Pubric lisence) version 2 or higher
or same terms of ruby(at your option).



                                          Feb 2000 (C) Ryoichi Kato
=end



############# Include Files and default value of variable ################
require "optparse"
require "pathname"
require "csv"
load "texlayout.rb"


###################### HELP and VERSION infomations ######################
Version="1.0.3"
Copyright="2013 (C) Ryoichi Kato"


USAGE=<<"EOUSAGE"
USAGE: #{File.basename($0)} [OPTIONS] [-f CSV_FILE.csv] FORMAT_FILE.fmt
         try --help for detail.
EOUSAGE



HELP=<<"EOHELP"
USAGE: #{File.basename($0)} [OPTIONS] [-f CSV_FILE.csv] FORMAT_FILE.fmt

 * Read CSV data file as table such like that of spread sheet or RDBMS,
   and output formated data in  LaTeX Format.
   output should be specified by the file with extention ".fmt".
 * By default, input file is CSV,  each line of input file is row, and row
   is separated into columns by delimiter(commna).

OPTIONS
  -f, --csvfile
    Spesify csv file explicitly (This option will over ride the definition
    of csv file in .fmt file.)
  -d, --debug
    Print debugging imformation.
  -h, --help
    Print this help and exit.
  -v, --version
    Print verion information and exit.
EOHELP


########################### Global Variables #############################

#  acceptable format option definition
#========================================
Fmt_acceptable_options = {
# "option_name"      => /RE_of_acceptable_pattern/
  "csvfile"          => /"[-\w]+\.csv"/,
  "print_pagenum"    => /true|false/,
  "print_frame"      => /true|false/,
  "print_tombow"     => /true|false/,
  "repeat_direction" => /true|false/,

  "paper_width"      => /[0-9]+/,
  "paper_height"     => /[0-9]+/,

  "box_width"        => /[0-9]+/,
  "box_height"       => /[0-9]+/,

  "x_repeat"         => /[0-9]+/,
  "y_repeat"         => /[0-9]+/,

  "x_offset"         => /[0-9]+/,
  "y_offset"         => /[0-9]+/,
  "tex_prologue"     => /.*/,
  "item"             => /\[[\s\.0-9]+,[\s\.0-9]+,.*\]/
}



##################### Commandline Option Parse ###########################
$skip  = FALSE
$DEBUG = FALSE
csvfilepath = nil
opt = OptionParser.new
opt.on('-h', '--help') { |flag| print HELP; exit(0); }
opt.on('-v', '--version') { |flag|
  print File.basename($0), "  ", "Ver.", Version, "                ",Copyright, "\n"
  exit(0)
}
#opt.on('-s', '--skip') { $skip = TRUE }
opt.on('-d', '--debug') { $DEBUG = TRUE }
opt.on('-f FILE', '--csvfile FILE') { |flag| csvfilepath = flag }

opt.parse!(ARGV)

unless fmtfilepath=ARGV[0]
  STDERR.print "please specify .fmt file.\n"
  STDERR.print USAGE
  exit(1)
end



######################### Format File Parser #############################


class Format
  def initialize(fmtfilepath)
    @fmtfile=File.open(fmtfilepath, "r:UTF-8")
    @items = []
    @linenum=0

    while @line = @fmtfile.gets
      @linenum += 1

      #Check the line is form of expression for value substitution.
      #If not just ignore the line
      if /^\s*([a-z_-]+)\s*=\s*([^;]*)\s*$/ =~ @line
    @option_matched = $1 # preserve match result
    @value_matched  = $2 
    @correspond_option_found = false # not found yet :)

    # Search the option definition to see the expression is valid
    Fmt_acceptable_options.each do |option,value_re|
      if  @option_matched == option           # correspont option for the statemment found.
        if value_re =~ @value_matched         # AND value for it is valid

          #########################
          #   then eval the line  #
          #########################
          if @option_matched == "item"
        eval "@item = #{@value_matched}"
        if @item.length == 3
          @items.push(@item)
        else
          STDERR.print "W: Illegal value \"#{@value_matched}\" for item in line #{@linenum}.\n"
          STDERR.print "Parse Error.\n"
          exit(1)
        end
          else
        eval "def #{option};  return #{@value_matched}; end"
          end
          @correspond_option_found = TRUE # and flag is ON.
          break                           # not neccesary far more query in this line

        else # @value_matched isn't valid format (described as value_re).
          STDERR.print "W: Illegal value \"#{@value_matched}\" for #{option} in line #{@linenum}.\n"
          STDERR.print "Parse Error.\n"
          exit(1)
        end
      end
    end #of Fmt_acceptable_option.each

    unless @correspond_option_found
      STDERR.print "W: Illegal option/statement in line #{@linenum}: #{@line}.\n"
      STDERR.print "Parse Error.\n"
      exit(1)
    end
      end
    end
  end #of initialize

  def items
    return @items
  end

end #of Format class definition


############### convert data to formated text ###################

def convert(data_array, format)
  formated_text_and_coordinates=[]
  for i in 0 ... format.items.size
    formated_text_current = format.items[i][2].clone
    for j in 0 ... data_array.size
      if formated_text_current =~ /__#{j}__/
        if ! data_array[j] then data_array[j]="" end
        eval "formated_text_current.gsub!(/__#{j}__/,data_array[j])"
      end
    end
    formated_text_and_coordinates.push([format.items[i][0], format.items[i][1], formated_text_current])
  end
  return formated_text_and_coordinates
end




#################################################################
#                        Main Routine
#################################################################


format=Format.new(fmtfilepath)
texpaper=TeXLayout::Paper.new

if defined? format.paper_width && defined? format.paper_height
  texpaper.set_papersize(format.paper_width, format.paper_height)
end
if defined? format.box_width && defined? format.box_height
  texpaper.set_boxsize(format.box_width, format.box_height)
end
if defined? format.x_repeat && defined? format.y_repeat
  texpaper.set_repeat(format.x_repeat, format.y_repeat)
end
if defined? format.x_offset && defined? format.y_offset
  texpaper.set_offset(format.x_offset, format.y_offset)
end
if defined? format.print_pagenum then texpaper.print_pagenum(format.print_pagenum) end
if defined? format.print_frame then texpaper.print_frame(format.print_frame) end
if defined? format.print_tombow then texpaper.print_tombow(format.print_tombow) end
if defined? format.repeat_direction then texpaper.repeat_direction(format.repeat_direction) end
if defined? format.tex_prologue then texpaper.tex_prologue(format.tex_prologue) end


#============== csv file open & parse ================
unless csvfilepath
  if defined? format.csvfile
    csvfilepath=Pathname.new(format.csvfile) # FIXME. make it relative to formatfile
    if not csvfilepath.absolute?
        csvfilepath = Pathname.new(fmtfilepath).dirname() + csvfilepath
    end
  else
    STDERR.print "CSV file isn't specified in .fmt file.\n"
    STDERR.print "use -f option to specify it in command line.\n\n"
    STDERR.print USAGE
    exit(1)
  end
end


if File.readable?(csvfilepath)
  CSV::foreach(csvfilepath, "r:UTF-8") do |row|
        texpaper.put( convert(row, format) )
  end
else
  STDERR.print "Can't load csvfile: #{csvfilepath}\n"
  exit(1)
end


texpaper.print_tex
