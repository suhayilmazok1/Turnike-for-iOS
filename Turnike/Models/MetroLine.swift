import SwiftUI

// MARK: - MetroLine

/// İstanbul metro/raylı sistem hatları.
/// Her hat kendi koltuk rengini, istasyonlarını ve yön bilgisini taşır.
/// UI tema renkleri bu enum üzerinden türetilir (glassmorphism katmanları dahil).
enum MetroLine: String, CaseIterable, Codable, Identifiable {

    // Metro
    case m1a
    case m1b
    case m2
    case m3
    case m4
    case m5
    case m6
    case m7
    case m8
    case m9
    case m11

    // Marmaray
    case marmaray

    // Tramvay
    case t1
    case t4

    var id: String { rawValue }

    // MARK: - Display Name

    var displayName: String {
        switch self {
        case .m1a:     return "M1A Yenikapı–Atatürk Havalimanı"
        case .m1b:     return "M1B Yenikapı–Kirazlı"
        case .m2:      return "M2 Yenikapı–Hacıosman"
        case .m3:      return "M3 Kirazlı–Başakşehir"
        case .m4:      return "M4 Kadıköy–Sabiha Gökçen"
        case .m5:      return "M5 Üsküdar–Çekmeköy"
        case .m6:      return "M6 Levent–Boğaziçi Ü./Hisarüstü"
        case .m7:      return "M7 Kabataş–Mahmutbey"
        case .m8:      return "M8 Bostancı–Dudullu"
        case .m9:      return "M9 Ataköy–İkitelli"
        case .m11:     return "M11 Gayrettepe–İstanbul Havalimanı"
        case .marmaray: return "Marmaray Halkalı–Gebze"
        case .t1:      return "T1 Kabataş–Bağcılar"
        case .t4:      return "T4 Topkapı–Mescid-i Selam"
        }
    }

    // MARK: - Seat Color (Koltuk Rengi)

    /// Gerçek koltuk döşeme rengine yakın UI rengi.
    var seatColor: Color {
        Color(hex: seatColorHex)
    }

    var seatColorHex: String {
        switch self {
        case .m1a:     return "#E63946"   // Kırmızı
        case .m1b:     return "#E63946"   // Kırmızı
        case .m2:      return "#2A6FDB"   // Mavi
        case .m3:      return "#6A994E"   // Yeşil
        case .m4:      return "#C77DFF"   // Mor/Lila
        case .m5:      return "#C7943E"   // Sarımtırak Kahverengi / Hardal
        case .m6:      return "#9381FF"   // Açık Mor
        case .m7:      return "#FF8FA3"   // Pembe
        case .m8:      return "#48CAE4"   // Açık Mavi
        case .m9:      return "#FFD166"   // Sarı / Gold
        case .m11:     return "#F4845F"   // Turuncu
        case .marmaray: return "#2EC4B6"  // Turkuaz
        case .t1:      return "#E76F51"   // Kiremit / Turuncu-Kırmızı
        case .t4:      return "#8AC926"   // Açık Yeşil
        }
    }

    /// Glassmorphism katmanlarında ikincil vurgu rengi.
    var accentGradient: Color {
        seatColor.opacity(0.55)
    }

    /// UI'da kullanılmak üzere gradient tanımı.
    var themeGradient: LinearGradient {
        LinearGradient(
            colors: [seatColor, accentGradient, seatColor.opacity(0.2)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Directions (İki Yön)

    /// Hattın iki uç durağı — yön bilgisi için.
    var directions: (start: String, end: String) {
        switch self {
        case .m1a:     return ("Yenikapı", "Atatürk Havalimanı")
        case .m1b:     return ("Yenikapı", "Kirazlı")
        case .m2:      return ("Yenikapı", "Hacıosman")
        case .m3:      return ("Kirazlı", "Başakşehir")
        case .m4:      return ("Kadıköy", "Sabiha Gökçen Havalimanı")
        case .m5:      return ("Üsküdar", "Çekmeköy")
        case .m6:      return ("Levent", "Boğaziçi Ü./Hisarüstü")
        case .m7:      return ("Kabataş", "Mahmutbey")
        case .m8:      return ("Bostancı", "Dudullu")
        case .m9:      return ("Ataköy", "İkitelli")
        case .m11:     return ("Gayrettepe", "İstanbul Havalimanı")
        case .marmaray: return ("Halkalı", "Gebze")
        case .t1:      return ("Kabataş", "Bağcılar")
        case .t4:      return ("Topkapı", "Mescid-i Selam")
        }
    }

    var directionNames: [String] {
        [directions.start, directions.end]
    }

    // MARK: - Stations (İstasyonlar)

    /// Hattın tüm durakları uçtan uca sıralı.
    var stations: [String] {
        switch self {
        case .m1a:
            return [
                "Yenikapı", "Aksaray", "Emniyet-Fatih", "Topkapı-Ulubatlı",
                "Bayrampaşa-Maltepe", "Merter", "Zeytinburnu", "Bakırköy-İncirli",
                "Bahçelievler", "Ataköy-Şirinevler", "Yenibosna", "DTM-İstanbul Fuar Merkezi",
                "Atatürk Havalimanı"
            ]
        case .m1b:
            return [
                "Yenikapı", "Aksaray", "Emniyet-Fatih", "Topkapı-Ulubatlı",
                "Bayrampaşa-Maltepe", "Merter", "Zeytinburnu", "Bakırköy-İncirli",
                "Bahçelievler", "Ataköy-Şirinevler", "Yenibosna",
                "Güngören", "Bağcılar-Kirazlı"
            ]
        case .m2:
            return [
                "Yenikapı", "Vezneciler-İstanbul Ü.", "Haliç", "Şişhane",
                "Taksim", "Osmanbey", "Şişli-Mecidiyeköy", "Gayrettepe",
                "Levent", "4. Levent", "Sanayi Mahallesi", "İTÜ-Ayazağa",
                "Atatürk Oto Sanayi", "Darüşşafaka", "Hacıosman"
            ]
        case .m3:
            return [
                "Kirazlı", "Başak Konutları", "Siteler", "Turgut Özal",
                "İkitelli Sanayi", "Ziya Gökalp Mahallesi", "Olimpiyat",
                "Başakşehir"
            ]
        case .m4:
            return [
                "Kadıköy", "Ayrılık Çeşmesi", "Acıbadem", "Ünalan",
                "Göztepe", "Yenisahra", "Kozyatağı", "Bostancı",
                "Küçükyalı", "Maltepe", "Huzurevi", "Gülsuyu",
                "Esenkent", "Hastane-Adliye", "Soğanlık", "Kartal",
                "Yakacık-Adnan Kahveci", "Pendik", "Tavşantepe",
                "Fevzi Çakmak", "Yayalar-Şeyhli", "Kurtköy",
                "Sabiha Gökçen Havalimanı"
            ]
        case .m5:
            return [
                "Üsküdar", "Fıstıkağacı", "Bağlarbaşı", "Altunizade",
                "Kısıklı", "Bulgurlu", "Ümraniye", "Çarşı",
                "Yamanevler", "Çakmak", "Ihlamurkuyu", "Altınşehir",
                "Sancaktepe", "Sarıgazi", "Meclis", "Çekmeköy"
            ]
        case .m6:
            return ["Levent", "Nispetiye", "Etiler", "Boğaziçi Ü./Hisarüstü"]
        case .m7:
            return [
                "Kabataş", "Beşiktaş", "Ortaköy", "Fulya",
                "Gayrettepe/Nef Stadyum", "Mecidiyeköy", "Çağlayan",
                "Kağıthane", "Nurtepe", "Alibeyköy", "Çırçır",
                "Veysel Karani", "Karadeniz Mahallesi", "Kazım Karabekir",
                "Yıldıztepe", "Derin Konak", "Mahmutbey"
            ]
        case .m8:
            return [
                "Bostancı", "Kozyatağı", "Küçükbakkalköy", "İçerenköy",
                "Kayışdağı", "İMES", "Modoko", "Dudullu"
            ]
        case .m9:
            return [
                "Ataköy", "Bahçelievler", "Yenibosna", "Güneşli",
                "Çoban Çeşme", "İkitelli"
            ]
        case .m11:
            return [
                "Gayrettepe", "Kağıthane", "Kemerburgaz",
                "Göktürk", "İhsaniye", "İstanbul Havalimanı"
            ]
        case .marmaray:
            return [
                "Halkalı", "Mustafa Kemal", "Küçükçekmece", "Florya",
                "Florya Akvaryum", "Yeşilköy", "Yeşilyurt",
                "Ataköy", "Bakırköy", "Yenimahalle", "Zeytinburnu",
                "Kazlıçeşme", "Yenikapı", "Sirkeci", "Üsküdar",
                "Ayrılık Çeşmesi", "Acıbadem", "Hasanpaşa", "Feneryolu",
                "Göztepe", "Erenköy", "Suadiye", "Bostancı",
                "Küçükyalı", "İdealtepe", "Süreyya Plajı", "Maltepe",
                "Cevizli", "Atalar", "Başak", "Kartal", "Yunus",
                "Pendik", "Kaynarca", "Tersane", "Güzelyalı",
                "Aydıntepe", "İçmeler", "Tuzla", "Çayırova",
                "Fatih", "Osmangazi", "Darıca", "Gebze"
            ]
        case .t1:
            return [
                "Kabataş", "Fındıklı", "Tophane", "Karaköy",
                "Eminönü", "Sirkeci", "Gülhane", "Sultanahmet",
                "Çemberlitaş", "Beyazıt-Kapalıçarşı", "Laleli-Üniversite",
                "Aksaray", "Yusufpaşa", "Haseki", "Fındıkzade",
                "Çapa-Şehremini", "Pazartekke", "Topkapı",
                "Cevizlibağ-AÖY", "Merkezefendi", "Zeytinburnu",
                "Mithatpaşa", "Akşemsettin", "Soğanlı", "Bağcılar"
            ]
        case .t4:
            return [
                "Topkapı", "Edirnekapı-Sultan Selim-Feshane",
                "Demirkapı", "Vatan", "Çapa", "Şehremini",
                "Eski Saraçhane", "Fatih Belediyesi", "Fener",
                "Balat-Karadeniz Mahallesi", "Ayvansaray",
                "Mescid-i Selam"
            ]
        }
    }
}

// MARK: - Color Hex Extension

extension Color {
    /// Hex string'den SwiftUI Color oluşturur.
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
