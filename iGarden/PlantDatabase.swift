//
//  PlantDatabase.swift
//  iGarden
//
//  Kuratert database over vanlige planter i norske hager, med
//  foretrukket jord-pH. Brukes til søk/autoutfylling i planteskjemaet
//  og av Smart hage-anbefalingene.
//

import Foundation

struct PlantInfo {
    let name: String
    let latinName: String?
    /// Ekstra søkeord/aliaser (norske synonymer).
    let aliases: [String]
    let phLow: Double
    let phHigh: Double

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
    private static func p(_ name: String, _ latin: String?, _ low: Double, _ high: Double, _ aliases: String...) -> PlantInfo {
        PlantInfo(name: name, latinName: latin, aliases: Array(aliases), phLow: low, phHigh: high)
    }

    static let plants: [PlantInfo] = [
        // MARK: Frukt og bær
        p("Eple", "Malus domestica", 6.0, 7.0, "epletre"),
        p("Prydeple", "Malus", 6.0, 7.0),
        p("Pære", "Pyrus communis", 6.0, 7.0, "pæretre"),
        p("Plomme", "Prunus domestica", 6.0, 7.5, "plommetre"),
        p("Kirsebær", "Prunus avium", 6.0, 7.5, "morell", "moreller"),
        p("Prydkirsebær", "Prunus serrulata", 6.0, 7.5, "japansk kirsebær"),
        p("Jordbær", "Fragaria × ananassa", 5.5, 6.5),
        p("Markjordbær", "Fragaria vesca", 5.5, 6.5),
        p("Bringebær", "Rubus idaeus", 5.5, 6.5),
        p("Bjørnebær", "Rubus fruticosus", 5.5, 7.0),
        p("Solbær", "Ribes nigrum", 6.0, 6.5),
        p("Rips", "Ribes rubrum", 6.0, 6.5),
        p("Stikkelsbær", "Ribes uva-crispa", 6.0, 6.5),
        p("Blåbær", "Vaccinium myrtillus", 4.0, 5.5),
        p("Hageblåbær", "Vaccinium corymbosum", 4.3, 5.5, "amerikansk blåbær"),
        p("Tyttebær", "Vaccinium vitis-idaea", 4.5, 5.5),
        p("Tranebær", "Vaccinium oxycoccos", 4.0, 5.0),
        p("Svarthyll", "Sambucus nigra", 6.0, 7.5, "hyll", "hylleblomst"),
        p("Havtorn", "Hippophae rhamnoides", 6.5, 7.5, "tindved"),
        p("Svartsurbær", "Aronia melanocarpa", 5.0, 6.5, "aronia"),
        p("Vindrue", "Vitis vinifera", 6.0, 7.0, "drue", "vinranke"),
        p("Minikiwi", "Actinidia arguta", 5.5, 7.0, "kiwibær"),
        p("Rabarbra", "Rheum rhabarbarum", 5.5, 6.5),
        p("Hassel", "Corylus avellana", 6.0, 7.5, "hasselnøtt"),
        p("Valnøtt", "Juglans regia", 6.0, 7.5),
        p("Fiken", "Ficus carica", 6.0, 7.5),
        p("Mispel", "Mespilus germanica", 6.0, 7.0),
        p("Kvede", "Cydonia oblonga", 6.0, 7.0),

        // MARK: Grønnsaker
        p("Potet", "Solanum tuberosum", 5.0, 6.5),
        p("Gulrot", "Daucus carota", 6.0, 7.0),
        p("Tomat", "Solanum lycopersicum", 6.0, 6.8),
        p("Agurk", "Cucumis sativus", 6.0, 7.0),
        p("Squash", "Cucurbita pepo", 6.0, 7.5, "sommersquash"),
        p("Gresskar", "Cucurbita maxima", 6.0, 7.5),
        p("Salat", "Lactuca sativa", 6.0, 7.0, "hodesalat", "plukksalat"),
        p("Ruccola", "Eruca sativa", 6.0, 7.0, "rukola", "salatsennep"),
        p("Spinat", "Spinacia oleracea", 6.5, 7.5),
        p("Grønnkål", "Brassica oleracea acephala", 6.0, 7.5),
        p("Hodekål", "Brassica oleracea capitata", 6.5, 7.5, "kål", "hvitkål"),
        p("Rødkål", "Brassica oleracea rubra", 6.5, 7.5),
        p("Blomkål", "Brassica oleracea botrytis", 6.5, 7.5),
        p("Brokkoli", "Brassica oleracea italica", 6.0, 7.0),
        p("Rosenkål", "Brassica oleracea gemmifera", 6.5, 7.5),
        p("Kålrot", "Brassica napus", 6.0, 7.5, "kålrabi"),
        p("Knutekål", "Brassica oleracea gongylodes", 6.0, 7.5),
        p("Reddik", "Raphanus sativus", 6.0, 7.0, "sommerreddik"),
        p("Rødbet", "Beta vulgaris", 6.0, 7.5, "rødbete", "bete"),
        p("Mangold", "Beta vulgaris cicla", 6.0, 7.5, "bladbete"),
        p("Sellerirot", "Apium graveolens rapaceum", 6.0, 7.0, "knollselleri"),
        p("Stangselleri", "Apium graveolens dulce", 6.0, 7.0),
        p("Pastinakk", "Pastinaca sativa", 6.0, 7.5),
        p("Persillerot", "Petroselinum crispum tuberosum", 6.0, 7.0),
        p("Kepaløk", "Allium cepa", 6.0, 7.0, "løk", "gul løk", "rødløk"),
        p("Hvitløk", "Allium sativum", 6.0, 7.5),
        p("Sjalottløk", "Allium ascalonicum", 6.0, 7.0),
        p("Vårløk", "Allium fistulosum", 6.0, 7.0, "pipeløk"),
        p("Purre", "Allium porrum", 6.0, 7.5, "purreløk"),
        p("Erter", "Pisum sativum", 6.0, 7.5, "ert", "hageert"),
        p("Sukkererter", "Pisum sativum saccharatum", 6.0, 7.5, "sukkerert"),
        p("Bønner", "Phaseolus vulgaris", 6.0, 7.5, "bønne", "buskbønne", "stangbønne"),
        p("Mais", "Zea mays", 5.5, 7.0, "sukkermais"),
        p("Paprika", "Capsicum annuum", 6.0, 7.0, "chili"),
        p("Aubergine", "Solanum melongena", 5.5, 6.8),
        p("Fennikel", "Foeniculum vulgare", 6.0, 7.0),
        p("Asparges", "Asparagus officinalis", 6.5, 7.5),
        p("Jordskokk", "Helianthus tuberosus", 5.8, 7.0),
        p("Nepe", "Brassica rapa", 6.0, 7.0, "mainepe"),
        p("Gressløk", "Allium schoenoprasum", 6.0, 7.0),

        // MARK: Urter
        p("Basilikum", "Ocimum basilicum", 6.0, 7.5),
        p("Persille", "Petroselinum crispum", 6.0, 7.0, "kruspersille", "bladpersille"),
        p("Dill", "Anethum graveolens", 5.5, 6.5),
        p("Koriander", "Coriandrum sativum", 6.2, 7.0),
        p("Timian", "Thymus vulgaris", 6.5, 7.5, "hagetimian"),
        p("Rosmarin", "Salvia rosmarinus", 6.0, 7.5),
        p("Salvie", "Salvia officinalis", 6.0, 7.5, "matsalvie"),
        p("Bergmynte", "Origanum vulgare", 6.5, 7.5, "oregano"),
        p("Mynte", "Mentha", 6.0, 7.5, "peppermynte", "spearmint"),
        p("Sitronmelisse", "Melissa officinalis", 6.0, 7.5),
        p("Estragon", "Artemisia dracunculus", 6.5, 7.5),
        p("Karse", "Lepidium sativum", 6.0, 7.0),
        p("Løpstikke", "Levisticum officinale", 6.0, 7.0),
        p("Kamille", "Matricaria chamomilla", 5.6, 7.5),
        p("Karve", "Carum carvi", 6.0, 7.0),
        p("Isop", "Hyssopus officinalis", 6.5, 7.5),
        p("Sar", "Satureja", 6.5, 7.5, "bønneurt"),

        // MARK: Stauder
        p("Hosta", "Hosta", 6.0, 7.5, "bladlilje"),
        p("Astilbe", "Astilbe", 5.5, 6.5, "spirea-astilbe"),
        p("Pion", "Paeonia", 6.5, 7.5, "peon", "silkepion", "bondepion"),
        p("Daglilje", "Hemerocallis", 6.0, 7.0),
        p("Iris", "Iris", 6.0, 7.5, "sverdlilje"),
        p("Hagelupin", "Lupinus polyphyllus", 5.5, 7.0, "lupin"),
        p("Storkenebb", "Geranium", 6.0, 7.5, "skoggstorkenebb", "blodstorkenebb"),
        p("Prydsalvie", "Salvia nemorosa", 6.0, 7.5),
        p("Lavendel", "Lavandula angustifolia", 6.5, 7.5),
        p("Rød solhatt", "Echinacea purpurea", 6.0, 7.0, "solhatt"),
        p("Gul solhatt", "Rudbeckia", 6.0, 7.0, "rudbeckia"),
        p("Høstasters", "Aster", 6.0, 7.5, "asters"),
        p("Hagekrysantemum", "Chrysanthemum", 6.0, 7.0, "krysantemum"),
        p("Ridderspore", "Delphinium", 6.5, 7.5),
        p("Akeleie", "Aquilegia", 6.0, 7.0),
        p("Revebjelle", "Digitalis purpurea", 5.5, 6.5, "fingerbøl"),
        p("Valmue", "Papaver", 6.0, 7.5, "kjempevalmue", "orientvalmue"),
        p("Kornblomst", "Centaurea cyanus", 6.5, 7.5),
        p("Hagenellik", "Dianthus", 6.5, 7.5, "nellik", "fjærnellik"),
        p("Stemorsblomst", "Viola × wittrockiana", 5.5, 6.5, "fiol", "hornfiol"),
        p("Kusymre", "Primula vulgaris", 6.0, 7.0, "primula", "hageprimula"),
        p("Bergenia", "Bergenia", 6.0, 7.5, "hjertebergblad"),
        p("Bergknapp", "Sedum", 6.0, 7.5, "sedum", "smørbukk"),
        p("Takløk", "Sempervivum", 6.5, 7.5, "husløk"),
        p("Lammeøre", "Stachys byzantina", 6.5, 7.5),
        p("Kattemynte", "Nepeta", 6.0, 7.5),
        p("Marikåpe", "Alchemilla mollis", 6.0, 7.5),
        p("Skogskjegg", "Aruncus dioicus", 5.5, 7.0),
        p("Gullris", "Solidago", 5.5, 7.0),
        p("Floks", "Phlox paniculata", 6.0, 7.0, "høstfloks", "sommerfloks", "flox"),
        p("Krypfloks", "Phlox subulata", 6.0, 7.0, "vårfloks"),
        p("Lungeurt", "Pulmonaria", 6.0, 7.5),
        p("Løytnantshjerte", "Lamprocapnos spectabilis", 6.0, 7.0, "hjerteblomst"),
        p("Klokkeblomst", "Campanula", 6.0, 7.5, "blåklokke", "kjempeklokke"),
        p("Ryllik", "Achillea millefolium", 6.0, 7.5, "jordbærryllik"),
        p("Prestekrage", "Leucanthemum", 6.0, 7.5, "kjempeprestekrage"),
        p("Blåveis", "Hepatica nobilis", 6.5, 7.5),
        p("Hvitveis", "Anemone nemorosa", 5.5, 6.5),
        p("Høstanemone", "Anemone hupehensis", 6.0, 7.5),
        p("Julerose", "Helleborus", 6.5, 7.5),
        p("Stjerneskjerm", "Astrantia major", 6.0, 7.0),
        p("Jernurt", "Verbena", 6.0, 7.0, "kjempeverbena"),
        p("Strandnellik", "Armeria maritima", 6.0, 7.5),
        p("Bregne", "Polypodiopsida", 5.0, 6.5, "skogburkne", "sisselrot"),
        p("Strutseving", "Matteuccia struthiopteris", 5.5, 6.5),
        p("Gullkorg", "Doronicum", 6.0, 7.0),
        p("Tusenfryd", "Bellis perennis", 6.0, 7.0),
        p("Forglemmegei", "Myosotis", 6.0, 7.0, "kjærminne"),
        p("Blåpute", "Aubrieta", 6.5, 7.5),
        p("Fjellflokk", "Polemonium caeruleum", 6.0, 7.0),
        p("Brennende kjærlighet", "Lychnis chalcedonica", 6.0, 7.5),
        p("Såpeurt", "Saponaria officinalis", 6.5, 7.5),
        p("Gyllenlakk", "Erysimum", 6.5, 7.5),
        p("Stokkrose", "Alcea rosea", 6.5, 7.5),
        p("Kattost", "Malva", 6.0, 7.5, "malva"),
        p("Humleblom", "Geum", 6.0, 7.0),
        p("Kongslys", "Verbascum", 6.5, 7.5),
        p("Dødnesle", "Lamium maculatum", 6.0, 7.5, "trådnesle"),
        p("Gravmyrt", "Vinca minor", 6.0, 7.5, "vinca"),
        p("Jonsokkoll", "Ajuga reptans", 6.0, 7.0),
        p("Krypfredløs", "Lysimachia nummularia", 6.0, 7.0, "fredløs"),
        p("Mjødurt", "Filipendula", 5.5, 7.0),
        p("Kubjelle", "Pulsatilla vulgaris", 6.5, 7.5),
        p("Lerkespore", "Corydalis", 6.0, 7.0),
        p("Rodgersia", "Rodgersia", 5.5, 6.5, "bronseblad"),
        p("Gunnera", "Gunnera manicata", 5.5, 6.5, "mammutblad"),
        p("Torskemunn", "Linaria", 6.5, 7.5),
        p("Veronika", "Veronica", 6.0, 7.5, "ærenpris", "aksveronika"),
        p("Solbrud", "Helenium", 5.5, 7.0),
        p("Kokardeblomst", "Gaillardia", 6.0, 7.0),
        p("Sløyfeblomst", "Iberis sempervirens", 6.5, 7.5),
        p("Hanekam", "Celosia argentea", 6.0, 7.0),
        p("Silkebygg", "Hordeum jubatum", 6.0, 7.5, "prydbygg"),
        p("Elefantgress", "Miscanthus sinensis", 5.5, 7.5, "prydgress", "kinagress"),
        p("Lampepussergress", "Pennisetum", 6.0, 7.0),
        p("Blåsvingel", "Festuca glauca", 5.5, 7.0),
        p("Blåtopp", "Molinia caerulea", 5.0, 6.5),
        p("Bambus", "Fargesia", 5.5, 6.5, "hagebambus"),
        p("Sibirvalmue", "Papaver nudicaule", 6.0, 7.5, "islandsvalmue"),
        p("Ekte malurt", "Artemisia absinthium", 6.5, 7.5, "malurt", "sølvmalurt"),
        p("Perlekurv", "Anaphalis", 6.0, 7.5),
        p("Hasselurt", "Asarum europaeum", 5.5, 6.5),
        p("Pryddødnesle", "Lamiastrum", 6.0, 7.5, "gulltvetann"),
        p("Bekkeblom", "Caltha palustris", 5.5, 7.0, "soleihov"),
        p("Sibiriris", "Iris sibirica", 5.5, 7.0),
        p("Kattefot", "Antennaria dioica", 5.0, 6.5),
        p("Hjortetrøst", "Eupatorium", 5.5, 7.0),

        // MARK: Busker
        p("Rhododendron", "Rhododendron", 4.5, 6.0, "alperose"),
        p("Asalea", "Rhododendron (Azalea)", 4.5, 6.0, "azalea", "hageasalea"),
        p("Hagehortensia", "Hydrangea macrophylla", 5.0, 6.5, "hortensia"),
        p("Syrinhortensia", "Hydrangea paniculata", 5.0, 6.5),
        p("Klatrehortensia", "Hydrangea petiolaris", 5.0, 6.5),
        p("Syrin", "Syringa vulgaris", 6.5, 7.5),
        p("Skjærsmin", "Philadelphus", 6.0, 7.5, "duftskjærsmin", "jasminbusk"),
        p("Spirea", "Spiraea", 6.0, 7.5, "bjørkebladspirea", "brudespirea", "japanspirea"),
        p("Snøbær", "Symphoricarpos", 6.0, 7.5),
        p("Berberis", "Berberis", 6.0, 7.5, "høstberberis"),
        p("Buksbom", "Buxus sempervirens", 6.5, 7.5),
        p("Liguster", "Ligustrum vulgare", 6.0, 7.5),
        p("Alperips", "Ribes alpinum", 6.0, 7.0, "fjellrips"),
        p("Blodrips", "Ribes sanguineum", 6.0, 7.0, "prydrips"),
        p("Gullbusk", "Forsythia", 6.0, 7.5, "forsythia"),
        p("Magnolia", "Magnolia", 5.5, 6.5),
        p("Kamelia", "Camellia japonica", 5.0, 6.5),
        p("Sommerfuglbusk", "Buddleja davidii", 6.0, 7.5, "buddleia"),
        p("Rose", "Rosa", 6.0, 7.0, "klaserose", "storblomstret rose", "klatrerose", "bedrose"),
        p("Rynkerose", "Rosa rugosa", 5.5, 7.0),
        p("Buskmure", "Dasiphora fruticosa", 5.5, 7.0, "potentilla"),
        p("Klokkebusk", "Weigela", 6.0, 7.0, "weigela"),
        p("Deutzia", "Deutzia", 6.0, 7.5, "styraksbusk"),
        p("Kornell", "Cornus", 5.5, 7.0, "villkornell", "sibirkornell", "kirsebærkornell"),
        p("Krossved", "Viburnum opulus", 5.5, 7.0, "snøballbusk", "korsved"),
        p("Duftkrossved", "Viburnum farreri", 5.5, 7.0),
        p("Røsslyng", "Calluna vulgaris", 4.5, 5.5, "lyng", "høstlyng"),
        p("Klokkelyng", "Erica", 4.5, 5.5, "vårlyng"),
        p("Pieris", "Pieris japonica", 4.5, 6.0, "lyngbusk"),
        p("Mahonia", "Mahonia aquifolium", 5.5, 7.0),
        p("Eldkvede", "Chaenomeles", 6.0, 7.0, "ildkvede", "prydkvede"),
        p("Dvergmispel", "Cotoneaster", 6.0, 7.5, "bulkemispel", "krypmispel"),
        p("Ildtorn", "Pyracantha", 6.0, 7.5),
        p("Gullregn", "Laburnum", 6.0, 7.5),
        p("Hagtorn", "Crataegus", 6.0, 7.5),
        p("Trollhassel", "Hamamelis", 5.5, 6.5),
        p("Perlebusk", "Exochorda", 6.0, 7.5),
        p("Sibirertebusk", "Caragana arborescens", 6.0, 7.5, "ertebusk"),
        p("Fagerbusk", "Kolkwitzia amabilis", 6.0, 7.5, "paradisbusk"),
        p("Einer", "Juniperus", 5.0, 7.5, "krypeiner", "søyleeiner"),
        p("Barlind", "Taxus baccata", 6.0, 7.5),
        p("Tuja", "Thuja occidentalis", 6.0, 7.5, "thuja", "livstre"),
        p("Sypress", "Chamaecyparis", 5.5, 7.0, "ertesypress"),
        p("Dvergfuru", "Pinus mugo", 4.5, 6.5, "buskfuru"),
        p("Vinterjasmin", "Jasminum nudiflorum", 6.0, 7.5),
        p("Frilandshibiskus", "Hibiscus syriacus", 6.0, 7.0, "hibiskus"),
        p("Blærespirea", "Physocarpus opulifolius", 5.5, 7.0),
        p("Sølvbusk", "Elaeagnus commutata", 6.0, 7.5),
        p("Rødhyll", "Sambucus racemosa", 6.0, 7.5),

        // MARK: Trær
        p("Bjørk", "Betula", 5.0, 6.5, "hengebjørk", "lavlandsbjørk"),
        p("Furu", "Pinus sylvestris", 4.5, 6.0),
        p("Gran", "Picea abies", 5.0, 6.5, "blågran", "sølvgran"),
        p("Eik", "Quercus robur", 5.5, 7.0, "sommereik"),
        p("Lønn", "Acer platanoides", 5.5, 7.3, "spisslønn"),
        p("Japansk lønn", "Acer palmatum", 5.5, 6.5, "viftelønn"),
        p("Ask", "Fraxinus excelsior", 6.0, 7.5),
        p("Svartor", "Alnus glutinosa", 5.5, 7.0, "or", "older"),
        p("Selje", "Salix caprea", 5.5, 7.5, "pil", "sølvpil", "hengepil"),
        p("Osp", "Populus tremula", 5.5, 7.0, "poppel"),
        p("Lind", "Tilia cordata", 6.0, 7.5, "parklind"),
        p("Bøk", "Fagus sylvatica", 5.5, 7.5, "blodbøk"),
        p("Rogn", "Sorbus aucuparia", 5.5, 7.0, "rognetre"),
        p("Hegg", "Prunus padus", 5.5, 7.0),
        p("Hestekastanje", "Aesculus hippocastanum", 6.0, 7.5, "kastanje"),
        p("Lerk", "Larix", 5.0, 6.5, "europalerk"),
        p("Alm", "Ulmus glabra", 6.0, 7.5),
        p("Kristtorn", "Ilex aquifolium", 5.5, 7.0),
        p("Platanlønn", "Acer pseudoplatanus", 5.5, 7.3),

        // MARK: Løk- og knollplanter
        p("Tulipan", "Tulipa", 6.0, 7.0),
        p("Påskelilje", "Narcissus", 6.0, 7.0, "narsiss", "pinselilje"),
        p("Krokus", "Crocus", 6.0, 7.0),
        p("Snøklokke", "Galanthus nivalis", 6.0, 7.0),
        p("Perleblomst", "Muscari", 6.0, 7.0, "perlehyasint"),
        p("Hagehyasint", "Hyacinthus orientalis", 6.0, 7.0, "hyasint"),
        p("Prydløk", "Allium giganteum", 6.0, 7.5, "kjempeløk"),
        p("Lilje", "Lilium", 5.5, 6.5, "asiatisk lilje", "kongelilje"),
        p("Keiserkrone", "Fritillaria imperialis", 6.0, 7.0),
        p("Rutelilje", "Fritillaria meleagris", 5.5, 6.5),
        p("Vinterblom", "Eranthis hyemalis", 6.0, 7.5),
        p("Blåstjerne", "Scilla", 6.0, 7.0, "russeblåstjerne", "sibirblåstjerne"),
        p("Dahlia", "Dahlia", 6.5, 7.0, "georginer", "georgine"),
        p("Gladiol", "Gladiolus", 6.0, 7.0),
        p("Knollbegonia", "Begonia × tuberhybrida", 5.5, 6.5, "begonia"),
        p("Ranunkel", "Ranunculus asiaticus", 6.0, 7.0),
        p("Hageanemone", "Anemone coronaria", 6.0, 7.0),
        p("Høstkrokus", "Colchicum", 6.0, 7.0, "tidløs"),

        // MARK: Sommerblomster
        p("Petunia", "Petunia", 5.5, 6.5, "hengepetunia"),
        p("Margeritt", "Argyranthemum frutescens", 6.0, 7.0),
        p("Fløyelsblomst", "Tagetes", 6.0, 7.5, "tagetes"),
        p("Ringblomst", "Calendula officinalis", 6.0, 7.0),
        p("Solsikke", "Helianthus annuus", 6.0, 7.5),
        p("Blomkarse", "Tropaeolum majus", 6.0, 7.5),
        p("Lobelia", "Lobelia erinus", 6.0, 7.5),
        p("Fuksia", "Fuchsia", 5.5, 6.5, "tåreblomst"),
        p("Pelargonia", "Pelargonium", 6.0, 7.0, "hengepelargonia"),
        p("Løvemunn", "Antirrhinum majus", 6.0, 7.5),
        p("Sinnia", "Zinnia elegans", 5.5, 7.0, "zinnia"),
        p("Pyntekorg", "Cosmos bipinnatus", 6.0, 7.5, "kosmos"),
        p("Sommerasters", "Callistephus chinensis", 6.0, 7.5),
        p("Nemesia", "Nemesia", 5.5, 6.5),
        p("Flittiglise", "Impatiens walleriana", 6.0, 6.5),
        p("Prydtobakk", "Nicotiana", 6.0, 7.0),
        p("Blåkorg", "Ageratum", 6.0, 7.5, "ageratum"),
        p("Blomsterert", "Lathyrus odoratus", 6.5, 7.5, "erteblomst", "luktert"),
        p("Sommerfiol", "Matthiola incana", 6.5, 7.5, "levkøy"),
        p("Slørblomst", "Gypsophila", 6.5, 7.5, "brudeslør"),
        p("Solvending", "Heliotropium arborescens", 6.5, 7.5, "heliotrop"),
        p("Portulakk", "Portulaca grandiflora", 5.5, 7.0),
        p("Isbegonia", "Begonia semperflorens", 5.5, 6.5),
        p("Sølvblad", "Senecio cineraria", 6.0, 7.5),
        p("Diascia", "Diascia", 6.0, 7.0),
        p("Soløye", "Heliopsis", 6.0, 7.5),
        p("Jomfru i det grønne", "Nigella damascena", 6.0, 7.5, "nigella"),
        p("Valmuesøster", "Eschscholzia californica", 6.0, 7.5, "kaliforniavalmue"),

        // MARK: Klatreplanter
        p("Klematis", "Clematis", 6.5, 7.5, "skogranke"),
        p("Kaprifol", "Lonicera caprifolium", 6.0, 7.5, "vivendel", "leddved"),
        p("Villvin", "Parthenocissus", 5.5, 7.5, "rådhusvin", "klatrevillvin"),
        p("Eføy", "Hedera helix", 6.0, 7.5, "bergflette"),
        p("Humle", "Humulus lupulus", 6.0, 7.5),
        p("Blåregn", "Wisteria", 6.0, 7.0),
        p("Klokkeranke", "Cobaea scandens", 6.0, 7.5),
        p("Svartøyesusanne", "Thunbergia alata", 6.0, 7.5),

        // MARK: Annet
        p("Gressplen", nil, 5.5, 7.0, "plen", "gress", "ferdigplen"),
        p("Blomstereng", nil, 5.5, 7.0, "engblanding", "villeng"),
        p("Sitrontimian", "Thymus citriodorus", 6.5, 7.5),
    ]

    /// Søk for autoutfylling: prefikstreff rangeres foran treff midt i ordet.
    static func search(_ query: String) -> [PlantInfo] {
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
    static func match(name: String, species: String?) -> PlantInfo? {
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
