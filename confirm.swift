import Foundation
import Cocoa
import LocalAuthentication

class ConfirmationDialog: NSObject {
    private let message: String
    private let iconPath: String?
    private let requireAuth: Bool
    
    init(message: String, iconPath: String? = nil, requireAuth: Bool = false) {
        self.message = message
        self.iconPath = iconPath
        self.requireAuth = requireAuth
        super.init()
    }
    
    func show() -> Bool {
        let app = NSApplication.shared
        app.setActivationPolicy(.regular)
        app.activate(ignoringOtherApps: true)
        
        if requireAuth {
            return authenticate()
        }
        
        let alert = NSAlert()
        alert.messageText = "Confirmation Required"
        alert.informativeText = message
        alert.addButton(withTitle: "Accept")
        alert.addButton(withTitle: "Decline")
        alert.alertStyle = .informational
        
        if let iconPath = iconPath, let image = NSImage(contentsOfFile: iconPath) {
            alert.icon = image
        }
        
        // Create a temporary window to ensure alert appears on top
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
                             styleMask: [],
                             backing: .buffered,
                             defer: false)
        window.level = .floating
        window.isOpaque = false
        window.backgroundColor = NSColor.clear
        window.makeKeyAndOrderFront(nil)
        
        let response = alert.runModal()
        
        window.orderOut(nil)
        
        return response == .alertFirstButtonReturn
    }
    
    private func authenticate() -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) {
            let semaphore = DispatchSemaphore(value: 0)
            var result = false
            
            context.evaluatePolicy(.deviceOwnerAuthentication, localizedReason: message) { success, _ in
                result = success
                semaphore.signal()
            }
            
            semaphore.wait()
            return result
        } else {
            print("Authentication not available: \(error?.localizedDescription ?? "Unknown error")")
            return false
        }
    }
    
    private func showPasswordPrompt() -> Bool {
        let alert = NSAlert()
        alert.messageText = "Authentication Required"
        alert.informativeText = "Please enter your password to confirm this action"
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Cancel")
        
        let passwordField = NSSecureTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        passwordField.placeholderString = "Password"
        alert.accessoryView = passwordField
        
        let response = alert.runModal()
        return response == .alertFirstButtonReturn && !passwordField.stringValue.isEmpty
    }
}

func printUsage() {
    print("Usage: ./confirm [options] <message>")
    print("Options:")
    print("  --icon <path>      Path to icon file")
    print("  --auth             Require authentication (Touch ID/Password)")
    print("  --help             Show this help message")
    print("\nExample:")
    print("  ./confirm \"Do you want to proceed?\"")
    print("  ./confirm --auth --icon /path/to/icon.png \"Delete important file?\"")
}

let arguments = CommandLine.arguments.dropFirst()

if arguments.isEmpty || arguments.contains("--help") {
    printUsage()
    exit(0)
}

var message = ""
var iconPath: String?
var requireAuth = false
var i = 0
let args = Array(arguments)

while i < args.count {
    let arg = args[i]
    
    switch arg {
    case "--icon":
        if i + 1 < args.count {
            iconPath = args[i + 1]
            i += 1
        } else {
            print("Error: --icon requires a path argument")
            exit(1)
        }
    case "--auth":
        requireAuth = true
    default:
        if message.isEmpty {
            message = arg
        } else {
            message += " " + arg
        }
    }
    i += 1
}

if message.isEmpty {
    print("Error: Message is required")
    printUsage()
    exit(1)
}

let dialog = ConfirmationDialog(message: message, iconPath: iconPath, requireAuth: requireAuth)
let result = dialog.show()

exit(result ? 0 : 1)