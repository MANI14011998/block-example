
import UIKit
import Blockly

/**
 View controller for editing the "code" when pressing a music button.
 */
class ButtonEditorViewController: UIViewController {

  // MARK: - Properties

  /// The ID of the button that is being edited.
  public private(set) var buttonID: String = "" {
    didSet {
      self.navigationItem.title = "Edit Button \(buttonID)"
    }
  }

  // MARK: - Super

  override func viewDidLoad() {
    super.viewDidLoad()

    edgesForExtendedLayout = []
    
    // Add editor to this view controller
    addChild(workbenchViewController)
    view.addSubview(workbenchViewController.view)
    workbenchViewController.view.frame = view.bounds
    workbenchViewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    workbenchViewController.didMove(toParent: self)
  }
    /// The main Blockly editor.
    private var workbenchViewController: WorkbenchViewController = {
      let workbenchViewController = WorkbenchViewController(style: .alternate)
      workbenchViewController.toolboxDrawerStaysOpen = true
        let blockFactory = workbenchViewController.blockFactory
        blockFactory.load(fromDefaultFiles: .allDefault)
        
        do {
           try blockFactory.load(fromJSONPaths: ["sound_blocks.json"])
         } catch let error {
           print("An error occurred loading the sound blocks: \(error)")
         }

       do {
          let toolboxPath = "toolbox.xml"
          if let bundlePath = Bundle.main.path(forResource: toolboxPath, ofType: nil) {
            let xmlString = try String(
              contentsOfFile: bundlePath, encoding: String.Encoding.utf8)
            let toolbox = try Toolbox.makeToolbox(
              xmlString: xmlString, factory: blockFactory)
            try workbenchViewController.loadToolbox(toolbox)
          } else {
            print("Could not load toolbox XML from '\(toolboxPath)'")
          }
        } catch let error {
          print("An error occurred loading the toolbox: \(error)")
        }

        return workbenchViewController
      }()

  override func viewDidAppear(_ animated: Bool) {
    self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
  }
  override func viewWillDisappear(_ animated: Bool) {
    // Save on exit
    saveBlocks()

    super.viewWillDisappear(animated)
  }

  // MARK: - Load / Write

  /**
   Load a workspace for a button ID into the workbench, if it exists on disk.

   - parameter buttonID: The button ID to load.
   */
  public func loadBlocks(forButtonID buttonID: String) {
    self.buttonID = buttonID

    do {
      // Create fresh workspace
      let workspace = Workspace()

      // Load blocks into this workspace from a saved file (if it exists).
      if let xml = FileHelper.loadContents(of: "workspace\(buttonID).xml") {
        try workspace.loadBlocks(
          fromXMLString: xml, factory: workbenchViewController.blockFactory)
      }

      // Load the workspace into the workbench
      try workbenchViewController.loadWorkspace(workspace)
    } catch let error {
      print("Couldn't load workspace from disk: \(error)")
    }
  }

  /**
   Saves the workspace for this button ID to disk.
   */
  public func saveBlocks() {
    // Save the workspace to disk
     if let workspace = workbenchViewController.workspace {
       do {
         let xml = try workspace.toXML()
         FileHelper.saveContents(xml, to: "workspace\(buttonID).xml")
       } catch let error {
         print("Couldn't save workspace to disk: \(error)")
       }
     }
  }
}
