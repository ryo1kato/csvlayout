module TeXLayout
  class Paper

    def initialize
      #option value
      @paper_width=210   #default is  A4
      @paper_height=297
      @box_width=90.5    #name card size
      @box_height=50
      @x_repeat=2        #fit default box to default paper
      @y_repeat=5
      @x_offset=0
      @y_offset=0
      @print_pagenum=false
      @print_frame=false
      @print_tombow=false
      @repeat_direction=true

      #for alignment
      @page=[]           #array of pages
      @boxes=[]          #store all boxes as array when 'put' called
      @pagenum=1         #for page numbering
      @boxnum=0          #how many boxes already put in current page?
    end

    def debug
      STDERR.print "paper size:  ", @paper_width, " ", @paper_height, "\n"
      STDERR.print "box size:    ", @box_width, " ", @box_height, "\n"
      STDERR.print "repeatation: ", @x_repeat, " ", @y_repeat, "\n"
      STDERR.print "offset:      ", @x_offset, " ", @y_offset, "\n"
    end

    def set_papersize(paper_width, paper_height)
      @paper_width=paper_width
      @paper_height=paper_height
    end
    def set_boxsize(box_width, box_height)
      @box_width=box_width
      @box_height=box_height
    end
    def set_repeat(x_repeat, y_repeat)
      @x_repeat=x_repeat
      @y_repeat=y_repeat
    end
    def set_offset(x_offset, y_offset)
      @x_offset=x_offset
      @y_offset=y_offset
    end
    def print_pagenum(print_pagenum)
      @print_pagenum=print_pagenum
    end
    def print_frame(print_frame)
      @print_frame=print_frame
    end
    def print_tombow(print_tombow)
      @print_tombow=print_tombow
    end
    def repeat_direction(repeat_direction)
      @repeat_direction=repeat_direction
    end


    private
    def put_header

        print <<EOF
\\documentclass{article}
\\unitlength     = 1mm

\\parindent      = 0pt
\\headsep        = 0pt
\\headheight     = 0pt
\\marginparwidth = 0pt
\\marginparsep   = 0pt 
\\topmargin      = -25.4mm
\\evensidemargin = -25.4mm
\\oddsidemargin  = \\evensidemargin

\\textwidth      = #{@paper_width}mm
\\textheight     = #{@paper_height}mm

\\pagestyle{empty}
\\usepackage{graphicx,color}

\\begin{document}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
EOF
    end


    # put single row of csv data given as array of formated 'items[]'
    public
    def put( data_array )
      @boxes.push(data_array)
    end

    ############ calculate margin ############

    def print_tex
      ############# CALUCULATE margins etc #################
      # box alignment origin for TOP-LEFT of page is set to TOP-LEFT
      # Tough original 'picture' environment of TeX's coordinate system is
      # UP-RIGHT increment, We introduce DOWN-RIGHT coordinate system.
      # So, if you want increment y-axis, you should decrement Y-value for TeX
      # Although x-axis is normal

      @x_origin =  (@paper_width - @box_width*@x_repeat)/2
      @y_origin = -(@paper_height - @box_height*@y_repeat)/2
      @frame_width = @box_width * @x_repeat
      @frame_height = @box_height * @y_repeat


      ############# HEADER for whole document ##############
      put_header


      ######################## BODY ########################
      @boxes.each do |box|
        #======== calculate where box to be put ========
        @boxnum += 1

        if @repeat_direction  #horizontal
          @alignment_x = (@boxnum-1)%@x_repeat +1
          @alignment_y = (@boxnum-1)/@x_repeat + 1
        else
          @alignment_x = (@boxnum)/(@y_repeat+1) + 1
          @alignment_y = (@boxnum-1) % (@y_repeat) + 1
        end

        @box_x =  (@alignment_x - 1) * @box_width
        @box_y = @frame_height - (@alignment_y) * @box_height


        #================= page header =================
        if @boxnum == 1 # if beginning of a page

          # frame which encircles whole page
          print "%============== new page ===============\n"
          print "\\begin{picture}(0, 0)\n"

          # frame which encircles edge of aligned boxes 
          print "\\put(#{@x_origin + @x_offset}, #{@y_origin - @frame_height - @y_offset}){\n"
          print "\\begin{picture}(0,0)\n"

          if @print_frame
            print "%---------- frame ---------\n"
            print "\\put(0,0){\\framebox(#{@box_width*@x_repeat}, #{@box_height*@y_repeat})}\n"
            for i in 1 ... @x_repeat
              print "\\put(#{i * @box_width} ,0){\\line(0, 1){#{@frame_height}}}\n"
            end
            for i in 1 ... @y_repeat
              print "\\put(0, #{i * @box_height}){\\line(1, 0){#{@frame_width}}}\n"
            end
          end

          if @print_tombow
            print "%--------- tombow ---------\n"
            #DOWN-LEFT
            print "\\put(0, -3){\\line(0, -1){5}}\n"
            print "\\put(0, -3){\\line(-1, 0){8}}\n"
            print "\\put(-3, 0){\\line(0, -1){8}}\n"
            print "\\put(-3, 0){\\line(-1, 0){5}}\n"
            #UP-LEFT
            print "\\put(0,  #{3 + @frame_height}){\\line(0,  1){5}}\n"
            print "\\put(0,  #{3 + @frame_height}){\\line(-1, 0){8}}\n"
            print "\\put(-3, #{0 + @frame_height}){\\line(0,  1){8}}\n"
            print "\\put(-3, #{0 + @frame_height}){\\line(-1,  0){5}}\n"
            #DOWN-RIGHT
            print "\\put(#{0 + @frame_width}, -3){\\line(0, -1){5}}\n"
            print "\\put(#{0 + @frame_width}, -3){\\line(1,  0){8}}\n"
            print "\\put(#{3 + @frame_width},  0){\\line(0, -1){8}}\n"
            print "\\put(#{3 + @frame_width},  0){\\line(1,  0){5}}\n"

            print "\\put(#{0 + @frame_width}, #{3 + @frame_height}){\\line(0, 1){5}}\n"
            print "\\put(#{0 + @frame_width}, #{3 + @frame_height}){\\line(1, 0){8}}\n"
            print "\\put(#{3 + @frame_width}, #{0 + @frame_height}){\\line(0, 1){8}}\n"
            print "\\put(#{3 + @frame_width}, #{0 + @frame_height}){\\line(1, 0){5}}\n"
            for i in 1 ... @x_repeat
              print "\\put(#{i * @box_width} , -3){\\line(0, -1){5}}\n"
              print "\\put(#{i * @box_width} , #{@frame_height +3}){\\line(0, 1){5}}\n"
            end
            for i in 1 ... @y_repeat
              print "\\put(-3, #{i * @box_height}){\\line(-1, 0){5}}\n"
              print "\\put(#{@frame_width + 3}, #{i * @box_height}){\\line( 1, 0){5}}\n"
            end
          end #of tombow

          if @print_pagenum
            print "\\put(#{@frame_width/2}, -4){#{@pagenum}}\n"
          end

        end # of if @boxnum=1

        #================= data itself =================
        print "     %box number is #{@boxnum}\n"
        print "     %box max number is #{@x_repeat * @y_repeat}\n"
        print "     \\put(#{@box_x}, #{@box_y}){\\begin{picture}(#{@box_width},#{@box_height})\n"
        for i in 0 ... box.size
          print "        \\put(#{box[i][0]}, #{box[i][1]}){#{box[i][2]}}\n"
        end
        print "     \\end{picture}}\n\n"

        #================ page footer ==================
        if @boxnum == (@x_repeat * @y_repeat)
          @boxnum = 0
          @pagenum += 1
          print "\\end{picture}} %end of box edge\n"
          print "\\end{picture} %end of each page\n\n\n\n"
          print "\\pagebreak\n"
        end
      end
      #################### FOOTER ##########################
      if @boxnum != @x_repeat * @y_repeat && @boxnum !=0
        print "\\end{picture}} %end of box edge\n"
        print "\\end{picture} %end of each page\n\n\n"
      end
      print "\n\\end{document}\n"
    end
  end
end
