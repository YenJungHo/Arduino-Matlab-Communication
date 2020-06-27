# Side project | Matlab & Arduino Serial Communication and Real-time Display Waveform

There are two part in this system. One is 'Arduino', the other is 'matlab'.
* Arduino : real-time sensor data collection, Acuator command(like motor).
* Matlab : get/save date from arduino, analysis and polt figure in time domain and frquency domain.

## 1. Arduino

### 1.1. Desired feature 
* Data input : sensor data collection.
* Data output : Acuator command, like motor.

### 1.2. Basic function
#### 1.2.1 ISR Timer
用途：因為要做傅立葉轉換，因此'Arduino' 需要固定時間間隔抓取資料。
* [Arduino Timer Interrupts](https://www.instructables.com/id/Arduino-Timer-Interrupts/)
* [Arduino Interrupts](http://programmermagazine.github.io/201407/htm/article1.html)

#### 1.2.2 critical section
用途：使用 'Arduino' Timer 抓取資料，怕發生 ‘race condition' ，使用critical section進行動作保護。
* [Arduinor referece. interrupts()](https://www.arduino.cc/reference/en/language/functions/interrupts/nointerrupts)

#### 1.2.3. seven display
用途：建立 'Arduino' 時鐘顯示功能，用來除錯。
* [四位數七段顯示器](https://openhome.cc/Gossip/CodeData/mBlockArduino/mBlockArduino17.html)

#### 1.2.4. data structure
用途：在 'Arduino' 使用 C++，建立感測器資料佇列，儲存感測器資料。
* [queue for arduino](http://alrightchiu.github.io/SecondRound/queue-introjian-jie-bing-yi-linked-listshi-zuo.html)

## 2. Matlab
### 2.1. Desired feature 
* Data input : 
    * Connenct serial communication vie usb.
    * Get raw date from arduino.
    * Plot figure immediately with raw date in time domain.
    * Save raw date.
* Data analysis : 
    * analysis and 
    * plot figure in time domain and frquency domain vie data from arduino raw data. 

### 2.2. Basic function
#### 2.2.1. Matlab & Arduino Serial Communication
用途：Matlab 使用 USB 跟 Arduino 建立串列通訊
* [Mac OSX Yosemite no serial ports showing for Uno R3](https://arduino.stackexchange.com/questions/12133/mac-osx-yosemite-no-serial-ports-showing-for-uno-r3)
* [Simple Matlab & Arduino Serial Communication](https://www.mathworks.com/matlabcentral/answers/80833-simple-matlab-arduino-serial-communication)
* [用Matlab與Arduino的序列阜溝通](http://hklifenote.blogspot.com/2015/03/matlabarduino.html)
* [Serial Communication between MATLAB and Arduino](https://circuitdigest.com/microcontroller-projects/serial-communication-between-matlab-and-arduino)
* [Read Streaming Data from Arduino Using Serial Port Communication](https://www.mathworks.com/help/matlab/matlab_external/read-streaming-data-from-arduino.html)

#### 2.2.2. Timer in GUIDE
用途：在 MATLAB 使用 timer 來持續更新即時動作。
* [MATLAB: How to close a MATLAB GUI by using count down timer](https://itectec.com/matlab/matlab-how-to-close-a-matlab-gui-by-using-count-down-timer/)
* [creating a timer in GUI](https://www.mathworks.com/matlabcentral/answers/38595-creating-a-timer-in-gui)
* [MATLAB](https://www.mathworks.com/help/matlab/ref/timer-class.html)

#### 2.2.3. save data dialog
用途：儲存 Matlab 蒐集到的 Arduino 資料。
* [matlab GUI中uiputfile保存文件](https://www.ilovematlab.cn/thread-35547-1-1.html)
* [列印函數FPRINTF](http://bime-matlab.blogspot.com/2006/10/76-fprintf.html)
