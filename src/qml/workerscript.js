.pragma library
Qt.include('constants.js')
Qt.include('storage.js')

WorkerScript.onMessage = function(message) {
            fetchAsync(message.url)
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
