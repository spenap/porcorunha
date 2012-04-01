.pragma library
Qt.include('util.js')

function getDatabase() {
    return openDatabaseSync("PorCorunha", "1.0", "StorageDatabase", 100000)
}

function initialize() {
    var db = getDatabase()
    try {
        db.transaction(
                    function(tx) {
                        tx.executeSql('PRAGMA foreign_keys = ON;')
                    })
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS lines ' +
                                      '(code INT, ' +
                                      'name TEXT, ' +
                                      'direction TEXT, ' +
                                      'directionDescription TEXT, ' +
                                      'description TEXT, ' +
                                      'PRIMARY KEY (code, direction)' +
                                      ')')
                    })
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS stops ' +
                                      '(code INT PRIMARY KEY, ' +
                                      'name TEXT, ' +
                                      'lat REAL, ' +
                                      'lon REAL' +
                                      ')')
                    })
        db.transaction(
                    function(tx) {
                        tx.executeSql('CREATE TABLE IF NOT EXISTS stopslines ' +
                                      '(lineCode INT, ' +
                                      'lineDirection TEXT, ' +
                                      'stopCode INT, ' +
                                      'stopOrder INT NOT NULL, ' +
                                      'PRIMARY KEY (lineCode, lineDirection, stopCode), ' +
                                      'FOREIGN KEY (lineCode, lineDirection) REFERENCES lines(code, direction), ' +
                                      'FOREIGN KEY (stopCode) REFERENCES stops(code)' +
                                      ')')
                    })
    } catch (ex) {
        console.log(ex)
    }
}

function saveLine(busLine) {
    var db = getDatabase()
    var result = true
    try {
        db.transaction(function(tx) {
                           tx.executeSql('REPLACE INTO lines (code, name, direction, directionDescription, description) ' +
                                         'VALUES (?, ?, ?, ?, ?);', [busLine.code,
                                                                     busLine.name,
                                                                     busLine.direction,
                                                                     busLine.directionDescription,
                                                                     busLine.description])
                       })
    } catch (ex) {
        console.log(ex)
        result = false
    }
    return result
}

function loadLines(filter) {
    var db = getDatabase()
    var res = []
    try {
        db.transaction(function(tx) {
                           var rs = tx.executeSql('SELECT code, name, direction, directionDescription, description ' +
                                                  'FROM lines ' +
                                                  'WHERE direction = ? ' +
                                                  'ORDER BY rowid ASC;', filter.direction)
                           if (rs.rows.length > 0) {
                               for(var i = 0; i < rs.rows.length; i++) {
                                   var currentItem = rs.rows.item(i)
                                   var line = new BusLine(currentItem.code,
                                                          currentItem.name,
                                                          currentItem.direction,
                                                          currentItem.directionDescription,
                                                          currentItem.description)
                                   res.push(line)
                               }
                           }
                       })
    } catch (ex) {
        console.log(ex)
    }
    return res
}

function loadLinesByStop(busStop) {
    var db = getDatabase()
    var res = []
    try {
        db.transaction(function(tx) {
                           var rs = tx.executeSql('SELECT code, name, direction, directionDescription, description ' +
                                                  'FROM lines, stopslines ' +
                                                  'WHERE code = lineCode ' +
                                                  'AND direction = lineDirection ' +
                                                  'AND stopCode = ? ' +
                                                  'ORDER BY lines.rowid ASC;', busStop.code)
                           if (rs.rows.length > 0) {
                               for (var i = 0; i < rs.rows.length; i ++) {
                                   var currentItem = rs.rows.item(i)
                                   var line = new BusLine(currentItem.code,
                                                          currentItem.name,
                                                          currentItem.direction,
                                                          currentItem.directionDescription,
                                                          currentItem.description,
                                                          { subtitle: 'Dirección ' + currentItem.directionDescription })
                                   res.push(line)
                               }
                           }
                       })
    } catch (ex) {
        console.log(ex)
    }

    return res
}

function saveStop(busStop) {
    var db = getDatabase()
    var result = true
    try {
        db.transaction(function(tx) {
                           tx.executeSql('REPLACE INTO stops (code, name, lat, lon) ' +
                                         'VALUES (?, ?, ?, ?);', [busStop.code,
                                                                  busStop.name,
                                                                  busStop.lat,
                                                                  busStop.lon])
                       })
    } catch (ex) {
        console.log(ex)
        result = false
    }
    return result
}

function saveStopAtLine(busStop, busLine) {
    var db = getDatabase()
    var result = true
    try {
        db.transaction(function(tx) {
                           tx.executeSql('REPLACE INTO stopslines (lineCode, lineDirection, stopCode, stopOrder) ' +
                                         'VALUES (?, ?, ?, ?);', [busLine.code,
                                                                  busLine.direction,
                                                                  busStop.code,
                                                                  busStop.position])
                       })
    } catch (ex) {
        console.log(ex)
        result = false
    }
    return result
}

function loadStopsByLine(busLine) {
    var db = getDatabase()
    var res = []
    try {
        db.transaction(function(tx) {
                           var rs = tx.executeSql('SELECT stopCode, name, lat, lon, stopOrder ' +
                                                  'FROM stopslines, stops ' +
                                                  'WHERE linedirection = ? AND stopCode = code AND lineCode = ? ' +
                                                  'ORDER BY stopOrder ASC;', [busLine.direction,
                                                                              busLine.lineCode])
                           if (rs.rows.length > 0) {
                               for(var i = 0; i < rs.rows.length; i++) {
                                   var currentItem = rs.rows.item(i)
                                   var stop = new BusStop(currentItem.stopCode,
                                                          currentItem.name,
                                                          currentItem.lat,
                                                          currentItem.lon,
                                                          currentItem.stopOrder)
                                   res.push(stop)
                               }
                           }
                       })
    } catch (ex) {
        console.log(ex)
    }

    return res
}

function searchStopsByName(stopName) {
    var db = getDatabase()
    var res = []
    try {
        db.transaction(function(tx) {
                           var rs = tx.executeSql('SELECT code, name, lat, lon ' +
                                                  'FROM stops ' +
                                                  'WHERE name LIKE ? ' +
                                                  'ORDER BY code ASC;', stopName)
                           if (rs.rows.length > 0) {
                               for(var i = 0; i < rs.rows.length; i++) {
                                   var currentItem = rs.rows.item(i)
                                   var stop = new BusStop(currentItem.code,
                                                          currentItem.name,
                                                          currentItem.lat,
                                                          currentItem.lon)
                                   res.push(stop)
                               }
                           }
                       })
    } catch (ex) {
        console.log(ex)
    }

    return res
}

function searchStopsByCoordinate(coordinate) {
    var db = getDatabase()
    var res = []
    try {
        db.transaction(function(tx) {
                           var rs = tx.executeSql('SELECT code, name, lat, lon, ' +
                                                  '(abs(lat - ?) + abs(lon - ?)) AS distance ' +
                                                  'FROM stops ' +
                                                  'ORDER BY distance ASC ' +
                                                  'LIMIT 5', [coordinate.latitude,
                                                              coordinate.longitude])
                           if (rs.rows.length > 0) {
                               for (var i = 0; i < rs.rows.length; i ++) {
                                   var currentItem = rs.rows.item(i)
                                   var stop = new BusStop(currentItem.code,
                                                          currentItem.name,
                                                          currentItem.lat,
                                                          currentItem.lon)
                                   res.push(stop)
                               }
                           }
                       })
    } catch (ex) {
        console.log(ex)
    }
    return res
}

function loadFavoriteStops(codes) {
    var db = getDatabase()
    var res = []
    try {
        db.transaction(function(tx) {
                           var query = 'SELECT code, name, lat, lon ' +
                                   'FROM stops WHERE code IN (' + codes[0]
                           for (var c = 1; c < codes.length; c ++) {
                               query += ',' + codes[c]
                           }
                           query += ') ORDER BY code ASC;'

                           var rs = tx.executeSql(query)
                           if (rs.rows.length > 0) {
                               for(var i = 0; i < rs.rows.length; i++) {
                                   var currentItem = rs.rows.item(i)
                                   var stop = new BusStop(currentItem.code,
                                                          currentItem.name,
                                                          currentItem.lat,
                                                          currentItem.lon)
                                   res.push(stop)
                               }
                           }
                       })
    } catch (ex) {
        console.log(ex)
    }
    return res
}
