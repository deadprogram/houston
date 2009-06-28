# Houston - Flight stick for flying_robot command set for Ruby Arduino Development
# Written by Ron Evans (http://deadprogrammersociety.com) for the flying_robot project

class Houston < ArduinoSketch
  
  input_pin 1, :as => :joystick_y
  input_pin 2, :as => :joystick_x
  input_pin 3, :as => :joystick_throttle
  
  software_serial 6, 7, :as => :my_lcd, :rate => 9600
  
  # xbee used for communication with ground station
  serial_begin :rate => 9600
  
  
  @x = "0, long"
  @y = "0, long"
  @throttle = "0, long"
  
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
    
  def loop
    softserial_sparkfun_lcd_init
    
    @x = analogRead(joystick_x)
    @y = analogRead(joystick_y)
    @throttle = analogRead(joystick_throttle)
    
    set_elevator
    set_rudder
    set_throttle
    
		update_display
		delay(100)
  end
  
  def set_elevator
    if @y < 517
      @elevator_direction = 1
      @deflection = 547 - @y
      @elevator_deflection = (@deflection * 90.0) / 373
      serial_print "e u "
      serial_print @elevator_deflection
      serial_print '\r'
    end
    
    if @y > 577
      @elevator_direction = 2
      @deflection = 920 - @y
      @elevator_deflection = (@deflection * 90.0) / 373
      @elevator_deflection = 90 - @elevator_deflection
      serial_print "e d "
      serial_print @elevator_deflection
      serial_print '\r'
    end
    
    if (@y >= 517) &&  (@y <= 577)
      @elevator_direction = 0
      serial_print "e c"
      serial_print '\r'
    end
    
    clear_response_buffer
  end
  
  def set_rudder
    if @x < 480
      @rudder_direction = 1
      @deflection = 515 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      serial_print "r r "
      serial_print @rudder_deflection
      serial_print '\r'
    end
    
    if @x > 540
      @rudder_direction = 2
      @deflection = 890 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      @rudder_deflection = 90 - @rudder_deflection
      serial_print "r l "
      serial_print @rudder_deflection
      serial_print '\r'
    end
    
    if (@x >= 480) &&  (@x <= 540)
      @rudder_direction = 0
      serial_print "r c"
      serial_print '\r'
    end
    
    clear_response_buffer
  end
  
  def set_throttle
    if @throttle < 450
      @throttle_direction = 2
      @speed = @throttle - 180.0
      @throttle_speed = (@speed / 273.0) * 100.0
      @throttle_speed = 100 - @throttle_speed
      serial_print "t r "
      serial_print @throttle_speed
      serial_print '\r'
    end
    
    if @throttle > 648
      @throttle_direction = 1
      @speed = 921 - @throttle
      @speed = 273 - @speed
      @speed = @speed * 10000
      @throttle_speed = (@speed / 273) / 100.0
      serial_print "t f "
      serial_print @throttle_speed
      serial_print '\r'
    end
    
    if (@throttle >= 450) && (@throttle <= 648)
      @throttle_direction = 0
      @throttle_speed = 0
      serial_print "t f 0"
      serial_print '\r'
    end
    
    clear_response_buffer
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
      # my_lcd.print "x: "
      # my_lcd.print @x

      #my_lcd.print "  e: "
      if @elevator_direction == 1
        my_lcd.print "up "
        my_lcd.print @elevator_deflection
      end
      if @elevator_direction == 0
        my_lcd.print "lvl "
      end
      if @elevator_direction == 2
        my_lcd.print "dwn "
        my_lcd.print @elevator_deflection
      end

      #my_lcd.print "r: "
      if @rudder_direction == 1
        my_lcd.print "  right "
        my_lcd.print @rudder_deflection
      end
      if @rudder_direction == 0
        my_lcd.print "  ctr "
      end
      if @rudder_direction == 2
        my_lcd.print "  left "
        my_lcd.print @rudder_deflection
      end

    
		
  		my_lcd.ss_selectLineTwo
  		my_lcd.print "throttle: "
  		my_lcd.print @throttle
  	
  	  @display_last_refresh_time = millis()
  	end
  end  
end
