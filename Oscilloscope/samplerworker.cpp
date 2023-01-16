#include <QTimer>
#include <QEventLoop>
#include <QThread>
#include <QDebug>
#include <QDate>
#include <QtCharts/QXYSeries>
#include <QtMath>
#include <QtCore/QRandomGenerator>
#include "samplerworker.h"



SamplerWorker::SamplerWorker(QQueue<QPointF> *samplesQueue, QObject *parent) :
    QObject(parent)
{
    _working = false;
    _abort = false;
    m_SamplesQueue = samplesQueue;
    m_adcFile.setFileName("/sys/bus/iio/devices/iio:device0/in_voltage1_raw");
    m_dataSource = DATASOURCE_ADC;
    m_refreshPoints = 100;
    m_index = -1;
}

SamplerWorker::~SamplerWorker()
{

}

void SamplerWorker::requestWork()
{
    mutex.lock();
    _working = true;
    _abort = false;
    qDebug()<<"Request worker start in Thread "<<thread()->currentThreadId();
    mutex.unlock();

    emit workRequested();
}

void SamplerWorker::abort()
{
    mutex.lock();
    if (_working) {
        _abort = true;
        qDebug()<<"Request worker aborting in Thread "<<thread()->currentThreadId();
    }
    mutex.unlock();
}

void SamplerWorker::setSource(int source)
{
    m_dataSource = source;
    if(source == DATASOURCE_ADC)
        m_refreshPoints = 100;
    else
        m_refreshPoints = 10;
    m_index = -1;
    m_SamplesQueue->clear();
}

void SamplerWorker::doWork()
{
    qDebug()<<"Starting worker process in Thread "<<thread()->currentThreadId();

    bool abort = false;
    qreal x = 0;
    qreal y = 0;
    int yValue = 0;


    quint8 inByte;
    int numByte = 0;
    int receiverStatus = RCV_ST_IDLE;
    Frame *m_inFrame = nullptr;
    quint8 checksum = 0, xored = 0x00;
    int dataLength = 0;

    // Serial Port Initialization
    m_Serial = new QSerialPort();
    m_Serial->setPortName("ttyUSB0");
    m_Serial->setBaudRate(QSerialPort::Baud115200);
    m_Serial->setDataBits(QSerialPort::Data8);
    m_Serial->setParity(QSerialPort::NoParity);
    m_Serial->setStopBits(QSerialPort::OneStop);
    m_Serial->setFlowControl(QSerialPort::NoFlowControl);
    m_Serial->open(QIODevice::ReadWrite);
    qDebug() << "SerialPort Status: " << m_Serial->isOpen();


    while(!abort)
    {
        mutex.lock();
        abort = _abort;
        mutex.unlock();
        if(m_dataSource == DATASOURCE_ADC)           // READ DATA FROM ADC
        {
            m_adcFile.open(QIODevice::ReadOnly | QIODevice::Text);
            yValue = QString(m_adcFile.readAll()).toInt();
            m_adcFile.close();
            QThread::usleep(100);
        } else                                      // READ DATA FROM SERIAL
        {
            if (m_Serial->waitForReadyRead(10))
            {
                QByteArray receivedData = m_Serial->readAll();

                while(receivedData.count() > 0)
                {
                    inByte = quint8(receivedData[0]);
                    receivedData.remove(0,1);

                    if(inByte == Frame::FRAME_ESCAPE_CHAR)
                    {
                        xored = Frame::FRAME_XOR_CHAR;
                    } else
                    {
                        inByte ^= xored;
                        xored = 0x00;

                        switch (receiverStatus)
                        {
                            case RCV_ST_IDLE:
                                {
                                    if(inByte == Frame::FRAME_START)
                                    {
                                        if (m_inFrame == nullptr)
                                            m_inFrame = new Frame();
                                        else
                                            m_inFrame->Clear();
                                        m_inFrame->AddByte(inByte);
                                        checksum = inByte;
                                        receiverStatus = RCV_ST_CMD;
                                    }
                                } break;

                            case RCV_ST_CMD:
                                {
                                    m_inFrame->AddByte(inByte);
                                    checksum += inByte;
                                    receiverStatus = RCV_ST_DATA_LENGTH;
                                } break;

                            case RCV_ST_DATA_LENGTH:
                                {
                                    numByte = dataLength = inByte;
                                    m_inFrame->AddByte(inByte);
                                    checksum += inByte;
                                    receiverStatus = RCV_ST_DATA;
                                } break;

                            case RCV_ST_DATA:
                                {
                                    m_inFrame->AddByte(inByte);
                                    checksum += inByte;
                                    if (--numByte == 0)
                                        receiverStatus = RCV_ST_CHECKSUM;
                                    else if (numByte < 0)
                                        receiverStatus = RCV_ST_IDLE;
                                } break;

                            case RCV_ST_CHECKSUM:
                                {
                                    if (inByte == checksum)
                                    {
                                        receiverStatus = RCV_ST_IDLE;
                                        m_inFrame->AddByte(checksum);
                                        if(m_inFrame->GetCmd() == CMD_ADC_INPUT)
                                        {
                                            yValue = m_inFrame->GetUInt16();
                                        }
                                    }
                                    else
                                    {
                                        receiverStatus = RCV_ST_IDLE;
                                        m_inFrame->Clear();
                                        delete m_inFrame;
                                    }
                                } break;
                        }
                    }
                }
            }
        }

        if(++m_index >= 2100)
            m_SamplesQueue->dequeue();

        y = qreal(yValue);
        x = qreal(m_index);
        m_SamplesQueue->enqueue(QPointF(x, y));

        if((m_index % m_refreshPoints) == 0)
        {
            emit updateCurve();

        }
    }

    // Set _working to false, meaning the process can't be aborted anymore.
    mutex.lock();
    _working = false;
    mutex.unlock();

    qDebug()<<"Worker process finished in Thread "<<thread()->currentThreadId();

    emit finished();
}


