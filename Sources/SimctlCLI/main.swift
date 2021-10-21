import ArgumentParser

struct SimctlCLI: ParsableCommand {
    static var configuration = CommandConfiguration(
        commandName: "SimctlCLI",
        abstract: "Swift client-server tool to call xcrun simctl from your test code.",
        subcommands: [
            StartServer.self,
            ListDevices.self
        ]
    )
}

SimctlCLI.main()
