import QtQuick 1.1

XmlListModel {
    source: ''
    query: '/stops/stop'

    XmlRole { name: 'code'; query: '@code/string()' }
    XmlRole { name: 'name'; query: '@name/string()' }
    XmlRole { name: 'lat'; query: '@lat/number()' }
    XmlRole { name: 'lng'; query: '@lng/number()' }
}
