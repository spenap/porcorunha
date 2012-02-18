import QtQuick 1.1

XmlListModel {
    source: ''
    query: '/lines/line'

    XmlRole { name: 'code'; query: '@code/string()' }
    XmlRole { name: 'name'; query: '@name/string()' }
    XmlRole { name: 'direction'; query: '@direction/string()' }
    XmlRole { name: 'directionDescription'; query: '@directionDescription/string()' }
    XmlRole { name: 'description'; query: '@description/string()' }
}
