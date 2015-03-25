class Log

	def initialize(file)
		@log_file = file
	end

	# Open the file
	def open_file
		@open_file = File.open(@log_file, "r+")
		read_lines
	end

	# Read each lines from the log file and remove blank
	def read_lines
		@open_file.read.split(/\n/).reject{ |r| r == " "}
	end

end

class VisitorLog

	def initialize(data,total)
		@log_data = data
		@total_data = total
	end

	# Get data with key
	def get_data
		visitors = []

		@log_data.drop(1).each do |l|
			visitors << Hash[ [:id,:room,:status,:timestamp].zip( l.split(" ") ) ]
		end

		visitors
	end

end

require 'action_view'
class Room

	def initialize(visitors)
		@visitors = visitors
	end

	# Get data based on each room
	def get_data
		visitor_count = {}
		avg_time = {}
		@visitors.group_by{|v| v[:room]}.each do |key, values|
			avg_time[key] = average_time(total_time(values),total_visitors(values))
			visitor_count[key] = total_visitors(values)
		end

		rooms_data = arrange_data(visitor_count, avg_time)
	end

	# Print data to the console
	def print_data(rooms_data)
		rooms_data.each do |room,data|
			p "Room #{room}, #{data[1][:avg_time]} minute average visit, #{ActionView::Base.new.pluralize(data[0][:visitor_count],'visitor')} total"
		end
	end

	private 

	# Get the total time taken by all the visitors in a room
	def total_time(values)
		sum = 0
		values.group_by{|v| v[:id]}.each do |v_key, visitor|
			time_spent = (visitor[1][:timestamp].to_i - visitor[0][:timestamp].to_i)+1
			sum += time_spent
		end
		sum
	end

	# Get total visitors
	def total_visitors(values)
		values.group_by{|v| v[:id]}.count
	end

	# Get the average time in a room
	def average_time(time, visitors)
		avg_time = time/visitors
	end

	# Arrange data based on room with visitor count and average time
	def arrange_data(visitor_count, avg_time)
		rooms = [avg_time, visitor_count].flat_map(&:keys).uniq

		rooms_data = {}
		rooms.each do |r| 
  			rooms_data[r.to_i] = [{visitor_count: visitor_count[r] || "0"}, {avg_time: avg_time[r] || "0"}]
		end
		rooms_data
	end

end

# Passing the log file
log = Log.new("log.txt")
# Open the log file and read the data
log_data = log.open_file

# Passing the log data to visitor log for formatting
visit = VisitorLog.new(log_data, log_data[0])
# Getting the formatted data 
visitors = visit.get_data

rooms = Room.new(visitors)
rooms_data = rooms.get_data.sort_by{|k,v| k}

# Call the print function
rooms.print_data(rooms_data)