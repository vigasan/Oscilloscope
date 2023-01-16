#ifndef SERIALWORKER_H
#define SERIALWORKER_H

#include <QObject>
#include <QMutex>
#include <QtSerialPort/QSerialPort>
#include <QQueue>
#include <QFile>
#include "frame.h"

#define CMD_BUTTON_1             1    //  ESP32 -> RPI        BUTTON 1 STATUS (PRESSED, UNPRESSED)
#define CMD_BUTTON_2             2    //  ESP32 -> RPI        BUTTON 2 STATUS (PRESSED, UNPRESSED)
#define CMD_LED_GREEN            3
#define CMD_PWM_LED_R            4    //  RPI -> ESP32        SET PWM DUTYCYCLE FOR RED LED (0 - 255)
#define CMD_PWM_LED_G            5    //  RPI -> ESP32        SET PWM DUTYCYCLE FOR GREEN LED (0 - 255)
#define CMD_PWM_LED_B            6    //  RPI -> ESP32        SET PWM DUTYCYCLE FOR BLUE LED (0 - 255)
#define CMD_ADC_INPUT            7    //  ESP32 -> RPI        ADC READ VALUE (0 - 4095)
#define CMD_ADC_ENABLE           8    //  RPI -> ESP32        ENABLE/DISABLE ADC READING/

#define DATASOURCE_ADC      0
#define DATASOURCE_SERIAL   1

class SamplerWorker : public QObject
{
    Q_OBJECT
public:
    explicit SamplerWorker(QQueue<QPointF> *samplesQueue, QObject *parent = nullptr);
    ~SamplerWorker();
    void requestWork();
    void abort();

private:
    static const int RCV_ST_IDLE = 0;
    static const int RCV_ST_CMD = 1;
    static const int RCV_ST_DATA_LENGTH = 2;
    static const int RCV_ST_DATA = 3;
    static const int RCV_ST_CHECKSUM = 4;

    bool _abort;
    bool _working;
    QMutex mutex;
    QQueue<QPointF> *m_SamplesQueue;
    QFile m_adcFile;
    QSerialPort *m_Serial;
    int m_dataSource;
    int m_refreshPoints;
    int m_index;


signals:
    void workRequested();
    void updateCurve();
    void finished();


public slots:
    void doWork();
    void setSource(int source);
};

#endif // SERIALWORKER_H
