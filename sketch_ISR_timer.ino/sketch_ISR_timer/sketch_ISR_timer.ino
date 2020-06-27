#include "arduino_queue_linklist.h"

#define SEVEN_SEC_DISPLAY_POS_PIN_BASE      (50)
#define SEVEN_SEC_DISPLAY_POS_PIN_SIZE      (4)
#define SEVEN_SEC_DISPLAY_NUM_PIN_BASE      (40)
#define SEVEN_SEC_DISPLAY_NUM_PIN_SIZE      (8)

// timer clock number
unsigned long time0_counter_s = 0;
unsigned long time0_counter_e = 0;
unsigned long time1_counter_s = 0;
unsigned long time1_counter_e = 0;
unsigned long time2_counter_s = 0;
unsigned long time2_counter_e = 0;

// seven section display
const int pinState[10][7] = {
  {1, 1, 1, 1, 1, 1, 0}, // 0
  {0, 1, 1, 0, 0, 0, 0}, // 1
  {1, 1, 0, 1, 1, 0, 1}, // 2
  {1, 1, 1, 1, 0, 0, 1}, // 3
  {0, 1, 1, 0, 0, 1, 1}, // 4
  {1, 0, 1, 1, 0, 1, 1}, // 5
  {1, 0, 1, 1, 1, 1, 1}, // 6
  {1, 1, 1, 0, 0, 0, 0}, // 7
  {1, 1, 1, 1, 1, 1, 1}, // 8
  {1, 1, 1, 1, 0, 1, 1}  // 9
};

// varible resistor
#define VAR_RESISTOR_AI_PIN         (0)
QueueList<int> q_resistor;

void init_timerISR() {
  cli();//stop interrupts
  
  //set timer0 interrupt at 2kHz
  TCCR0A = 0;// set entire TCCR2A register to 0
  TCCR0B = 0;// same for TCCR2B
  TCNT0  = 0;//initialize counter value to 0
  // set compare match register for 2khz increments
  OCR0A = 249;// = (16*10^6) / (1000*64) - 1 (must be <256)
  // turn on CTC mode
  TCCR0A |= (1 << WGM01);
  // Set CS01 and CS00 bits for 64 prescaler
  TCCR0B |= (1 << CS01) | (1 << CS00);   
  // enable timer compare interrupt
  TIMSK0 |= (1 << OCIE0A);
  
  //set timer1 interrupt at 1Hz
  TCCR1A = 0;// set entire TCCR1A register to 0
  TCCR1B = 0;// same for TCCR1B
  TCNT1  = 0;//initialize counter value to 0
  // set compare match register for 1hz increments
  OCR1A = 15624;// = (16*10^6) / (1*1024) - 1 (must be <65536)
  // turn on CTC mode
  TCCR1B |= (1 << WGM12);
  // Set CS12 and CS10 bits for 1024 prescaler
  TCCR1B |= (1 << CS12) | (1 << CS10);  
  // enable timer compare interrupt
  TIMSK1 |= (1 << OCIE1A);
  
  //set timer2 interrupt at 8kHz
//  TCCR2A = 0;// set entire TCCR2A register to 0
//  TCCR2B = 0;// same for TCCR2B
//  TCNT2  = 0;//initialize counter value to 0
//  // set compare match register for 8khz increments
//  OCR2A = 249;// = (16*10^6) / (8000*8) - 1 (must be <256)
//  // turn on CTC mode
//  TCCR2A |= (1 << WGM21);
//  // Set CS21 bit for 8 prescaler
//  TCCR2B |= (1 << CS21);   
//  // enable timer compare interrupt
//  TIMSK2 |= (1 << OCIE2A);
  
  sei();//allow interrupts
}

void init_7sec_display( int num_base, int num_size, int pos_base, int pos_size ) {
  for(int i = num_base; i < num_base+num_size; i++) {
    pinMode(i, OUTPUT);
  }
  for(int i = pos_base; i < pos_base+pos_size; i++) {
    pinMode(i, OUTPUT);
  }
}

void init_matlab_channel(){
  
}

void setup(){
  Serial.begin(230400);
  
  init_7sec_display(SEVEN_SEC_DISPLAY_NUM_PIN_BASE, SEVEN_SEC_DISPLAY_NUM_PIN_SIZE,
                    SEVEN_SEC_DISPLAY_POS_PIN_BASE, SEVEN_SEC_DISPLAY_POS_PIN_SIZE);
  init_timerISR();

  init_matlab_channel();

  Serial.println("Ready.");

}//end setup


ISR(TIMER0_COMPA_vect){//timer0 interrupt 2kHz 
  //noInterrupts();
  time0_counter_s++;

  //q_resistor.Push( analogRead( VAR_RESISTOR_AI_PIN ) );
  //Serial.print( time0_counter_s );
  //Serial.print( ',' );
  Serial.println( analogRead( VAR_RESISTOR_AI_PIN ) );

  //set_data_seven_display( time0_counter_s );
  
  time0_counter_e++;
 //interrupts();
}


ISR(TIMER1_COMPA_vect){//timer1 interrupt 1Hz 
  //noInterrupts();
  time1_counter_s++;

  //Serial.print( time1_counter_s );
  //Serial.print( ',' );
  //Serial.println( analogRead( VAR_RESISTOR_AI_PIN ) );
  //Serial.println( analogRead( VAR_RESISTOR_AI_PIN ) );

  

  time1_counter_e++;
  //interrupts();
}
  
ISR(TIMER2_COMPA_vect){//timer1 interrupt 8kHz 
  //noInterrupts();
  //time2_counter_s++;
  

  //time2_counter_e++;
  //interrupts();
}

void set_data_seven_display_one_digit(int number, int dp, int pos) {
    for(int i = SEVEN_SEC_DISPLAY_POS_PIN_BASE; i < SEVEN_SEC_DISPLAY_POS_PIN_BASE + SEVEN_SEC_DISPLAY_POS_PIN_SIZE; i++) {
        digitalWrite(i,HIGH);
    }
    for(int i = 0; i < 7 ; i++) {
        digitalWrite(i + SEVEN_SEC_DISPLAY_NUM_PIN_BASE, pinState[number][i]);
    }
    digitalWrite(pos + SEVEN_SEC_DISPLAY_POS_PIN_BASE, LOW);
    delay(5);
}

void set_data_seven_display(int number) {
    int r = 0;
    for( int i = 0; i < SEVEN_SEC_DISPLAY_POS_PIN_SIZE; i++ ) {
      r = number % 10;
      number /= 10;
      set_data_seven_display_one_digit( r, 0 , i );
    }
}

void loop(){
  
  //do other things here

  // print counter
  //noInterrupts();
  /*
  Serial.print( time0_counter_s );
  Serial.print( " " );
  Serial.print( time0_counter_e );
  Serial.print( " " );

  
  Serial.print( time1_counter_s );
  Serial.print( " " );
  Serial.print( time1_counter_e );
  Serial.print( " " );

  
  Serial.print( time2_counter_s );
  Serial.print( " " );
  Serial.print( time2_counter_e );
  Serial.println( "" );
  //interrupts();
  */

  set_data_seven_display( time1_counter_s );
  /*
  noInterrupts();
  set_data_seven_display( time0_counter_s );
  while( !q_resistor.IsEmpty() ) {
    Serial.print( time0_counter_s );
    Serial.print( ',' );
    Serial.print( time1_counter_s );
    Serial.print( ',' );
    Serial.print( time2_counter_s );
    Serial.print( ',' );
    Serial.println( q_resistor.getFront() );
    q_resistor.Pop();
  }
 
  interrupts();
   */
}
