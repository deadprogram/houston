# Houston - An Unmanned Aerial Vehicle that uses the flying_robot command set for Ruby Arduino Development
# Written by Ron Evans (http://deadprogrammersociety.com) for the flying_robot project

class Houston < ArduinoSketch
  
  input_pin 1, :as => :joystick_y
  input_pin 2, :as => :joystick_x
  input_pin 3, :as => :joystick_throttle
  
  software_serial 6, 7, :as => :my_lcd, :rate => 9600
  
  # xbee used for communication with ground station
  serial_begin :rate => 57600
  
  
  @x = "0, long"
  @y = "0, long"
  @throttle = "0, long"
  
  @deflection = "0, long"
  @elevator_deflection = "0, long"
  @elevator_direction = "1, byte"

  @rudder_deflection = "0, long"
  @rudder_direction = "1, byte"
    
  def loop
    softserial_sparkfun_lcd_init
    
    @x = analogRead(joystick_x)
    @y = analogRead(joystick_y)
    @throttle = analogRead(joystick_throttle)
    
    set_elevator
    set_rudder
    
    #my_lcd.backlightOn
    my_lcd.ss_clearLCD
    
    my_lcd.ss_selectLineOne
    # my_lcd.print "x: "
    # my_lcd.print @x

    my_lcd.print "r: "
    if @rudder_direction == 0
      my_lcd.print "r "
      my_lcd.print @rudder_deflection
    end
    if @rudder_direction == 1
      my_lcd.print "c "
    end
    if @rudder_direction == 2
      my_lcd.print "l "
      my_lcd.print @rudder_deflection
    end

    
    my_lcd.print "  e: "
    if @elevator_direction == 0
      my_lcd.print "u "
      my_lcd.print @elevator_deflection
    end
    if @elevator_direction == 1
      my_lcd.print "c "
    end
    if @elevator_direction == 2
      my_lcd.print "d "
      my_lcd.print @elevator_deflection
    end
		
		my_lcd.ss_selectLineTwo
		my_lcd.print "throttle: "
		my_lcd.print @throttle
		delay(100);
    
  end
  
  def set_elevator
    if @y < 517
      @elevator_direction = 0
      @deflection = 547 - @y
      @elevator_deflection = (@deflection * 90.0) / 373
      serial_print "e u "
      serial_println @elevator_deflection
    end
    
    if @y > 577
      @elevator_direction = 2
      @deflection = 920 - @y
      @elevator_deflection = (@deflection * 90.0) / 373
      @elevator_deflection = 90 - @elevator_deflection
      serial_print "e d "
      serial_println @elevator_deflection
    end
    
    if (@y >= 517) &&  (@y <= 577)
      @elevator_direction = 1
      serial_println "e c"
    end
    
  end
  
  def set_rudder
    if @x < 480
      @rudder_direction = 0
      @deflection = 515 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      serial_print "r r "
      serial_println @rudder_deflection
    end
    
    if @x > 540
      @rudder_direction = 2
      @deflection = 890 - @x
      @rudder_deflection = (@deflection * 90.0) / 375
      @rudder_deflection = 90 - @rudder_deflection
      serial_print "r l "
      serial_println @rudder_deflection
    end
    
    if (@x >= 480) &&  (@x <= 540)
      @rudder_direction = 1
      serial_println "r c"
    end
    
  end  
end
