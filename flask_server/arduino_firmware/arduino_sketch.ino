int flex_pin = A0;
int flex;

void setup() {
  Serial.begin(9600);
}

void loop() {
  flex = analogRead(flex_pin);
  Serial.println(flex);
  delay(200);
}

