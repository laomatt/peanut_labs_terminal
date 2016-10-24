require 'fileutils'
# Borrowed this code to check string for an integer
class String
  def is_i?
     !!(self =~ /\A[-+]?[0-9]+\z/)
  end
end
# Borrowed this code to check string for an integer


class Terminal
  attr_accessor :output
  def initialize(file_path=nil)
    @cursor_position = {
      :i => 0,
      :j => 0
    }

    @insert = false
    @overwrite = true
    @output = [
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "]
              ]
    if !file_path.nil?
      File.open( "#{file_path}" ).each do |line|
        com_array = []
        parse_line(line)
      end
    end
  end

  def parse_line(line)
    lined = line.gsub("\n",'').split('')
      idx = 0
      while idx < lined.length
          if lined[idx] != '^'
            write(lined[idx])
            idx += 1
          else
              # if we come across a ^ we check for single char commands
                # check for another ^
              if lined[idx + 1] == '^'
                write('^')
                idx += 1
                idx += 1
            # check for c,h,b,d,u,l,r,e,i,o
              elsif ['c','h','b','d','u','l','r','e','i','o'].include?(lined[idx + 1])
                command_me(lined[idx + 1])
                # if we come across a ^ we check for double char commands
                # two fixnums in a row
                idx += 1
                idx += 1
              else
                next if lined[idx + 1].nil? || lined[idx + 2].nil?
                if lined[idx + 1].is_i? && lined[idx + 2].is_i?
                  move_to(lined[idx + 1],lined[idx + 2])
                  idx += 1
                  idx += 1
                  idx += 1
                end
              end
          end
      end
  end

  def move_to(j,i)
    @cursor_position[:j] = j.to_i
    @cursor_position[:i] = i.to_i
  end

  def reset_cursor
    @cursor_position[:i] = 0
    @cursor_position[:j] = 0
  end

  def write_sentence(sentence)
    sentence.each_char do |char|
      write(char)
    end
  end

  def write(char)
    if @overwrite == true
      @output[@cursor_position[:j]][@cursor_position[:i]] = char
    elsif @insert == true
      row = @output[@cursor_position[:j]]
      index = row.length - 1
      while index >= @cursor_position[:i]
        # replace the current index with the previous (next) index value
        row[index] = row[index - 1]
        index -= 1
      end
      @output[@cursor_position[:j]][@cursor_position[:i]] = char
    end

    move
  end

  def reset
    @output = [
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "],
                [" "," "," "," "," "," "," "," "," "," "]
              ]
  end

  def command_me(comm)
    if comm == 'c'
      reset
    elsif comm == 'h'
      reset_cursor
    elsif comm == 'b'
      @cursor_position[:i] = 0
    elsif comm == 'd'
      @cursor_position[:j] += 1 if @cursor_position[:j] <= 9
    elsif comm == 'u'
      @cursor_position[:j] -= 1 if @cursor_position[:j] > 0
    elsif comm == 'l'
      @cursor_position[:i] -= 1 if @cursor_position[:i] > 0
    elsif comm == 'r'
      @cursor_position[:i] += 1 if @cursor_position[:i] <= 9
    elsif comm == 'e'
      row = output[@cursor_position[j]]
      row.each_with_index do |r, idx|
        if idx >= @cursor_position[i]
          row[idx] = " "
        end
      end
    elsif comm == 'i'
      @insert = true
      @overwrite = false
    elsif comm == 'o'
      @overwrite = true
      @insert = false
    else
      i = 0
      comm.split('').each do |character|
        @output[@cursor_position[:j]][@cursor_position[:i]] = character
        i += 1
      end
    end
  end

  def move
    @cursor_position[:i] += 1 if @cursor_position[:i] < 9


    # I assumed that if a cursor couldnt move to the right anymore, we should type writter it and move the cursor to the begining of the next row

    # if @cursor_position[:i] >= 9
    #   @cursor_position[:i] = 0
    #   if @cursor_position[:j] >= 9
    #     @cursor_position[:j] = 9
    #   else
    #     @cursor_position[:j] += 1
    #   end
    # else
    #   @cursor_position[:i] += 1
    # end
  end

  def display
    @output.each do |op|
      puts op.join
    end
  end

  def display_me_running
    @output.each do |op|
      r op.join
    end
  end
end



file_path = ARGV.shift
if file_path != 'start!'
  term = Terminal.new(file_path)
  term.display
else
  running = true
  term = Terminal.new()
  while running == true
    puts 'enter a command'
    comm = gets.chomp
    if comm.to_s == 'exit'
      running = false
    else
      term.parse_line(comm)
      term.display
    end
  end
end



