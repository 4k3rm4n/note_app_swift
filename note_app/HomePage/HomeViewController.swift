import UIKit
import RSKPlaceholderTextView

class HomeViewController: UIViewController {
    
    
    @IBOutlet weak var mainTextView: RSKPlaceholderTextView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var selectedPicturesCollectionView: UICollectionView!
    let presenter = HomePagePresenter()
    let imagePicker = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Main"
        
        presenter.setup()
        presenter.onChangedMessageData = { [weak self] in
            self?.mainTableView.reloadData()
        }
        presenter.onMessageRemovedCallback = { [weak self] indexPath in
            self?.mainTableView.deleteRows(at: [indexPath], with: .top)
        }
        presenter.onMessageAddedCallback = { [weak self] in
            self?.mainTableView.insertRows(at: [IndexPath(row: .zero, section: .zero)], with: .automatic)
        }
        presenter.onChangeSelectedImagesCallback = { [weak self] in
            self?.hideSelectedImagesIfNeeded()
            self?.selectedPicturesCollectionView.reloadData()
        }
        
        setupMainTextView()
        setupMainTableView()
        setupImagePicker()
        setupSelectedPicturesCollectionView()
        
        guard let documentDirectory = try? FileManager.default.url(
            for: .documentDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        ) else { return }
        print(documentDirectory)
    }
    
    private func setupMainTableView() {
        let cellName = String(describing: MainTableViewCell.self)
        mainTableView.register(UINib(nibName: cellName, bundle: nil), forCellReuseIdentifier: cellName)
        mainTableView.dataSource = self
        mainTableView.delegate = self
    }
    
    private func setupMainTextView() {
        mainTextView.placeholder = "start typing..."
        mainTextView.inputAccessoryView = createKeyboardToolbar()
        mainTextView.borderStyle = .none
    }
    
    private func setupImagePicker() {
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.allowsEditing = false
        imagePicker.delegate = self
    }
    
    private func setupSelectedPicturesCollectionView() {
        let selectedPicturesFlowLayout = UICollectionViewFlowLayout()
        selectedPicturesFlowLayout.itemSize = .init(width: 100, height: 100)
        selectedPicturesFlowLayout.scrollDirection = .horizontal
        selectedPicturesFlowLayout.minimumInteritemSpacing = 10
        selectedPicturesCollectionView.collectionViewLayout = selectedPicturesFlowLayout
        selectedPicturesCollectionView.showsHorizontalScrollIndicator = false
        hideSelectedImagesIfNeeded()
        
        selectedPicturesCollectionView.dataSource = self
        selectedPicturesCollectionView.delegate = self
        let cellName = String(describing: SelectedPicturesCollectionViewCell.self)
        selectedPicturesCollectionView.register(UINib(nibName: cellName, bundle: nil), forCellWithReuseIdentifier: cellName)
    }
    
    private func createKeyboardToolbar() -> UIToolbar {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        toolbar.backgroundColor = .lightGray
        
        let spacer = UIBarButtonItem.flexibleSpace()
        let addImageButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTouchAddImageButton))
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(didTouchButtonDone))
        let cancelButton = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTouchButtonCancel))
        
        toolbar.setItems([cancelButton, spacer, addImageButton, spacer, doneButton], animated: false)
        
        return toolbar
    }
    
    @objc private func didTouchButtonDone() {
        saveCurrentMessage()
    }
    
    @objc private func didTouchButtonCancel() {
        mainTextView.resignFirstResponder()
    }
    
    @objc private func didTouchAddImageButton() {
        present(imagePicker, animated: true)
    }
    
    private func saveCurrentMessage() {
        guard let messageText = mainTextView.text else { return }
        presenter.addNewMessage(message: messageText)
        mainTextView.text = ""
        mainTextView.resignFirstResponder()
    }
    
    private func hideSelectedImagesIfNeeded() {
        selectedPicturesCollectionView.isHidden = presenter.selectedImagesURL.isEmpty
    }
}

extension HomeViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        presenter.messagesPresentation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellName = String(describing: MainTableViewCell.self)
        guard let cell = mainTableView.dequeueReusableCell(withIdentifier: cellName) as? MainTableViewCell else { return UITableViewCell()}
        let presentation = presenter.messagesPresentation[indexPath.row]
        cell.updateView(withState: presentation)
        cell.onRemoveCell = { [weak self] in
            self?.presenter.removeMessage(by: presentation.id)
        }
        return cell
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("didSelect cell at indexPath: \(indexPath)")
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension HomeViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let imageURL = info[.imageURL] as? URL {
            if !presenter.isSamePictureSelected(by: imageURL) {
                presenter.selectImage(with: imageURL)
            } else {
                presenter.removeFileFromTmpDirectory(by: imageURL)
            }
        }
        picker.dismiss(animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

extension HomeViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
    }
}

extension HomeViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.selectedImagesURL.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cellName = String(describing: SelectedPicturesCollectionViewCell.self)
        guard let cell = selectedPicturesCollectionView.dequeueReusableCell(withReuseIdentifier: cellName, for: indexPath) as? SelectedPicturesCollectionViewCell else { return UICollectionViewCell() }
        if !presenter.selectedImagesURL.isEmpty {
            let item = presenter.selectedImagesURL[indexPath.row]
            cell.updateView(with: item)
            cell.onRemoveSelectedImageCallback = { [weak self] in
                self?.presenter.removeSelectedImage(by: item)
            }
        }
        return cell
    }
}

extension UIImage {
    /// Creates a thumbnail of the image while preserving its aspect ratio.
    func thumbnailOfSize(_ targetSize: CGSize) -> UIImage? {
        // Calculate the scaling ratio to maintain aspect ratio
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let scaleFactor = min(widthRatio, heightRatio) // Scale to fit the target size
        
        // Calculate the new size
        let newSize = CGSize(width: size.width * scaleFactor, height: size.height * scaleFactor)
        
        // Use CoreGraphics to scale the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        self.draw(in: CGRect(origin: CGPoint.zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
}
