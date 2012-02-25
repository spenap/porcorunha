.pragma library
Qt.include('constants.js')
Qt.include('storage.js')

WorkerScript.onMessage = function(message) {
            if (message.action === SAVE_LINE_ACTION) {
                saveLine(message.line)
            } else if (message.action === SAVE_STOP_LINE_ACTION) {
                saveStop(message.stop)
                saveStopAtLine(message.stop, message.line)
            } else /*if (message.action === ASYNC_FETCH_ACTION)*/ {
                fetchAsync(message.url)
            }
        }

function fetchAsync(serviceUrl) {
    var xhr = new XMLHttpRequest
    xhr.onreadystatechange = function() {
                if (xhr.readyState === XMLHttpRequest.DONE) {
                    WorkerScript.sendMessage({
                                                 url: serviceUrl,
                                                 status: xhr.status,
                                                 response: xhr.responseText
                                             })
                }
            }
    xhr.open("GET", serviceUrl)
    xhr.send()
}
