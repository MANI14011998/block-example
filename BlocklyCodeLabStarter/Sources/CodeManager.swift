//
//  CodeManager.swift
//  BlocklyCodeLabStarter
//
//  Created by MANINDER SINGH on 26/05/20.
//  Copyright © 2020 Google. All rights reserved.
//

import Foundation
import Blockly

/**
 Manages JS code in the app. It generates JS code from workspace XML and
 saves it in-memory for future use.
 */
class CodeManager {
    private var savedCode = [String: String]()

  /// Service used for converting workspace XML into JS code.
  private var codeGeneratorService: CodeGeneratorService = {
    let service = CodeGeneratorService(
      jsCoreDependencies: [
        // The JS file containing the Blockly engine
        "blockly_web/blockly_compressed.js",
        // The JS file containing a list of internationalized messages
        "blockly_web/msg/js/en.js"
      ])
    let builder = CodeGeneratorServiceRequestBuilder(
       // This is the name of the JS object that will generate JavaScript code
       jsGeneratorObject: "Blockly.JavaScript")
     // Load the block definitions for all default blocks
     builder.addJSONBlockDefinitionFiles(fromDefaultFiles: .allDefault)
     // Load the block definitions for our custom sound block
     builder.addJSONBlockDefinitionFiles(["sound_blocks.json"])
     builder.addJSBlockGeneratorFiles([
       // Use JavaScript code generators for the default blocks
       "blockly_web/javascript_compressed.js",
       // Use JavaScript code generators for our custom sound block
       "sound_block_generators.js"])

     // Assign the request builder to the service and cache it so subsequent
     // code generation runs are immediate.
     service.setRequestBuilder(builder, shouldCache: true)

    return service
  }()
    
    deinit {
      codeGeneratorService.cancelAllRequests()
    }
    /**
     Generates code for a given `key`.
     */
    func generateCode(forKey key: String, workspaceXML: String) {
      do {
        // Clear the code for this key as we generate the new code.
        self.savedCode[key] = nil

        let _ = try codeGeneratorService.generateCode(
          forWorkspaceXML: workspaceXML,
          onCompletion: { requestUUID, code in
            // Code generated successfully. Save it for future use.
            self.savedCode[key] = code
          },
          onError: { requestUUID, error in
            print("An error occurred generating code - \(error)\n" +
              "key: \(key)\n" +
              "workspaceXML: \(workspaceXML)\n")
          })
      } catch let error {
        print("An error occurred generating code - \(error)\n" +
          "key: \(key)\n" +
          "workspaceXML: \(workspaceXML)\n")
      }
    }
    func code(forKey key: String) -> String? {
      return savedCode[key]
    }

}
