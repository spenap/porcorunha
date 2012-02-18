.pragma library

WorkerScript.onMessage = function(message) {
            var xhr = new XMLHttpRequest
            xhr.onreadystatechange = function() {
                        if (xhr.readyState === XMLHttpRequest.DONE) {
                            WorkerScript.sendMessage({
                                                         url: message.url,
                                                         status: xhr.status,
                                                         response: xhr.responseText
                                                     })
                        }
                    }
            xhr.open("GET", message.url)
            xhr.send()
        }
