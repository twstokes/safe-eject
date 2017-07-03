#define UNSAFE 48
#define SAFE 49
#define WORKING 50

#define BUTTON 2
#define GREEN_LED 7
#define RED_LED 11

int buttonVal = LOW;
int state = UNSAFE;

void setup() {
	Serial.begin(9600);
	pinMode(BUTTON, INPUT);
	pinMode(GREEN_LED, OUTPUT);
	pinMode(RED_LED, OUTPUT);

	setState(WORKING);
}

void loop() {
	// data waiting
	if (Serial.available() > 0) {
		int newState = Serial.read();
		setState(newState);
	}

	if (state == WORKING) {
		pulse();
	}

	buttonVal = digitalRead(BUTTON);

	if (buttonVal == HIGH) {
		Serial.write("eject");
		setState(WORKING);
	}
}

void setState(int newState) {
	if (newState == UNSAFE) {
		digitalWrite(GREEN_LED, LOW);
		digitalWrite(RED_LED, HIGH);
	} else if(newState == SAFE) {
		digitalWrite(GREEN_LED, HIGH);
		digitalWrite(RED_LED, LOW);
	} else if(newState == WORKING) {
		digitalWrite(GREEN_LED, LOW);
		digitalWrite(RED_LED, LOW);
		pulse();
	} else {
		// invalid state passed
		newState = UNSAFE;
	}

	state = newState;
}

void pulse() {
  // fade in from min to max in increments of 5 points:
  for (int fadeValue = 0 ; fadeValue <= 255; fadeValue += 5) {
    // sets the value (range from 0 to 255):
    analogWrite(RED_LED, fadeValue);
    // wait for 30 milliseconds to see the dimming effect
    delay(10);
    // cut things short if there's a potential state change
    if (Serial.available() > 0) return;
  }

  // fade out from max to min in increments of 5 points:
  for (int fadeValue = 255 ; fadeValue >= 0; fadeValue -= 5) {
    // sets the value (range from 0 to 255):
    analogWrite(RED_LED, fadeValue);
    // wait for 30 milliseconds to see the dimming effect
    delay(10);
    // cut things short if there's a potential state change
    if (Serial.available() > 0) return;
  }
}