#include "controller.h"

#include <QGeoCoordinate>
#include <QDeclarativeContext>

Controller::Controller(QDeclarativeContext *context) :
    QObject(),
    m_declarativeContext(context),
    m_reverseGeoncoder(new ReverseGeocoder),
    m_addressLookupTable(),
    m_inSimulator(false)
{
#ifdef QT_SIMULATOR
    m_inSimulator = true;
#endif
    m_declarativeContext->setContextProperty("controller", this);
    m_declarativeContext->setContextProperty("inSimulator", m_inSimulator);

    connect(m_reverseGeoncoder, SIGNAL(addressResolved(int, QString)),
            SLOT(onAddressResolved(int,QString)));
}

Controller::~Controller()
{
    delete m_reverseGeoncoder;
}

int Controller::lookup(double latitude, double longitude)
{
    QGeoCoordinate coordinate(latitude, longitude);
    m_reverseGeoncoder->lookup(coordinate);

    return 0;
}

QString Controller::lookupAddress(int lookupId)
{
    if (!m_addressLookupTable.contains(lookupId)) {
        return QString("Not found");
    }
    return m_addressLookupTable[lookupId];
}

void Controller::onAddressResolved(int lookupId, QString address)
{
    m_addressLookupTable.insert(lookupId, address);
    emit addressResolved(lookupId, address);
}
