package main

import "fmt"

func kelvinToCelsius(kelvin float64) float64 {
    celsius := kelvin - 273.15
    return celsius
}

func main() {
    kelvinTemperature := 300.0
    celsiusTemperature := kelvinToCelsius(kelvinTemperature)

    fmt.Printf("%.2f Kelvin é equivalente a %.2f Celsius\n", kelvinTemperature, celsiusTemperature)
}
