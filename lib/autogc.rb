#This class disables garbage collection
class Autogc
  #Disables the normal GC and enables a timeout to automatically GC.
  def initialize(args = {})
    @args = args
    
    puts "Starting Autogc." if @args[:debug]
    @args[:time] = 1
    @thread = Thread.new(&self.method(:gc_loop))
    GC.disable
  end
  
  #Starts autogc if it is running on a known buggy environment.
  def self.enable_for_known_buggy_env(args = {})
    found = false
    found = true if RUBY_VERSION == "1.9.3"
    Autogc.new(args) if found
    return found
  end
  
  #Stops the garbage-collection on time and enables the normal GC.
  def stop
    GC.enable
    @thread.kill
  end
  
  #Starts the loop that executes the garbage-collection.
  def gc_loop
    loop do
      begin
        sleep @args[:time]
        self.gc
      rescue => e
        puts "Autogc: An error occurred while triggering the garbage-collection."
      end
    end
  end
  
  #Execute garbage-collection exclusive.
  def gc
    Thread.exclusive do
      puts "Autogc: Doing garbage collection." if @args[:debug]
      GC.enable
      GC.start
      GC.disable
    end
  end
end