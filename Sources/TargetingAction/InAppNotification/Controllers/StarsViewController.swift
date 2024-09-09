import UIKit

class StarsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Arkaplan rengini ayarlıyoruz
        view.backgroundColor = .white
        
        // Yıldızları ekleyeceğimiz stackView oluşturuyoruz
        let starsStackView = UIStackView()
        starsStackView.axis = .vertical
        starsStackView.alignment = .center
        starsStackView.spacing = 10
        
        // 10 adet tıklanabilir yıldız ekliyoruz
        for i in 1...10 {
            let starButton = UIButton(type: .system)
            starButton.setTitle("⭐️", for: .normal)
            starButton.titleLabel?.font = UIFont.systemFont(ofSize: 40)
            starButton.tag = i // Her butona bir tag veriyoruz
            starButton.addTarget(self, action: #selector(starTapped(_:)), for: .touchUpInside)
            starsStackView.addArrangedSubview(starButton)
        }
        
        // StackView'i ana görünüme ekliyoruz
        view.addSubview(starsStackView)
        
        // StackView için AutoLayout ayarları
        starsStackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            starsStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            starsStackView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    // Yıldız butonuna tıklandığında çağrılan fonksiyon
    @objc func starTapped(_ sender: UIButton) {
        let starIndex = sender.tag
        print("Yıldız \(starIndex) tıklandı!")
        // İstediğiniz işlemi burada yapabilirsiniz, örneğin bir animasyon veya başka bir aksiyon.
    }
}

// Kullanmak için AppDelegate veya SceneDelegate içinde çağırabilirsiniz
let starsViewController = StarsViewController()
// Örnek: window?.rootViewController = starsViewController
