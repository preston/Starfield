# Copyright © 2009 Preston Lee. All rights reserved.

require 'thread'

class AsychronousObject

  attr_reader :thread
  attr_reader :update_frequency
  attr_reader :last_updated

  def initialize(freq)
    @update_freqency = freq
    # puts @update_freqency
    @mutex = Mutex.new
    
    start
  end
  
  def start
    @last_updated = Time.now
    @state = :active # or :inactive
    # puts @mutex
    @thread = Thread.new do
      keep_going = true
      while keep_going do
        @mutex.synchronize do
          # puts "going"
          keep_going = false if @state == :inactive
        end
        if keep_going
          now = Time.now
          # puts "TL '#{@last_updated}' N #{now} F #{@update_freqency}"
          update(@last_updated, now)
          @last_updated = now
          sleep @update_freqency
        end
      end
    end
  end
  
  def update
    puts "FAIL!"
    raise "You need to implement this method!"
  end
  
  def activate
    @mutex.synchronize do
      case @state
      when :active
        # do nothing
      when :inactive
        start
      end
    end
  end
  
  def deactivate
    @mutex.synchronize do
      @state = :inactive
    end
  end
  
  def join
    @thread.join
  end

end