## Current status: Hack

![pressing button to eject](https://github.com/twstokes/safe-eject/blob/master/media/SafeEject.gif)

### Objective:

Provide a convenient way to eject mounted volumes from a Mac. Useful for "undocking" a Mac laptop.

### Hardware:

* Arduino
* Adafruit RGB pushbutton: https://www.adafruit.com/product/3350
* Pull-down resistor for button presses

#### Wiring:

* Anode to 5v
* Red cathode to PWM output
* Green cathode to digital output
* Button to input with pull-down resistor
* 5v to button

#### Todo:

* Clean up multiple calls about the same volume (includes slices)
* Convert to Menu Bar app
