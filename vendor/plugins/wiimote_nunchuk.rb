# Plugin for Ruby Arduino Development that allows use of the Wiimote Nunchuk
# Written by Ron Evans (http://deadprogrammersociety.com) for the flying_robot project
#
# Based on code taken from Tod Curt http://todbot.com/arduino/sketches/NunchuckServo/NunchuckServo.pde
class WiimoteNunchuk < ArduinoPlugin
  include_wire
  
  external_variables "int nunchukAddress = 0x52"
  external_variables "byte nunchukData[6]"
  
  external_variables "bool nunchuk_init_complete"
  add_to_setup "nunchuk_init_complete = false;"
  
  void prepare_nunchuk() {
    // hack to reference plugin, copied this trick from twitter plugin 
  }
  
  // General version of nunchuck_init_with_power()beginWithPower().
  // Call this first when a Nunchuck is plugged directly into Arduino
  void nunchuck_setpowerpins()
  {
      #define pwrpin PORTC3
      #define gndpin PORTC2
      DDRC |= _BV(pwrpin) | _BV(gndpin);
      PORTC &=~ _BV(gndpin);
      PORTC |=  _BV(pwrpin);
      delay(100);  // wait for things to stabilize
      
      Wire.begin();       
  }

  void init_nunchuk() {
    if (nunchuk_init_complete) {
      return ;
    }
    
    for(byte i = 0; i < 6; i++) {
      nunchukData[i] = 0 ;
    }
    
    nunchuk_init_complete = true ;
    
    nunchuck_setpowerpins();
    
    Wire.beginTransmission(nunchukAddress); // transmit to device 0x52
    Wire.send(0x40); // sends memory address
    Wire.send(0x00); // sends data.
    Wire.endTransmission();
    delay(100);
  } 
  
  void clear_nunchuk_buffer()
  {
    // clear the receive buffer from any partial data
    while( Wire.available())
      Wire.receive();
  }
  
  void send_zero()
  {
    Wire.beginTransmission(nunchukAddress); // transmit to device 0x52
    Wire.send(0x00); // sends one byte
    Wire.endTransmission(); // stop transmitting
  }
  
  char nunchuk_decode_byte(char x)
  {
    x = (x ^ 0x17) + 0x17;
    return x;
  }
  
  void read_nunchuk()
  {     
    send_zero();
    delay(5);                   // The Wiimote nunchuk needs this delay, it seems
    Wire.requestFrom(nunchukAddress, 6); // request data from nunchuck
    int cnt = 0;
    while ( Wire.available())
    {
      if (cnt > 6)
        break ;
        
      nunchukData[cnt++] = nunchuk_decode_byte(Wire.receive()); // receive byte and decode it
    }
    
    clear_nunchuk_buffer();
  }   
  
  int joy_x_axis()
  {
    return nunchukData[0];
  }

  int joy_y_axis()
  {
    return nunchukData[1];
  }

  int accel_x_axis()
  {
    int x_axis = nunchukData[2] * 2 * 2 ;
    
    if ((nunchukData[5] >> 2) & 1)
    {
      x_axis += 2;
    }
    if ((nunchukData[5] >> 3) & 1)
    {
      x_axis += 1;
    }
    
    return x_axis ;
  }

  int accel_y_axis()
  {
    int y_axis = nunchukData[3] * 2 * 2;
    
    if ((nunchukData[5] >> 4) & 1)
    {
      y_axis += 2;
    }
    if ((nunchukData[5] >> 5) & 1)
    {
      y_axis += 1;
    }
    
    return y_axis ;
  }

  int accel_z_axis()
  {
    int z_axis = nunchukData[4] * 2 * 2;
    
    if ((nunchukData[5] >> 6) & 1)
    {
      z_axis += 2;
    }
    if ((nunchukData[5] >> 7) & 1)
    {
      z_axis += 1;
    }
    
    return z_axis ;
  }
  
  int z_button()
  {
    if ((nunchukData[5] >> 0) & 1)
    {
      return 1;
    }
    else
    {
      return 0 ;
    }
  }

  int c_button()
  {
    if ((nunchukData[5] >> 1) & 1)
    {
      return 1;
    }
    else
    {
      return 0 ;
    }
  }
    
end


