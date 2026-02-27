import Foundation

// INFO
/// so only the most recent action runs after a delay
public actor Debouncer {
	private var task: Task<Void, Never>?

	public func debounce(milliseconds: Int = 300, _ action: @escaping () async -> Void) {
		task?.cancel()
		task = Task {
			try? await Task.sleep(nanoseconds: UInt64(milliseconds) * 1_000_000)
			guard !Task.isCancelled else { return }
			await action()
		}
	}
}
