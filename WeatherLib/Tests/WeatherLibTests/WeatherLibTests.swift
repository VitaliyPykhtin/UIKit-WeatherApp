import Testing
@testable import WeatherLib
import MockServiceImplementations
import Model

@Test func example() async throws {
	let model = Model(services: Services.mock)
	
//	let weather = try await model.weather(for: "London")
//	#expect(weather.condition == "clear")
    // Write your test here and use APIs like `#expect(...)` to check expected conditions.
}
