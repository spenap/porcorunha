#ifndef CONTROLLER_H
#define CONTROLLER_H

#include "reversegeocoder.h"
#include <QObject>

class QDeclarativeContext;

class Controller : public QObject
{
    Q_OBJECT
public:
    explicit Controller(QDeclarativeContext *context);
    ~Controller();

public Q_SLOTS:
    int lookup(double latitude, double longitude);
    QString lookupAddress(int lookupId);

Q_SIGNALS:
    void addressResolved(int lookupId, QString address);

private Q_SLOTS:
    void onAddressResolved(int lookupId, QString address);

private:
    QDeclarativeContext *m_declarativeContext;
    ReverseGeocoder* m_reverseGeoncoder;
    QHash<int, QString> m_addressLookupTable;
};

#endif // CONTROLLER_H