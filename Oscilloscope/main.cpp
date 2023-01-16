#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QtDebug>
#include <QThread>
#include <QQueue>
#include "samplerworker.h"
#include "datasource.h"

int main(int argc, char *argv[])
{
    int rv;
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);

    QQueue<QPointF> samplesQueue;

    QThread *threadSampler = new QThread();
    SamplerWorker *samplerWorker = new SamplerWorker(&samplesQueue);
    DataSource dataSource(&samplesQueue);

    QQmlApplicationEngine engine;
    QQmlContext* ctx = engine.rootContext();
    ctx->setContextProperty("dataSource", &dataSource);
    ctx->setContextProperty("sampleWorker", samplerWorker);


    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated, &app, [url](QObject *obj, const QUrl &objUrl)
    {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine.load(url);

    samplerWorker->moveToThread(threadSampler);
    //QObject::connect(samplerWorker, SIGNAL(updateCurve()), &dataSource, SLOT(FrameIncoming(Frame*)));
    QObject::connect(samplerWorker, SIGNAL(workRequested()), threadSampler, SLOT(start()));
    QObject::connect(threadSampler, SIGNAL(started()), samplerWorker, SLOT(doWork()));
    QObject::connect(samplerWorker, SIGNAL(finished()), threadSampler, SLOT(quit()), Qt::DirectConnection);

    samplerWorker->abort();
    threadSampler->wait(); // If the thread is not running, this will immediately return.
    samplerWorker->requestWork();

    rv = app.exec();
    samplerWorker->abort();
    threadSampler->wait();
    delete threadSampler;
    qDebug() << "Delete Sampler Thread";
    delete samplerWorker;
    qDebug() << "Delete Sampler SamplerWorker";

    qDebug() << "End Application";

    return rv;
}
