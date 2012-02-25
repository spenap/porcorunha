.pragma library

// code="100"
// name="1"
// direction="GO"
// directionDescription="Os Castros"
// description="Abente y Lago-Os Castros"
function BusLine(code, name, direction, directionDescription, description) {
    this.code = code
    this.name = name
    this.direction = direction
    this.directionDescription = directionDescription
    this.description = description

    this.title = this.name
    this.subtitle = this.description
}

// code="523"
// name="Abente y Lago"
// lat="43.3681210800812"
// lng="-8.39027762579297"
// position="0"
function BusStop(code, name, lat, lng, position) {
    this.code = code
    this.name = name
    this.lat = lat
    this.lon = lng
    this.position = position ? position : -1

    this.title = this.name
    this.lng = this.lon
}
