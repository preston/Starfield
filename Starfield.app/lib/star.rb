# Copyright © 2009 Preston Lee. All rights reserved.

require 'asynchronous_object'

class Star < AsychronousObject
  
  attr_reader :x, :y, :z
  
  DEFAULT_UPDATE_FREQUENCY = 0.20 # In seconds.
  DEFAULT_CLIPPING_PLANE = 1800 # The universe is a giant cube, with each side being this long.
  
  def initialize(freq = DEFAULT_UPDATE_FREQUENCY, clip = DEFAULT_CLIPPING_PLANE)
    @clipping_plane = clip
    @dxs = rand(20) - 10 # X-axis movement per wall second.
    @dys = rand(20) - 10 # Y-axis movement per wall second.
    @dzs = rand(200) * 2 # Z-axis movement per wall second.
    set_random_position
    
    super(freq) # We have to do this last since a +Thread+ will be created that needs our instance variables instantiated.
  end
  
  def set_random_position    
      @x = rand(@clipping_plane * 2) - @clipping_plane
      @y = rand(@clipping_plane * 2) - @clipping_plane
      @z = rand(@clipping_plane * 2) - @clipping_plane
  end
  
  def set_new_position 
    set_random_position
    @z = -1 * @clipping_plane
  end
  
  def update(last, now)
    # Check if the star is getting too far away from the universe, and move it back to a reasonable starting point if so.
    # puts "CLIP NIL" if @clipping_plane.nil?
    set_new_position if @x >= @clipping_plane
    set_new_position if @y >= @clipping_plane
    set_new_position if @z >= @clipping_plane
    
    
      # puts "Updating star position. '#{freq}'"
    # Figure out the translation required along each axis for this time period.
    dtime = now - last
    dx = @dxs * dtime
    dy = @dys * dtime
    dz = @dzs * dtime
    
    # Move the star.
    @x += dx
    @y += dy
    @z += dz

    # puts "Moving to #{@x}, #{@y}, #{@z}"
  end

  
end
