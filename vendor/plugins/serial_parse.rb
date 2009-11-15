# simple plugin to handle parsing of strings read-in via serial port.
# needed cause RAD has some troubles with parsing char* copy operations.

class SerialParse < ArduinoPlugin
  
  external_variables "bool current_response_received_complete"
  external_variables "int current_buffer_length = 0"
  external_variables "int max_message_length = 16;"
  external_variables "int max_response_length = 120;"
  external_variables "char response_buffer[120]"
  external_variables "unsigned long last_message_sent = 0"
  
  
  # initialize parser vars
  add_to_setup "current_response_received_complete = false;"
  
  void do_serial_parsing() {}
  
  bool response_is_complete() {
    return current_response_received_complete ;
  }
  
  unsigned long last_message_sent_time() {
    return last_message_sent ;
  }
  
  void reset_last_message_sent_time() {
    last_message_sent = millis();
  }
  
  void copy_response_buffer(char* str) {
    for(int i = 0; i < current_buffer_length; i++){
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
  
  void read_response() {
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

