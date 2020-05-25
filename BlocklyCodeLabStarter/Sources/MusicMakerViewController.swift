
import UIKit

/**
 View controller for displaying music maker buttons.

 In "run" mode, pressing a button will run code configured for that button.

 In "edit" mode, pressing a button will allow the user to edit the code for that button.
 */
class MusicMakerViewController: UIViewController {
    private var codeManager = CodeManager()
   private var codeRunners = [CodeRunner]()

  /// The current button ID that is being edited.
  private var editingButtonID: String = ""

  /// Instruction label.
  @IBOutlet weak var instructions: UILabel!

  // MARK: - Super

  override func viewDidLoad() {
    super.viewDidLoad()
    for i in 1...9 {
      generateCode(forButtonID: String(i))
    }

    // Start in edit mode
    setEditing(true, animated: false)
    updateState(animated: false)
  }
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)

      // If this view controller is appearing again after editing a button,
      // generate new code for it.
      if !editingButtonID.isEmpty {
        generateCode(forButtonID: editingButtonID)
        editingButtonID = ""
      }
    }


  // MARK: - State

  private func updateState(animated: Bool) {
    if isEditing {
      let button = UIBarButtonItem(
        barButtonSystemItem: .done, target: self, action: #selector(toggleEditing(_:)))
      navigationItem.setRightBarButton(button, animated: animated)
      navigationItem.title = "Music Maker Configuration"
    } else {
      let button = UIBarButtonItem(
        barButtonSystemItem: .edit, target: self, action: #selector(toggleEditing(_:)))
      navigationItem.setRightBarButton(button, animated: animated)
      navigationItem.title = "Music Maker"
      instructions.text = ""
    }

    UIView.animate(withDuration: animated ? 0.3 : 0.0) {
      if self.isEditing {
        self.instructions.text = "\nTap any button to edit its code.\n\nWhen complete, press Done."
        self.instructions.alpha = 1
        self.view.backgroundColor =
          UIColor(red: 224.0/255.0, green: 224.0/255.0, blue: 224.0/255.0, alpha: 1.0)
      } else {
        self.instructions.text = ""
        self.instructions.alpha = 0
        self.view.backgroundColor =
          UIColor(red: 245.0/255.0, green: 245.0/255.0, blue: 245.0/255.0, alpha: 1.0)
      }
    }
  }

  // MARK: - User Interaction Handlers

  @objc private dynamic func toggleEditing(_ sender: UIButton) {
    setEditing(!isEditing, animated: true)
    updateState(animated: true)
  }

  @IBAction func pressedMusicButton(_ sender: Any) {
    guard let button = sender as? UIButton,
      let buttonID = button.currentTitle else {
      return
    }

    if isEditing {
      editButton(buttonID: buttonID)
    } else {
      runCode(forButtonID: buttonID)
    }
  }

  // MARK: - Editing and Running Code

  /**
   Opens the code editor for a given button ID.

   - parameter buttonID: The button ID to edit.
   */
  func editButton(buttonID: String) {
     editingButtonID = buttonID

     // Load the editor for this button number
     let buttonEditorViewController = ButtonEditorViewController()
     buttonEditorViewController.loadBlocks(forButtonID: buttonID)
     navigationController?.pushViewController(buttonEditorViewController, animated: true)
  }

  /**
   Requests that the code manager generate code for a given button ID.

   - parameter buttonID: The button ID.
   */
  func generateCode(forButtonID buttonID: String) {
    // If a saved workspace file exists for this button, generate the code for it.
    if let workspaceXML = FileHelper.loadContents(of: "workspace\(buttonID).xml") {
      codeManager.generateCode(forKey: String(buttonID), workspaceXML: workspaceXML)
    }
  }

  /**
   Runs code associated with a given button ID.

   - parameter buttonID: The button ID.
   */
 func runCode(forButtonID buttonID: String) {
    if let code = codeManager.code(forKey: buttonID),
      code != "" {

      // Create and store a new CodeRunner, so it doesn't go out of memory.
      let codeRunner = CodeRunner()
      codeRunners.append(codeRunner)

      // Run the JS code, and remove the CodeRunner when finished.
      codeRunner.runJavascriptCode(code, completion: {
        self.codeRunners = self.codeRunners.filter { $0 !== codeRunner }
      })
    } else {
      print("No code has been set up for button \(buttonID).")
    }
  }
}
