#include <SPI.h>
#include <Adb.h>
#include "pitches.h"

// notes in the melody:
int melody[] = {
                NOTE_FS4,
                0,
                NOTE_CS4,
                NOTE_FS4,
                NOTE_CS4,
                NOTE_GS4
                };

// note durations: 4 = quarter note, 8 = eighth note, etc.:
int noteDurations[] = {4,18,16,16,16,4};

// led pin settings.
const int ledPin1 = 4;
const int ledPin2 = 5;

// data from Android.
int android_xy[2];

// Adb connection.
Connection * connection;

// Elapsed time for ADC sampling
long lastTime;
long melodylastTime;
int check_flag;

// Event handler for the shell connection. 
void adbEventHandler(Connection * connection, adb_eventType event, uint16_t length, uint8_t * data)
{
  int i;

  // Data packets contain two bytes, one for each servo, in the range of [0..180]
  if (event == ADB_CONNECTION_RECEIVE)
  {
    android_xy[0] = data[0];
    android_xy[1] = data[1];
  }

}

void setup()
{
  pinMode(ledPin1, OUTPUT);
  pinMode(ledPin2, OUTPUT);
  digitalWrite(ledPin1, HIGH);
  digitalWrite(ledPin2, HIGH);
  
  // Initialise serial port
  Serial.begin(57600);
  
  // Note start time
  lastTime = millis();
  melodylastTime = millis();
  check_flag = 0;
  
  // Initialise the ADB subsystem.  
  ADB::init();

  // Open an ADB stream to the phone's shell. Auto-reconnect
  connection = ADB::addConnection("tcp:4567", true, adbEventHandler);  
}

void loop()
{
  
  if ((millis() - lastTime) > 20)
  {
    uint16_t data = analogRead(A0);
    connection->write(2, (uint8_t*)&data);
    lastTime = millis();
  }
 
  if (android_xy[0] < 60){
    if (android_xy[1] < 45){
      digitalWrite(ledPin1, HIGH);
      digitalWrite(ledPin2, HIGH);
    }
    else if (android_xy[1] >= 45 && android_xy[1] < 90){
      if ((millis() - melodylastTime) > 2500){
        if ( check_flag == 0){
          digitalWrite(ledPin1, LOW);
          digitalWrite(ledPin2, HIGH);
          check_flag = 1;
        }
        else{
          digitalWrite(ledPin1, HIGH);
          digitalWrite(ledPin2, LOW);
          check_flag = 0;
        }
        tone_ones(NOTE_A4, 8);
        delay(30);
        tone_ones(NOTE_G4, 8);
        delay(60);
        tone_ones(NOTE_A4, 8);
        delay(30);
        tone_ones(NOTE_G4, 8);
        melodylastTime = millis();
      }
    }
    else if (android_xy[1] >= 90 && android_xy[1] < 120){
      digitalWrite(ledPin1, LOW);
      digitalWrite(ledPin2, HIGH);
    }
    else if (android_xy[1] >= 120 && android_xy[1] < 150){
      digitalWrite(ledPin1, HIGH);
      digitalWrite(ledPin2, LOW);
    }
    else{
      digitalWrite(ledPin1, LOW);
      digitalWrite(ledPin2, LOW);
    }
  }
  else if (android_xy[0] >= 60 && android_xy[0] < 120){
    digitalWrite(ledPin1, HIGH);
    digitalWrite(ledPin2, HIGH);
  }
  else if (android_xy[0] >= 120){
    if (android_xy[1] < 20){
      if ((millis() - melodylastTime) > 2000){
        melody_start();
        melodylastTime = millis();
      }
    }
    else if (android_xy[1] >= 20 && android_xy[1] < 40){
      tone_ones(NOTE_C3, 8);
    }
    else if (android_xy[1] >= 40 && android_xy[1] < 60){
      tone_ones(NOTE_D3, 8);
    }
    else if (android_xy[1] >= 60 && android_xy[1] < 80){
      tone_ones(NOTE_E3, 8);
    }
    else if (android_xy[1] >= 80 && android_xy[1] < 100){
      tone_ones(NOTE_F3, 8);
    }
    else if (android_xy[1] >= 100 && android_xy[1] < 120){
      tone_ones(NOTE_G3, 8);
    }
    else if (android_xy[1] >= 120 && android_xy[1] < 140){
      tone_ones(NOTE_A3, 8);
    }
    else if (android_xy[1] >= 140 && android_xy[1] < 160){
      tone_ones(NOTE_B3, 8);
    }
    else if (android_xy[1] >= 160 && android_xy[1] < 180){
      tone_ones(NOTE_C4, 8);
    }
  }


  // Poll the ADB subsystem.
  ADB::poll();
}

void melody_start() {
  // iterate over the notes of the melody:
  for (int thisNote = 0; thisNote < 6; thisNote++) {

    // to calculate the note duration, take one second 
    // divided by the note type.
    //e.g. quarter note = 1000 / 4, eighth note = 1000/8, etc.
    int noteDuration = 2500/noteDurations[thisNote];
    tone(14, melody[thisNote], noteDuration);

    digitalWrite(ledPin1, HIGH);
    digitalWrite(ledPin2, HIGH);
    delay(30);
    digitalWrite(ledPin1, LOW);
    digitalWrite(ledPin2, LOW);

    // to distinguish the notes, set a minimum time between them.
    // the note's duration + 30% seems to work well:
    int pauseBetweenNotes = noteDuration * 1.30;
    delay(pauseBetweenNotes);
  }
}

void tone_ones(int note_value, int Duration){
    int noteDuration = 1000/Duration;
    tone(14, note_value, noteDuration);
    //int pauseBetweenNotes = noteDuration * 1.30;
    delay(50);
}
