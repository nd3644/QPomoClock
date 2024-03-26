#include <QGuiApplication>
#include <QQmlApplicationEngine>


#include <QDirIterator>
#include <QResource>

void printResources() {
	QDirIterator it(":", QDirIterator::Subdirectories);
	while (it.hasNext()) {
		qDebug() << it.next();
	}
}

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);
	//printResources();		// debug

    QQmlApplicationEngine engine;
    const QUrl url(u"qrc:/QPomoClock/Main.qml"_qs);
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
