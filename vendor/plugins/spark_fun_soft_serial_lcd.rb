class SparkFunSoftSerialLcd < ArduinoPlugin
  
  # RAD plugins are c methods, directives, external variables and assignments and calls 
  # that may be added to the main setup method
  # function prototypes not needed since we generate them automatically
  
  # directives, external variables and setup assignments and calls can be added rails style (not c style)
  # hack from http://www.arduino.cc/cgi-bin/yabb2/YaBB.pl?num=1209050315

  #plugin_directives "#undef int", "#include <stdio.h>", "char _str[32];", "#define writeln(...) sprintf(_str, __VA_ARGS__); Serial.println(_str)"
  # add to directives
  #plugin_directives "#define EXAMPLE 10"

  # add to external variables
  #external_variables "char status_message[40] = \"very cool\"", "char* msg[40]"

  # add the following to the setup method
  # add_to_setup "foo = 1";, "bar = 1;" "sub_setup();"
  
  # one or more methods may be added and prototypes are generated automatically with rake make:upload
  
# methods for sparkfun serial lcd SerLCD v2.5
void softserial_sparkfun_lcd_init() {
}

void ss_selectLineOne(SoftwareSerial& lcd){  //puts the cursor at line 0 char 0.
   lcd.print(0xFE, BYTE);   //command flag
   lcd.print(128, BYTE);    //position
}
void ss_selectLineTwo(SoftwareSerial& lcd){  //puts the cursor at line 0 char 0.
   lcd.print(0xFE, BYTE);   //command flag
   lcd.print(192, BYTE);    //position
}
void ss_clearLCD(SoftwareSerial& lcd){
   lcd.print(0xFE, BYTE);   //command flag
   lcd.print(0x01, BYTE);   //clear command.
}
void ss_backlightOn(SoftwareSerial& lcd){  //turns on the backlight
    lcd.print(0x7C, BYTE);   //command flag for backlight stuff
    lcd.print(157, BYTE);    //light level.
}

void ss_set_backlight_level(SoftwareSerial& lcd, int level){  //turns on the backlight
  if (level > 29)
    level = 29;
    lcd.print(0x7C, BYTE);   //command flag for backlight stuff
    lcd.print(157 + level, BYTE);    //light level.
}

void ss_toggle_backlight(SoftwareSerial& lcd){  //turns off the backlight
    lcd.print(0x7C, BYTE);   //command flag for backlight stuff
    lcd.print("|");     //light level for off.
    lcd.print(1);
}

void ss_set_splash(SoftwareSerial& lcd){
  ss_selectLineOne(lcd);
  lcd.print(" Ruby + Auduino");
  ss_selectLineTwo(lcd);
  lcd.print(" RAD 0.2.4+     ");
  lcd.print(0x7C, BYTE);   // decimal 124, command flag for backlight stuff
  lcd.print(10, BYTE);
}

void ss_backlightOff(SoftwareSerial& lcd){  //turns off the backlight
    lcd.print(0x7C, BYTE);   // decimal 124, command flag for backlight stuff
    lcd.print(128, BYTE);     //light level for off.
}
void ss_serCommand(SoftwareSerial& lcd){   // decimal 254, a general function to call the command flag for issuing all other commands   
  lcd.print(0xFE, BYTE);
}




    

end