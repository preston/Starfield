# Copyright © 2009 Preston Lee. All rights reserved.

lib_dir = File.join(File.dirname(__FILE__), 'library')
Dir.new(lib_dir).entries.each do |e|
  # puts "#{e} #{e.class}"
  if File::directory?(File.join(lib_dir,e)) && !['.','..'].include?(e)
    l = File.join(lib_dir, e, 'lib')
    # puts "PUSHING #{l}"
    $LOAD_PATH.unshift(l)
  end
end
# puts $LOAD_PATH

require 'star'
require 'twitter'


  
class StarfieldStar < Star

  def draw
    $app.push_matrix
    $app.translate(@x, @y, @z)
    $app.box(8)
    $app.pop_matrix
  end
  
  
  
end

class Starfield < Processing::App

  
  load_library :opengl

  NUM_STARS = 200;
  CAMERA_SPEED = 20 # Pixels per wall second.
  CAMERA_ROTATE_SPEED = 0.08 # Radians per wall second.
  FRAME_RATE = 30 # Target frame per second.
  
  

  attr_accessor :stars

  def setup
    library_loaded?(:opengl) ? render_mode(OPENGL) : render_mode(P3D)
    frame_rate FRAME_RATE
    
    @moved = false
    @x = 0
    @y = 0
    @z = 0
    @rz = 0
    
    @mouse_last_x = nil 
    @mouse_last_y = nil
    @active = true
    @active_mutex = Mutex.new
    @stars = []
    for n in 0..NUM_STARS do
      @stars << StarfieldStar.new(1.0 / FRAME_RATE)
    end
    text_font load_font("Univers66.vlw.gz"), 10.0
    
  end
  
  
  def draw
    background 0 # Paint the entire screen solid black.
    fill(255)
    color(100,255,255)
    sphere(100)
    # text("Moving starfield demo aoenu hreouh rcohurcoeuh arochuoaentuhoe u.", 0, 0, 0)
    if !@moved
      push_matrix
      scale(5.0, 5.0, 5.0)
      # translate(0, 100, 0)
      text("Multi-threaded starfield simulation.", 0, 80, 0)
      text("Move: A, S, D, W, R, F, Arrow Keys", 0, 100, 0)
      text("Roll: Z, C", 0, 110, 0)
      text("Look: click and drag mouse.", 0, 120, 0)
      text("Pause/Resume: TAB", 0, 130, 0)
      text("OpenRain.com", 0, 150, 0)
      pop_matrix
    else
      # puts "MOVED"
    end


    @stars.each do |s|
      push_matrix
      s.draw
      pop_matrix
    end
    
    move_camera_for_frame
    # move_for_frame()
    # scale(5.0, 5.0, 5.0)
    # text('aoeuaoeuao euaoeuaoeu')
    # translate(@x, @y, @z)
    # rotate_z(@rz)
      
  end

  def mouse_released
    @mouse_last_x = nil
    @mouse_last_y = nil
  end
  
  def mouse_dragged
    @moved = true
    @mouse_last_x = mouse_x if @mouse_last_x.nil?
    @mouse_last_y = mouse_y if @mouse_last_y.nil?
    
    dx = @mouse_last_x - mouse_x
    dy = @mouse_last_y - mouse_y
    
    begin_camera
    if dx != 0
    # puts "#{mouse_x} #{mouse_y}"
      rotate_y radians(-dx) * 0.1
    end
    if dy != 0
      rotate_x radians(dy) * 0.1
    end
      
    end_camera
    
    @mouse_last_x = mouse_x
    @mouse_last_y = mouse_y
  end
  
  
  def key_pressed
    @moved = true
    # puts "KEY_PRESSED: #{key_code}"
    handle_camera_change_start
    handle_pause_and_resume
  end
  
  def handle_pause_and_resume
    case key_code
    when TAB:
      @active_mutex.synchronize do
        @stars.each do |s|
          @active ? s.deactivate : s.activate
        end
        @active = !@active
      end
    end
  end
  
  def key_released
    # puts "KEY_RELEASED: #{key_code}"
    handle_camera_change_stop
  end
  
  def handle_camera_change_start
    begin_camera
    case key_code
    when UP:
      @camera_move_z = -1
    when DOWN, 's', 'o':
      @camera_move_z = 1
    when LEFT:
      @camera_move_x = -1
    when RIGHT:
      @camera_move_x = 1
    end
    
    case key
    when 'w', ',':
      @camera_move_z = -1
    when 's', 'o':
      @camera_move_z = 1
    when 'a':
      @camera_move_x = -1
    when 'd', 'e':
      @camera_move_x = 1
    when 'r', 'p':
      @camera_move_y = -1
    when 'f', 'u':
      @camera_move_y = 1
    when 'z', ';':
      @camera_rotate_z = -1
    when 'c', 'j':
      @camera_rotate_z = 1
    end
    
    end_camera
  end
  
  def handle_camera_change_stop
    begin_camera
    case key_code
    when UP, DOWN, 'w', ',', 's', 'o':
      @camera_move_z = 0
    when LEFT, RIGHT, 'a', 'd', 'e':
      @camera_move_x = 0
    end
    
    case key
    when 'w', ',', 's', 'o':
      @camera_move_z = 0
    when 'a', 'd', 'e':
      @camera_move_x = 0
    when 'r', 'p', 'f', 'u':
      @camera_move_y = 0
    when 'z', ';', 'c', 'j':
      @camera_rotate_z = 0
    end
    end_camera
  end
  
  def move_camera_for_frame
    begin_camera
    @dx = (@camera_move_x || 0) * CAMERA_SPEED
    @dy = (@camera_move_y || 0) * CAMERA_SPEED
    @dz = (@camera_move_z || 0) * CAMERA_SPEED
    @drz = (@camera_rotate_z || 0) * CAMERA_ROTATE_SPEED
    @x += @dx
    @y += @dy
    @z += @dz
    @rz += @drz
    translate(@dx, 0, 0) if !@camera_move_x.nil? && @camera_move_x != 0
    translate(0, @dy, 0) if !@camera_move_y.nil? && @camera_move_y != 0
    translate(0, 0, @dz) if !@camera_move_z.nil? && @camera_move_z != 0  
    rotate_z(@drz) if !@camera_rotate_z.nil? && @camera_rotate_z != 0
    end_camera
  end
  
end

Starfield.new :width => 1000, :height => 800, :title => "Starfield"


