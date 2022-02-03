import Flutter
import UIKit

import SurvicateSdk

public class SwiftSurvicateFlutterSdkPlugin: NSObject, FlutterPlugin {
    private var survicateDelegate: FlutterSurvicateDelegate?

    class FlutterChannel: NSObject {
        static let shared: FlutterChannel = FlutterChannel()
        var channel: FlutterMethodChannel?
        private override init() {}
    }
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "survicate_flutter_sdk", binaryMessenger: registrar.messenger())
        let instance = SwiftSurvicateFlutterSdkPlugin()
        instance.survicateDelegate = FlutterSurvicateDelegate(channel)
        registrar.addMethodCallDelegate(instance, channel: channel)
        FlutterChannel.shared.channel = channel
        SurvicateSdk.shared.initialize()
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let arguments = call.arguments as? [String:String] ?? [:]
        
        if (call.method == "invokeEvent") {
            let eventName = arguments["eventName"]  ?? ""

            SurvicateSdk.shared.invokeEvent(name: eventName)

            result(true)
        } else if (call.method == "enterScreen") {
            let screenName = arguments["screenName"]  ?? ""

            SurvicateSdk.shared.enterScreen(value: screenName)

            result(true)
        } else if (call.method == "leaveScreen") {
            let screenName = arguments["screenName"]  ?? ""

            SurvicateSdk.shared.leaveScreen(value: screenName)

            result(true)
        } else if (call.method == "setUserTraits") {
            var traits = [UserTrait]()
            
            for (key, value) in arguments {
                traits.append(UserTrait(withName: key, value: value))
            }

            SurvicateSdk.shared.setUserTraits(traits: traits)

            result(true)
        } else if (call.method == "reset") {
            SurvicateSdk.shared.reset()

            result(true)
        } else if (call.method == "registerSurveyListeners") {
            SurvicateSdk.shared.delegate = survicateDelegate

            result(true)
        } else if (call.method == "unregisterSurveyListeners") {
            SurvicateSdk.shared.delegate = nil

            result(true)
        } else {
            result(FlutterMethodNotImplemented)
        }
    }
}

class FlutterSurvicateDelegate : SurvicateDelegate {
    let channel: FlutterMethodChannel?
    
    init(_ channel: FlutterMethodChannel) {
        self.channel = channel
    }
    
    public func surveyDisplayed(surveyId: String) {
        let arguments = ["surveyId": surveyId]

        DispatchQueue.main.async {
            self.channel?.invokeMethod("onSurveyDisplayed", arguments: arguments)
        }
    }

    public func questionAnswered(surveyId: String, questionId: Int, answer: SurvicateAnswer) {
        let answerMap = ["type": answer.type as Any, "id": answer.id as Any , "ids": answer.ids as Any , "value" : answer.value as Any] as [String : Any]
        let arguments = ["surveyId": surveyId, "questionId": questionId, "answer": answerMap] as [String : Any]

        DispatchQueue.main.async {
            self.channel?.invokeMethod("onQuestionAnswered", arguments: arguments)
        }
    }

    public func surveyCompleted(surveyId: String) {
        let arguments = ["surveyId": surveyId]

        DispatchQueue.main.async {
            self.channel?.invokeMethod("onSurveyCompleted", arguments: arguments)
        }
    }

    public func surveyClosed(surveyId: String) {
        let arguments = ["surveyId": surveyId]
        
        DispatchQueue.main.async {
            self.channel?.invokeMethod("onSurveyClosed", arguments: arguments)
        }
    }
}
