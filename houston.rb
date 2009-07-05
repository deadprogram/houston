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
  serial_begin :rate => 9600
  
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
  
  def loop
    softserial_sparkfun_lcd_init
    
    check_buttons    
    @x = analogRead(joystick_x)
    @y = analogRead(joystick_y)
    @throttle_reading = analogRead(joystick_throttle)
    
    set_elevator
    set_rudder
    set_throttle
    
		update_display
		delay(100)
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
      @elevator_deflection = (@deflection * 90.0) / 373
      serial_print "e u "
      serial_print @elevator_deflection
      serial_print '\r'
    end
    
    if @y > ELEVATOR_HIGHER_DETANTE
      @elevator_direction = ELEVATOR_DOWN
      @deflection = 920 - @y
      @elevator_deflection = (@deflection * 90.0) / 373
      @elevator_deflection = 90 - @elevator_deflection
      serial_print "e d "
      serial_print @elevator_deflection
      serial_print '\r'
    end
    
    if (@y >= ELEVATOR_LOWER_DETANTE) &&  (@y <= ELEVATOR_HIGHER_DETANTE)
      @elevator_direction = ELEVATOR_CENTER
      serial_print "e c"
      serial_print '\r'
    end
    
    clear_response_buffer
  end
  
  def set_rudder
    if @x < RUDDER_LOWER_DETANTE
      @rudder_direction = RUDDER_RIGHT
      @deflection = 515 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      serial_print "r r "
      serial_print @rudder_deflection
      serial_print '\r'
    end
    
    if @x > RUDDER_HIGHER_DETANTE
      @rudder_direction = RUDDER_LEFT
      @deflection = 890 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      @rudder_deflection = 90 - @rudder_deflection
      serial_print "r l "
      serial_print @rudder_deflection
      serial_print '\r'
    end
    
    if (@x >= RUDDER_LOWER_DETANTE) &&  (@x <= RUDDER_HIGHER_DETANTE)
      @rudder_direction = RUDDER_CENTER
      serial_print "r c"
      serial_print '\r'
    end
    
    clear_response_buffer
  end
  
  def set_throttle
    if @throttle_reading < THROTTLE_LOWER_DETANTE
      @throttle_direction = THROTTLE_REVERSE
      @speed = @throttle_reading - 180.0
      @throttle_speed = (@speed / 273.0) * 100.0
      @throttle_speed = 100 - @throttle_speed
      serial_print "t r "
      serial_print @throttle_speed
      serial_print '\r'
    end
    
    if @throttle_reading > THROTTLE_HIGHER_DETANTE
      @throttle_direction = THROTTLE_FORWARD
      @speed = 921 - @throttle_reading
      @speed = 273 - @speed
      @speed = @speed * 10000
      @throttle_speed = (@speed / 273) / 100.0
      serial_print "t f "
      serial_print @throttle_speed
      serial_print '\r'
    end
    
    if (@throttle_reading >= THROTTLE_LOWER_DETANTE) && (@throttle_reading <= THROTTLE_HIGHER_DETANTE)
      @throttle_direction = THROTTLE_OFF
      @throttle_speed = 0
      serial_print "t f 0"
      serial_print '\r'
    end
    
    clear_response_buffer
  end
  
  def set_autopilot_off
    @autopilot_status = AUTOPILOT_OFF
    @current_msg = 'Autopilot is off'
    serial_print "a 0"
    serial_print '\r'
    
    clear_response_buffer
  end

  def set_autopilot_on
    @autopilot_status = AUTOPILOT_ON
    @current_msg = 'Autopilot is on'
    serial_print "a 1"
    serial_print '\r'
    
    clear_response_buffer
  end
  
  def check_battery_status
    serial_print "i b"
    serial_print '\r'
    
    serial_read_and_parse
    copy_response_buffer(@current_msg)    
  end
  
  def clear_response_buffer
    while serial_available do
      serial_read
    end
  end
  
  def update_display
    if (millis() - @display_last_refresh_time > @display_refresh_rate)
    
      #my_lcd.backlightOn
      my_lcd.ss_clearLCD
    
      my_lcd.ss_selectLineOne

      # display message
      my_lcd.print @current_msg
      
      # my_lcd.print "autopilot "
      # if @autopilot_status == AUTOPILOT_OFF
      #   my_lcd.print "off"
      # end
      # if @autopilot_status == AUTOPILOT_ON
      #   my_lcd.print "on"
      # end

      # if @rudder_direction == 1
      #   my_lcd.print "  right "
      #   my_lcd.print @rudder_deflection
      # end
      # if @rudder_direction == 0
      #   my_lcd.print "  ctr "
      # end
      # if @rudder_direction == 2
      #   my_lcd.print "  left "
      #   my_lcd.print @rudder_deflection
      # end
		  
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
