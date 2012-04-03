.pragma library
Qt.include('constants.js')
Qt.include('storage.js')

WorkerScript.onMessage = function(message) {
            switch (message.action) {
            case REMOTE_FETCH_ACTION:
                remoteFetch(message.url)
                break
            case LOCAL_FETCH_ACTION:
                localFetchManager(message.query, message.model, message.args)
                break
            default:
                console.debug('Unsupported action:', message.action)
                break
            }
        }

function remoteFetch(serviceUrl) {
    var xhr = new XMLHttpRequest
    xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    WorkerScript.sendMessage({
                                                 action: REMOTE_FETCH_RESPONSE,
                                                 status: xhr.status,
                                                 response: xhr.responseText
                                             })
                }
            }
    xhr.open("GET", serviceUrl)
    xhr.send()
}

function localFetchManager(query, model, args) {
    model.clear()
    var elements = []
    switch (query) {
    case 'loadFavoriteStops':
        elements = loadFavoriteStops(args.codes)
        break
    case 'loadStopsByLine':
        elements = loadStopsByLine({ direction: args.direction, lineCode: args.lineCode })
        break
    case 'loadLines':
        elements = loadLines({ direction: args.direction })
        break
    case 'searchStopsByCoordinate':
        elements = searchStopsByCoordinate(args)
        break
    case 'searchStopsByName':
        elements = searchStopsByName(args.name)
        break
    case 'loadLinesByStop':
        elements = loadLinesByStop(args)
        break
    default:
        console.debug('Unsupported query:', query)
        break
    }
    for (var i = 0; i < elements.length; i ++) {
        model.append(elements[i])
    }
    model.sync()
    WorkerScript.sendMessage({ action: LOCAL_FETCH_RESPONSE })
}
