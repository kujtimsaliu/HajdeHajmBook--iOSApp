import UIKit
import Firebase
import FirebaseAuth

class ProfileViewController: UIViewController {
    
    private var window: UIWindow?
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemBackground
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = 50
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .systemGray5
        imageView.image = UIImage(systemName: "person.circle.fill")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .systemGray2
        return imageView
    }()
    
    private let cameraButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
        button.backgroundColor = .systemBlue
        button.tintColor = .white
        button.layer.cornerRadius = 15
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    private let emailLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let optionsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 1
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // MARK: - Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadUserData()
    }
    
    init(window: UIWindow?){
        self.window = window
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(headerView)
        headerView.addSubview(profileImageView)
        headerView.addSubview(cameraButton)
        headerView.addSubview(nameLabel)
        headerView.addSubview(emailLabel)
        
        contentView.addSubview(optionsStackView)
        
        setupConstraints()
        setupOptionsStack()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            profileImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 40),
            profileImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            profileImageView.widthAnchor.constraint(equalToConstant: 100),
            profileImageView.heightAnchor.constraint(equalToConstant: 100),
            
            cameraButton.trailingAnchor.constraint(equalTo: profileImageView.trailingAnchor),
            cameraButton.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 30),
            cameraButton.heightAnchor.constraint(equalToConstant: 30),
            
            nameLabel.topAnchor.constraint(equalTo: profileImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            
            emailLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            emailLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            emailLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            emailLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -20),
            
            optionsStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 20),
            optionsStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            optionsStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            optionsStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupOptionsStack() {
        let options: [(String, String, Selector)] = [
            ("person", "Edit Profile", #selector(openSettings)),
            ("creditcard", "Payment Information", #selector(openPaymentInfo)),
            ("clock.arrow.circlepath", "Order History", #selector(openOrderHistory)),
            ("arrow.right.circle", "Sign Out", #selector(signout))
        ]
        
        for (icon, title, action) in options {
            let button = createOptionButton(icon: icon, title: title, action: action)
            optionsStackView.addArrangedSubview(button)
        }
    }

    private func createOptionButton(icon: String, title: String, action: Selector) -> UIView {
        let container = UIView()
        container.backgroundColor = .systemBackground
        
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.setImage(UIImage(systemName: icon), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.contentHorizontalAlignment = .left
//        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 12)
        button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -4, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: -8)
        button.semanticContentAttribute = .forceLeftToRight
        button.addTarget(self, action: action, for: .touchUpInside)
        
        container.addSubview(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            container.heightAnchor.constraint(equalToConstant: 44),
            button.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
            button.topAnchor.constraint(equalTo: container.topAnchor),
            button.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        
        return container
    }
    
    private func setupActions() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(changeProfilePicture))
        profileImageView.addGestureRecognizer(tapGesture)
        profileImageView.isUserInteractionEnabled = true
        
        cameraButton.addTarget(self, action: #selector(changeProfilePicture), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadUserData() {
        if let customName = UserDefaults.standard.string(forKey: "userDisplayName") {
            nameLabel.text = customName
        } else if let email = Auth.auth().currentUser?.email {
            let username = email.components(separatedBy: "@").first ?? email
            nameLabel.text = username
        } else {
            nameLabel.text = "Unknown User"
        }
        
        emailLabel.text = Auth.auth().currentUser?.email ?? "No email"
        
        if let imageData = UserDefaults.standard.data(forKey: "userProfileImage"),
           let image = UIImage(data: imageData) {
            profileImageView.image = image
        }
    }
    
    // MARK: - Action Methods
    @objc private func changeProfilePicture() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in
                self.showImagePicker(sourceType: .camera)
            }))
        }
        
        actionSheet.addAction(UIAlertAction(title: "Choose Photo", style: .default, handler: { _ in
            self.showImagePicker(sourceType: .photoLibrary)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        present(actionSheet, animated: true)
    }
    
    private func showImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true)
    }
    
    @objc private func openSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }
    
    @objc private func openPaymentInfo() {
        let paymentVC = PaymentViewController()
        navigationController?.pushViewController(paymentVC, animated: true)
    }
    
    @objc private func openOrderHistory() {
        let orderHistoryVC = OrderHistoryViewController()
        navigationController?.pushViewController(orderHistoryVC, animated: true)
    }
    
    @objc private func signout() {
        let alert = UIAlertController(title: "Sign Out", message: "Are you sure you want to sign out?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sign Out", style: .destructive) { _ in
            do {
                try Auth.auth().signOut()
                self.window?.rootViewController = LoginViewController(window: self.window)
            } catch {
                print("Failed to sign out: \(error.localizedDescription)")
            }
        })
        present(alert, animated: true)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        guard let image = info[.editedImage] as? UIImage ?? info[.originalImage] as? UIImage else {
            return
        }
        
        profileImageView.image = image
        
        if let imageData = image.jpegData(compressionQuality: 0.8) {
            UserDefaults.standard.set(imageData, forKey: "userProfileImage")
        }
    }
}
