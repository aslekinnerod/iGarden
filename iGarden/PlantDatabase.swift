//
//  PlantDatabase.swift
//  iGarden
//
//  Kuratert database over vanlige planter i norske hager, med
//  foretrukket jord-pH. Dette er grunnlaget som såes inn i den delte
//  Firestore-katalogen (se PlantCatalog) og reserven når appen er
//  offline. Søk/autoutfylling i planteskjemaet går via PlantCatalog,
//  som slår sammen denne listen med planter lært av KI-oppslag.
//

import Foundation

/// Hvor en katalogoppføring kommer fra. Lagres i Firestore.
enum PlantInfoSource: String, Codable {
    /// Håndkuratert i PlantDatabase.swift.
    case curated
    /// Lært fra et KI-oppslag (Gemini) gjort av en bruker.
    case ai
}

struct PlantInfo: Codable, Identifiable {
    let name: String
    let latinName: String?
    /// Ekstra søkeord/aliaser (norske synonymer, og søkeord brukere
    /// har skrevet før et KI-oppslag – skrivefeil lærer seg selv).
    let aliases: [String]
    let phLow: Double
    let phHigh: Double
    let water: WaterNeed
    let light: LightNeed
    var source: PlantInfoSource

    init(name: String, latinName: String?, aliases: [String], phLow: Double, phHigh: Double, water: WaterNeed, light: LightNeed, source: PlantInfoSource = .curated) {
        self.name = name
        self.latinName = latinName
        self.aliases = aliases
        self.phLow = phLow
        self.phHigh = phHigh
        self.water = water
        self.light = light
        self.source = source
    }

    /// Dokument-id i Firestore-samlingen plants: foldet navn, trygt som id.
    var id: String { PlantInfo.documentID(for: name) }

    static func documentID(for name: String) -> String {
        let folded = name.folded
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: " ", with: "-")
        return String(folded.prefix(100))
    }

    private enum CodingKeys: String, CodingKey {
        case name, latinName, aliases, phLow, phHigh, water, light, source
    }

    /// Tolerant dekoding: eldre/håndredigerte dokumenter kan mangle
    /// aliaser og kilde.
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        latinName = try c.decodeIfPresent(String.self, forKey: .latinName)
        aliases = try c.decodeIfPresent([String].self, forKey: .aliases) ?? []
        phLow = try c.decode(Double.self, forKey: .phLow)
        phHigh = try c.decode(Double.self, forKey: .phHigh)
        water = try c.decode(WaterNeed.self, forKey: .water)
        light = try c.decode(LightNeed.self, forKey: .light)
        source = try c.decodeIfPresent(PlantInfoSource.self, forKey: .source) ?? .curated
    }

    /// Alle søkeord, foldet for søk (små bokstaver, uten diakritiske tegn).
    var keywords: [String] {
        ([name] + (latinName.map { [$0] } ?? []) + aliases).map { $0.folded }
    }

    var phRangeText: String {
        "\(phLow.formatted(.number.precision(.fractionLength(1))))–\(phHigh.formatted(.number.precision(.fractionLength(1))))"
    }
}

extension String {
    /// Små bokstaver uten diakritiske tegn, for robust søk (blåbær ↔ blabaer).
    /// æ/ø er egne bokstaver (ikke diakritiske) og mappes eksplisitt.
    var folded: String {
        folding(options: [.caseInsensitive, .diacriticInsensitive], locale: Locale(identifier: "nb"))
            .replacingOccurrences(of: "æ", with: "ae")
            .replacingOccurrences(of: "ø", with: "o")
            .replacingOccurrences(of: "å", with: "a")
    }
}

enum PlantDatabase {
    /// Økes når den kuraterte listen endres, så PlantCatalog sår den
    /// inn i Firestore på nytt (kuraterte dokumenter overskrives).
    static let bundledVersion = 1

    private static func p(_ name: String, _ latin: String?, _ low: Double, _ high: Double, _ water: WaterNeed, _ light: LightNeed, _ aliases: String...) -> PlantInfo {
        PlantInfo(name: name, latinName: latin, aliases: Array(aliases), phLow: low, phHigh: high, water: water, light: light)
    }

    static let plants: [PlantInfo] = [
        // MARK: Frukt og bær
        p("Eple", "Malus domestica", 6.0, 7.0, .medium, .sun, "epletre"),
        p("Prydeple", "Malus", 6.0, 7.0, .medium, .sun),
        p("Pære", "Pyrus communis", 6.0, 7.0, .medium, .sun, "pæretre"),
        p("Plomme", "Prunus domestica", 6.0, 7.5, .medium, .sun, "plommetre"),
        p("Kirsebær", "Prunus avium", 6.0, 7.5, .medium, .sun, "morell", "moreller"),
        p("Prydkirsebær", "Prunus serrulata", 6.0, 7.5, .medium, .sun, "japansk kirsebær"),
        p("Jordbær", "Fragaria × ananassa", 5.5, 6.5, .medium, .sun),
        p("Markjordbær", "Fragaria vesca", 5.5, 6.5, .medium, .partShade),
        p("Bringebær", "Rubus idaeus", 5.5, 6.5, .medium, .sun),
        p("Bjørnebær", "Rubus fruticosus", 5.5, 7.0, .medium, .sun),
        p("Solbær", "Ribes nigrum", 6.0, 6.5, .medium, .sun),
        p("Rips", "Ribes rubrum", 6.0, 6.5, .medium, .sun),
        p("Stikkelsbær", "Ribes uva-crispa", 6.0, 6.5, .medium, .sun),
        p("Blåbær", "Vaccinium myrtillus", 4.0, 5.5, .medium, .partShade),
        p("Hageblåbær", "Vaccinium corymbosum", 4.3, 5.5, .medium, .sun, "amerikansk blåbær"),
        p("Tyttebær", "Vaccinium vitis-idaea", 4.5, 5.5, .low, .partShade),
        p("Tranebær", "Vaccinium oxycoccos", 4.0, 5.0, .high, .sun),
        p("Svarthyll", "Sambucus nigra", 6.0, 7.5, .medium, .sun, "hyll", "hylleblomst"),
        p("Havtorn", "Hippophae rhamnoides", 6.5, 7.5, .medium, .sun, "tindved"),
        p("Svartsurbær", "Aronia melanocarpa", 5.0, 6.5, .medium, .sun, "aronia"),
        p("Vindrue", "Vitis vinifera", 6.0, 7.0, .medium, .sun, "drue", "vinranke"),
        p("Minikiwi", "Actinidia arguta", 5.5, 7.0, .medium, .sun, "kiwibær"),
        p("Rabarbra", "Rheum rhabarbarum", 5.5, 6.5, .high, .sun),
        p("Hassel", "Corylus avellana", 6.0, 7.5, .medium, .sun, "hasselnøtt"),
        p("Valnøtt", "Juglans regia", 6.0, 7.5, .medium, .sun),
        p("Fiken", "Ficus carica", 6.0, 7.5, .medium, .sun),
        p("Mispel", "Mespilus germanica", 6.0, 7.0, .medium, .sun),
        p("Kvede", "Cydonia oblonga", 6.0, 7.0, .medium, .sun),

        // MARK: Grønnsaker
        p("Potet", "Solanum tuberosum", 5.0, 6.5, .medium, .sun),
        p("Gulrot", "Daucus carota", 6.0, 7.0, .medium, .sun),
        p("Tomat", "Solanum lycopersicum", 6.0, 6.8, .high, .sun),
        p("Agurk", "Cucumis sativus", 6.0, 7.0, .high, .sun),
        p("Squash", "Cucurbita pepo", 6.0, 7.5, .high, .sun, "sommersquash"),
        p("Gresskar", "Cucurbita maxima", 6.0, 7.5, .high, .sun),
        p("Salat", "Lactuca sativa", 6.0, 7.0, .high, .partShade, "hodesalat", "plukksalat"),
        p("Ruccola", "Eruca sativa", 6.0, 7.0, .medium, .partShade, "rukola", "salatsennep"),
        p("Spinat", "Spinacia oleracea", 6.5, 7.5, .high, .partShade),
        p("Grønnkål", "Brassica oleracea acephala", 6.0, 7.5, .medium, .sun),
        p("Hodekål", "Brassica oleracea capitata", 6.5, 7.5, .medium, .sun, "kål", "hvitkål"),
        p("Rødkål", "Brassica oleracea rubra", 6.5, 7.5, .medium, .sun),
        p("Blomkål", "Brassica oleracea botrytis", 6.5, 7.5, .medium, .sun),
        p("Brokkoli", "Brassica oleracea italica", 6.0, 7.0, .medium, .sun),
        p("Rosenkål", "Brassica oleracea gemmifera", 6.5, 7.5, .medium, .sun),
        p("Kålrot", "Brassica napus", 6.0, 7.5, .medium, .sun, "kålrabi"),
        p("Knutekål", "Brassica oleracea gongylodes", 6.0, 7.5, .medium, .sun),
        p("Reddik", "Raphanus sativus", 6.0, 7.0, .medium, .sun, "sommerreddik"),
        p("Rødbet", "Beta vulgaris", 6.0, 7.5, .medium, .sun, "rødbete", "bete"),
        p("Mangold", "Beta vulgaris cicla", 6.0, 7.5, .medium, .sun, "bladbete"),
        p("Sellerirot", "Apium graveolens rapaceum", 6.0, 7.0, .high, .sun, "knollselleri"),
        p("Stangselleri", "Apium graveolens dulce", 6.0, 7.0, .high, .sun),
        p("Pastinakk", "Pastinaca sativa", 6.0, 7.5, .medium, .sun),
        p("Persillerot", "Petroselinum crispum tuberosum", 6.0, 7.0, .medium, .sun),
        p("Kepaløk", "Allium cepa", 6.0, 7.0, .medium, .sun, "løk", "gul løk", "rødløk"),
        p("Hvitløk", "Allium sativum", 6.0, 7.5, .medium, .sun),
        p("Sjalottløk", "Allium ascalonicum", 6.0, 7.0, .medium, .sun),
        p("Vårløk", "Allium fistulosum", 6.0, 7.0, .medium, .sun, "pipeløk"),
        p("Purre", "Allium porrum", 6.0, 7.5, .medium, .sun, "purreløk"),
        p("Erter", "Pisum sativum", 6.0, 7.5, .medium, .sun, "ert", "hageert"),
        p("Sukkererter", "Pisum sativum saccharatum", 6.0, 7.5, .medium, .sun, "sukkerert"),
        p("Bønner", "Phaseolus vulgaris", 6.0, 7.5, .medium, .sun, "bønne", "buskbønne", "stangbønne"),
        p("Mais", "Zea mays", 5.5, 7.0, .medium, .sun, "sukkermais"),
        p("Paprika", "Capsicum annuum", 6.0, 7.0, .medium, .sun, "chili"),
        p("Aubergine", "Solanum melongena", 5.5, 6.8, .medium, .sun),
        p("Fennikel", "Foeniculum vulgare", 6.0, 7.0, .medium, .sun),
        p("Asparges", "Asparagus officinalis", 6.5, 7.5, .medium, .sun),
        p("Jordskokk", "Helianthus tuberosus", 5.8, 7.0, .medium, .sun),
        p("Nepe", "Brassica rapa", 6.0, 7.0, .medium, .sun, "mainepe"),
        p("Gressløk", "Allium schoenoprasum", 6.0, 7.0, .medium, .sun),

        // MARK: Urter
        p("Basilikum", "Ocimum basilicum", 6.0, 7.5, .medium, .sun),
        p("Persille", "Petroselinum crispum", 6.0, 7.0, .medium, .partShade, "kruspersille", "bladpersille"),
        p("Dill", "Anethum graveolens", 5.5, 6.5, .medium, .sun),
        p("Koriander", "Coriandrum sativum", 6.2, 7.0, .medium, .sun),
        p("Timian", "Thymus vulgaris", 6.5, 7.5, .low, .sun, "hagetimian"),
        p("Rosmarin", "Salvia rosmarinus", 6.0, 7.5, .low, .sun),
        p("Salvie", "Salvia officinalis", 6.0, 7.5, .low, .sun, "matsalvie"),
        p("Bergmynte", "Origanum vulgare", 6.5, 7.5, .low, .sun, "oregano"),
        p("Mynte", "Mentha", 6.0, 7.5, .high, .partShade, "peppermynte", "spearmint"),
        p("Sitronmelisse", "Melissa officinalis", 6.0, 7.5, .medium, .partShade),
        p("Estragon", "Artemisia dracunculus", 6.5, 7.5, .low, .sun),
        p("Karse", "Lepidium sativum", 6.0, 7.0, .high, .partShade),
        p("Løpstikke", "Levisticum officinale", 6.0, 7.0, .medium, .sun),
        p("Kamille", "Matricaria chamomilla", 5.6, 7.5, .medium, .sun),
        p("Karve", "Carum carvi", 6.0, 7.0, .medium, .sun),
        p("Isop", "Hyssopus officinalis", 6.5, 7.5, .low, .sun),
        p("Sar", "Satureja", 6.5, 7.5, .low, .sun, "bønneurt"),

        // MARK: Stauder
        p("Hosta", "Hosta", 6.0, 7.5, .medium, .shade, "bladlilje"),
        p("Astilbe", "Astilbe", 5.5, 6.5, .high, .partShade, "spirea-astilbe"),
        p("Pion", "Paeonia", 6.5, 7.5, .medium, .sun, "peon", "silkepion", "bondepion"),
        p("Daglilje", "Hemerocallis", 6.0, 7.0, .medium, .sun),
        p("Iris", "Iris", 6.0, 7.5, .medium, .sun, "sverdlilje"),
        p("Hagelupin", "Lupinus polyphyllus", 5.5, 7.0, .medium, .sun, "lupin"),
        p("Storkenebb", "Geranium", 6.0, 7.5, .medium, .sun, "skoggstorkenebb", "blodstorkenebb"),
        p("Prydsalvie", "Salvia nemorosa", 6.0, 7.5, .medium, .sun),
        p("Lavendel", "Lavandula angustifolia", 6.5, 7.5, .low, .sun),
        p("Rød solhatt", "Echinacea purpurea", 6.0, 7.0, .medium, .sun, "solhatt"),
        p("Gul solhatt", "Rudbeckia", 6.0, 7.0, .medium, .sun, "rudbeckia"),
        p("Høstasters", "Aster", 6.0, 7.5, .medium, .sun, "asters"),
        p("Hagekrysantemum", "Chrysanthemum", 6.0, 7.0, .medium, .sun, "krysantemum"),
        p("Ridderspore", "Delphinium", 6.5, 7.5, .medium, .sun),
        p("Akeleie", "Aquilegia", 6.0, 7.0, .medium, .partShade),
        p("Revebjelle", "Digitalis purpurea", 5.5, 6.5, .medium, .partShade, "fingerbøl"),
        p("Valmue", "Papaver", 6.0, 7.5, .medium, .sun, "kjempevalmue", "orientvalmue"),
        p("Kornblomst", "Centaurea cyanus", 6.5, 7.5, .medium, .sun),
        p("Hagenellik", "Dianthus", 6.5, 7.5, .medium, .sun, "nellik", "fjærnellik"),
        p("Stemorsblomst", "Viola × wittrockiana", 5.5, 6.5, .medium, .sun, "fiol", "hornfiol"),
        p("Kusymre", "Primula vulgaris", 6.0, 7.0, .medium, .partShade, "primula", "hageprimula"),
        p("Bergenia", "Bergenia", 6.0, 7.5, .low, .partShade, "hjertebergblad"),
        p("Bergknapp", "Sedum", 6.0, 7.5, .low, .sun, "sedum", "smørbukk"),
        p("Takløk", "Sempervivum", 6.5, 7.5, .low, .sun, "husløk"),
        p("Lammeøre", "Stachys byzantina", 6.5, 7.5, .low, .sun),
        p("Kattemynte", "Nepeta", 6.0, 7.5, .low, .sun),
        p("Marikåpe", "Alchemilla mollis", 6.0, 7.5, .medium, .sun),
        p("Skogskjegg", "Aruncus dioicus", 5.5, 7.0, .medium, .partShade),
        p("Gullris", "Solidago", 5.5, 7.0, .medium, .sun),
        p("Floks", "Phlox paniculata", 6.0, 7.0, .medium, .sun, "høstfloks", "sommerfloks", "flox"),
        p("Krypfloks", "Phlox subulata", 6.0, 7.0, .medium, .sun, "vårfloks"),
        p("Lungeurt", "Pulmonaria", 6.0, 7.5, .medium, .shade),
        p("Løytnantshjerte", "Lamprocapnos spectabilis", 6.0, 7.0, .medium, .partShade, "hjerteblomst"),
        p("Klokkeblomst", "Campanula", 6.0, 7.5, .medium, .sun, "blåklokke", "kjempeklokke"),
        p("Ryllik", "Achillea millefolium", 6.0, 7.5, .low, .sun, "jordbærryllik"),
        p("Prestekrage", "Leucanthemum", 6.0, 7.5, .medium, .sun, "kjempeprestekrage"),
        p("Blåveis", "Hepatica nobilis", 6.5, 7.5, .medium, .partShade),
        p("Hvitveis", "Anemone nemorosa", 5.5, 6.5, .medium, .shade),
        p("Høstanemone", "Anemone hupehensis", 6.0, 7.5, .medium, .sun),
        p("Julerose", "Helleborus", 6.5, 7.5, .medium, .partShade),
        p("Stjerneskjerm", "Astrantia major", 6.0, 7.0, .medium, .partShade),
        p("Jernurt", "Verbena", 6.0, 7.0, .medium, .sun, "kjempeverbena"),
        p("Strandnellik", "Armeria maritima", 6.0, 7.5, .low, .sun),
        p("Bregne", "Polypodiopsida", 5.0, 6.5, .high, .shade, "skogburkne", "sisselrot"),
        p("Strutseving", "Matteuccia struthiopteris", 5.5, 6.5, .high, .shade),
        p("Gullkorg", "Doronicum", 6.0, 7.0, .medium, .sun),
        p("Tusenfryd", "Bellis perennis", 6.0, 7.0, .medium, .partShade),
        p("Forglemmegei", "Myosotis", 6.0, 7.0, .medium, .partShade, "kjærminne"),
        p("Blåpute", "Aubrieta", 6.5, 7.5, .low, .sun),
        p("Fjellflokk", "Polemonium caeruleum", 6.0, 7.0, .medium, .partShade),
        p("Brennende kjærlighet", "Lychnis chalcedonica", 6.0, 7.5, .medium, .sun),
        p("Såpeurt", "Saponaria officinalis", 6.5, 7.5, .low, .sun),
        p("Gyllenlakk", "Erysimum", 6.5, 7.5, .low, .sun),
        p("Stokkrose", "Alcea rosea", 6.5, 7.5, .medium, .sun),
        p("Kattost", "Malva", 6.0, 7.5, .medium, .sun, "malva"),
        p("Humleblom", "Geum", 6.0, 7.0, .medium, .sun),
        p("Kongslys", "Verbascum", 6.5, 7.5, .low, .sun),
        p("Dødnesle", "Lamium maculatum", 6.0, 7.5, .low, .shade, "trådnesle"),
        p("Gravmyrt", "Vinca minor", 6.0, 7.5, .low, .shade, "vinca"),
        p("Jonsokkoll", "Ajuga reptans", 6.0, 7.0, .medium, .partShade),
        p("Krypfredløs", "Lysimachia nummularia", 6.0, 7.0, .high, .partShade, "fredløs"),
        p("Mjødurt", "Filipendula", 5.5, 7.0, .high, .partShade),
        p("Kubjelle", "Pulsatilla vulgaris", 6.5, 7.5, .low, .sun),
        p("Lerkespore", "Corydalis", 6.0, 7.0, .medium, .partShade),
        p("Rodgersia", "Rodgersia", 5.5, 6.5, .high, .partShade, "bronseblad"),
        p("Gunnera", "Gunnera manicata", 5.5, 6.5, .high, .partShade, "mammutblad"),
        p("Torskemunn", "Linaria", 6.5, 7.5, .low, .sun),
        p("Veronika", "Veronica", 6.0, 7.5, .medium, .sun, "ærenpris", "aksveronika"),
        p("Solbrud", "Helenium", 5.5, 7.0, .medium, .sun),
        p("Kokardeblomst", "Gaillardia", 6.0, 7.0, .medium, .sun),
        p("Sløyfeblomst", "Iberis sempervirens", 6.5, 7.5, .medium, .sun),
        p("Hanekam", "Celosia argentea", 6.0, 7.0, .medium, .sun),
        p("Silkebygg", "Hordeum jubatum", 6.0, 7.5, .medium, .sun, "prydbygg"),
        p("Elefantgress", "Miscanthus sinensis", 5.5, 7.5, .medium, .sun, "prydgress", "kinagress"),
        p("Lampepussergress", "Pennisetum", 6.0, 7.0, .medium, .sun),
        p("Blåsvingel", "Festuca glauca", 5.5, 7.0, .medium, .sun),
        p("Blåtopp", "Molinia caerulea", 5.0, 6.5, .medium, .partShade),
        p("Bambus", "Fargesia", 5.5, 6.5, .medium, .sun, "hagebambus"),
        p("Sibirvalmue", "Papaver nudicaule", 6.0, 7.5, .medium, .sun, "islandsvalmue"),
        p("Ekte malurt", "Artemisia absinthium", 6.5, 7.5, .low, .sun, "malurt", "sølvmalurt"),
        p("Perlekurv", "Anaphalis", 6.0, 7.5, .low, .sun),
        p("Hasselurt", "Asarum europaeum", 5.5, 6.5, .medium, .shade),
        p("Pryddødnesle", "Lamiastrum", 6.0, 7.5, .medium, .shade, "gulltvetann"),
        p("Bekkeblom", "Caltha palustris", 5.5, 7.0, .high, .partShade, "soleihov"),
        p("Sibiriris", "Iris sibirica", 5.5, 7.0, .high, .sun),
        p("Kattefot", "Antennaria dioica", 5.0, 6.5, .low, .sun),
        p("Hjortetrøst", "Eupatorium", 5.5, 7.0, .medium, .sun),

        // MARK: Busker
        p("Rhododendron", "Rhododendron", 4.5, 6.0, .medium, .partShade, "alperose"),
        p("Asalea", "Rhododendron (Azalea)", 4.5, 6.0, .medium, .partShade, "azalea", "hageasalea"),
        p("Hagehortensia", "Hydrangea macrophylla", 5.0, 6.5, .high, .partShade, "hortensia"),
        p("Syrinhortensia", "Hydrangea paniculata", 5.0, 6.5, .medium, .sun),
        p("Klatrehortensia", "Hydrangea petiolaris", 5.0, 6.5, .medium, .shade),
        p("Syrin", "Syringa vulgaris", 6.5, 7.5, .medium, .sun),
        p("Skjærsmin", "Philadelphus", 6.0, 7.5, .medium, .sun, "duftskjærsmin", "jasminbusk"),
        p("Spirea", "Spiraea", 6.0, 7.5, .medium, .sun, "bjørkebladspirea", "brudespirea", "japanspirea"),
        p("Snøbær", "Symphoricarpos", 6.0, 7.5, .medium, .sun),
        p("Berberis", "Berberis", 6.0, 7.5, .medium, .sun, "høstberberis"),
        p("Buksbom", "Buxus sempervirens", 6.5, 7.5, .medium, .partShade),
        p("Liguster", "Ligustrum vulgare", 6.0, 7.5, .medium, .sun),
        p("Alperips", "Ribes alpinum", 6.0, 7.0, .medium, .sun, "fjellrips"),
        p("Blodrips", "Ribes sanguineum", 6.0, 7.0, .medium, .sun, "prydrips"),
        p("Gullbusk", "Forsythia", 6.0, 7.5, .medium, .sun, "forsythia"),
        p("Magnolia", "Magnolia", 5.5, 6.5, .medium, .partShade),
        p("Kamelia", "Camellia japonica", 5.0, 6.5, .medium, .partShade),
        p("Sommerfuglbusk", "Buddleja davidii", 6.0, 7.5, .low, .sun, "buddleia"),
        p("Rose", "Rosa", 6.0, 7.0, .medium, .sun, "klaserose", "storblomstret rose", "klatrerose", "bedrose"),
        p("Rynkerose", "Rosa rugosa", 5.5, 7.0, .medium, .sun),
        p("Buskmure", "Dasiphora fruticosa", 5.5, 7.0, .medium, .sun, "potentilla"),
        p("Klokkebusk", "Weigela", 6.0, 7.0, .medium, .sun, "weigela"),
        p("Deutzia", "Deutzia", 6.0, 7.5, .medium, .sun, "styraksbusk"),
        p("Kornell", "Cornus", 5.5, 7.0, .medium, .sun, "villkornell", "sibirkornell", "kirsebærkornell"),
        p("Krossved", "Viburnum opulus", 5.5, 7.0, .medium, .sun, "snøballbusk", "korsved"),
        p("Duftkrossved", "Viburnum farreri", 5.5, 7.0, .medium, .sun),
        p("Røsslyng", "Calluna vulgaris", 4.5, 5.5, .low, .sun, "lyng", "høstlyng"),
        p("Klokkelyng", "Erica", 4.5, 5.5, .medium, .sun, "vårlyng"),
        p("Pieris", "Pieris japonica", 4.5, 6.0, .medium, .partShade, "lyngbusk"),
        p("Mahonia", "Mahonia aquifolium", 5.5, 7.0, .low, .partShade),
        p("Eldkvede", "Chaenomeles", 6.0, 7.0, .medium, .sun, "ildkvede", "prydkvede"),
        p("Dvergmispel", "Cotoneaster", 6.0, 7.5, .medium, .sun, "bulkemispel", "krypmispel"),
        p("Ildtorn", "Pyracantha", 6.0, 7.5, .medium, .sun),
        p("Gullregn", "Laburnum", 6.0, 7.5, .medium, .sun),
        p("Hagtorn", "Crataegus", 6.0, 7.5, .medium, .sun),
        p("Trollhassel", "Hamamelis", 5.5, 6.5, .medium, .partShade),
        p("Perlebusk", "Exochorda", 6.0, 7.5, .medium, .sun),
        p("Sibirertebusk", "Caragana arborescens", 6.0, 7.5, .medium, .sun, "ertebusk"),
        p("Fagerbusk", "Kolkwitzia amabilis", 6.0, 7.5, .medium, .sun, "paradisbusk"),
        p("Einer", "Juniperus", 5.0, 7.5, .low, .sun, "krypeiner", "søyleeiner"),
        p("Barlind", "Taxus baccata", 6.0, 7.5, .medium, .partShade),
        p("Tuja", "Thuja occidentalis", 6.0, 7.5, .medium, .sun, "thuja", "livstre"),
        p("Sypress", "Chamaecyparis", 5.5, 7.0, .medium, .sun, "ertesypress"),
        p("Dvergfuru", "Pinus mugo", 4.5, 6.5, .low, .sun, "buskfuru"),
        p("Vinterjasmin", "Jasminum nudiflorum", 6.0, 7.5, .medium, .sun),
        p("Frilandshibiskus", "Hibiscus syriacus", 6.0, 7.0, .medium, .sun, "hibiskus"),
        p("Blærespirea", "Physocarpus opulifolius", 5.5, 7.0, .medium, .sun),
        p("Sølvbusk", "Elaeagnus commutata", 6.0, 7.5, .medium, .sun),
        p("Rødhyll", "Sambucus racemosa", 6.0, 7.5, .medium, .sun),

        // MARK: Trær
        p("Bjørk", "Betula", 5.0, 6.5, .medium, .sun, "hengebjørk", "lavlandsbjørk"),
        p("Furu", "Pinus sylvestris", 4.5, 6.0, .medium, .sun),
        p("Gran", "Picea abies", 5.0, 6.5, .medium, .sun, "blågran", "sølvgran"),
        p("Eik", "Quercus robur", 5.5, 7.0, .medium, .sun, "sommereik"),
        p("Lønn", "Acer platanoides", 5.5, 7.3, .medium, .sun, "spisslønn"),
        p("Japansk lønn", "Acer palmatum", 5.5, 6.5, .medium, .partShade, "viftelønn"),
        p("Ask", "Fraxinus excelsior", 6.0, 7.5, .medium, .sun),
        p("Svartor", "Alnus glutinosa", 5.5, 7.0, .medium, .sun, "or", "older"),
        p("Selje", "Salix caprea", 5.5, 7.5, .medium, .sun, "pil", "sølvpil", "hengepil"),
        p("Osp", "Populus tremula", 5.5, 7.0, .medium, .sun, "poppel"),
        p("Lind", "Tilia cordata", 6.0, 7.5, .medium, .sun, "parklind"),
        p("Bøk", "Fagus sylvatica", 5.5, 7.5, .medium, .sun, "blodbøk"),
        p("Rogn", "Sorbus aucuparia", 5.5, 7.0, .medium, .sun, "rognetre"),
        p("Hegg", "Prunus padus", 5.5, 7.0, .medium, .sun),
        p("Hestekastanje", "Aesculus hippocastanum", 6.0, 7.5, .medium, .sun, "kastanje"),
        p("Lerk", "Larix", 5.0, 6.5, .medium, .sun, "europalerk"),
        p("Alm", "Ulmus glabra", 6.0, 7.5, .medium, .sun),
        p("Kristtorn", "Ilex aquifolium", 5.5, 7.0, .medium, .partShade),
        p("Platanlønn", "Acer pseudoplatanus", 5.5, 7.3, .medium, .sun),

        // MARK: Løk- og knollplanter
        p("Tulipan", "Tulipa", 6.0, 7.0, .medium, .sun),
        p("Påskelilje", "Narcissus", 6.0, 7.0, .medium, .sun, "narsiss", "pinselilje"),
        p("Krokus", "Crocus", 6.0, 7.0, .medium, .sun),
        p("Snøklokke", "Galanthus nivalis", 6.0, 7.0, .medium, .partShade),
        p("Perleblomst", "Muscari", 6.0, 7.0, .medium, .sun, "perlehyasint"),
        p("Hagehyasint", "Hyacinthus orientalis", 6.0, 7.0, .medium, .sun, "hyasint"),
        p("Prydløk", "Allium giganteum", 6.0, 7.5, .medium, .sun, "kjempeløk"),
        p("Lilje", "Lilium", 5.5, 6.5, .medium, .sun, "asiatisk lilje", "kongelilje"),
        p("Keiserkrone", "Fritillaria imperialis", 6.0, 7.0, .medium, .sun),
        p("Rutelilje", "Fritillaria meleagris", 5.5, 6.5, .medium, .partShade),
        p("Vinterblom", "Eranthis hyemalis", 6.0, 7.5, .medium, .partShade),
        p("Blåstjerne", "Scilla", 6.0, 7.0, .medium, .partShade, "russeblåstjerne", "sibirblåstjerne"),
        p("Dahlia", "Dahlia", 6.5, 7.0, .medium, .sun, "georginer", "georgine"),
        p("Gladiol", "Gladiolus", 6.0, 7.0, .medium, .sun),
        p("Knollbegonia", "Begonia × tuberhybrida", 5.5, 6.5, .medium, .partShade, "begonia"),
        p("Ranunkel", "Ranunculus asiaticus", 6.0, 7.0, .medium, .sun),
        p("Hageanemone", "Anemone coronaria", 6.0, 7.0, .medium, .sun),
        p("Høstkrokus", "Colchicum", 6.0, 7.0, .medium, .sun, "tidløs"),

        // MARK: Sommerblomster
        p("Petunia", "Petunia", 5.5, 6.5, .high, .sun, "hengepetunia"),
        p("Margeritt", "Argyranthemum frutescens", 6.0, 7.0, .high, .sun),
        p("Fløyelsblomst", "Tagetes", 6.0, 7.5, .medium, .sun, "tagetes"),
        p("Ringblomst", "Calendula officinalis", 6.0, 7.0, .medium, .sun),
        p("Solsikke", "Helianthus annuus", 6.0, 7.5, .high, .sun),
        p("Blomkarse", "Tropaeolum majus", 6.0, 7.5, .medium, .sun),
        p("Lobelia", "Lobelia erinus", 6.0, 7.5, .high, .partShade),
        p("Fuksia", "Fuchsia", 5.5, 6.5, .high, .partShade, "tåreblomst"),
        p("Pelargonia", "Pelargonium", 6.0, 7.0, .medium, .sun, "hengepelargonia"),
        p("Løvemunn", "Antirrhinum majus", 6.0, 7.5, .medium, .sun),
        p("Sinnia", "Zinnia elegans", 5.5, 7.0, .medium, .sun, "zinnia"),
        p("Pyntekorg", "Cosmos bipinnatus", 6.0, 7.5, .medium, .sun, "kosmos"),
        p("Sommerasters", "Callistephus chinensis", 6.0, 7.5, .medium, .sun),
        p("Nemesia", "Nemesia", 5.5, 6.5, .medium, .sun),
        p("Flittiglise", "Impatiens walleriana", 6.0, 6.5, .high, .shade),
        p("Prydtobakk", "Nicotiana", 6.0, 7.0, .medium, .partShade),
        p("Blåkorg", "Ageratum", 6.0, 7.5, .medium, .sun, "ageratum"),
        p("Blomsterert", "Lathyrus odoratus", 6.5, 7.5, .high, .sun, "erteblomst", "luktert"),
        p("Sommerfiol", "Matthiola incana", 6.5, 7.5, .medium, .sun, "levkøy"),
        p("Slørblomst", "Gypsophila", 6.5, 7.5, .medium, .sun, "brudeslør"),
        p("Solvending", "Heliotropium arborescens", 6.5, 7.5, .medium, .sun, "heliotrop"),
        p("Portulakk", "Portulaca grandiflora", 5.5, 7.0, .low, .sun),
        p("Isbegonia", "Begonia semperflorens", 5.5, 6.5, .medium, .partShade),
        p("Sølvblad", "Senecio cineraria", 6.0, 7.5, .low, .sun),
        p("Diascia", "Diascia", 6.0, 7.0, .medium, .sun),
        p("Soløye", "Heliopsis", 6.0, 7.5, .medium, .sun),
        p("Jomfru i det grønne", "Nigella damascena", 6.0, 7.5, .medium, .sun, "nigella"),
        p("Valmuesøster", "Eschscholzia californica", 6.0, 7.5, .medium, .sun, "kaliforniavalmue"),

        // MARK: Klatreplanter
        p("Klematis", "Clematis", 6.5, 7.5, .medium, .sun, "skogranke"),
        p("Kaprifol", "Lonicera caprifolium", 6.0, 7.5, .medium, .partShade, "vivendel", "leddved"),
        p("Villvin", "Parthenocissus", 5.5, 7.5, .medium, .partShade, "rådhusvin", "klatrevillvin"),
        p("Eføy", "Hedera helix", 6.0, 7.5, .medium, .shade, "bergflette"),
        p("Humle", "Humulus lupulus", 6.0, 7.5, .high, .sun),
        p("Blåregn", "Wisteria", 6.0, 7.0, .medium, .sun),
        p("Klokkeranke", "Cobaea scandens", 6.0, 7.5, .medium, .sun),
        p("Svartøyesusanne", "Thunbergia alata", 6.0, 7.5, .medium, .sun),

        // MARK: Grønne stueplanter (Plantasjen/Hageland-sortiment)
        p("Monstera", "Monstera deliciosa", 5.5, 6.5, .medium, .partShade, "vindusblad"),
        p("Gullranke", "Epipremnum aureum", 6.0, 6.5, .medium, .partShade, "scindapsus"),
        p("Svigermors tunge", "Sansevieria trifasciata", 5.5, 7.0, .low, .partShade, "sansevieria", "bajonettplante"),
        p("Fiolinfiken", "Ficus lyrata", 6.0, 7.0, .medium, .partShade),
        p("Gummifiken", "Ficus elastica", 5.5, 7.0, .medium, .partShade, "gummitre"),
        p("Benjaminfiken", "Ficus benjamina", 6.0, 6.5, .medium, .partShade, "bjørkefiken"),
        p("Elefantøre", "Alocasia", 5.5, 6.5, .medium, .partShade, "alokasia"),
        p("Paraplytre", "Schefflera", 6.0, 6.5, .medium, .partShade),
        p("Fredslilje", "Spathiphyllum", 5.5, 6.5, .high, .shade),
        p("Grønnrenner", "Chlorophytum comosum", 6.0, 7.0, .medium, .partShade, "grønnlilje", "ampellilje"),
        p("Dragetre", "Dracaena", 6.0, 6.5, .medium, .partShade, "dracena"),
        p("Yucca", "Yucca elephantipes", 6.0, 7.5, .low, .sun, "palmelilje"),
        p("Kentiapalme", "Howea forsteriana", 6.0, 7.0, .medium, .partShade),
        p("Arecapalme", "Dypsis lutescens", 6.0, 6.5, .medium, .partShade, "gullpalme"),
        p("Stuepalme", "Chamaedorea elegans", 6.0, 7.0, .medium, .shade, "bergpalme"),
        p("Philodendron", "Philodendron", 5.5, 6.5, .medium, .partShade),
        p("Calathea", "Calathea", 6.0, 6.5, .high, .shade, "bønnemønsterplante"),
        p("Peperomia", "Peperomia", 6.0, 6.6, .low, .partShade),
        p("Kinesisk pengeplante", "Pilea peperomioides", 6.0, 7.0, .medium, .partShade, "pilea", "misjonærplante"),
        p("Smaragdpalme", "Zamioculcas zamiifolia", 6.0, 7.0, .low, .partShade, "zz-plante", "zamioculcas"),
        p("Aloe vera", "Aloe barbadensis", 6.5, 8.0, .low, .sun),
        p("Kaktus", "Cactaceae", 6.0, 7.0, .low, .sun, "ørkenkaktus"),
        p("Sukkulent", nil, 6.0, 7.0, .low, .sun, "sukkulenter"),
        p("Orkidé", "Phalaenopsis", 5.5, 6.5, .medium, .partShade, "brudeorkide"),
        p("Flamingoblomst", "Anthurium", 5.5, 6.5, .medium, .partShade),
        p("Voksblomst", "Hoya carnosa", 6.0, 7.0, .low, .partShade, "hoya", "porselensblomst"),
        p("Tradescantia", "Tradescantia zebrina", 5.5, 6.5, .medium, .partShade, "vandrejøde"),
        p("Bønneplante", "Maranta leuconeura", 5.5, 6.0, .high, .shade, "maranta"),
        p("Paradisfuglblomst", "Strelitzia", 5.5, 7.5, .medium, .sun, "strelitzia"),
        p("Bananplante", "Musa", 5.5, 6.5, .high, .sun),
        p("Pengetre", "Crassula ovata", 6.0, 7.0, .low, .sun, "jadeplante"),
        p("Flettetre", "Pachira aquatica", 6.0, 7.5, .medium, .partShade, "pachira"),
        p("Fittonia", "Fittonia albivenis", 6.0, 7.0, .high, .shade, "nerveplante"),
        p("Stuebregne", "Nephrolepis exaltata", 5.5, 6.5, .high, .shade, "sverdbregne"),
        p("Fugleredebregne", "Asplenium nidus", 5.5, 6.5, .medium, .shade),
        p("Kroton", "Codiaeum variegatum", 6.0, 6.5, .medium, .sun),
        p("Dieffenbachia", "Dieffenbachia", 6.0, 6.5, .medium, .partShade),
        p("Aglaonema", "Aglaonema", 5.5, 6.5, .medium, .shade, "silkeplante"),
        p("Hjerte på snor", "Ceropegia woodii", 6.0, 7.5, .low, .partShade, "hjerteranke"),
        p("Usambarafiol", "Saintpaulia", 5.5, 6.5, .medium, .partShade, "saintpaulia"),
        p("Elefantfot", "Beaucarnea recurvata", 6.0, 7.0, .low, .sun),
        p("Sagopalme", "Cycas revoluta", 5.5, 6.5, .low, .sun, "konglepalme"),

        // MARK: Blomstrende stueplanter
        p("Julestjerne", "Euphorbia pulcherrima", 5.8, 6.5, .medium, .partShade),
        p("Amaryllis", "Hippeastrum", 6.0, 6.8, .medium, .sun, "ridderstjerne"),
        p("Alpefiol", "Cyclamen persicum", 5.5, 6.5, .medium, .partShade, "cyclamen"),
        p("Julekaktus", "Schlumbergera", 5.5, 6.5, .low, .partShade),
        p("Ildtopp", "Kalanchoe blossfeldiana", 6.0, 7.0, .low, .sun, "kalanchoe"),
        p("Gerbera", "Gerbera jamesonii", 5.5, 6.5, .medium, .sun),
        p("Stuejasmin", "Jasminum polyanthum", 6.0, 7.0, .medium, .sun),

        // MARK: Middelhavsplanter (Hageland-kategori)
        p("Oliventre", "Olea europaea", 6.5, 8.0, .low, .sun, "oliven"),
        p("Sitrontre", "Citrus limon", 5.5, 6.5, .medium, .sun, "sitrus"),
        p("Appelsintre", "Citrus sinensis", 5.5, 6.5, .medium, .sun, "kalamondin"),
        p("Laurbær", "Laurus nobilis", 6.0, 7.5, .medium, .sun, "laurbærtre"),
        p("Hamppalme", "Trachycarpus fortunei", 6.0, 7.5, .medium, .sun, "vifteplame"),
        p("Oleander", "Nerium oleander", 6.5, 7.5, .medium, .sun),
        p("Bougainvillea", "Bougainvillea", 5.5, 6.5, .low, .sun, "trillingblomst"),
        p("Agapanthus", "Agapanthus", 6.0, 7.0, .medium, .sun, "skjermlilje"),

        // MARK: Hekk og prydgress (tillegg)
        p("Agnbøk", "Carpinus betulus", 6.0, 7.5, .medium, .sun, "hekkagnbøk"),
        p("Naverlønn", "Acer campestre", 6.0, 7.5, .medium, .sun),
        p("Rørkvein", "Calamagrostis acutiflora", 5.5, 7.5, .medium, .sun, "karl foerster"),
        p("Starr", "Carex", 5.5, 7.0, .high, .partShade, "prydstarr"),
        p("Pampasgress", "Cortaderia selloana", 6.0, 7.5, .low, .sun),
        p("Japansk blodgress", "Imperata cylindrica", 5.5, 6.5, .medium, .sun),

        // MARK: Stauder, løk og sommerblomster (tillegg)
        p("Alunrot", "Heuchera", 6.0, 7.0, .medium, .partShade, "purpurklokke", "heuchera"),
        p("Liljekonvall", "Convallaria majalis", 5.5, 7.0, .medium, .shade),
        p("Krokosmia", "Crocosmia", 6.0, 7.5, .medium, .sun, "montbretia"),
        p("Nattlys", "Oenothera", 5.5, 7.0, .low, .sun),
        p("Prydkål", "Brassica oleracea (pryd)", 6.0, 7.5, .medium, .sun, "høstkål"),
        p("Trompetranke", "Campsis radicans", 6.0, 7.5, .medium, .sun),
        p("Ginkgo", "Ginkgo biloba", 6.0, 7.5, .medium, .sun, "tempeltre"),
        p("Snøstjerne", "Chionodoxa", 6.0, 7.0, .medium, .partShade, "vårstjerne"),
        p("Prærielilje", "Camassia", 6.0, 7.0, .medium, .sun),
        p("Million bells", "Calibrachoa", 5.5, 6.5, .high, .sun, "småpetunia"),
        p("Bacopa", "Sutera cordata", 5.5, 6.5, .high, .partShade, "snøflake"),
        p("Melon", "Cucumis melo", 6.0, 7.0, .high, .sun),
        p("Sitrongress", "Cymbopogon citratus", 6.0, 7.5, .high, .sun),

        // MARK: Annet
        p("Gressplen", nil, 5.5, 7.0, .medium, .sun, "plen", "gress", "ferdigplen"),
        p("Blomstereng", nil, 5.5, 7.0, .low, .sun, "engblanding", "villeng"),
        p("Sitrontimian", "Thymus citriodorus", 6.5, 7.5, .low, .sun),
    ]

    /// Søk for autoutfylling: prefikstreff rangeres foran treff midt i ordet.
    static func search(_ query: String, in plants: [PlantInfo] = plants) -> [PlantInfo] {
        let folded = query.folded.trimmingCharacters(in: .whitespaces)
        guard !folded.isEmpty else { return [] }

        func score(_ info: PlantInfo) -> Int? {
            var best: Int?
            for keyword in info.keywords {
                if keyword.hasPrefix(folded) {
                    best = min(best ?? 2, keyword == info.name.folded ? 0 : 1)
                } else if keyword.contains(folded) {
                    best = min(best ?? 2, 2)
                }
            }
            return best
        }

        return plants
            .compactMap { info in score(info).map { (info, $0) } }
            .sorted { ($0.1, $0.0.name) < ($1.1, $1.0.name) }
            .map(\.0)
    }

    /// Finner pH-preferanse fra plantens navn og art. Lengste søkeord
    /// vinner, så «gressløk» ikke matches som «gress».
    static func match(name: String, species: String?, in plants: [PlantInfo] = plants) -> PlantInfo? {
        let haystack = (name + " " + (species ?? "")).folded
        var best: (info: PlantInfo, keywordLength: Int)?
        for info in plants {
            for keyword in info.keywords where haystack.contains(keyword) {
                if keyword.count > (best?.keywordLength ?? 0) {
                    best = (info, keyword.count)
                }
            }
        }
        return best?.info
    }
}
