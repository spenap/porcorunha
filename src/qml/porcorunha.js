var moveteAPI = new Movete()

function Movete() {
    this.config = new Object
    this.url = new Object

    this.config['baseUrl'] = 'http://movete.trabesoluciones.net/coruna/bus/'
    this.config['startPage'] = 1
    this.config['count'] = 20

    this.url['lines'] = this.config['baseUrl'] + 'lines/list'
    this.url['lines_count'] = this.config['baseUrl'] + 'lines/count'
    this.url['show'] = this.config['baseUrl'] + 'lines/show'
    this.url['stop'] = this.config['baseUrl'] + 'lines/stop'
    this.url['stops'] = this.config['baseUrl'] + 'stops/list'
    this.url['stops_count'] = this.config['baseUrl'] + 'stops/count'
    this.url['search'] = this.config['baseUrl'] + 'stops/search'
    this.url['search_count'] = this.config['baseUrl'] + 'stops/countSearch'
    this.url['distances'] = this.config['baseUrl'] + 'distances/stop'

    this.get_lines = get_lines
    this.get_lines_count = get_lines_count
    this.get_lines_by_stop = get_lines_by_stop
    this.show_line = show_line
    this.get_stops = get_stops
    this.get_stops_count = get_stops_count
    this.search = search
    this.search_count = search_count
    this.get_distances = get_distances
}

function get_lines(startPage, count) {
    if (!startPage) {
        startPage = this.config['startPage']
    }
    if (!count) {
        count = this.config['count']
    }

    return this.url['lines'] +
            '?page=' + startPage +
            '&length=' + count
}

function get_lines_count() {
    return this.url['lines_count']
}

function show_line(lineCode, direction) {
    if (!direction) {
        direction = 'GO'
    }

    return this.url['show'] +
            '?lineCode=' + lineCode +
            '&direction=' + direction
}

function get_lines_by_stop(stopCode, startPage, count) {
    if (!startPage) {
        startPage = this.config['startPage']
    }
    if (!count) {
        count = this.config['count']
    }

    return this.url['stop'] +
            '?stopCode=' + stopCode +
            '&page=' + startPage +
            '&length=' + count
}

function get_stops(startPage, count) {
    if (!startPage) {
        startPage = this.config['startPage']
    }
    if (!count) {
        count = this.config['count']
    }

    return this.url['stops'] +
            '?page=' + startPage +
            '&length=' + count
}

function get_stops_count() {
    return this.url['stops_count']
}

function search(searchTerms, startPage, count) {
    if (!startPage) {
        startPage = this.config['startPage']
    }
    if (!count) {
        count = this.config['count']
    }

    return this.url['search'] +
            '?terms=' + searchTerms +
            '&page=' + startPage +
            '&length=' + count
}

function search_count(searchTerms) {
    return this.url['search_count'] +
            '?terms=' + searchTerms
}

function get_distances(stopCode) {
    return this.url['distances'] +
            '?stopCode=' + stopCode
}
