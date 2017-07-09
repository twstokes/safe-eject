#define UNSAFE 48
#define SAFE 49
#define WORKING 50

#define BUTTON 2
#define GREEN_LED 7
#define RED_LED 11

int buttonVal = LOW;
int state = UNSAFE;

// Note: RGB button works in reverse state, e.g.: LOW == On

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

		// only set if necessary
		if (newState != state) {
			setState(newState);
		}
	}

	if (state == WORKING) {
		pulse();
	}

	buttonVal = digitalRead(BUTTON);

	if (buttonVal == HIGH) {
		Serial.write("eject");
		setState(WORKING);
		// debounce
		delay(200);
	}
}

void setState(int newState) {
	if (newState == UNSAFE) {
		// Green off
		digitalWrite(GREEN_LED, HIGH);
		// Red on
		digitalWrite(RED_LED, LOW);
	} else if(newState == SAFE) {
		digitalWrite(GREEN_LED, LOW);
		digitalWrite(RED_LED, HIGH);
	} else if(newState == WORKING) {
		digitalWrite(GREEN_LED, HIGH);
		digitalWrite(RED_LED, LOW);
	} else {
		// invalid state passed
		newState = UNSAFE;
	}

	state = newState;
}

void pulse() {
   // fade out from max to min in increments of 5 points:
  for (int fadeValue = 0 ; fadeValue <= 255; fadeValue += 5) {
    // sets the value (range from 0 to 255):
    analogWrite(RED_LED, fadeValue);
    // wait for 30 milliseconds to see the dimming effect
    delay(10);
  }

  // fade in from min to max in increments of 5 points:
  for (int fadeValue = 255 ; fadeValue >= 0; fadeValue -= 5) {
    // sets the value (range from 0 to 255):
    analogWrite(RED_LED, fadeValue);
    // wait for 30 milliseconds to see the dimming effect
    delay(10);
  }
}