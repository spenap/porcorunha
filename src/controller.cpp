#include "controller.h"

#include <QGeoCoordinate>
#include <QDeclarativeContext>
#include <QDBusInterface>
#include <QDBusPendingCall>

static const QString FAVORITE_STOPS("favorites");
static const QString STORE_DBUS_IFACE("com.nokia.OviStoreClient");

Controller::Controller(QDeclarativeContext *context) :
    QObject(),
    m_declarativeContext(context),
    m_reverseGeoncoder(new ReverseGeocoder),
    m_addressLookupTable(),
    m_inSimulator(false),
    m_settings()
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

bool Controller::isFavorite(QString code) const
{
    QStringList favorites;
    favorites = m_settings.value(FAVORITE_STOPS,
                                 QVariant::fromValue(favorites)).value<QStringList>();

    return favorites.contains(code);
}

void Controller::setFavorite(QString code, bool value)
{
    QStringList favorites;
    favorites = m_settings.value(FAVORITE_STOPS,
                                 QVariant::fromValue(favorites)).value<QStringList>();

    if (value && !favorites.contains(code)) {
        favorites.append(code);
    } else if (!value) {
        favorites.removeAll(code);
    }
    m_settings.setValue(FAVORITE_STOPS, QVariant::fromValue(favorites));
}

QStringList Controller::favorites() const
{
    QStringList favorites;
    favorites = m_settings.value(FAVORITE_STOPS,
                                 QVariant::fromValue(favorites)).value<QStringList>();
    return favorites;
}

void Controller::openStoreClient(const QString& url) const
{
    // Based on
    // https://gitorious.org/n9-apps-client/n9-apps-client/blobs/master/daemon/notificationhandler.cpp#line178
#ifdef QT_SIMULATOR
    Q_UNUSED(url)
#else
    QDBusInterface dbusInterface(STORE_DBUS_IFACE,
                                 "/",
                                 STORE_DBUS_IFACE,
                                 QDBusConnection::sessionBus());

    QStringList callParams;
    callParams << url;

    dbusInterface.asyncCall("LaunchWithLink", QVariant::fromValue(callParams));
#endif
}
