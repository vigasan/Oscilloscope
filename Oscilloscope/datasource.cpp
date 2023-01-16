#include "datasource.h"
#include <QtCharts/QXYSeries>
#include <QtCore/QRandomGenerator>
#include <QtCore/QtMath>
#include <QDebug>
#include <QTimer>

QT_CHARTS_USE_NAMESPACE

Q_DECLARE_METATYPE(QAbstractSeries *)
Q_DECLARE_METATYPE(QAbstractAxis *)

DataSource::DataSource(QQueue<QPointF> *samplesQueue, QObject *parent) : QObject(parent)
{
    //m_index = -1;
    qRegisterMetaType<QAbstractSeries*>();
    qRegisterMetaType<QAbstractAxis*>();

    m_SamplesQueue = samplesQueue;
}
/*
void DataSource::timerTrigger()
{

    if(m_adcFile.exists())
    {
        m_adcFile.open(QIODevice::ReadOnly | QIODevice::Text);
        int adc = QString(m_adcFile.readAll()).toInt();
        m_adcFile.close();

        if(++m_index > X_POINTS)
            m_queuePoints.dequeue();

        qreal x = 0;
        qreal y = 0;
        y = adc;
        x = m_index;
        m_queuePoints.enqueue(QPointF(x, y));

        if((m_index % 10) == 0)
            emit updateCurve();


        //double m_Voltage = double(adc) * 0.125;
        //qDebug()<< "Voltage [V]: " << m_Voltage;

    }


}
*/


void DataSource::update(QAbstractSeries *series)
{
    if(series)
    {
        QXYSeries *xySeries = static_cast<QXYSeries *>(series);
        xySeries->replace(*m_SamplesQueue);
    }

}


