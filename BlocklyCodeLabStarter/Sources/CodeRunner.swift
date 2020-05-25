//
//  CodeRunner.swift
//  BlocklyCodeLabStarter
//
//  Created by MANINDER SINGH on 26/05/20.
//  Copyright © 2020 Google. All rights reserved.
//

import Blockly
import JavaScriptCore
import UIKit

/**
 Runs JavaScript code.
 */
class CodeRunner {
  /// The JS context used for running the JS code.
  private var context: JSContext?

  /// A background thread used for executing the JS code.
  private let jsThread = DispatchQueue(label: "jsContext")

  init() {
    // Instantiate the JS context on a background thread.
    jsThread.async {
      self.context = JSContext()
      self.context?.exceptionHandler = { context, exception in
        let error = exception?.description ?? "unknown error"
        print("JS Error: \(error)")
      }

      // Expose `MusicMaker` as a bridged Javascript object
      self.context?.setObject(MusicMaker.self, forKeyedSubscript: "MusicMaker" as NSString)
    }
  }

  /**
   Runs Javascript code on a background thread.

   - parameter code: The Javascript code.
   - parameter completion: Closure that is called on the main thread when the code has finished
   executing.
   */
  func runJavascriptCode(_ code: String, completion: @escaping () -> ()) {
    // Execute JS Code on the background thread
    jsThread.async {
      _ = self.context?.evaluateScript(code)

      DispatchQueue.main.async {
        completion()
      }
    }
  }
}
