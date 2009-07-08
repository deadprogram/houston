# Houston - Flight stick for flying_robot command set for Ruby Arduino Development
# Written by Ron Evans (http://deadprogrammersociety.com) for the flying_robot project

class Houston < ArduinoSketch
  
  input_pin 1, :as => :joystick_y
  input_pin 2, :as => :joystick_x
  input_pin 3, :as => :joystick_throttle
  
  software_serial 6, 7, :as => :my_lcd, :rate => 9600
  
  input_pin 8, :as => :autopilot_off_button, :device => :button
  input_pin 9, :as => :autopilot_on_button, :device => :button
  #input_pin 10, :as => :autopilot_on_button, :device => :button
  input_pin 11, :as => :battery_status_button, :device => :button
  
  # xbee used for communication with ground station
  serial_begin :rate => 19200
  
  define "ELEVATOR_LOWER_DETANTE 517"
  define "ELEVATOR_HIGHER_DETANTE 577"
  define "ELEVATOR_CENTER 0"
  define "ELEVATOR_UP 1"
  define "ELEVATOR_DOWN 2"
  
  define "RUDDER_LOWER_DETANTE 480"
  define "RUDDER_HIGHER_DETANTE 540"
  define "RUDDER_CENTER 0"
  define "RUDDER_LEFT 1"
  define "RUDDER_RIGHT 2"

  define "THROTTLE_LOWER_DETANTE 450"
  define "THROTTLE_HIGHER_DETANTE 648"
  define "THROTTLE_OFF 0"
  define "THROTTLE_REVERSE 2"
  define "THROTTLE_FORWARD 1"
  
  define "AUTOPILOT_OFF 0"
  define "AUTOPILOT_ON 1"
  
  @controls_refresh_rate = "100, unsigned long"
  @controls_last_refresh_time = "0, unsigned long"
  @x = "0, long"
  @y = "0, long"
  @throttle_reading = "0, long"
  
  @deflection = "0, long"
  @elevator_deflection = "0, long"
  @elevator_direction = "1, byte"

  @rudder_deflection = "0, long"
  @rudder_direction = "1, byte" 

  @speed = "0, unsigned long"
  @throttle_speed = "0, unsigned long"
  @throttle_direction = "1, byte" 
  
  @display_refresh_rate = "1000, unsigned long"
  @display_last_refresh_time = "0, unsigned long"
  
  @autopilot_status = "0, byte"
  @current_msg = "All Systems Go  "
  @response_length = "0, long"
  
  @message_to_display = false
  #@message_to_display = "false, boolean"
  @messages_expected = "0, int"
  #@messages_expected = 0
  
  def loop
    softserial_sparkfun_lcd_init
    do_serial_parsing
    
    if @messages_expected > 0
      process_messages
    else
      check_controls
    end
  	
  	update_display
  end
  
  def check_controls
    if (millis() - @controls_last_refresh_time > @controls_refresh_rate)
      @x = analogRead(joystick_x)
      @y = analogRead(joystick_y)
      @throttle_reading = analogRead(joystick_throttle)
    
      set_elevator
      set_rudder
      set_throttle

      check_buttons    
  		
      @controls_last_refresh_time = millis()
    end
  end
  
  def check_buttons
  	set_autopilot_off if read_input autopilot_off_button
  	set_autopilot_on if read_input autopilot_on_button
  	check_battery_status if read_input battery_status_button
  end
  
  def set_elevator
    if @y < ELEVATOR_LOWER_DETANTE
      @elevator_direction = ELEVATOR_UP
      @deflection = 547 - @y
      @deflection = (@deflection * 90.0) / 373
      
      if @elevator_deflection != @deflection
        @elevator_deflection = @deflection
        serial_print "e u "
        serial_print @elevator_deflection
        serial_print '\r'
        ignore_next_message
      end
    end
    
    if @y > ELEVATOR_HIGHER_DETANTE
      @elevator_direction = ELEVATOR_DOWN
      @deflection = 920 - @y
      @deflection = (@deflection * 90.0) / 373
      @deflection = 90 - @deflection
      
      if @elevator_deflection != @deflection
        @elevator_deflection = @deflection
        serial_print "e d "
        serial_print @elevator_deflection
        serial_print '\r'
        ignore_next_message
      end
        
    end
    
    if (@y >= ELEVATOR_LOWER_DETANTE) &&  (@y <= ELEVATOR_HIGHER_DETANTE)
      @elevator_direction = ELEVATOR_CENTER
      
      if @elevator_deflection != 0
        @elevator_deflection = 0
        serial_print "e c"
        serial_print '\r'
        ignore_next_message
      end
      
    end
    
  end
  
  def set_rudder
    if @x < RUDDER_LOWER_DETANTE
      @rudder_direction = RUDDER_RIGHT
      @deflection = 515 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      
      if @rudder_deflection != @deflection
        @rudder_deflection = @deflection
        serial_print "r r "
        serial_print @rudder_deflection
        serial_print '\r'
        ignore_next_message
      end
    end
    
    if @x > RUDDER_HIGHER_DETANTE
      @rudder_direction = RUDDER_LEFT
      @deflection = 890 - @x
      @deflection = (@deflection * 90.0) / 375
      @deflection = 90 - @deflection
      
      if @rudder_deflection != @deflection
        @rudder_deflection = @deflection
        serial_print "r l "
        serial_print @rudder_deflection
        serial_print '\r'
        ignore_next_message
      end
    end
    
    if (@x >= RUDDER_LOWER_DETANTE) &&  (@x <= RUDDER_HIGHER_DETANTE)
      @rudder_direction = RUDDER_CENTER
      
      if @rudder_deflection != 0
        @rudder_deflection = 0
        serial_print "r c"
        serial_print '\r'
        ignore_next_message
      end
    end
    
  end
  
  def set_throttle
    if @throttle_reading < THROTTLE_LOWER_DETANTE
      @throttle_direction = THROTTLE_REVERSE
      @speed = @throttle_reading - 180.0
      @speed = (@speed / 273.0) * 100.0
      @speed = 100 - @speed

      if @throttle_speed != @speed
        @throttle_speed = @speed
        serial_print "t r "
        serial_print @throttle_speed
        serial_print '\r'
        ignore_next_message
      end
    end
    
    if @throttle_reading > THROTTLE_HIGHER_DETANTE
      @throttle_direction = THROTTLE_FORWARD
      @speed = 921 - @throttle_reading
      @speed = 273 - @speed
      @speed = @speed * 10000
      @speed = (@speed / 273) / 100.0
      
      if @throttle_speed != @speed
        @throttle_speed = @speed
        serial_print "t f "
        serial_print @throttle_speed
        serial_print '\r'
        ignore_next_message
      end
    end
    
    if (@throttle_reading >= THROTTLE_LOWER_DETANTE) && (@throttle_reading <= THROTTLE_HIGHER_DETANTE)
      @throttle_direction = THROTTLE_OFF
      
      if @throttle_speed != 0
        @throttle_speed = 0
        serial_print "t f 0"
        serial_print '\r'
        ignore_next_message
      end
    end
    
  end
  
  def set_autopilot_off
    @autopilot_status = AUTOPILOT_OFF
    @current_msg = 'Autopilot is off'
    serial_print "a 0"
    serial_print '\r'
    
    ignore_next_message
  end

  def set_autopilot_on
    @autopilot_status = AUTOPILOT_ON
    @current_msg = 'Autopilot is on'
    serial_print "a 1"
    serial_print '\r'
    
    ignore_next_message
  end
  
  def check_battery_status
    serial_print "i b"
    serial_print '\r'
    
    display_next_message
  end
  
  def ignore_next_message
    @messages_expected = @messages_expected + 1
  end
  
  def display_next_message
    @messages_expected = @messages_expected + 1
    @message_to_display = true
  end
  
  def process_messages
    read_response
    process_response if response_is_complete()
  end
  
  def process_response
    @messages_expected = @messages_expected - 1
    if @messages_expected == 0 && @message_to_display
      copy_response_buffer(@current_msg)
      @message_to_display = false
    end
  end
  
  def update_display
    if (millis() - @display_last_refresh_time > @display_refresh_rate)
    
      my_lcd.ss_clearLCD
    
      my_lcd.ss_selectLineOne

      # display message
      my_lcd.print @current_msg
      
		  # display throttle
  		my_lcd.ss_selectLineTwo
  		my_lcd.print "throttle "
      if @throttle_direction == THROTTLE_REVERSE
        my_lcd.print "rev "
        my_lcd.print @throttle_speed
      end
      if @throttle_direction == 0
        my_lcd.print "off"
      end
      if @throttle_direction == THROTTLE_FORWARD
        my_lcd.print "fwd "
        my_lcd.print @throttle_speed
      end
  	
  	  @display_last_refresh_time = millis()
  	end
  end  
end
