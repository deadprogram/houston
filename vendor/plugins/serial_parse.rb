# simple plugin to handle parsing of strings read-in via serial port.
# needed cause RAD has some troubles with parsing char* copy operations.

class SerialParse < ArduinoPlugin
  
  external_variables "bool current_response_received_complete"
  external_variables "int current_buffer_length"
  external_variables "int max_message_length = 16;"
  external_variables "int max_response_length = 120;"
  external_variables "char response_buffer[120]"
  
  # initialize parser vars
  add_to_setup "current_response_received_complete = false;"
  
  void copy_response_buffer(char* str) {
    for(int i = 0; i < max_message_length; i++){
      str[i] = response_buffer[i] ;
    }    
  }
  
  void reset_response_buffer() {
    for(int i = 0; i < max_response_length; i++){
      response_buffer[i] = 0 ;
    }
    
    current_buffer_length = 0 ;
    current_response_received_complete = false ;
  }
  
  void serial_read_and_parse() {
    if(current_response_received_complete) {
      reset_response_buffer();
    }
    
    while(Serial.available() > 0) {
      response_buffer[current_buffer_length] = Serial.read();
      if(response_buffer[current_buffer_length] == '\r') {
        current_response_received_complete = true ;
        return;
      } else {
        current_buffer_length++ ;
      }
    }
  }
  
end