/**
 * EV3 TV Gun
 * Karandash & Samodelkin, 2016
 */

import java.awt.*;
import java.awt.event.*;
import processing.serial.*;
import java.nio.ByteBuffer;

Robot robot;
Point save_p;

KeystrokeSimulator keySim;
Serial myPort;  
 
byte[] in_message = new byte[64];
int in_mailbox_length = 0;
char[] in_mailbox = new char[16];
char[] in_value_chars = new char[64];
byte[] mes_value = new byte[0];

boolean ex,shot,go,strafe,left,right;

int i_1,i_2,i_3,i_4;
int povorot = 50;

long ex_timer = millis();
long shot_timer = millis();
long go_timer = millis();
long strafe_timer = millis();
long gyro_drift = millis();

Point p = getGlobalMouseLocation();


void setup() 
{
  keySim = new KeystrokeSimulator(); 

  try { 
    robot = new Robot();
    robot.setAutoDelay(0);
  } 
  catch (Exception e) {
    e.printStackTrace();
  }

  String portName = Serial.list()[0];
  myPort = new Serial(this, portNam, 115200); 
}

void draw() {
  boolean InMessageTrue = false;
  int pov = 0;
  if (abs(povorot-50)<10) pov = round((povorot-50)/8);
  if (abs(povorot-50)>=10 && abs(povorot-50)<25) pov = round((povorot-50)/5);
  if (abs(povorot-50)>=25 && abs(povorot-50)<40) pov = (round(povorot-50)/4);
  if (abs(povorot-50)>=40) pov = round((povorot-50)/3);
  mouseMove((int)p.getX()-pov, (int)p.getY());      
  p = getGlobalMouseLocation();
  while (myPort.available() > 0)
  {
    in_message = myPort.readBytes();
    myPort.readBytes(in_message);    

    if (in_message.length < 12) break;
    byte[] mes_size = {in_message[0], in_message[1]};

    in_mailbox_length = int(in_message[6]-1);
    if (in_mailbox_length > in_message.length-10) break;
    in_mailbox = new char[0];
    for (int i=0; i<in_mailbox_length; i++) {
      in_mailbox = append(in_mailbox, char(in_message[7+i]));
    }

    mes_value = new byte[0];
    byte[] mes_value = {in_message[in_message.length-4], in_message[in_message.length-3], in_message[in_message.length-2], in_message[in_message.length-1]};
    float x = java.nio.ByteBuffer.wrap(mes_value).order(java.nio.ByteOrder.LITTLE_ENDIAN).getFloat();
    String TmpString = new String(in_mailbox);

    int i = int(x);
    
    i_1 = round((i - 1000000)/100000);    
    i_2 = round((i - 1000000 - i_1*100000)/10000);
    i_3 = round((i - 1000000 - i_1*100000 - i_2*10000)/1000);
    i_4 = round((i - 1000000 - i_1*100000 - i_2*10000 - i_3*1000)/100);
    povorot = i - 1000000 - i_1*100000 - i_2*10000 - i_3*1000 - i_4*100;
    
    if (i_1 == 1 && ex == false) {
      try{
        keySim.simulatePress('E');
      }
      catch(AWTException e){
        println(e);
      }
      ex = true;
    }

    if (i_1 == 0 && ex == true || ex == true && ex_timer - millis() > 500) {
      try{
        keySim.simulateRelease('E');
      }
      catch(AWTException e){
        println(e);
      }
      ex = false;
      ex_timer = millis();
    }    
          
    if (i_2 == 1 && shot == false) {
      try{
        keySim.simulatePress('P');
      }
      catch(AWTException e){
        println(e);
      }
      shot = true;
    }

    if (i_2 == 0 && shot == true || shot == true && shot_timer - millis() > 500) {
      try{
        keySim.simulateRelease('P');
      }
      catch(AWTException e){
        println(e);
      }
      shot = false;
      shot_timer = millis();
    }
        
    if (i_3 == 1 && go == false) {
      try{
        keySim.simulatePress('W');
      }
      catch(AWTException e){
        println(e);
      }
      go = true;      
    }

    if (i_3 == 0 && go == true || go == true && go_timer  - millis()> 500) {
      try{
        keySim.simulateRelease('W');
      }
      catch(AWTException e){
        println(e);
      }
      go = false;
      go_timer = millis();
    }
       
    if (i_4 == 1 && strafe == false) {
      try{
        keySim.simulatePress('O'); 
      }
      catch(AWTException e){
        println(e);
      }
      strafe = true;      
    }

    if (i_4 == 0 && strafe == true || strafe == true && strafe_timer  - millis()> 1000) {
      try{
        keySim.simulateRelease('O');
      }
      catch(AWTException e){
        println(e);
      }
      strafe = false;
      strafe_timer = millis();
    }
               
  }
}

public class KeystrokeSimulator {
private Robot robot;
 
  KeystrokeSimulator(){
    try{
      robot = new Robot();  
    }
    catch(AWTException e){
      println(e);
    }
  }
  
  void simulatePress(char c) throws AWTException {   
      robot.keyPress(c);
  }
  
  void simulateRelease(char c) throws AWTException {   
      robot.keyRelease(c);
  }
  
}

Point getGlobalMouseLocation() {
  // java.awt.MouseInfo
  PointerInfo pointerInfo = MouseInfo.getPointerInfo();
  Point p = pointerInfo.getLocation();
  return p;  
}

void mouseMove(int x, int y) {
  robot.mouseMove(x, y);
}