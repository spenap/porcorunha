#include "reversegeocoder.h"

#include <QGeoCoordinate>
#include <QGeoServiceProvider>
#include <QGeoSearchManager>
#include <QGeoPlace>

static const QString GEO_SERVICE_PROVIDER("nokia");

QTM_USE_NAMESPACE

ReverseGeocoder::ReverseGeocoder() :
    m_serviceProvider(new QGeoServiceProvider(GEO_SERVICE_PROVIDER)),
    m_searchManager(0),
    m_coordinate(new QGeoCoordinate)
{
    m_searchManager = m_serviceProvider->searchManager();

    connect(m_searchManager, SIGNAL(finished(QGeoSearchReply*)),
            this, SLOT(onReplyFinished(QGeoSearchReply*)));
}

ReverseGeocoder::~ReverseGeocoder()
{
    delete m_serviceProvider;
    delete m_coordinate;
}

#include <QDebug>
void ReverseGeocoder::onReplyFinished(QGeoSearchReply *searchReply)
{
    if (searchReply->error() == QGeoSearchReply::NoError) {
        Q_FOREACH(QGeoPlace place, searchReply->places()) {
            QString address(place.address().street());
            if (!address.isEmpty()) {
                emit addressResolved(0, address);
            } else {
                emit addressResolved(0, place.address().city());
            }
        }

        delete searchReply;
    } else {
        qDebug() << searchReply->error() << searchReply->errorString();
    }
}

void ReverseGeocoder::lookup(const QGeoCoordinate& coordinate)
{
    if (!m_coordinate->isValid() ||
            m_coordinate->distanceTo(coordinate) > 50) {

        m_coordinate->setLatitude(coordinate.latitude());
        m_coordinate->setLongitude(coordinate.longitude());

        if (m_searchManager->supportsReverseGeocoding()) {
            m_searchManager->reverseGeocode(*m_coordinate);
        }
    }
}
