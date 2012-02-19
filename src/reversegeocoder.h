#ifndef REVERSEGEOENCODER_H
#define REVERSEGEOENCODER_H

#include <QObject>
#include <QUrl>

namespace QtMobility {
    class QGeoCoordinate;
    class QGeoSearchReply;
    class QGeoSearchManager;
    class QGeoServiceProvider;
}

using QtMobility::QGeoCoordinate;
using QtMobility::QGeoSearchReply;

class ReverseGeocoder : public QObject
{
    Q_OBJECT
public:
    ReverseGeocoder();
    virtual ~ReverseGeocoder();

public Q_SLOTS:
    void lookup(const QGeoCoordinate& coordinate);

Q_SIGNALS:
    void addressResolved(int lookupId, QString address);

private Q_SLOTS:
    void onReplyFinished(QGeoSearchReply* searchReply);

private:
    QtMobility::QGeoServiceProvider* m_serviceProvider;
    QtMobility::QGeoSearchManager* m_searchManager;
    QtMobility::QGeoCoordinate* m_coordinate;
};

#endif // REVERSEGEOENCODER_H
