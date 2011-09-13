// SLhwi.pde
// Arduino mega interface for controlling SooperLooper through PureData
// written by goldfish Copyright (c) 2011. All rights reserved.
// see README file for license information
// 

// set up 7 footswitches monitoring
int buttonF[] = { 23,25,27,29,31,33,35 };
boolean buttonFstate[7];
boolean buttonFstatePREV[] = { 0,0,0,0,0,0,0 };

// set up 5 sliders monitoring
int slider[] = { 0, 1, 2, 3, 4 };
int sliderValue[5];
int sliderValuePREV[5];

// set up polling of inputs on timers so we don't have to use delays
unsigned long currentTime;
unsigned long nextFbuttonPoll = 0;
unsigned long nextSliderPoll = 0;

void setup(){
    Serial.begin( 57600 ); // make sure to set your serial monitor at the right speed if debugging
    delay( 500 ); // delay to give time to turn on serial monitor
    
    for( int i=0;i<5;i++ ){ 
        sliderValue[i] = analogRead( slider[i] );
        Serial.print( "/AM/S/" );
        Serial.print( i );
        Serial.print( " " );
        Serial.println( sliderValue[i] );
    }
    for( int i=0;i<7;i++ ){
        pinMode( buttonF[i], INPUT );  
        digitalWrite( buttonF[i], 1 ); // turn on internal pull up
        buttonFstatePREV[i] = buttonFstate[i];
        buttonFstate[i] = !( digitalRead( buttonF[i] ));
        // Using internal pull-ups and N/O momentary buttons tied to ground
        // our default pin state is high when the button is not being pressed.
        // we take the inverse of this for our switch state so being pressed is 1
        Serial.print( "/AM/F/" );
        Serial.print( i );
        Serial.print( " " );
        Serial.println( buttonFstate[i], BIN );
    }
}

void loop(){
    currentTime = millis(); // set current time for button debouncing and polling purposes
    
    if( currentTime > nextFbuttonPoll ){ // Poll the 7 foot switches.
        for( int i=0;i<7;i++ ){
            buttonFstatePREV[i] = buttonFstate[i];
            buttonFstate[i] = !( digitalRead( buttonF[i] )); // open high switch
            if( buttonFstate[i] != buttonFstatePREV[i] && buttonFstate[i] == 1 ){
                Serial.print( "/AM/F/" );
                Serial.print( i );
                Serial.print( " " );
                Serial.println( buttonFstate[i], BIN );
            }
        }
        nextFbuttonPoll = currentTime + 25; // this sets the time in millis between button polls.
    }
    
    if( currentTime > nextSliderPoll ){ // poll the five sliders
        for( int i=0;i<5;i++ ){
            sliderValuePREV[i] = sliderValue[i];
            sliderValue[i] = analogRead( slider[i] );
            if( abs( sliderValue[i] - sliderValuePREV[i]) > 15 ){ // ***************tweak jiggle value later
                Serial.print( "/AM/S/" );
                Serial.print( i );
                Serial.print( " " );
                Serial.println( sliderValue[i] );
            }
        }
        nextSliderPoll = currentTime + 100; // this sets the time in millis between slider polls.
    }
}
