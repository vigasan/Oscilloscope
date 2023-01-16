#ifndef DATASOURCE_H
#define DATASOURCE_H

#include <QObject>
#include <QAbstractSeries>
#include <QQueue>
#include <QFile>

QT_CHARTS_USE_NAMESPACE

#define X_POINTS 703

class DataSource : public QObject
{
    Q_OBJECT
public:
    explicit DataSource(QQueue<QPointF> *samplesQueue, QObject *parent = nullptr);

signals:
    void updateCurve();

public slots:
    void update(QAbstractSeries *series);
    //void timerTrigger();


private:
    QQueue<QPointF> *m_SamplesQueue;
    //int m_index;
};

#endif // DATASOURCE_H
